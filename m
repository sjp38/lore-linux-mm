Date: Fri, 02 May 2008 00:06:05 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <ab3f9b940804301907y5a3e84e1l6cb41a339bc2241b@mail.gmail.com>
References: <cfd9edbf0804230127k33a56312i6582f926e00ea17@mail.gmail.com> <ab3f9b940804301907y5a3e84e1l6cb41a339bc2241b@mail.gmail.com>
Message-Id: <20080501232431.F617.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tom May <tom@tommay.com>
Cc: kosaki.motohiro@jp.fujitsu.com, =?ISO-2022-JP?B?IkRhbmllbCBTcBskQmlPGyhCZyI=?= <daniel.spang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Tom,

> In my case of a Java virtual machine, where I originally saw the
> problem, most of the code is interpreted byte codes or jit-compiled
> native code, all of which resides not in the text segment but in
> anonymous pages that aren't backed by a file, and there is no swap
> space.  The actual text segment working set can be very small (memory
> allocation, garbage collection, synchronization, other random native
> code).  And, as KOSAKI Motohiro pointed out, it may be wise to mlock
> these areas.  So the text working set doesn't make an adequate
> reserve.

your memnotify check routine is written by native or java?
if native, my suggestion is right.
but if java, it is wrong.

my point is "on swapless system, /dev/mem_notify checked routine should be mlocked".


> However, I can maintain a reserve of cached and/or mapped memory by
> touching pages in the text segment (or any mapped file) as the final
> step of low memory notification handling, if the cached page count is
> getting low.  For my purposes, this is nearly the same as having an
> additional threshold-based notification, since it forces notifications
> to occur while the kernel still has some memory to satisfy allocations
> while userspace code works to free memory.  And it's simple.
> 
> Unfortunately, this is more expensive than it could be since the pages
> need to be read in from some device (mapping /dev/zero doesn't cause
> pages to be allocated). What I'm looking for now is a cheap way to
> populate the cache with pages that the kernel can throw away when it
> needs to reclaim memory.

I hope understand your requirement more.
Can I ask your system more?

I think all java text and data is mapped.
When cached+mapped+free memory is happend?
and at the time, What is used memory?

Please don't think I have objection your proposal.
merely, I don't understand your system yet.

if I make new code before understand your requirement exactly, 
It makes many bug.


IMHO threshold based notification has a problems.
if low memory happend and application has no freeable memory,
mem notification don't stop and increase CPU usage dramatically, but it is perfectly useless.

I don't thin embedded java is not important, but I don't hope
desktop regression...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
