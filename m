Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDA28E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:15:12 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id f16so708510lfc.3
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:15:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h39-v6sor16663786lji.32.2018.12.21.10.15.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 10:15:09 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 12/12] x86_64: __clear_user as case of __memset_user
Date: Fri, 21 Dec 2018 20:14:23 +0200
Message-Id: <20181221181423.20455-13-igor.stoppa@huawei.com>
In-Reply-To: <20181221181423.20455-1-igor.stoppa@huawei.com>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To avoid code duplication, re-use __memset_user(), when clearing
user-space memory.

The overhead should be minimal (2 extra register assignments) and
outside of the writing loop.

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
 arch/x86/lib/usercopy_64.c | 29 +----------------------------
 1 file changed, 1 insertion(+), 28 deletions(-)

diff --git a/arch/x86/lib/usercopy_64.c b/arch/x86/lib/usercopy_64.c
index 84f8f8a20b30..ab6aabb62055 100644
--- a/arch/x86/lib/usercopy_64.c
+++ b/arch/x86/lib/usercopy_64.c
@@ -69,34 +69,7 @@ EXPORT_SYMBOL(memset_user);
 
 unsigned long __clear_user(void __user *addr, unsigned long size)
 {
-	long __d0;
-	might_fault();
-	/* no memory constraint because it doesn't change any memory gcc knows
-	   about */
-	stac();
-	asm volatile(
-		"	testq  %[size8],%[size8]\n"
-		"	jz     4f\n"
-		"0:	movq $0,(%[dst])\n"
-		"	addq   $8,%[dst]\n"
-		"	decl %%ecx ; jnz   0b\n"
-		"4:	movq  %[size1],%%rcx\n"
-		"	testl %%ecx,%%ecx\n"
-		"	jz     2f\n"
-		"1:	movb   $0,(%[dst])\n"
-		"	incq   %[dst]\n"
-		"	decl %%ecx ; jnz  1b\n"
-		"2:\n"
-		".section .fixup,\"ax\"\n"
-		"3:	lea 0(%[size1],%[size8],8),%[size8]\n"
-		"	jmp 2b\n"
-		".previous\n"
-		_ASM_EXTABLE_UA(0b, 3b)
-		_ASM_EXTABLE_UA(1b, 2b)
-		: [size8] "=&c"(size), [dst] "=&D" (__d0)
-		: [size1] "r"(size & 7), "[size8]" (size / 8), "[dst]"(addr));
-	clac();
-	return size;
+	return __memset_user(addr, 0, size);
 }
 EXPORT_SYMBOL(__clear_user);
 
-- 
2.19.1
