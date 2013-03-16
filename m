Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id AE9A16B0039
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 17:12:03 -0400 (EDT)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 2/2] Drivers: hv: balloon: Support 2M page allocations for ballooning
Date: Sat, 16 Mar 2013 14:42:05 -0700
Message-Id: <1363470125-24606-2-git-send-email-kys@microsoft.com>
In-Reply-To: <1363470125-24606-1-git-send-email-kys@microsoft.com>
References: <1363470088-24565-1-git-send-email-kys@microsoft.com>
 <1363470125-24606-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

While ballooning memory out of the guest, attempt 2M allocations first.
If 2M allocations fail, then go for 4K allocations. In cases where we
have performed 2M allocations, split this 2M page so that we can free this
page at 4K granularity (when the host returns the memory).

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/hv_balloon.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index 2cf7d4e..71655b4 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -997,6 +997,14 @@ static int  alloc_balloon_pages(struct hv_dynmem_device *dm, int num_pages,
 
 		dm->num_pages_ballooned += alloc_unit;
 
+		/*
+		 * If we allocatted 2M pages; split them so we
+		 * can free them in any order we get.
+		 */
+
+		if (alloc_unit != 1)
+			split_page(pg, get_order(alloc_unit << PAGE_SHIFT));
+
 		bl_resp->range_count++;
 		bl_resp->range_array[i].finfo.start_page =
 			page_to_pfn(pg);
@@ -1023,9 +1031,10 @@ static void balloon_up(struct work_struct *dummy)
 
 
 	/*
-	 * Currently, we only support 4k allocations.
+	 * We will attempt 2M allocations. However, if we fail to
+	 * allocate 2M chunks, we will go back to 4k allocations.
 	 */
-	alloc_unit = 1;
+	alloc_unit = 512;
 
 	while (!done) {
 		bl_resp = (struct dm_balloon_response *)send_buffer;
@@ -1041,6 +1050,11 @@ static void balloon_up(struct work_struct *dummy)
 						bl_resp, alloc_unit,
 						 &alloc_error);
 
+		if ((alloc_error) && (alloc_unit != 1)) {
+			alloc_unit = 1;
+			continue;
+		}
+
 		if ((alloc_error) || (num_ballooned == num_pages)) {
 			bl_resp->more_pages = 0;
 			done = true;
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
