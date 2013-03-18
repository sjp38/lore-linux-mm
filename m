Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id E4C386B0039
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 16:21:26 -0400 (EDT)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 3/3] Drivers: hv: Notify the host of permanent hot-add failures
Date: Mon, 18 Mar 2013 13:51:38 -0700
Message-Id: <1363639898-1615-3-git-send-email-kys@microsoft.com>
In-Reply-To: <1363639898-1615-1-git-send-email-kys@microsoft.com>
References: <1363639873-1576-1-git-send-email-kys@microsoft.com>
 <1363639898-1615-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

If memory hot-add fails with the error -EEXIST, then this is a permanent
failure. Notify the host of this information, so the host will not attempt
hot-add again. If the failure were a transient failure, host will attempt
a hot-add after some delay.

In this version of the patch, I have added some additional comments
to clarify how the host treats different failure conditions.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/hv_balloon.c |   33 +++++++++++++++++++++++++++++++--
 1 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index 71655b4..4cc1d10 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -583,6 +583,16 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 
 		if (ret) {
 			pr_info("hot_add memory failed error is %d\n", ret);
+			if (ret == -EEXIST) {
+				/*
+				 * This error indicates that the error
+				 * is not a transient failure. This is the
+				 * case where the guest's physical address map
+				 * precludes hot adding memory. Stop all further
+				 * memory hot-add.
+				 */
+				do_hot_add = false;
+			}
 			has->ha_end_pfn -= HA_CHUNK;
 			has->covered_end_pfn -=  processed_pfn;
 			break;
@@ -842,11 +852,30 @@ static void hot_add_req(struct work_struct *dummy)
 		rg_sz = region_size;
 	}
 
-	resp.page_count = process_hot_add(pg_start, pfn_cnt,
-					rg_start, rg_sz);
+	if (do_hot_add)
+		resp.page_count = process_hot_add(pg_start, pfn_cnt,
+						rg_start, rg_sz);
 #endif
+	/*
+	 * The result field of the response structure has the
+	 * following semantics:
+	 *
+	 * 1. If all or some pages hot-added: Guest should return success.
+	 *
+	 * 2. If no pages could be hot-added:
+	 *
+	 * If the guest returns success, then the host
+	 * will not attempt any further hot-add operations. This
+	 * signifies a permanent failure.
+	 *
+	 * If the guest returns failure, then this failure will be
+	 * treated as a transient failure and the host may retry the
+	 * hot-add operation after some delay.
+	 */
 	if (resp.page_count > 0)
 		resp.result = 1;
+	else if (!do_hot_add)
+		resp.result = 1;
 	else
 		resp.result = 0;
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
