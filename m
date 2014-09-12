Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 00BBE6B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 14:39:46 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id s7so1164088qap.18
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 11:39:46 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id x9si6738978qai.121.2014.09.12.11.39.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 11:39:46 -0700 (PDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so1236423qgd.1
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 11:39:46 -0700 (PDT)
Date: Fri, 12 Sep 2014 14:39:35 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 0/3 v3] mmu_notifier: Allow to manage CPU external TLBs
Message-ID: <20140912183934.GA5196@gmail.com>
References: <1410277434-3087-1-git-send-email-joro@8bytes.org>
 <20140910150125.31a7495c7d0fe814b85fd514@linux-foundation.org>
 <20140911000211.GA4989@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140911000211.GA4989@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, jroedel@suse.de, Peter Zijlstra <a.p.zijlstra@chello.nl>, John.Bridgman@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, ben.sander@amd.com, linux-mm@kvack.org, Jerome Glisse <jglisse@redhat.com>, Jay.Cornwall@amd.com, Mel Gorman <mgorman@suse.de>, David Woodhouse <dwmw2@infradead.org>, Johannes Weiner <jweiner@redhat.com>, iommu@lists.linux-foundation.org

On Wed, Sep 10, 2014 at 08:02:12PM -0400, Jerome Glisse wrote:
> On Wed, Sep 10, 2014 at 03:01:25PM -0700, Andrew Morton wrote:
> > On Tue,  9 Sep 2014 17:43:51 +0200 Joerg Roedel <joro@8bytes.org> wrote:
> > 
> > > here is a patch-set to extend the mmu_notifiers in the Linux
> > > kernel to allow managing CPU external TLBs. Those TLBs may
> > > be implemented in IOMMUs or any other external device, e.g.
> > > ATS/PRI capable PCI devices.
> > > 
> > > The problem with managing these TLBs are the semantics of
> > > the invalidate_range_start/end call-backs currently
> > > available. Currently the subsystem using mmu_notifiers has
> > > to guarantee that no new TLB entries are established between
> > > invalidate_range_start/end. Furthermore the
> > > invalidate_range_start() function is called when all pages
> > > are still mapped and invalidate_range_end() when the pages
> > > are unmapped an already freed.
> > > 
> > > So both call-backs can't be used to safely flush any non-CPU
> > > TLB because _start() is called too early and _end() too
> > > late.
> > 
> > There's a lot of missing information here.  Why don't the existing
> > callbacks suit non-CPU TLBs?  What is different about them?  Please
> > update the changelog to contain all this context.
> 
> So unlike KVM or any current user of the mmu_notifier api, any PCIE
> ATS/PASID capable hardware IOMMUv2 for AMD and forgot the marketing
> name for Intel (probably VTd) implementation walk the cpu page table
> on there own and have there own TLB cache. In fact not only the iommu
> can have a TLB cache but any single PCIE hardware can implement its
> own local TLB cache.
> 
> So if we flush the IOMMU and device TLB inside the range_start callback
> there is a chance that the hw will just rewalk the cpu page table and
> repopulate its TLB before the CPU page table is actually updated.
> 
> Now if we shoot down the TLB inside the range_end callback, then we
> are too late ie the CPU page table is already populated with new entry
> and all the TLB in the IOMMU an in device might be pointing to the old
> pages.
> 
> So the aim of this callback is to happen right after the CPU page table
> is updated but before the old page is freed or recycled. Note that it
> is also safe for COW and other transition from like read only to read
> and write or the other way around.
> 
> > 
> > > In the AMD IOMMUv2 driver this is currently implemented by
> > > assigning an empty page-table to the external device between
> > > _start() and _end(). But as tests have shown this doesn't
> > > work as external devices don't re-fault infinitly but enter
> > > a failure state after some time.
> > 
> > More missing info.  Why are these faults occurring?  Is there some
> > device activity which is trying to fault in pages, but the CPU is
> > executing code between _start() and _end() so the driver must refuse to
> > instantiate a page to satisfy the fault?  That's just a guess, and I
> > shouldn't be guessing.  Please update the changelog to fully describe
> > the dynamic activity which is causing this.
> 
> The hack that was use prior to this patch was to point the IOMMU to an
> empty page table (a zero page) inside the range_start() callback and
> shoot down the TLB but this meant that the device might enter inside a
> storm of page fault. GPU can have thousand of threads and because during
> invalidation the empty page table is use they all starts triggering page
> fault even if they were not trying to access the range being invalidated.
> It turns out that when this happens current hw like AMD GPU actually stop
> working after a while ie the hw stumble because there is too much fault
> going on.
> 
> > 
> > > Next problem with this solution is that it causes an
> > > interrupt storm for IO page faults to be handled when an
> > > empty page-table is assigned.
> > 
> > Also too skimpy.  I *think* this is a variant of the problem in the
> > preceding paragraph.  We get a fault storm (which is problem 2) and
> > sometimes the faulting device gives up (which is problem 1).
> > 
> > Or something.  Please de-fog all of this.
> > 
> 
> Does above explanation help understand the issue ? Given that on each
> device page fault an IRQ is trigger (well the way the hw works is bit
> more complex than that).
> 
> > > Furthermore the _start()/end() notifiers only catch the
> > > moment when page mappings are released, but not page-table
> > > pages. But this is necessary for managing external TLBs when
> > > the page-table is shared with the CPU.
> > 
> > How come?
> 
> As explained above end() might happens after page that were previously
> mapped are free or recycled.
> 
> > 
> > > To solve this situation I wrote a patch-set to introduce a
> > > new notifier call-back: mmu_notifer_invalidate_range(). This
> > > notifier lifts the strict requirements that no new
> > > references are taken in the range between _start() and
> > > _end(). When the subsystem can't guarantee that any new
> > > references are taken is has to provide the
> > > invalidate_range() call-back to clear any new references in
> > > there.
> > > 
> > > It is called between invalidate_range_start() and _end()
> > > every time the VMM has to wipe out any references to a
> > > couple of pages. This are usually the places where the CPU
> > > TLBs are flushed too and where its important that this
> > > happens before invalidate_range_end() is called.
> > > 
> > > Any comments and review appreciated!
> > 
> > The patchset looks decent, although I find it had to review because I
> > just wasn't provided with enough of the thinking that went into it.  I
> > have enough info to look at the C code, but not enough info to identify
> > and evaluate alternative implementation approaches, to identify
> > possible future extensions, etc.
> > 
> > The patchset does appear to add significant additional overhead to hot
> > code paths when mm_has_notifiers(mm).  Please let's update the
> > changelog to address this rather important concern.  How significant is
> > the impact on such mm's, how common are such mm's now and in the
> > future, should we (for example) look at short-circuiting
> > __mmu_notifier_invalidate_range() if none of the registered notifiers
> > implement ->invalidate_range(), etc.
> 
> So one might feel like just completely removing the range_start()/end()
> from the mmu_notifier and stick to this one callback but it will not work
> with other hardware like the one i am doing HMM patchset for (i send it
> again a couple weeks ago https://lkml.org/lkml/2014/8/29/423).
> 
> Right now there are very few user of the mmu_notifier, SGI, xen, KVM and
> sadly recently the GPU folks (which i am part of too). So as the GPU are
> starting to use it we will see a lot more application going through the
> mmu_notifier callback. Yet you do want to leverage the hw like GPU and
> you do want to use the same address space on the GPU as on the CPU and
> thus you do want to share or at least keep synchronize the GPU view of
> the CPU page table.
> 
> Right now, for IOMMUv2 this means adding this callback, for device that
> do not rely on ATS/PASID PCIE extension this means something like HMM.
> Also note that HMM is a superset of IOMMUv2 as it could be use at the
> same time and provide more feature mainly allowing migrating some page
> to device local memory for performances purposes.
> 
> I think this sumup all motivation behind this patchset and also behind
> my other patchset. As usual i am happy to discuss alternative way to do
> things but i think that the path of least disruption from current code
> is the one implemented by those patchset.
> 
> Cheers,
> Jerome

Hi Andrew, i wanted to touch base to see if those explanations were enough
to understand the problem we are trying to solve. Do you think the patchset
is ok or do you feel like there should be a better solution ?

Cheers,
Jerome

> 
> 
> > _______________________________________________
> > iommu mailing list
> > iommu@lists.linux-foundation.org
> > https://lists.linuxfoundation.org/mailman/listinfo/iommu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
