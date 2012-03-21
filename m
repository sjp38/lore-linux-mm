Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 6F15A6B00EF
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:56:49 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:56:48 -0700 (PDT)
Subject: [PATCH 08/16] mm/unicore32: use vm_flags_t for vma flags
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:56:46 +0400
Message-ID: <20120321065645.13852.83925.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-kernel@vger.kernel.org

The same magic like in arm: assembler code wants to test VM_EXEC,
but for big-endian we should get upper word for this.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
---
 arch/unicore32/kernel/asm-offsets.c |    6 +++++-
 arch/unicore32/mm/fault.c           |    2 +-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/unicore32/kernel/asm-offsets.c b/arch/unicore32/kernel/asm-offsets.c
index ffcbe75..e3199b5 100644
--- a/arch/unicore32/kernel/asm-offsets.c
+++ b/arch/unicore32/kernel/asm-offsets.c
@@ -87,9 +87,13 @@ int main(void)
 	DEFINE(S_FRAME_SIZE,	sizeof(struct pt_regs));
 	BLANK();
 	DEFINE(VMA_VM_MM,	offsetof(struct vm_area_struct, vm_mm));
+#if defined(CONFIG_CPU_BIG_ENDIAN) && (NR_VMA_FLAGS > 32)
+	DEFINE(VMA_VM_FLAGS,	offsetof(struct vm_area_struct, vm_flags) + 4);
+#else
 	DEFINE(VMA_VM_FLAGS,	offsetof(struct vm_area_struct, vm_flags));
+#endif
 	BLANK();
-	DEFINE(VM_EXEC,		VM_EXEC);
+	DEFINE(VM_EXEC,		(__force unsigned int)VM_EXEC);
 	BLANK();
 	DEFINE(PAGE_SZ,		PAGE_SIZE);
 	BLANK();
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 283aa4b..9137996 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -158,7 +158,7 @@ void do_bad_area(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
  */
 static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 {
-	unsigned int mask = VM_READ | VM_WRITE | VM_EXEC;
+	vm_flags_t mask = VM_READ | VM_WRITE | VM_EXEC;
 
 	if (!(fsr ^ 0x12))	/* write? */
 		mask = VM_WRITE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
