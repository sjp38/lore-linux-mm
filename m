Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B56416B0268
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 05:37:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v109so5754277wrc.5
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 02:37:31 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id o184si1012314wme.43.2017.09.21.02.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 02:37:30 -0700 (PDT)
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] mm: fix RODATA_TEST failure "rodata_test: test data was not read only"
Message-Id: <20170921093729.1080368AC1@po15668-vm-win7.idsi0.si.c-s.fr>
Date: Thu, 21 Sep 2017 11:37:28 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Jinbum Park <jinb.park7@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On powerpc, RODATA_TEST fails with message the following messages:

[    6.199505] Freeing unused kernel memory: 528K
[    6.203935] rodata_test: test data was not read only

This is because GCC allocates it to .data section:

c0695034 g     O .data	00000004 rodata_test_data

Since commit 056b9d8a76924 ("mm: remove rodata_test_data export,
add pr_fmt"), rodata_test_data is used only inside rodata_test.c
By declaring it static, it gets properly allocated into .rodata
section instead of .data:

c04df710 l     O .rodata	00000004 rodata_test_data

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 mm/rodata_test.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rodata_test.c b/mm/rodata_test.c
index 6bb4deb12e78..d908c8769b48 100644
--- a/mm/rodata_test.c
+++ b/mm/rodata_test.c
@@ -14,7 +14,7 @@
 #include <linux/uaccess.h>
 #include <asm/sections.h>
 
-const int rodata_test_data = 0xC3;
+static const int rodata_test_data = 0xC3;
 
 void rodata_test(void)
 {
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
