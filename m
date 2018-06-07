Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 274756B026D
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:40:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w1-v6so3577609pgr.7
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:40:44 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id p7-v6si34643777pgn.346.2018.06.07.07.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:40:43 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 7/9] x86/mm: Shadow stack page fault error checking
Date: Thu,  7 Jun 2018 07:37:03 -0700
Message-Id: <20180607143705.3531-8-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143705.3531-1-yu-cheng.yu@intel.com>
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

If a page fault is triggered by a shadow stack access (e.g.
call/ret) or shadow stack management instructions (e.g.
wrussq), then bit[6] of the page fault error code is set.

In access_error(), we check if a shadow stack page fault
is within a shadow stack memory area.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/traps.h |  2 ++
 arch/x86/mm/fault.c          | 11 +++++++++++
 2 files changed, 13 insertions(+)

diff --git a/arch/x86/include/asm/traps.h b/arch/x86/include/asm/traps.h
index 5196050ff3d5..58ea2f5722e9 100644
--- a/arch/x86/include/asm/traps.h
+++ b/arch/x86/include/asm/traps.h
@@ -157,6 +157,7 @@ enum {
  *   bit 3 ==				1: use of reserved bit detected
  *   bit 4 ==				1: fault was an instruction fetch
  *   bit 5 ==				1: protection keys block access
+ *   bit 6 ==				1: shadow stack access fault
  */
 enum x86_pf_error_code {
 	X86_PF_PROT	=		1 << 0,
@@ -165,5 +166,6 @@ enum x86_pf_error_code {
 	X86_PF_RSVD	=		1 << 3,
 	X86_PF_INSTR	=		1 << 4,
 	X86_PF_PK	=		1 << 5,
+	X86_PF_SHSTK	=		1 << 6,
 };
 #endif /* _ASM_X86_TRAPS_H */
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 73bd8c95ac71..2b3b9170109c 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1166,6 +1166,17 @@ access_error(unsigned long error_code, struct vm_area_struct *vma)
 				       (error_code & X86_PF_INSTR), foreign))
 		return 1;
 
+	/*
+	 * Verify X86_PF_SHSTK is within a shadow stack VMA.
+	 * It is always an error if there is a shadow stack
+	 * fault outside a shadow stack VMA.
+	 */
+	if (error_code & X86_PF_SHSTK) {
+		if (!(vma->vm_flags & VM_SHSTK))
+			return 1;
+		return 0;
+	}
+
 	if (error_code & X86_PF_WRITE) {
 		/* write, present and write, not present: */
 		if (unlikely(!(vma->vm_flags & VM_WRITE)))
-- 
2.15.1
