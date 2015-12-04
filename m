Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BF6F36B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 05:19:50 -0500 (EST)
Received: by pfu207 with SMTP id 207so24383086pfu.2
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 02:19:50 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id se8si18551924pac.136.2015.12.04.02.19.49
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 02:19:50 -0800 (PST)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] mm: kmemleak: mark kmemleak_init prototype as __init
Date: Fri,  4 Dec 2015 10:19:42 +0000
Message-Id: <1449224382-11031-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Nicolas Iooss <nicolas.iooss_linux@m4x.org>

From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>

kmemleak_init() definition in mm/kmemleak.c is marked __init but its
prototype in include/linux/kmemleak.h is marked __ref since commit
a6186d89c913 ("kmemleak: Mark the early log buffer as __initdata").

This causes a section mismatch which is reported as a warning when
building with clang -Wsection, because kmemleak_init() is declared in
section .ref.text but defined in .init.text.

Fix this by marking kmemleak_init() prototype __init.

Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---

I think this patch was missed some time ago, so resending (minor fix).

Thanks,

Catalin

 include/linux/kmemleak.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index d0a1f99e24e3..4894c6888bc6 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -25,7 +25,7 @@
 
 #ifdef CONFIG_DEBUG_KMEMLEAK
 
-extern void kmemleak_init(void) __ref;
+extern void kmemleak_init(void) __init;
 extern void kmemleak_alloc(const void *ptr, size_t size, int min_count,
 			   gfp_t gfp) __ref;
 extern void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
