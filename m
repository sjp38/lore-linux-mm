Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE686B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:38:04 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so33010268wia.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:38:04 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id eh6si4355634wib.92.2015.03.26.10.38.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 10:38:02 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 26 Mar 2015 17:38:01 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4F50217D8062
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 17:38:24 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2QHbtI48061410
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 17:37:56 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2QHbt36032151
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:37:55 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v4 1/2] mm: Introducing arch_remap hook
Date: Thu, 26 Mar 2015 18:37:52 +0100
Message-Id: <fe0cafd7f98ce8cdd4b695de55a8c22dd903e334.1427390952.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1427390952.git.ldufour@linux.vnet.ibm.com>
References: <cover.1427390952.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1427390952.git.ldufour@linux.vnet.ibm.com>
References: <20150326141730.GA23060@gmail.com> <cover.1427390952.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: cov@codeaurora.org, criu@openvz.org

Some architecture would like to be triggered when a memory area is moved
through the mremap system call.

This patch is introducing a new arch_remap mm hook which is placed in the
path of mremap, and is called before the old area is unmapped (and the
arch_unmap hook is called).

The architectures which need to call this hook should define
__HAVE_ARCH_REMAP in their asm/mmu_context.h and provide the arch_remap
service with the following prototype:
void arch_remap(struct mm_struct *mm,
                unsigned long old_start, unsigned long old_end,
                unsigned long new_start, unsigned long new_end);

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/mremap.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 57dadc025c64..bafc234db45c 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -25,6 +25,7 @@
 
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
+#include <asm/mmu_context.h>
 
 #include "internal.h"
 
@@ -286,8 +287,14 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		old_len = new_len;
 		old_addr = new_addr;
 		new_addr = -ENOMEM;
-	} else if (vma->vm_file && vma->vm_file->f_op->mremap)
-		vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
+	} else {
+		if (vma->vm_file && vma->vm_file->f_op->mremap)
+			vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
+#ifdef __HAVE_ARCH_REMAP
+		arch_remap(mm, old_addr, old_addr+old_len,
+			   new_addr, new_addr+new_len);
+#endif
+	}
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
 	if (vm_flags & VM_ACCOUNT) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
