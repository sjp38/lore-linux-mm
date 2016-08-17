Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0866B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 18:29:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so3234145pfg.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 15:29:25 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id v7si1275902pal.10.2016.08.17.15.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 15:29:24 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id ti13so465498pac.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 15:29:24 -0700 (PDT)
Date: Wed, 17 Aug 2016 15:29:22 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] usercopy: Skip multi-page bounds checking on SLOB
Message-ID: <20160817222921.GA25148@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Laura Abbott <labbott@fedoraproject.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiaolong.ye@intel.com

When an allocator does not mark all allocations as PageSlab, or does not
mark multipage allocations with __GFP_COMP, hardened usercopy cannot
correctly validate the allocation. SLOB lacks this, so short-circuit
the checking for the allocators that aren't marked with
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR. This also updates the config
help and corrects a typo in the usercopy comments.

Reported-by: xiaolong.ye@intel.com
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/usercopy.c    | 11 ++++++++++-
 security/Kconfig |  5 +++--
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index 8ebae91a6b55..855944b05cc7 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -172,6 +172,15 @@ static inline const char *check_heap_object(const void *ptr, unsigned long n,
 		return NULL;
 	}
 
+#ifndef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
+	/*
+	 * If the allocator isn't marking multi-page allocations as
+	 * either __GFP_COMP or PageSlab, we cannot correctly perform
+	 * bounds checking of multi-page allocations, so we stop here.
+	 */
+	return NULL;
+#endif
+
 	/* Allow kernel data region (if not marked as Reserved). */
 	if (ptr >= (const void *)_sdata && end <= (const void *)_edata)
 		return NULL;
@@ -192,7 +201,7 @@ static inline const char *check_heap_object(const void *ptr, unsigned long n,
 		return NULL;
 
 	/*
-	 * Reject if range is entirely either Reserved (i.e. special or
+	 * Allow if range is entirely either Reserved (i.e. special or
 	 * device memory), or CMA. Otherwise, reject since the object spans
 	 * several independently allocated pages.
 	 */
diff --git a/security/Kconfig b/security/Kconfig
index df28f2b6f3e1..08dce0327d5b 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -122,8 +122,9 @@ config HAVE_HARDENED_USERCOPY_ALLOCATOR
 	bool
 	help
 	  The heap allocator implements __check_heap_object() for
-	  validating memory ranges against heap object sizes in
-	  support of CONFIG_HARDENED_USERCOPY.
+	  validating memory ranges against heap object sizes in support
+	  of CONFIG_HARDENED_USERCOPY. It must mark all managed pages as
+	  PageSlab(), or set __GFP_COMP for multi-page allocations.
 
 config HAVE_ARCH_HARDENED_USERCOPY
 	bool
-- 
2.7.4


-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
