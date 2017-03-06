Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B26AC6B038E
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 09:21:23 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 20so25712310iod.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 06:21:23 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0131.outbound.protection.outlook.com. [104.47.2.131])
        by mx.google.com with ESMTPS id 70si8500204ioo.245.2017.03.06.06.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 06:21:22 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv6 1/5] x86/mm: introduce arch_rnd() to compute 32/64 mmap rnd
Date: Mon, 6 Mar 2017 17:17:17 +0300
Message-ID: <20170306141721.9188-2-dsafonov@virtuozzo.com>
In-Reply-To: <20170306141721.9188-1-dsafonov@virtuozzo.com>
References: <20170306141721.9188-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

To fix 32-bit mmap() syscall returning pointer higher than 4Gb in
64-bit binaries, two mmap bases will be used: one for mapping with
32-bit syscalls and another for 64-bit syscall.
To correctly place those two bases, introduce arch_rnd() function,
which will return the random factor independently of mmap_is_ia32().

Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/mm/mmap.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 7940166c799b..f31ed7097d0b 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -55,6 +55,14 @@ static unsigned long stack_maxrandom_size(void)
 #define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
 #define MAX_GAP (TASK_SIZE/6*5)
 
+#ifdef CONFIG_COMPAT
+# define mmap32_rnd_bits  mmap_rnd_compat_bits
+# define mmap64_rnd_bits  mmap_rnd_bits
+#else
+# define mmap32_rnd_bits  mmap_rnd_bits
+# define mmap64_rnd_bits  mmap_rnd_bits
+#endif
+
 static int mmap_is_legacy(void)
 {
 	if (current->personality & ADDR_COMPAT_LAYOUT)
@@ -66,20 +74,14 @@ static int mmap_is_legacy(void)
 	return sysctl_legacy_va_layout;
 }
 
-unsigned long arch_mmap_rnd(void)
+static unsigned long arch_rnd(unsigned int rndbits)
 {
-	unsigned long rnd;
-
-	if (mmap_is_ia32())
-#ifdef CONFIG_COMPAT
-		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
-#else
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
-#endif
-	else
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
+	return (get_random_long() & ((1UL << rndbits) - 1)) << PAGE_SHIFT;
+}
 
-	return rnd << PAGE_SHIFT;
+unsigned long arch_mmap_rnd(void)
+{
+	return arch_rnd(mmap_is_ia32() ? mmap32_rnd_bits : mmap64_rnd_bits);
 }
 
 static unsigned long mmap_base(unsigned long rnd)
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
