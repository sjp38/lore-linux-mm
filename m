Received: by fk-out-0910.google.com with SMTP id z22so1197987fkz.6
        for <linux-mm@kvack.org>; Fri, 02 May 2008 15:21:41 -0700 (PDT)
Message-ID: <ab3f9b940805021521o4680116fyde099f16d66a1e5a@mail.gmail.com>
Date: Fri, 2 May 2008 15:21:40 -0700
From: "Tom May" <tom@tommay.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <20080501232431.F617.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <cfd9edbf0804230127k33a56312i6582f926e00ea17@mail.gmail.com>
	 <ab3f9b940804301907y5a3e84e1l6cb41a339bc2241b@mail.gmail.com>
	 <20080501232431.F617.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: =?ISO-2022-JP?B?IkRhbmllbCBTcBskQmlPGyhCZyI=?= <daniel.spang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, May 1, 2008 at 8:06 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi Tom,
>
>
>  > In my case of a Java virtual machine, where I originally saw the
>  > problem, most of the code is interpreted byte codes or jit-compiled
>  > native code, all of which resides not in the text segment but in
>  > anonymous pages that aren't backed by a file, and there is no swap
>  > space.  The actual text segment working set can be very small (memory
>  > allocation, garbage collection, synchronization, other random native
>  > code).  And, as KOSAKI Motohiro pointed out, it may be wise to mlock
>  > these areas.  So the text working set doesn't make an adequate
>  > reserve.
>
>  your memnotify check routine is written by native or java?

Some of each.

>  if native, my suggestion is right.
>  but if java, it is wrong.
>
>  my point is "on swapless system, /dev/mem_notify checked routine should be mlocked".

mlocking didn't fix things, it just made the oom happen at a different
time (see graphs below), both in the small test program where I used
mlockall, and in the jvm where during initialization I read
/proc/self/maps and mlocked each region of memory that was mapped to a
file.  Note that without swap, all of the anonymous pages containing
the java code are effectively locked in memory, too, so everything
runs without page faults.

>  > However, I can maintain a reserve of cached and/or mapped memory by
>  > touching pages in the text segment (or any mapped file) as the final
>  > step of low memory notification handling, if the cached page count is
>  > getting low.  For my purposes, this is nearly the same as having an
>  > additional threshold-based notification, since it forces notifications
>  > to occur while the kernel still has some memory to satisfy allocations
>  > while userspace code works to free memory.  And it's simple.
>  >
>  > Unfortunately, this is more expensive than it could be since the pages
>  > need to be read in from some device (mapping /dev/zero doesn't cause
>  > pages to be allocated). What I'm looking for now is a cheap way to
>  > populate the cache with pages that the kernel can throw away when it
>  > needs to reclaim memory.
>
>  I hope understand your requirement more.

Most simply, I need to get low memory notifications while there is
still enough memory to handle them before oom.

>  Can I ask your system more?

x86, Linux 2.6.23.9 (with your patches trivially backported), 128MB,
no swap.  Is there something else I can tell you?

>  I think all java text and data is mapped.

It's not what /proc/meminfo calls "Mapped".  It's in anonymous pages
with no backing store, i.e., mmap with MAP_ANONYMOUS.

>  When cached+mapped+free memory is happend?
>  and at the time, What is used memory?

Here's a graph of MemFree, Cached, and Mapped over time (I believe
Mapped is mostly or entirely subset of Cached here, so it's not
actually important):

http://www.tommay.net/memory.png

The amount of MemFree fluctuates as java allocates and garbage
collects, but the Cached memory decreases (since the kernel has to use
it for __alloc_pages when memory is low) until at some point there is
no memory to satisfy __alloc_pages and there is an oom.

The same things happens if I use mlock, only it happens sooner because
the kernel can't discard any of the 15MB of mlock'd memory so it
actually runs out of memory faster:

http://www.tommay.net/memory-mlock.png

I'm not sure how to explain it differently than I have before.  Maybe
someone else could explain it better.  So, at the risk of merely
repeating myself: The jvm allocates memory.  MemFree decreases.  In
the kernel, __alloc_pages is called.  It finds that memory is low,
memory_pressure_notify is called, and some cached pages are moved to
the inactive list.  These pages may then be used to satisfy
__alloc_pages requests.  The jvm gets the notification, collects
garbage, and returns memory to the kernel which appears as MemFree in
/proc/meminfo.  The cycle continues: the jvm allocates memory until
memory_pressure_notify is called, more cached pages are moved to the
inactive list, etc.  Eventually there are no more pages to move to the
inactive list, and __alloc_pages will invoke the oom killer.

>  Please don't think I have objection your proposal.
>  merely, I don't understand your system yet.
>
>  if I make new code before understand your requirement exactly,
>  It makes many bug.

Of course.

>  IMHO threshold based notification has a problems.
>  if low memory happend and application has no freeable memory,
>  mem notification don't stop and increase CPU usage dramatically, but it is perfectly useless.

My thought was to notify only when the threshold is crossed, i.e.,
edge-triggered not level-triggered.  But I now think a threshold
mechanism may be too complicated, and artificially putting pages in
the cache works just as well.  As a proof-of-concept, I do this, and
it works well, but is inefficient:

   extern char _text;
   for (int i = 0; i < bytes; i += 4096) {
       *((volatile char *)&_text + i);
   }

>  I don't thin embedded java is not important, but I don't hope
>  desktop regression...

I think embedded Java is a perfect user of /dev/mem_notify :-) I was
happy to see your patches and the criteria you used for notification.
But I'm having a problem in practice :-(

.tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
