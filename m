Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD70A6B0008
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:42:01 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f91-v6so3699634plb.10
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:42:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u4-v6si12230541pgm.454.2018.07.24.13.42.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 13:42:00 -0700 (PDT)
Date: Tue, 24 Jul 2018 13:41:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 1/3] mm: Introduce vma_init()
Message-Id: <20180724134158.676dfa7a4da16adbab3b851c@linux-foundation.org>
In-Reply-To: <CA+55aFz1Vj3b2w-nOBdV5=WwsCYhSBprjPjGog6=_=q75Z5Z-w@mail.gmail.com>
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
	<20180724121139.62570-2-kirill.shutemov@linux.intel.com>
	<20180724130308.bbd46afc3703af4c5e1d6868@linux-foundation.org>
	<CA+55aFz1Vj3b2w-nOBdV5=WwsCYhSBprjPjGog6=_=q75Z5Z-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 24 Jul 2018 13:16:33 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Tue, Jul 24, 2018 at 1:03 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> >
> > I'd sleep better if this became a kmem_cache_alloc() and the memset
> > was moved into vma_init().
> 
> Yeah, with the vma_init(), I guess the advantage of using
> kmem_cache_zalloc() is pretty dubious.
> 
> Make it so.
> 

Did I get everything?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm: zero out the vma in vma_init()

Rather than in vm_area_alloc().  To ensure that the various oddball
stack-based vmas are in a good state.  Some of the callers were zeroing
them out, others were not.

Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/arm/kernel/process.c |    9 ++++-----
 fs/hugetlbfs/inode.c      |    2 --
 include/linux/mm.h        |    1 +
 kernel/fork.c             |    3 ++-
 mm/mempolicy.c            |    1 -
 mm/shmem.c                |    1 -
 6 files changed, 7 insertions(+), 10 deletions(-)

diff -puN arch/arm/kernel/process.c~mm-zero-out-the-vma-in-vma_init arch/arm/kernel/process.c
--- a/arch/arm/kernel/process.c~mm-zero-out-the-vma-in-vma_init
+++ a/arch/arm/kernel/process.c
@@ -330,16 +330,15 @@ unsigned long arch_randomize_brk(struct
  * atomic helpers. Insert it into the gate_vma so that it is visible
  * through ptrace and /proc/<pid>/mem.
  */
-static struct vm_area_struct gate_vma = {
-	.vm_start	= 0xffff0000,
-	.vm_end		= 0xffff0000 + PAGE_SIZE,
-	.vm_flags	= VM_READ | VM_EXEC | VM_MAYREAD | VM_MAYEXEC,
-};
+static struct vm_area_struct gate_vma;
 
 static int __init gate_vma_init(void)
 {
 	vma_init(&gate_vma, NULL);
 	gate_vma.vm_page_prot = PAGE_READONLY_EXEC;
+	gate_vma.vm_start = 0xffff0000;
+	gate_vma.vm_end	= 0xffff0000 + PAGE_SIZE;
+	gate_vma.vm_flags = VM_READ | VM_EXEC | VM_MAYREAD | VM_MAYEXEC;
 	return 0;
 }
 arch_initcall(gate_vma_init);
diff -puN fs/hugetlbfs/inode.c~mm-zero-out-the-vma-in-vma_init fs/hugetlbfs/inode.c
--- a/fs/hugetlbfs/inode.c~mm-zero-out-the-vma-in-vma_init
+++ a/fs/hugetlbfs/inode.c
@@ -410,7 +410,6 @@ static void remove_inode_hugepages(struc
 	int i, freed = 0;
 	bool truncate_op = (lend == LLONG_MAX);
 
-	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
 	vma_init(&pseudo_vma, current->mm);
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pagevec_init(&pvec);
@@ -595,7 +594,6 @@ static long hugetlbfs_fallocate(struct f
 	 * allocation routines.  If NUMA is configured, use page index
 	 * as input to create an allocation policy.
 	 */
-	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
 	vma_init(&pseudo_vma, mm);
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pseudo_vma.vm_file = file;
diff -puN include/linux/mm.h~mm-zero-out-the-vma-in-vma_init include/linux/mm.h
--- a/include/linux/mm.h~mm-zero-out-the-vma-in-vma_init
+++ a/include/linux/mm.h
@@ -456,6 +456,7 @@ static inline void vma_init(struct vm_ar
 {
 	static const struct vm_operations_struct dummy_vm_ops = {};
 
+	memset(vma, 0, sizeof(*vma));
 	vma->vm_mm = mm;
 	vma->vm_ops = &dummy_vm_ops;
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
diff -puN kernel/fork.c~mm-zero-out-the-vma-in-vma_init kernel/fork.c
--- a/kernel/fork.c~mm-zero-out-the-vma-in-vma_init
+++ a/kernel/fork.c
@@ -310,8 +310,9 @@ static struct kmem_cache *mm_cachep;
 
 struct vm_area_struct *vm_area_alloc(struct mm_struct *mm)
 {
-	struct vm_area_struct *vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	struct vm_area_struct *vma;
 
+	vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (vma)
 		vma_init(vma, mm);
 	return vma;
diff -puN mm/mempolicy.c~mm-zero-out-the-vma-in-vma_init mm/mempolicy.c
--- a/mm/mempolicy.c~mm-zero-out-the-vma-in-vma_init
+++ a/mm/mempolicy.c
@@ -2504,7 +2504,6 @@ void mpol_shared_policy_init(struct shar
 			goto put_new;
 
 		/* Create pseudo-vma that contains just the policy */
-		memset(&pvma, 0, sizeof(struct vm_area_struct));
 		vma_init(&pvma, NULL);
 		pvma.vm_end = TASK_SIZE;	/* policy covers entire file */
 		mpol_set_shared_policy(sp, &pvma, new); /* adds ref */
diff -puN mm/shmem.c~mm-zero-out-the-vma-in-vma_init mm/shmem.c
--- a/mm/shmem.c~mm-zero-out-the-vma-in-vma_init
+++ a/mm/shmem.c
@@ -1421,7 +1421,6 @@ static void shmem_pseudo_vma_init(struct
 		struct shmem_inode_info *info, pgoff_t index)
 {
 	/* Create a pseudo vma that just contains the policy */
-	memset(vma, 0, sizeof(*vma));
 	vma_init(vma, NULL);
 	/* Bias interleave by inode number to distribute better across nodes */
 	vma->vm_pgoff = index + info->vfs_inode.i_ino;
_
