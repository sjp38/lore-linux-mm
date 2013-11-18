Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 95E336B0035
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 13:54:10 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so5564787pab.9
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 10:54:10 -0800 (PST)
Received: from psmtp.com ([74.125.245.117])
        by mx.google.com with SMTP id dj6si10341817pad.148.2013.11.18.10.54.08
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 10:54:08 -0800 (PST)
Date: Mon, 18 Nov 2013 13:54:01 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1384800841-314l1f3e-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1384800714-y653r3ch-mutt-n-horiguchi@ah.jp.nec.com>
References: <20131115225550.737E5C33@viggo.jf.intel.com>
 <20131115225553.B0E9DFFB@viggo.jf.intel.com>
 <1384800714-y653r3ch-mutt-n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: call cond_resched() per MAX_ORDER_NR_PAGES pages copy
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Mel Gorman <mgorman@suse.de>

In copy_huge_page() we call cond_resched() before every single page copy.
This is an overkill because single page copy is not a heavy operation.
This patch changes this to call cond_resched() per MAX_ORDER_NR_PAGES pages.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index cb5d152b58bc..661ff5f66591 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -454,7 +454,8 @@ static void __copy_gigantic_page(struct page *dst, struct page *src,
 	struct page *src_base = src;
 
 	for (i = 0; i < nr_pages; ) {
-		cond_resched();
+		if (i % MAX_ORDER_NR_PAGES == 0)
+			cond_resched();
 		copy_highpage(dst, src);
 
 		i++;
@@ -483,10 +484,9 @@ static void copy_huge_page(struct page *dst, struct page *src)
 		nr_pages = hpage_nr_pages(src);
 	}
 
-	for (i = 0; i < nr_pages; i++ ) {
-		cond_resched();
+	cond_resched();
+	for (i = 0; i < nr_pages; i++)
 		copy_highpage(dst + i, src + i);
-	}
 }
 
 /*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
