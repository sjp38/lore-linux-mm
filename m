Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id DA0BF6B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:41:06 -0500 (EST)
Received: by wmec201 with SMTP id c201so64173194wme.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:41:06 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id ld9si33663974wjb.130.2015.11.25.02.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 02:41:02 -0800 (PST)
Received: by wmec201 with SMTP id c201so249748800wme.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:41:02 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm: warn about ALLOC_NO_WATERMARKS request failures
Date: Wed, 25 Nov 2015 11:40:54 +0100
Message-Id: <1448448054-804-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1448448054-804-1-git-send-email-mhocko@kernel.org>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

ALLOC_NO_WATERMARKS requests can dive into memory reserves without any
restriction. They are used only in the case of emergency to allow
forward memory reclaim progress assuming the caller should return the
memory in a short time (e.g. {__GFP,PF}_MEMALLOC requests or OOM victim
on the way to exit or __GFP_NOFAIL requests hitting OOM). There is no
guarantee such request succeed because memory reserves might get
depleted as well. This might be either a result of a bug where memory
reserves are abused or a result of a too optimistic configuration of
memory reserves.

This patch makes sure that the administrator gets a warning when these
requests fail with a hint that min_free_kbytes might be used to increase
the amount of memory reserves. The warning might also help us check
whether the issue is caused by a buggy user or the configuration. To
prevent from flooding the logs the warning is on off but we allow it to
trigger again after min_free_kbytes was updated. Something really bad is
clearly going on if the warning hits even after multiple updates of
min_free_kbytes.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 70db11c27046..6a05d771cb08 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -240,6 +240,8 @@ compound_page_dtor * const compound_page_dtors[] = {
 #endif
 };
 
+/* warn about depleted watermarks */
+static bool warn_alloc_no_wmarks;
 int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
 
@@ -2642,6 +2644,13 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	if (zonelist_rescan)
 		goto zonelist_scan;
 
+	/* WARN only once unless min_free_kbytes is updated */
+	if (warn_alloc_no_wmarks && (alloc_flags & ALLOC_NO_WATERMARKS)) {
+		warn_alloc_no_wmarks = 0;
+		WARN(1, "Memory reserves are depleted for order:%d, mode:0x%x."
+			" You might consider increasing min_free_kbytes\n",
+			order, gfp_mask);
+	}
 	return NULL;
 }
 
@@ -6048,6 +6057,9 @@ static void __setup_per_zone_wmarks(void)
 	struct zone *zone;
 	unsigned long flags;
 
+	/* Warn when ALLOC_NO_WATERMARKS request fails */
+	warn_alloc_no_wmarks = 1;
+
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
 		if (!is_highmem(zone))
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
