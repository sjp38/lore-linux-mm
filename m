Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBB6900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:24:21 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5MJBLs4016040
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 13:11:21 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5MJNwQl169390
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 13:24:01 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5MJNveu005691
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 13:23:57 -0600
Message-ID: <4E024122.5020601@linux.vnet.ibm.com>
Date: Wed, 22 Jun 2011 14:23:14 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] Add zv_pool_pages_count to zcache sysfs
References: <4E023F61.8080904@linux.vnet.ibm.com>
In-Reply-To: <4E023F61.8080904@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>

This attribute returns the number of pages currently
in use by the xvmalloc pool used to store persistent
pages compressed by zcache. This attribute, in combination
with the curr_pages attribute of frontswap, can be used
to calculate the effective compression of frontswap
(i.e. zv_pool_pages_count/curr_pages)

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
  drivers/staging/zcache/zcache.c |   20 ++++++++++++++++++++
  1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zcache/zcache.c 
b/drivers/staging/zcache/zcache.c
index 77ac2d4..9821d88 100644
--- a/drivers/staging/zcache/zcache.c
+++ b/drivers/staging/zcache/zcache.c
@@ -684,6 +684,23 @@ static struct {
  	struct xv_pool *xvpool;
  } zcache_client;

+#ifdef CONFIG_SYSFS
+static int zv_show_pool_pages_count(char *buf)
+{
+	char *p = buf;
+	unsigned long numpages;
+
+	if (zcache_client.xvpool == NULL)
+		p += sprintf(p, "%d\n", 0);
+	else {
+		numpages = xv_get_total_size_bytes(zcache_client.xvpool);
+		p += sprintf(p, "%lu\n", numpages >> PAGE_SHIFT);
+	}
+
+	return p - buf;
+}
+#endif
+
  /*
   * Tmem operations assume the poolid implies the invoking client.
   * Zcache only has one client (the kernel itself), so translate
@@ -1130,6 +1147,8 @@ ZCACHE_SYSFS_RO_CUSTOM(zbud_unbuddied_list_counts,
  			zbud_show_unbuddied_list_counts);
  ZCACHE_SYSFS_RO_CUSTOM(zbud_cumul_chunk_counts,
  			zbud_show_cumul_chunk_counts);
+ZCACHE_SYSFS_RO_CUSTOM(zv_pool_pages_count,
+			zv_show_pool_pages_count);

  static struct attribute *zcache_attrs[] = {
  	&zcache_curr_obj_count_attr.attr,
@@ -1160,6 +1179,7 @@ static struct attribute *zcache_attrs[] = {
  	&zcache_aborted_shrink_attr.attr,
  	&zcache_zbud_unbuddied_list_counts_attr.attr,
  	&zcache_zbud_cumul_chunk_counts_attr.attr,
+	&zcache_zv_pool_pages_count_attr.attr,
  	NULL,
  };

-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
