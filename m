Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1C2D6B42D1
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:35:01 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w1so5145441qta.12
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:35:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e24si690728qtp.141.2018.11.26.09.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 09:35:00 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 5/5] userfaultfd: shmem: UFFDIO_COPY: set the page dirty if VM_WRITE is not set
Date: Mon, 26 Nov 2018 12:34:52 -0500
Message-Id: <20181126173452.26955-6-aarcange@redhat.com>
In-Reply-To: <20181126173452.26955-1-aarcange@redhat.com>
References: <20181126173452.26955-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

Set the page dirty if VM_WRITE is not set because in such case the pte
won't be marked dirty and the page would be reclaimed without
writepage (i.e. swapout in the shmem case).

This was found by source review. Most apps (certainly including QEMU)
only use UFFDIO_COPY on PROT_READ|PROT_WRITE mappings or the app can't
modify the memory in the first place. This is for correctness and it
could help the non cooperative use case to avoid unexpected data loss.

Reviewed-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
Fixes: 4c27fe4c4c84 ("userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support")
Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/shmem.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index c3ece7a51949..82a381d463bc 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2272,6 +2272,16 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
 	if (dst_vma->vm_flags & VM_WRITE)
 		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
+	else {
+		/*
+		 * We don't set the pte dirty if the vma has no
+		 * VM_WRITE permission, so mark the page dirty or it
+		 * could be freed from under us. We could do it
+		 * unconditionally before unlock_page(), but doing it
+		 * only if VM_WRITE is not set is faster.
+		 */
+		set_page_dirty(page);
+	}
 
 	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
 
@@ -2305,6 +2315,7 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 	return ret;
 out_release_uncharge_unlock:
 	pte_unmap_unlock(dst_pte, ptl);
+	ClearPageDirty(page);
 	delete_from_page_cache(page);
 out_release_uncharge:
 	mem_cgroup_cancel_charge(page, memcg, false);
