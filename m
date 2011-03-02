Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C81C88D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 03:38:31 -0500 (EST)
Received: by gyb13 with SMTP id 13so2949935gyb.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 00:38:30 -0800 (PST)
From: Liu Yuan <namei.unix@gmail.com>
Subject: [RFC PATCH 3/5] block: Make Page Cache counters work with sysfs
Date: Wed,  2 Mar 2011 16:38:08 +0800
Message-Id: <1299055090-23976-3-git-send-email-namei.unix@gmail.com>
In-Reply-To: <no>
References: <no>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

From: Liu Yuan <tailai.ly@taobao.com>

Three counters are exported to the userspace from
/sys/block/sdx/{,sdxx}/page_cache_stats.

Signed-off-by: Liu Yuan <tailai.ly@taobao.com>
---
 block/genhd.c         |    6 ++++++
 fs/partitions/check.c |   23 +++++++++++++++++++++++
 include/linux/genhd.h |    4 ++++
 3 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/block/genhd.c b/block/genhd.c
index cbf1112..af9e7f8 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -988,6 +988,9 @@ static struct device_attribute dev_attr_fail_timeout =
 	__ATTR(io-timeout-fail,  S_IRUGO|S_IWUSR, part_timeout_show,
 		part_timeout_store);
 #endif
+#ifdef CONFIG_PAGE_CACHE_ACCT
+static DEVICE_ATTR(page_cache_stats, S_IRUGO, part_page_cache_stats_show, NULL);
+#endif
 
 static struct attribute *disk_attrs[] = {
 	&dev_attr_range.attr,
@@ -1006,6 +1009,9 @@ static struct attribute *disk_attrs[] = {
 #ifdef CONFIG_FAIL_IO_TIMEOUT
 	&dev_attr_fail_timeout.attr,
 #endif
+#ifdef CONFIG_PAGE_CACHE_ACCT
+	&dev_attr_page_cache_stats.attr,
+#endif
 	NULL
 };
 
diff --git a/fs/partitions/check.c b/fs/partitions/check.c
index 9c21119..e882e95 100644
--- a/fs/partitions/check.c
+++ b/fs/partitions/check.c
@@ -316,6 +316,23 @@ ssize_t part_fail_store(struct device *dev,
 }
 #endif
 
+#ifdef CONFIG_PAGE_CACHE_ACCT
+ssize_t part_page_cache_stats_show(struct device *dev,
+					  struct device_attribute * attr,
+					  char *buf)
+{
+	struct hd_struct  *p = dev_to_part(dev);
+
+	return sprintf(buf,
+			"%8lu %8lu %8lu %8lu %8lu\n ",
+			part_stat_read(p, page_cache_readpages),
+			part_stat_read(p, page_cache_missed[READ]),
+			part_stat_read(p, page_cache_hit[READ]),
+			part_stat_read(p, page_cache_missed[WRITE]),
+			part_stat_read(p, page_cache_hit[WRITE]));
+}
+#endif
+
 static DEVICE_ATTR(partition, S_IRUGO, part_partition_show, NULL);
 static DEVICE_ATTR(start, S_IRUGO, part_start_show, NULL);
 static DEVICE_ATTR(size, S_IRUGO, part_size_show, NULL);
@@ -329,6 +346,9 @@ static DEVICE_ATTR(inflight, S_IRUGO, part_inflight_show, NULL);
 static struct device_attribute dev_attr_fail =
 	__ATTR(make-it-fail, S_IRUGO|S_IWUSR, part_fail_show, part_fail_store);
 #endif
+#ifdef CONFIG_PAGE_CACHE_ACCT
+static DEVICE_ATTR(page_cache_stats, S_IRUGO, part_page_cache_stats_show, NULL);
+#endif
 
 static struct attribute *part_attrs[] = {
 	&dev_attr_partition.attr,
@@ -342,6 +362,9 @@ static struct attribute *part_attrs[] = {
 #ifdef CONFIG_FAIL_MAKE_REQUEST
 	&dev_attr_fail.attr,
 #endif
+#ifdef CONFIG_PAGE_CACHE_ACCT
+	&dev_attr_page_cache_stats.attr,
+#endif
 	NULL
 };
 
diff --git a/include/linux/genhd.h b/include/linux/genhd.h
index 4f0257c..0ecd165 100644
--- a/include/linux/genhd.h
+++ b/include/linux/genhd.h
@@ -682,6 +682,10 @@ extern ssize_t part_fail_store(struct device *dev,
 			       struct device_attribute *attr,
 			       const char *buf, size_t count);
 #endif /* CONFIG_FAIL_MAKE_REQUEST */
+#ifdef CONFIG_PAGE_CACHE_ACCT
+extern ssize_t part_page_cache_stats_show(struct device *dev,
+					  struct device_attribute *attr, char *buf);
+#endif /*  CONFIG_PAGE_CACHE_ACCT */
 
 static inline void hd_ref_init(struct hd_struct *part)
 {
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
