Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 561BE6B0070
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:41:27 -0400 (EDT)
Received: by padev16 with SMTP id ev16so22896035pad.0
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:41:27 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id bz12si377059pdb.79.2015.06.07.10.41.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:41:26 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:40:40 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-0d69bdff451a10aa48f80509e8bf18fb24683c06@git.kernel.org>
Reply-To: akpm@linux-foundation.org, hpa@zytor.com, luto@amacapital.net,
        linux-mm@kvack.org, torvalds@linux-foundation.org, toshi.kani@hp.com,
        mingo@kernel.org, mcgrof@suse.com, peterz@infradead.org,
        linux-kernel@vger.kernel.org, tglx@linutronix.de, bp@suse.de
In-Reply-To: <1433436928-31903-6-git-send-email-bp@alien8.de>
References: <1433436928-31903-6-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/pat: Change reserve_memtype()
  for Write-Through type
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: hpa@zytor.com, akpm@linux-foundation.org, linux-mm@kvack.org, luto@amacapital.net, torvalds@linux-foundation.org, toshi.kani@hp.com, peterz@infradead.org, mingo@kernel.org, mcgrof@suse.com, linux-kernel@vger.kernel.org, bp@suse.de, tglx@linutronix.de

Commit-ID:  0d69bdff451a10aa48f80509e8bf18fb24683c06
Gitweb:     http://git.kernel.org/tip/0d69bdff451a10aa48f80509e8bf18fb24683c06
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:13 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:55 +0200

x86/mm/pat: Change reserve_memtype() for Write-Through type

When a target range is in RAM, reserve_ram_pages_type() verifies
the requested type. Change it to fail WT and WP requests with
-EINVAL since set_page_memtype() is limited to handle three
types: WB, WC and UC-.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-6-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/pat.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 59ab1a0f..6311193 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -401,9 +401,12 @@ static int pat_pagerange_is_ram(resource_size_t start, resource_size_t end)
 
 /*
  * For RAM pages, we use page flags to mark the pages with appropriate type.
- * Here we do two pass:
- * - Find the memtype of all the pages in the range, look for any conflicts
- * - In case of no conflicts, set the new memtype for pages in the range
+ * The page flags are limited to three types, WB, WC and UC-. WT and WP requests
+ * fail with -EINVAL, and UC gets redirected to UC-.
+ *
+ * Here we do two passes:
+ * - Find the memtype of all the pages in the range, look for any conflicts.
+ * - In case of no conflicts, set the new memtype for pages in the range.
  */
 static int reserve_ram_pages_type(u64 start, u64 end,
 				  enum page_cache_mode req_type,
@@ -412,6 +415,13 @@ static int reserve_ram_pages_type(u64 start, u64 end,
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
@@ -461,6 +471,7 @@ static int free_ram_pages_type(u64 start, u64 end)
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
