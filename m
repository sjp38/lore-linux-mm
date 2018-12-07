Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD0896B7F2E
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 02:16:22 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so2080572plr.8
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 23:16:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y20si2135906pgi.50.2018.12.06.23.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 23:16:21 -0800 (PST)
Date: Fri, 7 Dec 2018 08:16:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] Ext4: fix deadlock on dirty pages between fault and
 writeback
Message-ID: <20181207071615.GO1286@dhcp22.suse.cz>
References: <1540858969-75803-1-git-send-email-bo.liu@linux.alibaba.com>
 <20181127114249.GH16301@quack2.suse.cz>
 <20181128201122.r4sec265cnlxgj2x@US-160370MP2.local>
 <20181129085238.GD31087@quack2.suse.cz>
 <20181129120253.GR6311@dastard>
 <20181129130002.GM31087@quack2.suse.cz>
 <20181129204019.GS6311@dastard>
 <20181205170656.GJ30615@quack2.suse.cz>
 <20181207052051.GB6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181207052051.GB6311@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Liu Bo <bo.liu@linux.alibaba.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Fri 07-12-18 16:20:51, Dave Chinner wrote:
> On Wed, Dec 05, 2018 at 06:06:56PM +0100, Jan Kara wrote:
> > Added MM people to CC since this starts to be relevant for them.
> > 
> > On Fri 30-11-18 07:40:19, Dave Chinner wrote:
> > > On Thu, Nov 29, 2018 at 02:00:02PM +0100, Jan Kara wrote:
> > > > On Thu 29-11-18 23:02:53, Dave Chinner wrote:
> > > > > As it is, this sort of lock vs reclaim inversion should be caught by
> > > > > lockdep - allocations and reclaim contexts are recorded by lockdep
> > > > > we get reports if we do lock A - alloc and then do reclaim - lock A.
> > > > > We've always had problems with false positives from lockdep for
> > > > > these situations where common XFS code can be called from GFP_KERNEL
> > > > > valid contexts as well as reclaim or GFP_NOFS-only contexts, but I
> > > > > don't recall ever seeing such a report for the writeback path....
> > > > 
> > > > I think for A == page lock, XFS may have the problem (and lockdep won't
> > > > notice because it does not track page locks). There are some parts of
> > > > kernel which do GFP_KERNEL allocations under page lock - pte_alloc_one() is
> > > > one such function which allocates page tables with GFP_KERNEL and gets
> > > > called with the faulted page locked. And I believe there are others.
> > > 
> > > Where in direct reclaim are we doing writeback to XFS?
> > > 
> > > It doesn't happen, and I've recently proposed we remove ->writepage
> > > support from XFS altogether so that memory reclaim never, ever
> > > tries to write pages to XFS filesystems, even from kswapd.
> > 
> > Direct reclaim will never do writeback but it may still wait for writeback
> > that has been started by someone else. That is enough for the deadlock to
> > happen. But from what you write below you seem to understand that so I just
> > write this comment here so that others don't get confused.
> > 
> > > > So direct reclaim from pte_alloc_one() can wait for writeback on page B
> > > > while holding lock on page A. And if B is just prepared (added to bio,
> > > > under writeback, unlocked) but not submitted in xfs_writepages() and we
> > > > block on lock_page(A), we have a deadlock.
> > > 
> > > Fundamentally, doing GFP_KERNEL allocations with a page lock
> > > held violates any ordering rules we might have for multiple page
> > > locking order. This is asking for random ABBA reclaim deadlocks to
> > > occur, and it's not a filesystem bug - that's a bug in the page
> > > table code. e.g if we are doing this in a filesystem/page cache
> > > context, it's always in ascending page->index order for pages
> > > referenced by the inode's mapping. Memory reclaim provides none of
> > > these lock ordering guarantees.
> > 
> > So this is where I'd like MM people to tell their opinion. Reclaim code
> > tries to avoid possible deadlocks on page lock by always doing trylock on
> > the page. But as this example shows it is not enough once is blocks in
> > wait_on_page_writeback().
> 
> I think it only does this in a "legacy memcg" case, according to the
> comment in shrink_page_list. Which is, apparently, a hack around the
> fact that memcgs didn't used to have dirty page throttling. AFAIA,
> balance_dirty_pages() has had memcg-based throttling for some time
> now, so that kinda points to stale reclaim algorithms, right?

Memcg v1 indeed doesn't have any dirty IO throttling and this is a
poor's man workaround. We still do not have that AFAIK and I do not know
of an elegant way around that. Fortunatelly we shouldn't have that many
GFP_KERNEL | __GFP_ACCOUNT allocations under page lock and we can work
around this specific one quite easily. I haven't tested this yet but the
following should work

diff --git a/mm/memory.c b/mm/memory.c
index 4ad2d293ddc2..59c98eeb0260 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2993,6 +2993,16 @@ static vm_fault_t __do_fault(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	vm_fault_t ret;
 
+	/*
+	 * Preallocate pte before we take page_lock because this might lead to
+	 * deadlocks for memcg reclaim which waits for pages under writeback.
+	 */
+	if (!vmf->prealloc_pte) {
+		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm>mm, vmf->address);
+		if (!vmf->prealloc_pte)
+			return VM_FAULT_OOM;
+	}
+
 	ret = vma->vm_ops->fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
 			    VM_FAULT_DONE_COW)))

Is there any reliable reproducer?
-- 
Michal Hocko
SUSE Labs
