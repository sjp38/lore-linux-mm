Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 349F26B0038
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 14:47:46 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id c11so1454039lbj.1
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 11:47:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mi6si7853285lbb.81.2014.09.12.11.47.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 11:47:44 -0700 (PDT)
Date: Fri, 12 Sep 2014 20:47:39 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 0/3 v3] mmu_notifier: Allow to manage CPU external TLBs
Message-ID: <20140912184739.GF2519@suse.de>
References: <1410277434-3087-1-git-send-email-joro@8bytes.org>
 <20140910150125.31a7495c7d0fe814b85fd514@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140910150125.31a7495c7d0fe814b85fd514@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

Hi Andrew,

thanks for your review, I tried to answer your questions below.

On Wed, Sep 10, 2014 at 03:01:25PM -0700, Andrew Morton wrote:
> On Tue,  9 Sep 2014 17:43:51 +0200 Joerg Roedel <joro@8bytes.org> wrote:
> > So both call-backs can't be used to safely flush any non-CPU
> > TLB because _start() is called too early and _end() too
> > late.
> 
> There's a lot of missing information here.  Why don't the existing
> callbacks suit non-CPU TLBs?  What is different about them?  Please
> update the changelog to contain all this context.

The existing call-backs are called too early or too late. Specifically,
invalidate_range_start() is called when all pages are still mapped and 
invalidate_range_end() when all pages are unmapped and potentially
freed.

This is fine when the users of the mmu_notifiers manage their own
SoftTLB, like KVM does. When the TLB is managed in software it is easy
to wipe out entries for a given range and prevent new entries to be
established until invalidate_range_end is called.

But when the user of mmu_notifiers has to manage a hardware TLB it can
still wipe out TLB entries in invalidate_range_start, but it can't make
sure that no new TLB entries in the given range are established between
invalidate_range_start and invalidate_range_end.

	[ Actually the current AMD IOMMUv2 code tries to do that with
	  setting the setting an empty page-table for the non-CPU TLB,
	  but this causes address translation errors which end up in
	  device failures. ]

But to avoid silent data corruption the TLB entries need to be flushed
out of the non-CPU hardware TLB when the pages are unmapped (at this
point in time no _new_ TLB entries can be established in the non-CPU
TLB) but not yet freed (as the non-CPU TLB may still have _existing_
entries pointing to the pages about to be freed).

So to fix this problem we need to catch the moment when the Linux VMM
flushes remote TLBs (as a non-CPU TLB is not very different in its
flushing requirements from any other remote CPU TLB), as this is the
point in time when the pages are unmapped but _not_ yet freed.

The mmu_notifier_invalidate_range() function aims to catch that moment.

> > In the AMD IOMMUv2 driver this is currently implemented by
> > assigning an empty page-table to the external device between
> > _start() and _end(). But as tests have shown this doesn't
> > work as external devices don't re-fault infinitly but enter
> > a failure state after some time.
> 
> More missing info.  Why are these faults occurring?  Is there some
> device activity which is trying to fault in pages, but the CPU is
> executing code between _start() and _end() so the driver must refuse to
> instantiate a page to satisfy the fault?  That's just a guess, and I
> shouldn't be guessing.  Please update the changelog to fully describe
> the dynamic activity which is causing this.

The device (usually a GPU) runs some process (for example a compute job)
that directly accesses a Linux process address space. Any access
to a process address space can cause a page-fault, whether the access
comes from the CPU or a remote device.

When the page-fault comes from a compute job running on a GPU, is is
reported to Linux by an IOMMU interrupt.

The current implementation of invalidate_range_start/end assigns an
empty page-table, which causes many page-faults from the GPU process,
resulting in an interrupt storm for the IOMMU.

The fault handler doesn't handle the fault if an
invalidate_range_start/end pair is active, but just reports back SUCESS
to the device to let it refault the page then (refaulting is the same strategy
KVM implements). But existing GPUs that make use of this feature don't
refault indefinitly, after a certain number of faults for the same
address the device enters a failure state and needs to be resetted.L

> > Next problem with this solution is that it causes an
> > interrupt storm for IO page faults to be handled when an
> > empty page-table is assigned.
> 
> Also too skimpy.  I *think* this is a variant of the problem in the
> preceding paragraph.  We get a fault storm (which is problem 2) and
> sometimes the faulting device gives up (which is problem 1).
> 
> Or something.  Please de-fog all of this.

Right, I will update the description to be more clear.

> > Furthermore the _start()/end() notifiers only catch the
> > moment when page mappings are released, but not page-table
> > pages. But this is necessary for managing external TLBs when
> > the page-table is shared with the CPU.
> 
> How come?

As mmu_notifiers are not used for managing TLBs that share the same
page-table as the CPU uses, there was not need to catch the page-table
freeing events, so it is not available yet.

> > Any comments and review appreciated!
> 
> The patchset looks decent, although I find it had to review because I
> just wasn't provided with enough of the thinking that went into it.  I
> have enough info to look at the C code, but not enough info to identify
> and evaluate alternative implementation approaches, to identify
> possible future extensions, etc.

Fair enough, I hope I clarified a few things with my explanations
above. I will also update the description of the patch-set when I
re-send.

> The patchset does appear to add significant additional overhead to hot
> code paths when mm_has_notifiers(mm).  Please let's update the
> changelog to address this rather important concern.  How significant is
> the impact on such mm's, how common are such mm's now and in the
> future, should we (for example) look at short-circuiting
> __mmu_notifier_invalidate_range() if none of the registered notifiers
> implement ->invalidate_range(), etc.

I think it adds the most overhead to single-CPU kernels. The
invalidate_range notifier is called in the paths that also do a remote
TLB flush, which is very expensive on its own. To those paths it adds
just another remote TLB that needs to be flushed.

Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
