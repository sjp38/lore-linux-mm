Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2558E6B0036
	for <linux-mm@kvack.org>; Sat, 28 Dec 2013 20:45:23 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id x13so10897704ief.20
        for <linux-mm@kvack.org>; Sat, 28 Dec 2013 17:45:22 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id nh2si48018356icc.78.2013.12.28.17.45.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 28 Dec 2013 17:45:22 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 2/2] mm: additional checks to page flag set/clear
Date: Sat, 28 Dec 2013 20:45:04 -0500
Message-Id: <1388281504-11453-2-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1388281504-11453-1-git-send-email-sasha.levin@oracle.com>
References: <1388281504-11453-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill@shutemov.name, Sasha Levin <sasha.levin@oracle.com>

Check if the flag is already set before setting it, and vice versa
for clearing.

Obviously setting or clearing a flag twice isn't a problem on it's
own, but it implies that there's an issue where some piece of code
assumed an opposite state of the flag.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/page-flags.h | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d1fe1a7..36b0bef 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -130,6 +130,12 @@ enum pageflags {
 
 #ifndef __GENERATING_BOUNDS_H
 
+#ifdef CONFIG_DEBUG_VM_PAGE_FLAGS
+#define VM_ASSERT_FLAG(assert, page) VM_BUG_ON_PAGE(assert, page)
+#else
+#define VM_ASSERT_FLAG(assert, page) do { } while (0)
+#endif
+
 /*
  * Macros to create function definitions for page flags
  */
@@ -139,11 +145,13 @@ static inline int Page##uname(const struct page *page)			\
 
 #define SETPAGEFLAG(uname, lname)					\
 static inline void SetPage##uname(struct page *page)			\
-			{ set_bit(PG_##lname, &page->flags); }
+			{ VM_ASSERT_FLAG(Page##uname(page), page);	\
+			set_bit(PG_##lname, &page->flags); }
 
 #define CLEARPAGEFLAG(uname, lname)					\
 static inline void ClearPage##uname(struct page *page)			\
-			{ clear_bit(PG_##lname, &page->flags); }
+			{ VM_ASSERT_FLAG(!Page##uname(page), page);	\
+			clear_bit(PG_##lname, &page->flags); }
 
 #define __SETPAGEFLAG(uname, lname)					\
 static inline void __SetPage##uname(struct page *page)			\
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
