Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 487786B0269
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 16:18:13 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id f22so39875423qkm.11
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 13:18:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n2si4794505qvp.28.2018.11.14.13.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 13:18:12 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 5/6] hv_balloon: mark inflated pages PG_offline
Date: Wed, 14 Nov 2018 22:17:03 +0100
Message-Id: <20181114211704.6381-6-david@redhat.com>
In-Reply-To: <20181114211704.6381-1-david@redhat.com>
References: <20181114211704.6381-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, David Hildenbrand <david@redhat.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Kairui Song <kasong@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

Mark inflated and never onlined pages PG_offline, to tell the world that
the content is stale and should not be dumped.

Cc: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
Cc: Kairui Song <kasong@redhat.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/hv/hv_balloon.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index 5728dc470eeb..778b6f879d1c 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -681,8 +681,13 @@ static struct notifier_block hv_memory_nb = {
 /* Check if the particular page is backed and can be onlined and online it. */
 static void hv_page_online_one(struct hv_hotadd_state *has, struct page *pg)
 {
-	if (!has_pfn_is_backed(has, page_to_pfn(pg)))
+	if (!has_pfn_is_backed(has, page_to_pfn(pg))) {
+		if (!PageOffline(pg))
+			__SetPageOffline(pg);
 		return;
+	}
+	if (PageOffline(pg))
+		__ClearPageOffline(pg);
 
 	/* This frame is currently backed; online the page. */
 	__online_page_set_limits(pg);
@@ -1200,6 +1205,7 @@ static void free_balloon_pages(struct hv_dynmem_device *dm,
 
 	for (i = 0; i < num_pages; i++) {
 		pg = pfn_to_page(i + start_frame);
+		__ClearPageOffline(pg);
 		__free_page(pg);
 		dm->num_pages_ballooned--;
 	}
@@ -1212,7 +1218,7 @@ static unsigned int alloc_balloon_pages(struct hv_dynmem_device *dm,
 					struct dm_balloon_response *bl_resp,
 					int alloc_unit)
 {
-	unsigned int i = 0;
+	unsigned int i, j;
 	struct page *pg;
 
 	if (num_pages < alloc_unit)
@@ -1244,6 +1250,10 @@ static unsigned int alloc_balloon_pages(struct hv_dynmem_device *dm,
 		if (alloc_unit != 1)
 			split_page(pg, get_order(alloc_unit << PAGE_SHIFT));
 
+		/* mark all pages offline */
+		for (j = 0; j < (1 << get_order(alloc_unit << PAGE_SHIFT)); j++)
+			__SetPageOffline(pg + j);
+
 		bl_resp->range_count++;
 		bl_resp->range_array[i].finfo.start_page =
 			page_to_pfn(pg);
-- 
2.17.2
