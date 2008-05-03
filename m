Date: Sat, 03 May 2008 21:26:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <ab3f9b940805021521o4680116fyde099f16d66a1e5a@mail.gmail.com>
References: <20080501232431.F617.KOSAKI.MOTOHIRO@jp.fujitsu.com> <ab3f9b940805021521o4680116fyde099f16d66a1e5a@mail.gmail.com>
Message-Id: <20080503205732.642F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tom May <tom@tommay.com>
Cc: kosaki.motohiro@jp.fujitsu.com,  Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmciIiA=?= <daniel.spang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> >  your memnotify check routine is written by native or java?
> 
> Some of each.

Wow!
you have 2 /dev/mem_notify checking routine?
java routine free java memory, native routine free native memory, right? 


> >  my point is "on swapless system, /dev/mem_notify checked routine should be mlocked".
> 
> mlocking didn't fix things, it just made the oom happen at a different
> time (see graphs below), both in the small test program where I used
> mlockall, and in the jvm where during initialization I read
> /proc/self/maps and mlocked each region of memory that was mapped to a
> file.  Note that without swap, all of the anonymous pages containing
> the java code are effectively locked in memory, too, so everything
> runs without page faults.

okey.


> >  I hope understand your requirement more.
> 
> Most simply, I need to get low memory notifications while there is
> still enough memory to handle them before oom.

Ah, That's your implementation idea.
I hope know why don't works well my current implementation at first.


> >  Can I ask your system more?
> 
> x86, Linux 2.6.23.9 (with your patches trivially backported), 128MB,
> no swap.  Is there something else I can tell you?
> 
> >  I think all java text and data is mapped.
> 
> It's not what /proc/meminfo calls "Mapped".  It's in anonymous pages
> with no backing store, i.e., mmap with MAP_ANONYMOUS.

okey.
Mapped of /proc/meminfo mean mapped pages with file backing store.

therefore, that isn't contain anonymous memory(e.g. java).

> >  When cached+mapped+free memory is happend?
> >  and at the time, What is used memory?
> 
> Here's a graph of MemFree, Cached, and Mapped over time (I believe
> Mapped is mostly or entirely subset of Cached here, so it's not
> actually important):
> 
> http://www.tommay.net/memory.png

I hope know your system memory usage detail.
your system have 128MB, but your graph vertical line represent 0M - 35M.
Who use remain 93MB(128-35)?
We should know who use memory intead decrease cached memory.

So, Can you below operation before mesurement?

# echo 100 > /proc/sys/vm/swappiness
# echo 3 >/proc/sys/vm/drop_caches

and, Can you mesure AnonPages of /proc/meminfo too?
(Can your memory shrinking routine reduce anonymous memory?)

if JVM use memory as anonymous memory and your memory shrinking routine can't
anonymous memory, that isn't mem_notify proble, 
that is just poor JVM garbege collection problem.

Why I think that?
mapped page of your graph decrease linearly.
if notification doesn't happened, it doesn't decrease.

thus, 
in your system, memory notification is happend rightly.
but your JVM doesn't have enough freeable memory.

if my assumption is right, increase number of memory notification 
doesn't solve your problem.

Sould we find way of good interaction to JVM GC and mem_notify shrinker?
Sould mem_notify shrinker kick JVM GC for shrink anonymous memory?



> My thought was to notify only when the threshold is crossed, i.e.,
> edge-triggered not level-triggered.  

Hm, interesting..


> But I now think a threshold
> mechanism may be too complicated, and artificially putting pages in
> the cache works just as well.  As a proof-of-concept, I do this, and
> it works well, but is inefficient:
> 
>    extern char _text;
>    for (int i = 0; i < bytes; i += 4096) {
>        *((volatile char *)&_text + i);
>    }

you intent populate to .text segment?
if so, you can mamp(MAP_POPULATE), IMHO.


> I think embedded Java is a perfect user of /dev/mem_notify :-) I was
> happy to see your patches and the criteria you used for notification.
> But I'm having a problem in practice :-(

Yeah, absolutely.
I'll try to set up JVM to my test environment tomorrow.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
