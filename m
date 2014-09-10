Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 865BF6B00BE
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 18:01:29 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so9912118pdb.11
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:01:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d8si29538897pat.120.2014.09.10.15.01.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 15:01:28 -0700 (PDT)
Date: Wed, 10 Sep 2014 15:01:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3 v3] mmu_notifier: Allow to manage CPU external TLBs
Message-Id: <20140910150125.31a7495c7d0fe814b85fd514@linux-foundation.org>
In-Reply-To: <1410277434-3087-1-git-send-email-joro@8bytes.org>
References: <1410277434-3087-1-git-send-email-joro@8bytes.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Jerome Glisse <jglisse@redhat.com>, jroedel@suse.de, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

On Tue,  9 Sep 2014 17:43:51 +0200 Joerg Roedel <joro@8bytes.org> wrote:

> here is a patch-set to extend the mmu_notifiers in the Linux
> kernel to allow managing CPU external TLBs. Those TLBs may
> be implemented in IOMMUs or any other external device, e.g.
> ATS/PRI capable PCI devices.
> 
> The problem with managing these TLBs are the semantics of
> the invalidate_range_start/end call-backs currently
> available. Currently the subsystem using mmu_notifiers has
> to guarantee that no new TLB entries are established between
> invalidate_range_start/end. Furthermore the
> invalidate_range_start() function is called when all pages
> are still mapped and invalidate_range_end() when the pages
> are unmapped an already freed.
> 
> So both call-backs can't be used to safely flush any non-CPU
> TLB because _start() is called too early and _end() too
> late.

There's a lot of missing information here.  Why don't the existing
callbacks suit non-CPU TLBs?  What is different about them?  Please
update the changelog to contain all this context.

> In the AMD IOMMUv2 driver this is currently implemented by
> assigning an empty page-table to the external device between
> _start() and _end(). But as tests have shown this doesn't
> work as external devices don't re-fault infinitly but enter
> a failure state after some time.

More missing info.  Why are these faults occurring?  Is there some
device activity which is trying to fault in pages, but the CPU is
executing code between _start() and _end() so the driver must refuse to
instantiate a page to satisfy the fault?  That's just a guess, and I
shouldn't be guessing.  Please update the changelog to fully describe
the dynamic activity which is causing this.

> Next problem with this solution is that it causes an
> interrupt storm for IO page faults to be handled when an
> empty page-table is assigned.

Also too skimpy.  I *think* this is a variant of the problem in the
preceding paragraph.  We get a fault storm (which is problem 2) and
sometimes the faulting device gives up (which is problem 1).

Or something.  Please de-fog all of this.

> Furthermore the _start()/end() notifiers only catch the
> moment when page mappings are released, but not page-table
> pages. But this is necessary for managing external TLBs when
> the page-table is shared with the CPU.

How come?

> To solve this situation I wrote a patch-set to introduce a
> new notifier call-back: mmu_notifer_invalidate_range(). This
> notifier lifts the strict requirements that no new
> references are taken in the range between _start() and
> _end(). When the subsystem can't guarantee that any new
> references are taken is has to provide the
> invalidate_range() call-back to clear any new references in
> there.
> 
> It is called between invalidate_range_start() and _end()
> every time the VMM has to wipe out any references to a
> couple of pages. This are usually the places where the CPU
> TLBs are flushed too and where its important that this
> happens before invalidate_range_end() is called.
> 
> Any comments and review appreciated!

The patchset looks decent, although I find it had to review because I
just wasn't provided with enough of the thinking that went into it.  I
have enough info to look at the C code, but not enough info to identify
and evaluate alternative implementation approaches, to identify
possible future extensions, etc.

The patchset does appear to add significant additional overhead to hot
code paths when mm_has_notifiers(mm).  Please let's update the
changelog to address this rather important concern.  How significant is
the impact on such mm's, how common are such mm's now and in the
future, should we (for example) look at short-circuiting
__mmu_notifier_invalidate_range() if none of the registered notifiers
implement ->invalidate_range(), etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
