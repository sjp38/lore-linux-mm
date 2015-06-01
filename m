Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id B80ED6B006C
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 15:56:18 -0400 (EDT)
Received: by oiww2 with SMTP id w2so109880596oiw.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 12:56:18 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id e8si78756obo.53.2015.06.01.12.56.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 12:56:17 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v12 2/10] x86, mm, pat: Change reserve_memtype() for WT
Date: Mon,  1 Jun 2015 13:36:25 -0600
Message-Id: <1433187393-22688-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
References: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

When a RAM range is requested to reserve_memtype(), it calls
reserve_ram_pages_type() to verify the requested type.
reserve_ram_pages_type() is changed to fail WT and WP requests
with -EINVAL since set_page_memtype() is limited to handle
three types, WB, WC and UC-.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---
Patch 8/10 enhances set_page_memtype() to support WT.
---
 arch/x86/mm/pat.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 83af01a..56c8b4d 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -401,6 +401,8 @@ static int pat_pagerange_is_ram(resource_size_t start, resource_size_t end)
 
 /*
  * For RAM pages, we use page flags to mark the pages with appropriate type.
+ * The page flags are limited to three types, WB, WC and UC-.
+ * WT and WP requests fail with -EINVAL, and UC gets redirected to UC-.
  * Here we do two pass:
  * - Find the memtype of all the pages in the range, look for any conflicts
  * - In case of no conflicts, set the new memtype for pages in the range
@@ -412,6 +414,13 @@ static int reserve_ram_pages_type(u64 start, u64 end,
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
@@ -461,6 +470,7 @@ static int free_ram_pages_type(u64 start, u64 end)
  * - _PAGE_CACHE_MODE_WC
  * - _PAGE_CACHE_MODE_UC_MINUS
  * - _PAGE_CACHE_MODE_UC
+ * - _PAGE_CACHE_MODE_WT
  *
  * If new_type is NULL, function will return an error if it cannot reserve the
  * region with req_type. If new_type is non-NULL, function will return

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
