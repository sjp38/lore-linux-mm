Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE276B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 13:41:16 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so9562574pab.18
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 10:41:16 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id dl5si7597358pdb.97.2014.07.09.10.41.14
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 10:41:15 -0700 (PDT)
Date: Wed, 9 Jul 2014 18:40:55 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: arm64 flushing 255GB of vmalloc space takes too long
Message-ID: <20140709174055.GC2814@arm.com>
References: <CAMPhdO-j5SfHexP8hafB2EQVs91TOqp_k_SLwWmo9OHVEvNWiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMPhdO-j5SfHexP8hafB2EQVs91TOqp_k_SLwWmo9OHVEvNWiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Miao <eric.y.miao@gmail.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, Russell King <linux@arm.linux.org.uk>

On Wed, Jul 09, 2014 at 05:53:26PM +0100, Eric Miao wrote:
> On Tue, Jul 8, 2014 at 6:43 PM, Laura Abbott <lauraa@codeaurora.org> wrote:
> > I have an arm64 target which has been observed hanging in __purge_vmap_area_lazy
> > in vmalloc.c The root cause of this 'hang' is that flush_tlb_kernel_range is
> > attempting to flush 255GB of virtual address space. This takes ~2 seconds and
> > preemption is disabled at this time thanks to the purge lock. Disabling
> > preemption for that time is long enough to trigger a watchdog we have setup.

That's definitely not good.

> > A couple of options I thought of:
> > 1) Increase the timeout of our watchdog to allow the flush to occur. Nobody
> > I suggested this to likes the idea as the watchdog firing generally catches
> > behavior that results in poor system performance and disabling preemption
> > for that long does seem like a problem.
> > 2) Change __purge_vmap_area_lazy to do less work under a spinlock. This would
> > certainly have a performance impact and I don't even know if it is plausible.
> > 3) Allow module unloading to trigger a vmalloc purge beforehand to help avoid
> > this case. This would still be racy if another vfree came in during the time
> > between the purge and the vfree but it might be good enough.
> > 4) Add 'if size > threshold flush entire tlb' (I haven't profiled this yet)
> 
> We have the same problem. I'd agree with point 2 and point 4, point 1/3 do not
> actually fix this issue. purge_vmap_area_lazy() could be called in other
> cases.

I would also discard point 2 as it still takes ~2 seconds, only that not
under a spinlock.

> w.r.t the threshold to flush entire tlb instead of doing that page-by-page, that
> could be different from platform to platform. And considering the cost of tlb
> flush on x86, I wonder why this isn't an issue on x86.

The current __purge_vmap_area_lazy() was done as an optimisation (commit
db64fe02258f1) to avoid IPIs. So flush_tlb_kernel_range() would only be
IPI'ed once.

IIUC, the problem is how start/end are computed in
__purge_vmap_area_lazy(), so even if you have only two vmap areas, if
they are 255GB apart you've got this problem.

One temporary option is to limit the vmalloc space on arm64 to something
like 2 x RAM-size (haven't looked at this yet). But if you get a
platform with lots of RAM, you hit this problem again.

Which leaves us with point (4) but finding the threshold is indeed
platform dependent. Another way could be a check for latency - so if it
took certain usecs, we break the loop and flush the whole TLB.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
