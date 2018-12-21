Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50DF28E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:14:49 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id g12-v6so1905065lji.3
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:14:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a66-v6sor16166926ljf.31.2018.12.21.10.14.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 10:14:46 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 01/12] x86_64: memset_user()
Date: Fri, 21 Dec 2018 20:14:12 +0200
Message-Id: <20181221181423.20455-2-igor.stoppa@huawei.com>
In-Reply-To: <20181221181423.20455-1-igor.stoppa@huawei.com>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Create x86_64 specific version of memset for user space, based on
clear_user().
This will be used for implementing wr_memset() in the __wr_after_init
scenario, where write-rare variables have an alternate mapping for
writing.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/x86/include/asm/uaccess_64.h |  6 ++++
 arch/x86/lib/usercopy_64.c        | 54 +++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/arch/x86/include/asm/uaccess_64.h b/arch/x86/include/asm/uaccess_64.h
index a9d637bc301d..f194bfce4866 100644
--- a/arch/x86/include/asm/uaccess_64.h
+++ b/arch/x86/include/asm/uaccess_64.h
@@ -213,4 +213,10 @@ copy_user_handle_tail(char *to, char *from, unsigned len);
 unsigned long
 mcsafe_handle_tail(char *to, char *from, unsigned len);
 
+unsigned long __must_check
+memset_user(void __user *mem, int c, unsigned long len);
+
+unsigned long __must_check
+__memset_user(void __user *mem, int c, unsigned long len);
+
 #endif /* _ASM_X86_UACCESS_64_H */
diff --git a/arch/x86/lib/usercopy_64.c b/arch/x86/lib/usercopy_64.c
index 1bd837cdc4b1..84f8f8a20b30 100644
--- a/arch/x86/lib/usercopy_64.c
+++ b/arch/x86/lib/usercopy_64.c
@@ -9,6 +9,60 @@
 #include <linux/uaccess.h>
 #include <linux/highmem.h>
 
+/*
+ * Memset Userspace
+ */
+
+unsigned long __memset_user(void __user *addr, int c, unsigned long size)
+{
+	long __d0;
+	unsigned long  pattern = 0;
+	int i;
+
+	for (i = 0; i < 8; i++)
+		pattern = (pattern << 8) | (0xFF & c);
+	might_fault();
+	/* no memory constraint: gcc doesn't know about this memory */
+	stac();
+	asm volatile(
+		"       movq %[val], %%rdx\n"
+		"	testq  %[size8],%[size8]\n"
+		"	jz     4f\n"
+		"0:	mov %%rdx,(%[dst])\n"
+		"	addq   $8,%[dst]\n"
+		"	decl %%ecx ; jnz   0b\n"
+		"4:	movq  %[size1],%%rcx\n"
+		"	testl %%ecx,%%ecx\n"
+		"	jz     2f\n"
+		"1:	movb   %%dl,(%[dst])\n"
+		"	incq   %[dst]\n"
+		"	decl %%ecx ; jnz  1b\n"
+		"2:\n"
+		".section .fixup,\"ax\"\n"
+		"3:	lea 0(%[size1],%[size8],8),%[size8]\n"
+		"	jmp 2b\n"
+		".previous\n"
+		_ASM_EXTABLE_UA(0b, 3b)
+		_ASM_EXTABLE_UA(1b, 2b)
+		: [size8] "=&c"(size), [dst] "=&D" (__d0)
+		: [size1] "r"(size & 7), "[size8]" (size / 8), "[dst]"(addr),
+		  [val] "ri"(pattern)
+		: "rdx");
+
+	clac();
+	return size;
+}
+EXPORT_SYMBOL(__memset_user);
+
+unsigned long memset_user(void __user *to, int c, unsigned long n)
+{
+	if (access_ok(VERIFY_WRITE, to, n))
+		return __memset_user(to, c, n);
+	return n;
+}
+EXPORT_SYMBOL(memset_user);
+
+
 /*
  * Zero Userspace
  */
-- 
2.19.1
