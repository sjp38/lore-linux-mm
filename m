Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5638E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 23:18:39 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id p4so28163060pgj.21
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 20:18:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s8si1902986pgl.503.2019.01.02.20.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 20:18:37 -0800 (PST)
Date: Wed, 2 Jan 2019 20:18:33 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103041833.GN6310@bombadil.infradead.org>
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103015654.GB15619@redhat.com>
 <785af237-eb67-c304-595d-9080a2f48102@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <785af237-eb67-c304-595d-9080a2f48102@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>

On Wed, Jan 02, 2019 at 07:32:08PM -0800, John Hubbard wrote:
> Having the range struct declared in separate places from the mmu_notifier_range_init()
> calls is not great. But I'm not sure I see a way to make it significantly cleaner, given
> that __follow_pte_pmd uses the range pointer as a way to decide to issue the mmn calls.

Yeah, I don't think there's anything we can do.  But I started reviewing
the comments, and they don't make sense together:

                /*
                 * Note because we provide range to follow_pte_pmd it will
                 * call mmu_notifier_invalidate_range_start() on our behalf
                 * before taking any lock.
                 */
                if (follow_pte_pmd(vma->vm_mm, address, &range,
                                   &ptep, &pmdp, &ptl))
                        continue;

                /*
                 * No need to call mmu_notifier_invalidate_range() as we are
                 * downgrading page table protection not changing it to point
                 * to a new page.
                 *
                 * See Documentation/vm/mmu_notifier.rst
                 */

So if we don't call mmu_notifier_invalidate_range, why are we calling
mmu_notifier_invalidate_range_start and mmu_notifier_invalidate_range_end?
ie, why not this ...

diff --git a/fs/dax.c b/fs/dax.c
index 6959837cc465..905340149924 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -777,7 +777,6 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
 
 	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, index, index) {
-		struct mmu_notifier_range range;
 		unsigned long address;
 
 		cond_resched();
@@ -787,12 +786,7 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
 
 		address = pgoff_address(index, vma);
 
-		/*
-		 * Note because we provide start/end to follow_pte_pmd it will
-		 * call mmu_notifier_invalidate_range_start() on our behalf
-		 * before taking any lock.
-		 */
-		if (follow_pte_pmd(vma->vm_mm, address, &range,
+		if (follow_pte_pmd(vma->vm_mm, address, NULL,
 				   &ptep, &pmdp, &ptl))
 			continue;
 
@@ -834,8 +828,6 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
 unlock_pte:
 			pte_unmap_unlock(ptep, ptl);
 		}
-
-		mmu_notifier_invalidate_range_end(&range);
 	}
 	i_mmap_unlock_read(mapping);
 }
