Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 963836B0074
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 13:25:10 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id 20so2555000yks.9
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 10:25:10 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id w2si7850314qab.9.2014.11.21.10.25.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Nov 2014 10:25:09 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v6 2/7] x86, mm, pat: Change reserve_memtype() to handle WT
Date: Fri, 21 Nov 2014 11:10:35 -0700
Message-Id: <1416593440-23083-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1416593440-23083-1-git-send-email-toshi.kani@hp.com>
References: <1416593440-23083-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

This patch changes reserve_memtype() to handle the WT cache mode
with PAT.  When PAT is not enabled, WB and UC- are the only types
supported.

When a target range is in RAM, reserve_ram_pages_type() verifies
the requested type.  In this case, WT and WP requests fail with
-EINVAL and UC gets redirected to UC- since set_page_memtype() is
limited to handle three types, WB, WC and UC-.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 arch/x86/mm/pat.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 0f0be47..5552384 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -360,6 +360,8 @@ static int pat_pagerange_is_ram(resource_size_t start, resource_size_t end)
 
 /*
  * For RAM pages, we use page flags to mark the pages with appropriate type.
+ * The page flags are limited to three types, WB, WC and UC-.
+ * WT and WP requests fail with -EINVAL, and UC gets redirected to UC-.
  * Here we do two pass:
  * - Find the memtype of all the pages in the range, look for any conflicts
  * - In case of no conflicts, set the new memtype for pages in the range
@@ -371,6 +373,13 @@ static int reserve_ram_pages_type(u64 start, u64 end,
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
@@ -420,6 +429,7 @@ static int free_ram_pages_type(u64 start, u64 end)
  * - _PAGE_CACHE_MODE_WC
  * - _PAGE_CACHE_MODE_UC_MINUS
  * - _PAGE_CACHE_MODE_UC
+ * - _PAGE_CACHE_MODE_WT
  *
  * If new_type is NULL, function will return an error if it cannot reserve the
  * region with req_type. If new_type is non-NULL, function will return
@@ -437,12 +447,12 @@ int reserve_memtype(u64 start, u64 end, enum page_cache_mode req_type,
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
