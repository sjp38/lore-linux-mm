Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF946B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 14:05:01 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id wo20so777782obc.35
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 11:05:00 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id ik8si64686365obc.39.2014.07.09.11.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 11:05:00 -0700 (PDT)
Received: by mail-ob0-f174.google.com with SMTP id va2so8456553obc.19
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 11:04:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140709174055.GC2814@arm.com>
References: <CAMPhdO-j5SfHexP8hafB2EQVs91TOqp_k_SLwWmo9OHVEvNWiQ@mail.gmail.com>
 <20140709174055.GC2814@arm.com>
From: Eric Miao <eric.y.miao@gmail.com>
Date: Wed, 9 Jul 2014 11:04:39 -0700
Message-ID: <CAMPhdO_XqAL4oXcuJkp2PTQ-J07sGG4Nm5HjHO=yGqS+KuWQzg@mail.gmail.com>
Subject: Re: arm64 flushing 255GB of vmalloc space takes too long
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, Russell King <linux@arm.linux.org.uk>

On Wed, Jul 9, 2014 at 10:40 AM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> On Wed, Jul 09, 2014 at 05:53:26PM +0100, Eric Miao wrote:
>> On Tue, Jul 8, 2014 at 6:43 PM, Laura Abbott <lauraa@codeaurora.org> wrote:
>> > I have an arm64 target which has been observed hanging in __purge_vmap_area_lazy
>> > in vmalloc.c The root cause of this 'hang' is that flush_tlb_kernel_range is
>> > attempting to flush 255GB of virtual address space. This takes ~2 seconds and
>> > preemption is disabled at this time thanks to the purge lock. Disabling
>> > preemption for that time is long enough to trigger a watchdog we have setup.
>
> That's definitely not good.
>
>> > A couple of options I thought of:
>> > 1) Increase the timeout of our watchdog to allow the flush to occur. Nobody
>> > I suggested this to likes the idea as the watchdog firing generally catches
>> > behavior that results in poor system performance and disabling preemption
>> > for that long does seem like a problem.
>> > 2) Change __purge_vmap_area_lazy to do less work under a spinlock. This would
>> > certainly have a performance impact and I don't even know if it is plausible.
>> > 3) Allow module unloading to trigger a vmalloc purge beforehand to help avoid
>> > this case. This would still be racy if another vfree came in during the time
>> > between the purge and the vfree but it might be good enough.
>> > 4) Add 'if size > threshold flush entire tlb' (I haven't profiled this yet)
>>
>> We have the same problem. I'd agree with point 2 and point 4, point 1/3 do not
>> actually fix this issue. purge_vmap_area_lazy() could be called in other
>> cases.
>
> I would also discard point 2 as it still takes ~2 seconds, only that not
> under a spinlock.
>

Point is - we could still end up a good amount of time in that function,
giving the default value of lazy_vfree_pages to be 32MB * log(ncpu),
worst case of all vmap areas being only one page, tlb flush page by
page, and traversal of the list, calling __free_vmap_area() that many
times won't likely to reduce the execution time to microsecond level.

If it's something inevitable - we do it in a bit cleaner way.

>> w.r.t the threshold to flush entire tlb instead of doing that page-by-page, that
>> could be different from platform to platform. And considering the cost of tlb
>> flush on x86, I wonder why this isn't an issue on x86.
>
> The current __purge_vmap_area_lazy() was done as an optimisation (commit
> db64fe02258f1) to avoid IPIs. So flush_tlb_kernel_range() would only be
> IPI'ed once.
>
> IIUC, the problem is how start/end are computed in
> __purge_vmap_area_lazy(), so even if you have only two vmap areas, if
> they are 255GB apart you've got this problem.

Indeed.

>
> One temporary option is to limit the vmalloc space on arm64 to something
> like 2 x RAM-size (haven't looked at this yet). But if you get a
> platform with lots of RAM, you hit this problem again.
>
> Which leaves us with point (4) but finding the threshold is indeed
> platform dependent. Another way could be a check for latency - so if it
> took certain usecs, we break the loop and flush the whole TLB.

Or we end up having platform specific tlb flush implementation just as we
did for cache ops. I would expect only few platforms will have their own
thresholds. A simple heuristic guess of the threshold based on number of
tlb entries would be good to go?

>
> --
> Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
