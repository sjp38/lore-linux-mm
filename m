Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB4A6B0038
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:44:56 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id wp4so4374594obc.29
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:44:55 -0700 (PDT)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id cw6si291483obd.107.2014.07.15.12.44.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:44:55 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 3/11] x86, mm, pat: Change reserve_memtype() to handle WT type
Date: Tue, 15 Jul 2014 13:34:36 -0600
Message-Id: <1405452884-25688-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, konrad.wilk@oracle.com, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de, Toshi Kani <toshi.kani@hp.com>

This patch changes reserve_memtype() to handle the new WT type.
When (!pat_enabled && new_type), it continues to set either WB
or UC- to *new_type.  When pat_enabled, it can reserve a given
non-RAM range for WT.  At this point, it may not reserve a RAM
range for WT since reserve_ram_pages_type() uses the page flags
limited to three memory types, WB, WC and UC.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/cacheflush.h |    2 ++
 arch/x86/mm/pat.c                 |   12 +++++++++---
 arch/x86/mm/pat_internal.h        |    1 +
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index 9863ee3..c80a3a1 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -42,6 +42,8 @@ static inline void set_page_memtype(struct page *pg, unsigned long memtype)
 	unsigned long old_flags;
 	unsigned long new_flags;
 
+	BUG_ON(memtype == _PAGE_CACHE_WT);
+
 	switch (memtype) {
 	case _PAGE_CACHE_WC:
 		memtype_flags = _PGMT_WC;
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 176d4d6..8a8be17 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -203,6 +203,8 @@ static int pat_pagerange_is_ram(resource_size_t start, resource_size_t end)
 
 /*
  * For RAM pages, we use page flags to mark the pages with appropriate type.
+ * The page flags are currently limited to three types, WB, WC and UC. Hence,
+ * any request to WT will fail with -EINVAL.
  * Here we do two pass:
  * - Find the memtype of all the pages in the range, look for any conflicts
  * - In case of no conflicts, set the new memtype for pages in the range
@@ -213,6 +215,9 @@ static int reserve_ram_pages_type(u64 start, u64 end, unsigned long req_type,
 	struct page *page;
 	u64 pfn;
 
+	if (req_type == _PAGE_CACHE_WT)
+		return -EINVAL;
+
 	for (pfn = (start >> PAGE_SHIFT); pfn < (end >> PAGE_SHIFT); ++pfn) {
 		unsigned long type;
 
@@ -254,6 +259,7 @@ static int free_ram_pages_type(u64 start, u64 end)
  * req_type typically has one of the:
  * - _PAGE_CACHE_WB
  * - _PAGE_CACHE_WC
+ * - _PAGE_CACHE_WT
  * - _PAGE_CACHE_UC_MINUS
  *
  * If new_type is NULL, function will return an error if it cannot reserve the
@@ -274,10 +280,10 @@ int reserve_memtype(u64 start, u64 end, unsigned long req_type,
 	if (!pat_enabled) {
 		/* This is identical to page table setting without PAT */
 		if (new_type) {
-			if (req_type == _PAGE_CACHE_WC)
-				*new_type = _PAGE_CACHE_UC_MINUS;
+			if (req_type == _PAGE_CACHE_WB)
+				*new_type = _PAGE_CACHE_WB;
 			else
-				*new_type = req_type & _PAGE_CACHE_MASK;
+				*new_type = _PAGE_CACHE_UC_MINUS;
 		}
 		return 0;
 	}
diff --git a/arch/x86/mm/pat_internal.h b/arch/x86/mm/pat_internal.h
index 2593d40..7ae6b37 100644
--- a/arch/x86/mm/pat_internal.h
+++ b/arch/x86/mm/pat_internal.h
@@ -20,6 +20,7 @@ static inline char *cattr_name(unsigned long flags)
 	case _PAGE_CACHE_UC_MINUS:	return "uncached-minus";
 	case _PAGE_CACHE_WB:		return "write-back";
 	case _PAGE_CACHE_WC:		return "write-combining";
+	case _PAGE_CACHE_WT:		return "write-through";
 	default:			return "broken";
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
