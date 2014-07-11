Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A41886B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:46:14 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id p10so1008725pdj.41
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 05:46:14 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id ih9si2394361pbc.11.2014.07.11.05.46.12
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 05:46:13 -0700 (PDT)
Date: Fri, 11 Jul 2014 13:45:53 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: arm64 flushing 255GB of vmalloc space takes too long
Message-ID: <20140711124553.GG11473@arm.com>
References: <CAMPhdO-j5SfHexP8hafB2EQVs91TOqp_k_SLwWmo9OHVEvNWiQ@mail.gmail.com>
 <20140709174055.GC2814@arm.com>
 <CAMPhdO_XqAL4oXcuJkp2PTQ-J07sGG4Nm5HjHO=yGqS+KuWQzg@mail.gmail.com>
 <53BF3D58.2010900@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BF3D58.2010900@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Eric Miao <eric.y.miao@gmail.com>, "msalter@redhat.com" <msalter@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, Russell King <linux@arm.linux.org.uk>

On Fri, Jul 11, 2014 at 02:26:48AM +0100, Laura Abbott wrote:
> On 7/9/2014 11:04 AM, Eric Miao wrote:
> > On Wed, Jul 9, 2014 at 10:40 AM, Catalin Marinas
> > <catalin.marinas@arm.com> wrote:
> >> On Wed, Jul 09, 2014 at 05:53:26PM +0100, Eric Miao wrote:
> >>> On Tue, Jul 8, 2014 at 6:43 PM, Laura Abbott <lauraa@codeaurora.org> wrote:
> >>>> I have an arm64 target which has been observed hanging in __purge_vmap_area_lazy
> >>>> in vmalloc.c The root cause of this 'hang' is that flush_tlb_kernel_range is
> >>>> attempting to flush 255GB of virtual address space. This takes ~2 seconds and
> >>>> preemption is disabled at this time thanks to the purge lock. Disabling
> >>>> preemption for that time is long enough to trigger a watchdog we have setup.
> >>
> >> That's definitely not good.
> >>
> >>>> A couple of options I thought of:
> >>>> 1) Increase the timeout of our watchdog to allow the flush to occur. Nobody
> >>>> I suggested this to likes the idea as the watchdog firing generally catches
> >>>> behavior that results in poor system performance and disabling preemption
> >>>> for that long does seem like a problem.
> >>>> 2) Change __purge_vmap_area_lazy to do less work under a spinlock. This would
> >>>> certainly have a performance impact and I don't even know if it is plausible.
> >>>> 3) Allow module unloading to trigger a vmalloc purge beforehand to help avoid
> >>>> this case. This would still be racy if another vfree came in during the time
> >>>> between the purge and the vfree but it might be good enough.
> >>>> 4) Add 'if size > threshold flush entire tlb' (I haven't profiled this yet)
> >>>
> >>> We have the same problem. I'd agree with point 2 and point 4, point 1/3 do not
> >>> actually fix this issue. purge_vmap_area_lazy() could be called in other
> >>> cases.
> >>
> >> I would also discard point 2 as it still takes ~2 seconds, only that not
> >> under a spinlock.
> > 
> > Point is - we could still end up a good amount of time in that function,
> > giving the default value of lazy_vfree_pages to be 32MB * log(ncpu),
> > worst case of all vmap areas being only one page, tlb flush page by
> > page, and traversal of the list, calling __free_vmap_area() that many
> > times won't likely to reduce the execution time to microsecond level.
> > 
> > If it's something inevitable - we do it in a bit cleaner way.

In general I think it makes sense to add a mutex instead of a spinlock
here if slowdown is caused by other things as well. That's independent
of the TLB invalidation optimisation for arm64.

> > Or we end up having platform specific tlb flush implementation just as we
> > did for cache ops. I would expect only few platforms will have their own
> > thresholds. A simple heuristic guess of the threshold based on number of
> > tlb entries would be good to go?
> 
> Mark Salter actually proposed a fix to this back in May 
> 
> https://lkml.org/lkml/2014/5/2/311
> 
> I never saw any further comments on it though. It also matches what x86
> does with their TLB flushing. It fixes the problem for me and the threshold
> seems to be the best we can do unless we want to introduce options per
> platform. It will need to be rebased to the latest tree though.

There were other patches in this area and I forgot about this. The
problem is that the ARM architecture does not define the actual
micro-architectural implementation of the TLBs (and it shouldn't), so
there is no way to guess how many TLB entries there are. It's not an
easy figure to get either since there are multiple levels of caching for
the TLBs.

So we either guess some value here (we may not always be optimal) or we
put some time bound (e.g. based on sched_clock()) on how long to loop.
The latter is not optimal either, the only aim being to avoid
soft-lockups.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
