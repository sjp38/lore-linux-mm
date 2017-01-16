Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8FD6B0260
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:36:39 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so248275266pfb.6
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:36:39 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00106.outbound.protection.outlook.com. [40.107.0.106])
        by mx.google.com with ESMTPS id i8si1695660pll.65.2017.01.16.04.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 04:36:38 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 1/5] x86/mm: split arch_mmap_rnd() on compat/native versions
Date: Mon, 16 Jan 2017 15:33:06 +0300
Message-ID: <20170116123310.22697-2-dsafonov@virtuozzo.com>
In-Reply-To: <20170116123310.22697-1-dsafonov@virtuozzo.com>
References: <20170116123310.22697-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

I need those arch_{native,compat}_rnd() to compute separately
random factor for mmap() in compat syscalls for 64-bit binaries
and vice-versa for native syscall in 32-bit compat binaries.
They will be used in the following patches.

Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/include/asm/elf.h |  5 +++++
 arch/x86/mm/mmap.c         | 25 ++++++++++++++++---------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index e7f155c3045e..ee1a87782b2c 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -349,6 +349,11 @@ static inline int mmap_is_ia32(void)
 		test_thread_flag(TIF_ADDR32));
 }
 
+#ifdef CONFIG_COMPAT
+extern unsigned long arch_compat_rnd(void);
+#endif
+extern unsigned long arch_native_rnd(void);
+
 /* Do not change the values. See get_align_mask() */
 enum align_flags {
 	ALIGN_VA_32	= BIT(0),
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index d2dc0438d654..0b2007b08194 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -65,20 +65,27 @@ static int mmap_is_legacy(void)
 	return sysctl_legacy_va_layout;
 }
 
-unsigned long arch_mmap_rnd(void)
+#ifdef CONFIG_COMPAT
+unsigned long arch_compat_rnd(void)
 {
-	unsigned long rnd;
+	return (get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1))
+		<< PAGE_SHIFT;
+}
+#endif
 
-	if (mmap_is_ia32())
+unsigned long arch_native_rnd(void)
+{
+	return (get_random_long() & ((1UL << mmap_rnd_bits) - 1)) << PAGE_SHIFT;
+}
+
+unsigned long arch_mmap_rnd(void)
+{
 #ifdef CONFIG_COMPAT
-		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
-#else
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
+	if (mmap_is_ia32())
+		return arch_compat_rnd();
 #endif
-	else
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
 
-	return rnd << PAGE_SHIFT;
+	return arch_native_rnd();
 }
 
 static unsigned long mmap_base(unsigned long rnd)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
