Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A0B736B000D
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:10 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p11so512291wrd.20
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:34:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d40si498267edb.7.2018.04.17.07.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:34:09 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HESvdA100703
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:08 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hdhth370p-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:07 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:34:04 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 07/25] mm: introduce INIT_VMA()
Date: Tue, 17 Apr 2018 16:33:13 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-8-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Some VMA struct fields need to be initialized once the VMA structure is
allocated.
Currently this only concerns anon_vma_chain field but some other will be
added to support the speculative page fault.

Instead of spreading the initialization calls all over the code, let's
introduce a dedicated inline function.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 fs/exec.c          |  2 +-
 include/linux/mm.h |  5 +++++
 kernel/fork.c      |  2 +-
 mm/mmap.c          | 10 +++++-----
 mm/nommu.c         |  2 +-
 5 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 32eea4c65909..bd03689aa358 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -311,7 +311,7 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	vma->vm_start = vma->vm_end - PAGE_SIZE;
 	vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
-	INIT_LIST_HEAD(&vma->anon_vma_chain);
+	INIT_VMA(vma);
 
 	err = insert_vm_struct(mm, vma);
 	if (err)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 714da99d77a3..efc1248b82bd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1261,6 +1261,11 @@ struct zap_details {
 	pgoff_t last_index;			/* Highest page->index to unmap */
 };
 
+static inline void INIT_VMA(struct vm_area_struct *vma)
+{
+	INIT_LIST_HEAD(&vma->anon_vma_chain);
+}
+
 struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			     pte_t pte, bool with_public_device);
 #define vm_normal_page(vma, addr, pte) _vm_normal_page(vma, addr, pte, false)
diff --git a/kernel/fork.c b/kernel/fork.c
index b1d877f1a0ac..d937e5945f77 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -451,7 +451,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		if (!tmp)
 			goto fail_nomem;
 		*tmp = *mpnt;
-		INIT_LIST_HEAD(&tmp->anon_vma_chain);
+		INIT_VMA(tmp);
 		retval = vma_dup_policy(mpnt, tmp);
 		if (retval)
 			goto fail_nomem_policy;
diff --git a/mm/mmap.c b/mm/mmap.c
index 188f195883b9..8bd9ae1dfacc 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1700,7 +1700,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	vma->vm_flags = vm_flags;
 	vma->vm_page_prot = vm_get_page_prot(vm_flags);
 	vma->vm_pgoff = pgoff;
-	INIT_LIST_HEAD(&vma->anon_vma_chain);
+	INIT_VMA(vma);
 
 	if (file) {
 		if (vm_flags & VM_DENYWRITE) {
@@ -2586,7 +2586,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* most fields are the same, copy all, and then fixup */
 	*new = *vma;
 
-	INIT_LIST_HEAD(&new->anon_vma_chain);
+	INIT_VMA(new);
 
 	if (new_below)
 		new->vm_end = addr;
@@ -2956,7 +2956,7 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 		return -ENOMEM;
 	}
 
-	INIT_LIST_HEAD(&vma->anon_vma_chain);
+	INIT_VMA(vma);
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
@@ -3167,7 +3167,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		new_vma->vm_pgoff = pgoff;
 		if (vma_dup_policy(vma, new_vma))
 			goto out_free_vma;
-		INIT_LIST_HEAD(&new_vma->anon_vma_chain);
+		INIT_VMA(new_vma);
 		if (anon_vma_clone(new_vma, vma))
 			goto out_free_mempol;
 		if (new_vma->vm_file)
@@ -3310,7 +3310,7 @@ static struct vm_area_struct *__install_special_mapping(
 	if (unlikely(vma == NULL))
 		return ERR_PTR(-ENOMEM);
 
-	INIT_LIST_HEAD(&vma->anon_vma_chain);
+	INIT_VMA(vma);
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
diff --git a/mm/nommu.c b/mm/nommu.c
index 13723736d38f..6909ea0bf88d 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1212,7 +1212,7 @@ unsigned long do_mmap(struct file *file,
 	region->vm_flags = vm_flags;
 	region->vm_pgoff = pgoff;
 
-	INIT_LIST_HEAD(&vma->anon_vma_chain);
+	INIT_VMA(vma);
 	vma->vm_flags = vm_flags;
 	vma->vm_pgoff = pgoff;
 
-- 
2.7.4
