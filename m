Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 0C79C6B00EB
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:01 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 04/16] block: add sysfs attributes for runtime control of dpmg and swapin
Date: Thu, 3 May 2012 19:53:03 +0530
Message-ID: <1336054995-22988-5-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

sysfs entries for DPMG and SWAPIN requests so that they can
be set/reset from userspace.

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 block/blk-sysfs.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index cf15001..764de9f 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -213,6 +213,8 @@ queue_store_##name(struct request_queue *q, const char *page, size_t count) \
 }
 
 QUEUE_SYSFS_BIT_FNS(nonrot, NONROT, 1);
+QUEUE_SYSFS_BIT_FNS(expedite_dmpg, EXP_DMPG, 0);
+QUEUE_SYSFS_BIT_FNS(expedite_swapin, EXP_SWAPIN, 0);
 QUEUE_SYSFS_BIT_FNS(random, ADD_RANDOM, 0);
 QUEUE_SYSFS_BIT_FNS(iostats, IO_STAT, 0);
 #undef QUEUE_SYSFS_BIT_FNS
@@ -387,6 +389,18 @@ static struct queue_sysfs_entry queue_random_entry = {
 	.store = queue_store_random,
 };
 
+static struct queue_sysfs_entry queue_dmpg_entry = {
+	.attr = {.name = "expedite_demandpaging", .mode = S_IRUGO | S_IWUSR },
+	.show = queue_show_expedite_dmpg,
+	.store = queue_store_expedite_dmpg,
+};
+
+static struct queue_sysfs_entry queue_swapin_entry = {
+	.attr = {.name = "expedite_swapping", .mode = S_IRUGO | S_IWUSR },
+	.show = queue_show_expedite_swapin,
+	.store = queue_store_expedite_swapin,
+};
+
 static struct attribute *default_attrs[] = {
 	&queue_requests_entry.attr,
 	&queue_ra_entry.attr,
@@ -409,6 +423,8 @@ static struct attribute *default_attrs[] = {
 	&queue_rq_affinity_entry.attr,
 	&queue_iostats_entry.attr,
 	&queue_random_entry.attr,
+	&queue_dmpg_entry.attr,
+	&queue_swapin_entry.attr,
 	NULL,
 };
 
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
