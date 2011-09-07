Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5594E6B016C
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 10:12:57 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p87DkViM029993
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 09:46:31 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p87E9Qxw249758
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 10:09:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p87E9O7h010374
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 10:09:26 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH v2 3/3] staging: zcache: add zv_page_count and zv_desc_count
Date: Wed,  7 Sep 2011 09:09:07 -0500
Message-Id: <1315404547-20075-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: dan.magenheimer@oracle.com, ngupta@vflare.org, cascardo@holoscopio.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, linux-mm@kvack.org, rcj@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, brking@linux.vnet.ibm.com, Seth Jennings <sjenning@linux.vnet.ibm.com>

This patch adds the zv_page_count and zv_desc_count attributes
to the zcache sysfs.  They are read-only attributes and return
the number of pages and the number of block descriptors in use
by the pool respectively.

These statistics can be used to calculate effective compression
and block descriptor overhead for the xcfmalloc allocator.

Using the frontswap curr_pages attribute, effective compression
is: zv_page_count / curr_pages

Using /proc/slabinfo to get the objsize for a xcf_desc_cache
object, descriptor overhead is: zv_desc_count * objsize

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index b07377b..6adbbbe 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -789,6 +789,24 @@ static int zv_cumul_dist_counts_show(char *buf)
 	return p - buf;
 }
 
+static int zv_page_count_show(char *buf)
+{
+	char *p = buf;
+	unsigned long count;
+	count = xcf_get_total_size_bytes(zcache_host.xcfmpool) >> PAGE_SHIFT;
+	p += sprintf(p, "%lu\n", count);
+	return p - buf;
+}
+
+static int zv_desc_count_show(char *buf)
+{
+	char *p = buf;
+	unsigned long count;
+	count = xcf_get_desc_count(zcache_host.xcfmpool);
+	p += sprintf(p, "%lu\n", count);
+	return p - buf;
+}
+
 /*
  * setting zv_max_zsize via sysfs causes all persistent (e.g. swap)
  * pages that don't compress to less than this value (including metadata
@@ -1477,6 +1495,10 @@ ZCACHE_SYSFS_RO_CUSTOM(zv_curr_dist_counts,
 			zv_curr_dist_counts_show);
 ZCACHE_SYSFS_RO_CUSTOM(zv_cumul_dist_counts,
 			zv_cumul_dist_counts_show);
+ZCACHE_SYSFS_RO_CUSTOM(zv_page_count,
+			zv_page_count_show);
+ZCACHE_SYSFS_RO_CUSTOM(zv_desc_count,
+			zv_desc_count_show);
 
 static struct attribute *zcache_attrs[] = {
 	&zcache_curr_obj_count_attr.attr,
@@ -1513,6 +1535,8 @@ static struct attribute *zcache_attrs[] = {
 	&zcache_zv_max_zsize_attr.attr,
 	&zcache_zv_max_mean_zsize_attr.attr,
 	&zcache_zv_page_count_policy_percent_attr.attr,
+	&zcache_zv_page_count_attr.attr,
+	&zcache_zv_desc_count_attr.attr,
 	NULL,
 };
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
