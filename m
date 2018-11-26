Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A75716B42CE
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:35:00 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q33so16965042qte.23
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:35:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t7si693925qtd.217.2018.11.26.09.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 09:34:59 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/5] userfaultfd: shmem: allocate anonymous memory for MAP_PRIVATE shmem
Date: Mon, 26 Nov 2018 12:34:49 -0500
Message-Id: <20181126173452.26955-3-aarcange@redhat.com>
In-Reply-To: <20181126173452.26955-1-aarcange@redhat.com>
References: <20181126173452.26955-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

Userfaultfd did not create private memory when UFFDIO_COPY was invoked
on a MAP_PRIVATE shmem mapping. Instead it wrote to the shmem file,
even when that had not been opened for writing. Though, fortunately,
that could only happen where there was a hole in the file.

Fix the shmem-backed implementation of UFFDIO_COPY to create private
memory for MAP_PRIVATE mappings. The hugetlbfs-backed implementation
was already correct.

This change is visible to userland, if userfaultfd has been used in
unintended ways: so it introduces a small risk of incompatibility, but
is necessary in order to respect file permissions.

An app that uses UFFDIO_COPY for anything like postcopy live migration
won't notice the difference, and in fact it'll run faster because
there will be no copy-on-write and memory waste in the tmpfs pagecache
anymore.

Userfaults on MAP_PRIVATE shmem keep triggering only on file holes
like before.

The real zeropage can also be built on a MAP_PRIVATE shmem mapping
through UFFDIO_ZEROPAGE and that's safe because the zeropage pte is
never dirty, in turn even an mprotect upgrading the vma permission
from PROT_READ to PROT_READ|PROT_WRITE won't make the zeropage pte
writable.

Reported-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
Fixes: 4c27fe4c4c84 ("userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support")
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/userfaultfd.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 46c8949e5f8f..471b6457f95f 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -380,7 +380,17 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
 {
 	ssize_t err;
 
-	if (vma_is_anonymous(dst_vma)) {
+	/*
+	 * The normal page fault path for a shmem will invoke the
+	 * fault, fill the hole in the file and COW it right away. The
+	 * result generates plain anonymous memory. So when we are
+	 * asked to fill an hole in a MAP_PRIVATE shmem mapping, we'll
+	 * generate anonymous memory directly without actually filling
+	 * the hole. For the MAP_PRIVATE case the robustness check
+	 * only happens in the pagetable (to verify it's still none)
+	 * and not in the radix tree.
+	 */
+	if (!(dst_vma->vm_flags & VM_SHARED)) {
 		if (!zeropage)
 			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
 					       dst_addr, src_addr, page);
@@ -489,7 +499,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 * dst_vma.
 	 */
 	err = -ENOMEM;
-	if (vma_is_anonymous(dst_vma) && unlikely(anon_vma_prepare(dst_vma)))
+	if (!(dst_vma->vm_flags & VM_SHARED) &&
+	    unlikely(anon_vma_prepare(dst_vma)))
 		goto out_unlock;
 
 	while (src_addr < src_start + len) {
