Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id E59CE6B003A
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 16:21:26 -0400 (EDT)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 2/3] Drivers: hv: balloon: Support 2M page allocations for ballooning
Date: Mon, 18 Mar 2013 13:51:37 -0700
Message-Id: <1363639898-1615-2-git-send-email-kys@microsoft.com>
In-Reply-To: <1363639898-1615-1-git-send-email-kys@microsoft.com>
References: <1363639873-1576-1-git-send-email-kys@microsoft.com>
 <1363639898-1615-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

On Hyper-V it will be very efficient to use 2M allocations in the guest as this
makes the ballooning protocol with the host that much more efficient. Hyper-V
uses page ranges (start pfn : number of pages) to specify memory being moved
around and with 2M pages this encoding can be very efficient. However, when
memory is returned to the guest, the host does not guarantee any granularity.
To deal with this issue, split the page soon after a successful 2M allocation
so that this memory can potentially be freed as 4K pages.

If 2M allocations fail, we revert to 4K allocations.

In this version of the patch, based on the feedback from Michal Hocko
<mhocko@suse.cz>, I have added some additional commentary to the patch
description. 

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
