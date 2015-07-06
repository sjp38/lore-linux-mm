Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 68A042802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 14:38:04 -0400 (EDT)
Received: by lagc2 with SMTP id c2so165398289lag.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 11:38:03 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id jt2si15898823lab.166.2015.07.06.11.38.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 11:38:02 -0700 (PDT)
Received: by labgy5 with SMTP id gy5so13977501lab.2
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 11:38:01 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 7 Jul 2015 00:08:01 +0530
Message-ID: <CAOuPNLhRWtUunO6baJC_U7Nrh=hX+e=AN7k0pc-T5HLMGYfxvw@mail.gmail.com>
Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory feature
From: Pintu Kumar <pintu.ping@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Pintu Kumar <pintu.k@samsung.com>, Pintu Kumar <pintu.ping@gmail.com>
Cc: "corbet@lwn.net" <corbet@lwn.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "gorcunov@openvz.org" <gorcunov@openvz.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "emunson@akamai.com" <emunson@akamai.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "standby24x7@gmail.com" <standby24x7@gmail.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "hughd@google.com" <hughd@google.com>, "minchan@kernel.org" <minchan@kernel.org>, "tj@kernel.org" <tj@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "xypron.glpk@gmx.de" <xypron.glpk@gmx.de>, "dzickus@redhat.com" <dzickus@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "uobergfe@redhat.com" <uobergfe@redhat.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "cj@linux.com" <cj@linux.com>, "opensource.ganesh@gmail.com" <opensource.ganesh@gmail.com>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "cpgs@samsung.com" <cpgs@samsung.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, "rohit.kr@samsung.com" <rohit.kr@samsung.com>, "iqbal.ams@samsung.com" <iqbal.ams@samsung.com>

Hi,
Please find my comments inline.

> Sent: Saturday, 4 July 2015 6:25 PM
> Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory feature
>
> On Sat, Jul 04, 2015 at 06:04:37AM +0000, PINTU KUMAR wrote:
>> >On Fri, Jul 03, 2015 at 06:50:07PM +0530, Pintu Kumar wrote:
>> >> This patch provides 2 things:
>> >> 1. Add new control called shrink_memory in /proc/sys/vm/.
>> >> This control can be used to aggressively reclaim memory
> system-wide
>> >> in one shot from the user space. A value of 1 will instruct the
>> >> kernel to reclaim as much as totalram_pages in the system.
>> >> Example: echo 1 > /proc/sys/vm/shrink_memory
>> >>
>> >> 2. Enable shrink_all_memory API in kernel with new
> CONFIG_SHRINK_MEMORY.
>> >> Currently, shrink_all_memory function is used only during
> hibernation.
>> >> With the new config we can make use of this API for
> non-hibernation case
>> >> also without disturbing the hibernation case.
>> >>
>> >> The detailed paper was presented in Embedded Linux Conference,
> Mar-2015
>> >> http://events.linuxfoundation.org/sites/events/files/slides/
>> >> %5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf
>> >>
>> >> Scenarios were this can be used and helpful are:
>> >> 1) Can be invoked just after system boot-up is finished.
>> >
>> >The allocator automatically reclaims when memory is needed, that's
> why
>> >the metrics quoted in those slides, free pages and fragmentation level,
>> >don't really mean much.  We don't care how much memory is free
> or how
>> >fragmented it is UNTIL somebody actually asks for it.  The only metric
>> >that counts is the allocation success ratio (and possibly the latency).
>>
>> Yes, the allocator automatically reclaims memory but in the
>> slowpath. Also it reclaims only to satisfy the current allocation
>> needs. That means for all future higher-order allocations the system
>> will be entering slowpath again and again. Over a point of time
>> (with multiple application launch), the higher-orders (2^4 and
>> above) will be gone. The system entering slowpath means that the
>> first allocation attempt has already failed. Then in slowpath the
>> sequence is: kswapd -> compaction -> then direct reclaim. Thus
>> entering slowpath again and again will be a costly operation.
>>
>> Thus keeping free memory ready in higher-order pages will be helpful
>> for succeeding first allocation attempt.
>
> High order allocation fastpath sounds like a bad idea, especially on
> embedded devices.  It takes a lot of work to create higher order
> pages, so anything that relies on being able to allocate them
> frequently and quickly is going to be very expensive.
>
> But even if you need higher order pages on a regular pages, compaction
> is *way* more efficient and directed than what you are proposing.  My
> phone has 2G of memory, which is over half a million of pages.  What
> would it do to my battery life if you told the VM on a regular basis
> to scan the LRUs until it has reclaimed half a million pages?
>
Yes, may be for 2GB and above we dont need to worry about.
It is mainly be useful for less than 1GB and 512MB RAM devices.
Like in our case with 512MB RAM device, the totalram_pages was around 460MB.
And actual free memory was just about 30MB after bootup and
reclaimable memory goes up to ~200MB.
In this scenario it is highly unlikely that we have order-4, order-8
pages available after some usage.
Thus we found it to be useful when system is idle and when order-4 and
above becomes 0.
And we dont need to run it on regular basis.
Ok, I will try to get the power measurement done between slowpath and
shrink memory.

>> The scenario that is discussed here is about: Invoking shrink_memory
>> from user space, as soon as the system boot is finished.  Because as
>> per my observation, the buffer+caches that is accumulated during
>> boot-up is not very helpful for the system for later application
>> launch.  Thus reclaiming all memory in shot after the boot-up will
>> help grab higher-order pages and freeing lots of memory. Also the
>> reclaimed memory stays in as actual free memory. The cached that
>> gets accumulated after the application launch will be having more
>> hits.  It is like a little advanced version of drop_caches.
>
> The buffers and cache are trivial to reclaim and compact, so that
> shouldn't affect allocation success at all.  And even allocation
> latency should be reasonable.
>
> drop_caches is a development/debugging tool for kernel developers, not
> a tool to implement userspace memory management.  If you find you need
> to use it on a regular basis because of performance issues, then
> please file a bug report.
>
Yes, shrink_memory can also be helpful in debugging and vm parameter
tuning like drop_caches.
It is a way of performing direct_reclaim for user space just like
direct_compact.
Following are the benefits:
It help us to identify how much of maximum memory could be reclaimable
at any point of time.
What and how much higher-order pages could be formed with this amount
of reclaimable memory.
Also, In shrink_all_memory, we enable may_swap = 1, that means all
unused pages could be swapped out to says ZRAM backing store.
Thus we will know, what could be the best swap space that can be
configured for the device for an over-loaded scenario.
Thus it can help in system tuning also.

>> >> 2) Can be invoked just before entering entire system suspend.
>> >
>> >Why is that?  Suspend already allocates as much as it needs to create
>>
>> >the system image.
>>
>> Sorry, but I think you got it wrong here. We are not talking about
>> snapshot image creation part that comes under hibernation.  We are
>> talking about the mobile world, where the system gets suspended when
>> it is kept idle for longer time. The hibernation part does not comes
>> here.  The idea is that the shrink_memory can be best utilized when
>> the system is not doing any useful stuffs and going from idle to
>> suspend. In this scenario, we can check the state of free memory and
>> perform the system-wide reclaim if necessary. Thus when the system
>> resume again, it will have enough memory as free.  Again, this is
>> mainly for embedded world where hibernation is not enabled.  For
>> normal world, it already does it during hibernation snapshot image
>> creation.
>
> The reason they are suspending is to conserve energy, now?  This is an
> outrageous amount of work you propose should be done when the system
> goes idle.  Generally, proactive work tends to be less efficient than
> on-demand work due to overproduction, so the more power-restrained
> your system, the lazier and just-in-time you should be.
>
The amount of work will be done only if it is really required, just
before entering suspend.
That is only if the system is heavily fragmented and most likely to
enter slowpath again and again.
In which case the system will be already slow.

> If your higher-order allocation latency really is an issue, at least
> use targetted background compaction.  But again, everybody would be
> better off if you didn't rely on frequent higher-order allocations,
> because they require a lot of CPU-intensive work that consumes a lot
> of power, whether you schedule that work on-demand or proactively.
>
Yes, we tried compaction, but as per our analysis background
compaction is not useful always if
you have less free memory and more reclaimable.
And, it should not be called always. It should be called based on some
condition and when situation demands.
Ok, we will also perform power measurement and report.

>> >> 3) Can be invoked from kernel when order-4 pages starts failing.
>> >
>> >We have compaction for that, and compaction invokes page reclaim
>>
>> >automatically to satisfy its need for free pages.
>>
>> It is not always true. Compaction may not be always
>> successful. Again it is related to slowpath. When order-4 starts
>> failing very often that means all higher-orders becomes 0. Thus
>> system will be entering slowpath again and again, doing swap,
>> compaction, reclaim most of the time.  And even for compaction,
>> there is a knob in user space to call compaction from user space:
>> #echo 1 > /proc/sys/vm/compact_memory
>
> At least that's not a cache-destructive operation and just compacts
> already free pages but, just like drop_caches, you shouldn't ever have
> to use this in production.
>
Yes, we will not be using this in production.
As I said earlier, this feature can be used for some tuning purpose also.

>> >> 4) Can be helpful to completely avoid or delay the kerenl OOM
> condition.
>> >
>> >That's not how OOM works.  An OOM is triggered when there is demand
> for
>> >memory but no more pages to reclaim, telling the kernel to look harder
>> >will not change that.
>>
>> >
>> Yes, I know this. I am not talking about calling shrink_memory after OOM.
>>
>> Rather much before OOM when the first attempt of higher-order starts
> failing.
>> This will delay the OOM to a much later stage.
>
> That's not how OOM works *at all*.  OOM happens when all the pages are
> tied up in places where they can't be reclaimed.  It has nothing to do
> with fragmentation (OOM is not even defined for higher order pages) or
> reclaim timing (since reclaim can't reclaim unreclaimable pages. heh).
>
> You're really not making a lot of sense here.
>
If you check my last part of the slides in the ELC presentation, I
have covered few scenarios.
Consider a case, that you have launched 10 application, and free
memory is not enough for 11th app launch.
Now, system have 2 choice, keep performing direct reclaim or goes for OOM kill.
But, we dont want the old application to be killed and instead allows
more application to be launched.
Now, if after 10 application, if we execute memory shrinker, and swap
of previous pages out, we get enough free memory.
This will allow us to launch few more application and at the same time
retain previous application content on swap.

>> >> 5) Can be developed as a system-tool to quickly defragment entire
> system
>> >>    from user space, without the need to kill any application.
>> >
>> >Again, the kernel automatically reclaims and compacts memory on demand.
>> >If the existing mechanisms don't do this properly, and you have
> actual
>> >problems with them, they should be reported and fixed, not bypassed.
>> >But the metrics you seem to base this change on are not representative
>>
>> >of something that should matter in practice.
>>
>> It is not always guaranteed that compaction/reclaim
>> _did_some_progress_ always yield some results on the fly. It takes
>> sometime to get sync with the free memory.  Thus keeping the free
>> list ready before hand will be much more helpful.
>
> We can always make compaction more aggressive with certain GFP flags
> and tell it to wait for delayed memory frees etc.
>
As per our experiments, we found that compaction is not always helpful
in kernel 3.10.
The compaction success rate is 3/20 attempts. Instead direct_reclaim
is more helpful.

>> Anyways, the use case here is to develop a system utility which can
>> perform compaction/reclaim/compaction aggressively.  Its an
>> additional idea that somebody interested can develop.
>
> I'm having a hard time seeing a clear usecase from your proposal, and
> the implementation is too heavyhanded and destructive to be generally
> useful as a memory management tool in real life.
>
I have few more use cases to be presented.
Calling shrink_memory from ION/Graphics driver in a work queue, if
order-4 requests are failing for IOMMU allocation.
We also observed that, after heavy file transfer operation to/from
Device/PC, the free memory becomes very low and reclaimable memory
becomes very high.
This reclaimable memory may not be very useful for future application launch.
So, we can schedule a shrink_memory to make it part of free.

Sorry, if I have misunderstood any of your request.
If you have any other suggestions or experiments that you would like
me to perform to come to a conclusion, please let me know.
I will be happy to take your request.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
