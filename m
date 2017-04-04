Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE4976B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 17:09:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v78so23230214qkl.10
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 14:09:12 -0700 (PDT)
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com. [209.85.220.173])
        by mx.google.com with ESMTPS id v10si16112212qtf.111.2017.04.04.14.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 14:09:11 -0700 (PDT)
Received: by mail-qk0-f173.google.com with SMTP id g195so81314088qke.2
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 14:09:11 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCH] mm/usercopy: Drop extra is_vmalloc_or_module check
Date: Tue,  4 Apr 2017 14:09:00 -0700
Message-Id: <1491340140-18238-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>

virt_addr_valid was previously insufficient to validate if virt_to_page
could be called on an address on arm64. This has since been fixed up
so there is no need for the extra check. Drop it.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
I've given this some testing on my machine and haven't seen any problems
(e.g. random crashes without the check) and the fix has been in for long
enough now. I'm in no rush to have this merged so I'm okay if this sits in
a tree somewhere to get more testing.
---
 mm/usercopy.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index d155e12563b1..4d23a0e0e232 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -206,17 +206,6 @@ static inline const char *check_heap_object(const void *ptr, unsigned long n,
 {
 	struct page *page;
 
-	/*
-	 * Some architectures (arm64) return true for virt_addr_valid() on
-	 * vmalloced addresses. Work around this by checking for vmalloc
-	 * first.
-	 *
-	 * We also need to check for module addresses explicitly since we
-	 * may copy static data from modules to userspace
-	 */
-	if (is_vmalloc_or_module_addr(ptr))
-		return NULL;
-
 	if (!virt_addr_valid(ptr))
 		return NULL;
 
-- 
2.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
