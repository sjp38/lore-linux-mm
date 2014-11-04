Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 671E66B00BF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:18:49 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id vb8so6599623obc.23
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 14:18:49 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id ws9si1893750oeb.27.2014.11.04.14.18.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 14:18:48 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v5 3/8] x86, mm, pat: Change reserve_memtype() to handle WT
Date: Tue,  4 Nov 2014 15:04:33 -0700
Message-Id: <1415138678-22958-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1415138678-22958-1-git-send-email-toshi.kani@hp.com>
References: <1415138678-22958-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

This patch changes reserve_memtype() to handle the WT cache mode
with PAT.  When PAT is not enabled, WB and UC- are the only types
supported.

When a target range is RAM, reserve_ram_pages_type() verifies the
requested type.  WT and WP requests fail with -EINVAL and UC gets
redirected to UC- since set_page_memtype() is limited to handle
three types, WB, WC and UC-.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 arch/x86/mm/pat.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 91c01b9..2b69db8 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -349,6 +349,8 @@ static inline void set_page_memtype(struct page *pg,
 
 /*
  * For RAM pages, we use page flags to mark the pages with appropriate type.
+ * The page flags are limited to three types, WB, WC and UC-.
+ * WT and WP requests fail with -EINVAL, and UC gets redirected to UC-.
  * Here we do two pass:
  * - Find the memtype of all the pages in the range, look for any conflicts
  * - In case of no conflicts, set the new memtype for pages in the range
@@ -360,6 +362,13 @@ static int reserve_ram_pages_type(u64 start, u64 end,
 	struct page *page;
 	u64 pfn;
 
+	if ((req_type == _PAGE_CACHE_MODE_WT) ||
+	    (req_type == _PAGE_CACHE_MODE_WP)) {
+		if (new_type)
+			*new_type = _PAGE_CACHE_MODE_UC_MINUS;
+		return -EINVAL;
+	}
+
 	if (req_type == _PAGE_CACHE_MODE_UC) {
 		/* We do not support strong UC */
 		WARN_ON_ONCE(1);
@@ -409,6 +418,7 @@ static int free_ram_pages_type(u64 start, u64 end)
  * - _PAGE_CACHE_MODE_WC
  * - _PAGE_CACHE_MODE_UC_MINUS
  * - _PAGE_CACHE_MODE_UC
+ * - _PAGE_CACHE_MODE_WT
  *
  * If new_type is NULL, function will return an error if it cannot reserve the
  * region with req_type. If new_type is non-NULL, function will return
@@ -426,12 +436,12 @@ int reserve_memtype(u64 start, u64 end, enum page_cache_mode req_type,
 	BUG_ON(start >= end); /* end is exclusive */
 
 	if (!pat_enabled) {
-		/* This is identical to page table setting without PAT */
+		/* WB and UC- are the only types supported without PAT */
 		if (new_type) {
-			if (req_type == _PAGE_CACHE_MODE_WC)
-				*new_type = _PAGE_CACHE_MODE_UC_MINUS;
+			if (req_type == _PAGE_CACHE_MODE_WB)
+				*new_type = _PAGE_CACHE_MODE_WB;
 			else
-				*new_type = req_type;
+				*new_type = _PAGE_CACHE_MODE_UC_MINUS;
 		}
 		return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
