Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0396B0261
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:36:44 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so249647245pfb.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:36:44 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00122.outbound.protection.outlook.com. [40.107.0.122])
        by mx.google.com with ESMTPS id d9si21450222pgg.146.2017.01.16.04.36.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 04:36:43 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 3/5] x86/mm: fix native mmap() in compat bins and vice-versa
Date: Mon, 16 Jan 2017 15:33:08 +0300
Message-ID: <20170116123310.22697-4-dsafonov@virtuozzo.com>
In-Reply-To: <20170116123310.22697-1-dsafonov@virtuozzo.com>
References: <20170116123310.22697-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

Fix 32-bit compat_sys_mmap() mapping VMA over 4Gb in 64-bit binaries
and 64-bit sys_mmap() mapping VMA only under 4Gb in 32-bit binaries.
Changed arch_get_unmapped_area{,_topdown}() to recompute mmap_base
for those cases and use according high/low limits for vm_unmapped_area()
The recomputing of mmap_base may make compat sys_mmap() in 64-bit
binaries a little slower than native, which uses already known from exec
time mmap_base - but, as it returned buggy address, that case seemed
unused previously, so no performance degradation for already used ABI.
Can be optimized in future by introducing mmap_compat_{,legacy}_base
in mm_struct.

I discovered that bug on ZDTM tests for compat 32-bit C/R.
Working compat sys_mmap() in 64-bit binaries is really needed for that
purpose, as 32-bit applications are restored from 64-bit CRIU binary.

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/kernel/sys_x86_64.c | 44 +++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 41 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index a55ed63b9f91..1bf90cd1400c 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -113,10 +113,31 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 		if (current->flags & PF_RANDOMIZE) {
 			*begin = randomize_page(*begin, 0x02000000);
 		}
+		return;
+	}
+
+	if (!test_thread_flag(TIF_ADDR32)) {
+#ifdef CONFIG_COMPAT
+		/* 64-bit native binary doing compat 32-bit syscall */
+		if (in_compat_syscall()) {
+			*begin = mmap_legacy_base(arch_compat_rnd(),
+						IA32_PAGE_OFFSET);
+			*end = IA32_PAGE_OFFSET;
+			return;
+		}
+#endif
 	} else {
-		*begin = current->mm->mmap_legacy_base;
-		*end = TASK_SIZE;
+		/* 32-bit binary doing 64-bit syscall */
+		if (!in_compat_syscall()) {
+			*begin = mmap_legacy_base(arch_native_rnd(),
+						IA32_PAGE_OFFSET);
+			*end = TASK_SIZE_MAX;
+			return;
+		}
 	}
+
+	*begin = current->mm->mmap_legacy_base;
+	*end = TASK_SIZE;
 }
 
 unsigned long
@@ -157,6 +178,23 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	return vm_unmapped_area(&info);
 }
 
+static unsigned long find_top(void)
+{
+	if (!test_thread_flag(TIF_ADDR32)) {
+#ifdef CONFIG_COMPAT
+		/* 64-bit native binary doing compat 32-bit syscall */
+		if (in_compat_syscall())
+			return mmap_base(arch_compat_rnd(), IA32_PAGE_OFFSET);
+#endif
+	} else {
+		/* 32-bit binary doing 64-bit syscall */
+		if (!in_compat_syscall())
+			return mmap_base(arch_native_rnd(), TASK_SIZE_MAX);
+	}
+
+	return current->mm->mmap_base;
+}
+
 unsigned long
 arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			  const unsigned long len, const unsigned long pgoff,
@@ -190,7 +228,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = mm->mmap_base;
+	info.high_limit = find_top();
 	info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	if (filp) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
