Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B51B1900016
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:37:47 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so153890876wgy.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:37:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id he1si18327102wib.34.2015.04.28.07.37.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 07:37:24 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/13] mm: meminit: Remove mminit_verify_page_links
Date: Tue, 28 Apr 2015 15:37:10 +0100
Message-Id: <1430231830-7702-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1430231830-7702-1-git-send-email-mgorman@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

mminit_verify_page_links() is an extremely paranoid check that was introduced
when memory initialisation was being heavily reworked. Profiles indicated
that up to 10% of parallel memory initialisation was spent on checking
this for every page. The cost could be reduced but in practice this check
only found problems very early during the initialisation rewrite and has
found nothing since. This patch removes an expensive unnecessary check.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/internal.h   | 8 --------
 mm/mm_init.c    | 8 --------
 mm/page_alloc.c | 1 -
 3 files changed, 17 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index bed751a7ac42..467a93e6a7b1 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -360,10 +360,7 @@ do { \
 } while (0)
 
 extern void mminit_verify_pageflags_layout(void);
-extern void mminit_verify_page_links(struct page *page,
-		enum zone_type zone, unsigned long nid, unsigned long pfn);
 extern void mminit_verify_zonelist(void);
-
 #else
 
 static inline void mminit_dprintk(enum mminit_level level,
@@ -375,11 +372,6 @@ static inline void mminit_verify_pageflags_layout(void)
 {
 }
 
-static inline void mminit_verify_page_links(struct page *page,
-		enum zone_type zone, unsigned long nid, unsigned long pfn)
-{
-}
-
 static inline void mminit_verify_zonelist(void)
 {
 }
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 28fbf87b20aa..fdadf918de76 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -131,14 +131,6 @@ void __init mminit_verify_pageflags_layout(void)
 	BUG_ON(or_mask != add_mask);
 }
 
-void __meminit mminit_verify_page_links(struct page *page, enum zone_type zone,
-			unsigned long nid, unsigned long pfn)
-{
-	BUG_ON(page_to_nid(page) != nid);
-	BUG_ON(page_zonenum(page) != zone);
-	BUG_ON(page_to_pfn(page) != pfn);
-}
-
 static __init int set_mminit_loglevel(char *str)
 {
 	get_option(&str, &mminit_loglevel);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 313f4a5a3907..9c8f2a72263d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -853,7 +853,6 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
 	set_page_links(page, zone, nid, pfn);
-	mminit_verify_page_links(page, zone, nid, pfn);
 	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
