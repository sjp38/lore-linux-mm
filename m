Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7F27C82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 19:54:52 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id 186so205565704iow.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 16:54:52 -0800 (PST)
Received: from g2t2355.austin.hp.com (g2t2355.austin.hp.com. [15.217.128.54])
        by mx.google.com with ESMTPS id h18si36930267igt.85.2015.12.22.16.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 16:54:50 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 1/2] x86/mm/pat: Add untrack_pfn_moved for mremap
Date: Tue, 22 Dec 2015 17:54:23 -0700
Message-Id: <1450832064-10093-2-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1450832064-10093-1-git-send-email-toshi.kani@hpe.com>
References: <1450832064-10093-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@alien8.de
Cc: stsp@list.ru, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>

mremap() with MREMAP_FIXED on a VM_PFNMAP range causes the following
WARN_ON_ONCE() message in untrack_pfn().

  WARNING: CPU: 1 PID: 3493 at arch/x86/mm/pat.c:985 untrack_pfn+0xbd/0xd0()
  Call Trace:
  [<ffffffff817729ea>] dump_stack+0x45/0x57
  [<ffffffff8109e4b6>] warn_slowpath_common+0x86/0xc0
  [<ffffffff8109e5ea>] warn_slowpath_null+0x1a/0x20
  [<ffffffff8106a88d>] untrack_pfn+0xbd/0xd0
  [<ffffffff811d2d5e>] unmap_single_vma+0x80e/0x860
  [<ffffffff811d3725>] unmap_vmas+0x55/0xb0
  [<ffffffff811d916c>] unmap_region+0xac/0x120
  [<ffffffff811db86a>] do_munmap+0x28a/0x460
  [<ffffffff811dec33>] move_vma+0x1b3/0x2e0
  [<ffffffff811df113>] SyS_mremap+0x3b3/0x510
  [<ffffffff817793ee>] entry_SYSCALL_64_fastpath+0x12/0x71

MREMAP_FIXED moves a pfnmap from old vma to new vma.  untrack_pfn() is
called with the old vma after its pfnmap page table has been removed,
which causes follow_phys() to fail.  The new vma has a new pfnmap to
the same pfn & cache type with VM_PAT set.  Therefore, we only need to
clear VM_PAT from the old vma in this case.

Add untrack_pfn_moved(), which clears VM_PAT from a given old vma.
move_vma() is changed to call this function with the old vma when
VM_PFNMAP is set.  move_vma() then calls do_munmap(), and untrack_pfn()
is a no-op since VM_PAT is cleared.

Link: http://lkml.kernel.org/r/<1446072663.20657.150.camel@hpe.com>
Reported-by: Stas Sergeev <stsp@list.ru>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Borislav Petkov <bp@suse.de>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 arch/x86/mm/pat.c             |   10 ++++++++++
 include/asm-generic/pgtable.h |   10 +++++++++-
 mm/mremap.c                   |    4 ++++
 3 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 188e3e0..1aca073 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -992,6 +992,16 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 	vma->vm_flags &= ~VM_PAT;
 }
 
+/*
+ * untrack_pfn_moved is called, while mremapping a pfnmap for a new region,
+ * with the old vma after its pfnmap page table has been removed.  The new
+ * vma has a new pfnmap to the same pfn & cache type with VM_PAT set.
+ */
+void untrack_pfn_moved(struct vm_area_struct *vma)
+{
+	vma->vm_flags &= ~VM_PAT;
+}
+
 pgprot_t pgprot_writecombine(pgprot_t prot)
 {
 	return __pgprot(pgprot_val(prot) |
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 14b0ff32..3a6803c 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -569,7 +569,7 @@ static inline int track_pfn_copy(struct vm_area_struct *vma)
 }
 
 /*
- * untrack_pfn_vma is called while unmapping a pfnmap for a region.
+ * untrack_pfn is called while unmapping a pfnmap for a region.
  * untrack can be called for a specific region indicated by pfn and size or
  * can be for the entire vma (in which case pfn, size are zero).
  */
@@ -577,6 +577,13 @@ static inline void untrack_pfn(struct vm_area_struct *vma,
 			       unsigned long pfn, unsigned long size)
 {
 }
+
+/*
+ * untrack_pfn_moved is called while mremapping a pfnmap for a new region.
+ */
+static inline void untrack_pfn_moved(struct vm_area_struct *vma)
+{
+}
 #else
 extern int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 			   unsigned long pfn, unsigned long addr,
@@ -586,6 +593,7 @@ extern int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 extern int track_pfn_copy(struct vm_area_struct *vma);
 extern void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 			unsigned long size);
+extern void untrack_pfn_moved(struct vm_area_struct *vma);
 #endif
 
 #ifdef __HAVE_COLOR_ZERO_PAGE
diff --git a/mm/mremap.c b/mm/mremap.c
index c25bc62..de824e7 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -319,6 +319,10 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	hiwater_vm = mm->hiwater_vm;
 	vm_stat_account(mm, vma->vm_flags, vma->vm_file, new_len>>PAGE_SHIFT);
 
+	/* Tell pfnmap has moved from this vma */
+	if (unlikely(vma->vm_flags & VM_PFNMAP))
+		untrack_pfn_moved(vma);
+
 	if (do_munmap(mm, old_addr, old_len) < 0) {
 		/* OOM: unable to split vma, just get accounts right */
 		vm_unacct_memory(excess >> PAGE_SHIFT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
