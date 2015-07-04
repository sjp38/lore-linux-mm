Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 770C4280281
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 08:56:28 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so78472377pdb.1
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 05:56:27 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id jo1si19315116pbc.252.2015.07.04.05.56.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Jul 2015 05:56:26 -0700 (PDT)
Date: Sat, 4 Jul 2015 08:55:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
Message-ID: <20150704125512.GA11103@cmpxchg.org>
References: <20150703183809.GA6781@cmpxchg.org>
 <1643824843.2299688.1435989877460.JavaMail.yahoo@mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1643824843.2299688.1435989877460.JavaMail.yahoo@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: Pintu Kumar <pintu.k@samsung.com>, "corbet@lwn.net" <corbet@lwn.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "gorcunov@openvz.org" <gorcunov@openvz.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "emunson@akamai.com" <emunson@akamai.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "standby24x7@gmail.com" <standby24x7@gmail.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "hughd@google.com" <hughd@google.com>, "minchan@kernel.org" <minchan@kernel.org>, "tj@kernel.org" <tj@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "xypron.glpk@gmx.de" <xypron.glpk@gmx.de>, "dzickus@redhat.com" <dzickus@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "uobergfe@redhat.com" <uobergfe@redhat.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "cj@linux.com" <cj@linux.com>, "opensource.ganesh@gmail.com" <opensource.ganesh@gmail.com>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "cpgs@samsung.com" <cpgs@samsung.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, "rohit.kr@samsung.com" <rohit.kr@samsung.com>, "iqbal.ams@samsung.com" <iqbal.ams@samsung.com>

On Sat, Jul 04, 2015 at 06:04:37AM +0000, PINTU KUMAR wrote:
> >On Fri, Jul 03, 2015 at 06:50:07PM +0530, Pintu Kumar wrote:
> >> This patch provides 2 things:
> >> 1. Add new control called shrink_memory in /proc/sys/vm/.
> >> This control can be used to aggressively reclaim memory system-wide
> >> in one shot from the user space. A value of 1 will instruct the
> >> kernel to reclaim as much as totalram_pages in the system.
> >> Example: echo 1 > /proc/sys/vm/shrink_memory
> >> 
> >> 2. Enable shrink_all_memory API in kernel with new CONFIG_SHRINK_MEMORY.
> >> Currently, shrink_all_memory function is used only during hibernation.
> >> With the new config we can make use of this API for non-hibernation case
> >> also without disturbing the hibernation case.
> >> 
> >> The detailed paper was presented in Embedded Linux Conference, Mar-2015
> >> http://events.linuxfoundation.org/sites/events/files/slides/
> >> %5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf
> >> 
> >> Scenarios were this can be used and helpful are:
> >> 1) Can be invoked just after system boot-up is finished.
> >
> >The allocator automatically reclaims when memory is needed, that's why
> >the metrics quoted in those slides, free pages and fragmentation level,
> >don't really mean much.  We don't care how much memory is free or how
> >fragmented it is UNTIL somebody actually asks for it.  The only metric
> >that counts is the allocation success ratio (and possibly the latency).
> 
> Yes, the allocator automatically reclaims memory but in the
> slowpath. Also it reclaims only to satisfy the current allocation
> needs. That means for all future higher-order allocations the system
> will be entering slowpath again and again. Over a point of time
> (with multiple application launch), the higher-orders (2^4 and
> above) will be gone. The system entering slowpath means that the
> first allocation attempt has already failed. Then in slowpath the
> sequence is: kswapd -> compaction -> then direct reclaim. Thus
> entering slowpath again and again will be a costly operation.
> 
> Thus keeping free memory ready in higher-order pages will be helpful
> for succeeding first allocation attempt.

High order allocation fastpath sounds like a bad idea, especially on
embedded devices.  It takes a lot of work to create higher order
pages, so anything that relies on being able to allocate them
frequently and quickly is going to be very expensive.

But even if you need higher order pages on a regular pages, compaction
is *way* more efficient and directed than what you are proposing.  My
phone has 2G of memory, which is over half a million of pages.  What
would it do to my battery life if you told the VM on a regular basis
to scan the LRUs until it has reclaimed half a million pages?

> The scenario that is discussed here is about: Invoking shrink_memory
> from user space, as soon as the system boot is finished.  Because as
> per my observation, the buffer+caches that is accumulated during
> boot-up is not very helpful for the system for later application
> launch.  Thus reclaiming all memory in shot after the boot-up will
> help grab higher-order pages and freeing lots of memory. Also the
> reclaimed memory stays in as actual free memory. The cached that
> gets accumulated after the application launch will be having more
> hits.  It is like a little advanced version of drop_caches.

The buffers and cache are trivial to reclaim and compact, so that
shouldn't affect allocation success at all.  And even allocation
latency should be reasonable.

drop_caches is a development/debugging tool for kernel developers, not
a tool to implement userspace memory management.  If you find you need
to use it on a regular basis because of performance issues, then
please file a bug report.

> >> 2) Can be invoked just before entering entire system suspend.
> >
> >Why is that?  Suspend already allocates as much as it needs to create
> 
> >the system image.
> 
> Sorry, but I think you got it wrong here. We are not talking about
> snapshot image creation part that comes under hibernation.  We are
> talking about the mobile world, where the system gets suspended when
> it is kept idle for longer time. The hibernation part does not comes
> here.  The idea is that the shrink_memory can be best utilized when
> the system is not doing any useful stuffs and going from idle to
> suspend. In this scenario, we can check the state of free memory and
> perform the system-wide reclaim if necessary. Thus when the system
> resume again, it will have enough memory as free.  Again, this is
> mainly for embedded world where hibernation is not enabled.  For
> normal world, it already does it during hibernation snapshot image
> creation.

The reason they are suspending is to conserve energy, now?  This is an
outrageous amount of work you propose should be done when the system
goes idle.  Generally, proactive work tends to be less efficient than
on-demand work due to overproduction, so the more power-restrained
your system, the lazier and just-in-time you should be.

If your higher-order allocation latency really is an issue, at least
use targetted background compaction.  But again, everybody would be
better off if you didn't rely on frequent higher-order allocations,
because they require a lot of CPU-intensive work that consumes a lot
of power, whether you schedule that work on-demand or proactively.

> >> 3) Can be invoked from kernel when order-4 pages starts failing.
> >
> >We have compaction for that, and compaction invokes page reclaim
> 
> >automatically to satisfy its need for free pages.
> 
> It is not always true. Compaction may not be always
> successful. Again it is related to slowpath. When order-4 starts
> failing very often that means all higher-orders becomes 0. Thus
> system will be entering slowpath again and again, doing swap,
> compaction, reclaim most of the time.  And even for compaction,
> there is a knob in user space to call compaction from user space:
> #echo 1 > /proc/sys/vm/compact_memory

At least that's not a cache-destructive operation and just compacts
already free pages but, just like drop_caches, you shouldn't ever have
to use this in production.

> >> 4) Can be helpful to completely avoid or delay the kerenl OOM condition.
> >
> >That's not how OOM works.  An OOM is triggered when there is demand for
> >memory but no more pages to reclaim, telling the kernel to look harder
> >will not change that.
> 
> >
> Yes, I know this. I am not talking about calling shrink_memory after OOM. 
> 
> Rather much before OOM when the first attempt of higher-order starts failing.
> This will delay the OOM to a much later stage.

That's not how OOM works *at all*.  OOM happens when all the pages are
tied up in places where they can't be reclaimed.  It has nothing to do
with fragmentation (OOM is not even defined for higher order pages) or
reclaim timing (since reclaim can't reclaim unreclaimable pages. heh).

You're really not making a lot of sense here.

> >> 5) Can be developed as a system-tool to quickly defragment entire system
> >>    from user space, without the need to kill any application.
> >
> >Again, the kernel automatically reclaims and compacts memory on demand.
> >If the existing mechanisms don't do this properly, and you have actual
> >problems with them, they should be reported and fixed, not bypassed.
> >But the metrics you seem to base this change on are not representative
> 
> >of something that should matter in practice.
> 
> It is not always guaranteed that compaction/reclaim
> _did_some_progress_ always yield some results on the fly. It takes
> sometime to get sync with the free memory.  Thus keeping the free
> list ready before hand will be much more helpful.

We can always make compaction more aggressive with certain GFP flags
and tell it to wait for delayed memory frees etc.

> Anyways, the use case here is to develop a system utility which can
> perform compaction/reclaim/compaction aggressively.  Its an
> additional idea that somebody interested can develop.

I'm having a hard time seeing a clear usecase from your proposal, and
the implementation is too heavyhanded and destructive to be generally
useful as a memory management tool in real life.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
