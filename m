Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3EFB6B026B
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 15:16:16 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a3-v6so950899pgv.10
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 12:16:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n7-v6si20052667pgp.411.2018.08.15.12.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 Aug 2018 12:16:15 -0700 (PDT)
Date: Wed, 15 Aug 2018 12:16:06 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in
 munmap
Message-ID: <20180815191606.GA4201@bombadil.infradead.org>
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 16, 2018 at 02:49:48AM +0800, Yang Shi wrote:
> +static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
> +			       size_t len, struct list_head *uf)
> +{
> +	unsigned long end;
> +	struct vm_area_struct *start_vma, *prev, *vma;
> +	int ret = 0;
> +
> +	if (!addr_ok(start, len))
> +		return -EINVAL;
> +
> +	len = PAGE_ALIGN(len);
> +
> +	end = start + len;
> +
> +	/*
> +	 * Need write mmap_sem to split vmas and detach vmas
> +	 * splitting vma up-front to save PITA to clean if it is failed
> +	 */
> +	if (down_write_killable(&mm->mmap_sem))
> +		return -EINTR;
> +
> +	start_vma = munmap_lookup_vma(mm, start, end);
> +	if (!start_vma)
> +		goto out;
> +	if (IS_ERR(start_vma)) {
> +		ret = PTR_ERR(start_vma);
> +		goto out;
> +	}
> +
> +	prev = start_vma->vm_prev;
> +
> +	if (unlikely(uf)) {
> +		ret = userfaultfd_unmap_prep(start_vma, start, end, uf);
> +		if (ret)
> +			goto out;
> +	}
> +
> +	/*
> +	 * Unmapping vmas, which have:
> +	 *   VM_HUGETLB or
> +	 *   VM_PFNMAP or
> +	 *   uprobes
> +	 * need get done with write mmap_sem held since they may update
> +	 * vm_flags. Deal with such mappings with regular do_munmap() call.
> +	 */
> +	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
> +		if ((vma->vm_file &&
> +		    has_uprobes(vma, vma->vm_start, vma->vm_end)) ||
> +		    (vma->vm_flags & (VM_HUGETLB | VM_PFNMAP)))
> +			goto regular_path;

but ... that's going to redo all the work you already did!  Why not just this:

(not even compiled, and I can see a good opportunity for combining the
VM_LOCKED loop with the has_uprobes loop)

diff --git a/mm/mmap.c b/mm/mmap.c
index de699523c0b7..8d121db36efc 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2803,6 +2803,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
+	int res = 0;
+	bool downgrade = false;
 
 	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE-start)
 		return -EINVAL;
@@ -2811,17 +2813,20 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	if (len == 0)
 		return -EINVAL;
 
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
 	/* Find the first overlapping VMA */
 	vma = find_vma(mm, start);
 	if (!vma)
-		return 0;
+		goto unlock;
 	prev = vma->vm_prev;
-	/* we have  start < vma->vm_end  */
+	/* we have start < vma->vm_end  */
 
 	/* if it doesn't overlap, we have nothing.. */
 	end = start + len;
 	if (vma->vm_start >= end)
-		return 0;
+		goto unlock;
 
 	/*
 	 * If we need to split any vma, do it now to save pain later.
@@ -2831,28 +2836,27 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	 * places tmp vma above, and higher split_vma places tmp vma below.
 	 */
 	if (start > vma->vm_start) {
-		int error;
-
 		/*
 		 * Make sure that map_count on return from munmap() will
 		 * not exceed its limit; but let map_count go just above
 		 * its limit temporarily, to help free resources as expected.
 		 */
+		res = -ENOMEM
 		if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
-			return -ENOMEM;
+			goto unlock;
 
-		error = __split_vma(mm, vma, start, 0);
-		if (error)
-			return error;
+		res = __split_vma(mm, vma, start, 0);
+		if (res)
+			goto unlock;
 		prev = vma;
 	}
 
 	/* Does it split the last one? */
 	last = find_vma(mm, end);
 	if (last && end > last->vm_start) {
-		int error = __split_vma(mm, last, end, 1);
-		if (error)
-			return error;
+		res = __split_vma(mm, last, end, 1);
+		if (res)
+			goto unlock;
 	}
 	vma = prev ? prev->vm_next : mm->mmap;
 
@@ -2866,9 +2870,19 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 		 * split, despite we could. This is unlikely enough
 		 * failure that it's not worth optimizing it for.
 		 */
-		int error = userfaultfd_unmap_prep(vma, start, end, uf);
-		if (error)
-			return error;
+		result = userfaultfd_unmap_prep(vma, start, end, uf);
+		if (result)
+			goto unlock;
+	}
+
+	downgrade = true;
+
+	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
+		if (vma->vm_file &&
+				has_uprobes(vma, vma->vm_start, vma->vm_end)) {
+			downgrade = false;
+			break;
+		}
 	}
 
 	/*
@@ -2885,6 +2899,9 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 		}
 	}
 
+	if (downgrade)
+		downgrade_write(&mm->mmap_sem);
+
 	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
@@ -2896,7 +2913,14 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	/* Fix up all other VM information */
 	remove_vma_list(mm, vma);
 
-	return 0;
+	res = 0;
+unlock:
+	if (downgrade) {
+		up_read(&mm->mmap_sem);
+	} else {
+		up_write(&mm->mmap_sem);
+	}
+	return res;
 }
 
 int vm_munmap(unsigned long start, size_t len)
@@ -2905,11 +2929,7 @@ int vm_munmap(unsigned long start, size_t len)
 	struct mm_struct *mm = current->mm;
 	LIST_HEAD(uf);
 
-	if (down_write_killable(&mm->mmap_sem))
-		return -EINTR;
-
 	ret = do_munmap(mm, start, len, &uf);
-	up_write(&mm->mmap_sem);
 	userfaultfd_unmap_complete(mm, &uf);
 	return ret;
 }
