Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id C438F8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 17:09:09 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k10-v6so366561qtb.8
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 14:09:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z204-v6sor56538qka.18.2018.09.26.14.09.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 14:09:08 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 5/9] mm: drop the mmap_sem in all read fault cases
Date: Wed, 26 Sep 2018 17:08:52 -0400
Message-Id: <20180926210856.7895-6-josef@toxicpanda.com>
In-Reply-To: <20180926210856.7895-1-josef@toxicpanda.com>
References: <20180926210856.7895-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, tj@kernel.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, riel@redhat.com, linux-mm@kvack.org, linux-btrfs@vger.kernel.org

Johannes' patches didn't quite cover all of the IO cases that we need to
drop the mmap_sem for, this patch covers the rest of them.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/filemap.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 1ed35cd99b2c..65395ee132a0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2523,6 +2523,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	int error;
 	struct mm_struct *mm = vmf->vma->vm_mm;
 	struct file *file = vmf->vma->vm_file;
+	struct file *fpin = NULL;
 	struct address_space *mapping = file->f_mapping;
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
@@ -2610,11 +2611,15 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	return ret | VM_FAULT_LOCKED;
 
 no_cached_page:
+	fpin = maybe_unlock_mmap_for_io(vmf->vma, vmf->flags);
+
 	/*
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
 	 */
 	error = page_cache_read(file, offset, vmf->gfp_mask);
+	if (fpin)
+		goto out_retry;
 
 	/*
 	 * The page we want has now been added to the page cache.
@@ -2634,6 +2639,8 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	return VM_FAULT_SIGBUS;
 
 page_not_uptodate:
+	fpin = maybe_unlock_mmap_for_io(vmf->vma, vmf->flags);
+
 	/*
 	 * Umm, take care of errors if the page isn't up-to-date.
 	 * Try to re-read it _once_. We do this synchronously,
@@ -2647,6 +2654,8 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		if (!PageUptodate(page))
 			error = -EIO;
 	}
+	if (fpin)
+		goto out_retry;
 	put_page(page);
 
 	if (!error || error == AOP_TRUNCATED_PAGE)
@@ -2665,6 +2674,8 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	}
 
 out_retry:
+	if (fpin)
+		fput(fpin);
 	if (page)
 		put_page(page);
 	return ret | VM_FAULT_RETRY;
-- 
2.14.3
