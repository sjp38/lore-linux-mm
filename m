Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8527A6B0257
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 11:26:21 -0500 (EST)
Received: by oixx65 with SMTP id x65so29390483oix.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 08:26:21 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id 62si9076378oid.142.2015.12.09.08.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 08:26:20 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 1/2] x86/mm/pat: Change untrack_pfn() to handle unmapped vma
Date: Wed,  9 Dec 2015 09:26:07 -0700
Message-Id: <1449678368-31793-2-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1449678368-31793-1-git-send-email-toshi.kani@hpe.com>
References: <1449678368-31793-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@alien8.de
Cc: stsp@list.ru, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>, Borislav Petkov <bp@suse.de>

mremap() with MREMAP_FIXED, remapping to a new virtual address, on
a VM_PFNMAP range causes the following WARN_ON_ONCE() message in
untrack_pfn().

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

MREMAP_FIXED moves a virtual address of VM_PFNMAP, but keeps the pfn
and cache type.  In this case, untrack_pfn() is called with the old
vma after its translation has removed.  Hence, when follow_phys()
fails, track_pfn() is changed to keep the pfn tracked and clears
VM_PAT from the old vma, instead of WARN_ON_ONCE() on the case.

Reference: https://lkml.org/lkml/2015/10/28/865
Reported-by: Stas Sergeev <stsp@list.ru>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Borislav Petkov <bp@suse.de>
---
 arch/x86/mm/pat.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 188e3e0..f3e391e 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -966,8 +966,14 @@ int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 
 /*
  * untrack_pfn is called while unmapping a pfnmap for a region.
- * untrack can be called for a specific region indicated by pfn and size or
- * can be for the entire vma (in which case pfn, size are zero).
+ * untrack_pfn can be called for a specific region indicated by pfn and
+ * size or can be for the entire vma (in which case pfn, size are zero).
+ *
+ * NOTE: mremap may move a virtual address of VM_PFNMAP, but keeps the
+ * pfn and cache type.  In this case, untrack_pfn() is called with the
+ * old vma after its translation has removed.  Hence, when follow_phys()
+ * fails, track_pfn() keeps the pfn tracked and clears VM_PAT from the
+ * old vma.
  */
 void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 		 unsigned long size)
@@ -981,14 +987,13 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 	/* free the chunk starting from pfn or the whole chunk */
 	paddr = (resource_size_t)pfn << PAGE_SHIFT;
 	if (!paddr && !size) {
-		if (follow_phys(vma, vma->vm_start, 0, &prot, &paddr)) {
-			WARN_ON_ONCE(1);
-			return;
-		}
+		if (follow_phys(vma, vma->vm_start, 0, &prot, &paddr))
+			goto out;
 
 		size = vma->vm_end - vma->vm_start;
 	}
 	free_pfn_range(paddr, size);
+out:
 	vma->vm_flags &= ~VM_PAT;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
