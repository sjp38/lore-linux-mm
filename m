Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0027C8E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 03:49:52 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so2436816edz.15
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 00:49:52 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m23si1902794eda.188.2018.12.14.00.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 00:49:51 -0800 (PST)
Date: Fri, 14 Dec 2018 09:49:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm, memcg: fix reclaim deadlock with writeback
Message-ID: <20181214084948.GA5624@dhcp22.suse.cz>
References: <20181212155055.1269-1-mhocko@kernel.org>
 <20181213092221.27270-1-mhocko@kernel.org>
 <20181213220400.GA9829@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213220400.GA9829@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Liu Bo <bo.liu@linux.alibaba.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>, Stable tree <stable@vger.kernel.org>

On Thu 13-12-18 17:04:00, Johannes Weiner wrote:
[...]
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!

> Just one nit:
> 
> > @@ -2993,6 +2993,17 @@ static vm_fault_t __do_fault(struct vm_fault *vmf)
> >  	struct vm_area_struct *vma = vmf->vma;
> >  	vm_fault_t ret;
> >  
> > +	/*
> > +	 * Preallocate pte before we take page_lock because this might lead to
> > +	 * deadlocks for memcg reclaim which waits for pages under writeback.
> > +	 */
> > +	if (pmd_none(*vmf->pmd) && !vmf->prealloc_pte) {
> > +		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm_mm, vmf->address);
> > +		if (!vmf->prealloc_pte)
> > +			return VM_FAULT_OOM;
> > +		smp_wmb(); /* See comment in __pte_alloc() */
> > +	}
> 
> Could you be more specific in the deadlock comment? git blame will
> work fine for a while, but it becomes a pain to find corresponding
> patches after stuff gets moved around for years.
> 
> In particular the race diagram between reclaim with a page lock held
> and the fs doing SetPageWriteback batches before kicking off IO would
> be useful directly in the code, IMO.

This?

diff --git a/mm/memory.c b/mm/memory.c
index bb78e90a9b70..ece221e4da6d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2995,7 +2995,18 @@ static vm_fault_t __do_fault(struct vm_fault *vmf)
 
 	/*
 	 * Preallocate pte before we take page_lock because this might lead to
-	 * deadlocks for memcg reclaim which waits for pages under writeback.
+	 * deadlocks for memcg reclaim which waits for pages under writeback:
+	 * 				lock_page(A)
+	 * 				SetPageWriteback(A)
+	 * 				unlock_page(A)
+	 * lock_page(B)
+	 * 				lock_page(B)
+	 * pte_alloc_pne
+	 *   shrink_page_list
+	 *     wait_on_page_writeback(A)
+	 *     				SetPageWriteback(B)
+	 *     				unlock_page(B)
+	 *     				# flush A, B to clear the writeback
 	 */
 	if (pmd_none(*vmf->pmd) && !vmf->prealloc_pte) {
 		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm_mm, vmf->address);
-- 
Michal Hocko
SUSE Labs
