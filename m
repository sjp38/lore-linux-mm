Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id CB9306B0039
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 20:26:18 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 05:51:14 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 608DA1258023
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 05:57:37 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3A0Q9xQ5964276
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 05:56:09 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3A0QCXH002719
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 00:26:12 GMT
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 04/10] staging: ramster: Provide accessory functions for counter decrease
Date: Wed, 10 Apr 2013 08:25:54 +0800
Message-Id: <1365553560-32258-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

This patch enables these functions to be wrapped and
can disable/enable this with CONFIG_DEBUG_FS.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/ramster/ramster.c |   32 ++++++++++++++++++------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/zcache/ramster/ramster.c b/drivers/staging/zcache/ramster/ramster.c
index b60e884..c3d7f96 100644
--- a/drivers/staging/zcache/ramster/ramster.c
+++ b/drivers/staging/zcache/ramster/ramster.c
@@ -73,6 +73,10 @@ static inline void inc_ramster_flnodes(void)
 	if (ramster_flnodes > ramster_flnodes_max)
 		ramster_flnodes_max = ramster_flnodes;
 }
+static inline void dec_ramster_flnodes(void)
+{
+	ramster_flnodes = atomic_dec_return(&ramster_flnodes_atomic);
+}
 static ssize_t ramster_foreign_eph_pages;
 static atomic_t ramster_foreign_eph_pages_atomic = ATOMIC_INIT(0);
 static ssize_t ramster_foreign_eph_pages_max;
@@ -83,6 +87,11 @@ static inline void inc_ramster_foreign_eph_pages(void)
 	if (ramster_foreign_eph_pages > ramster_foreign_eph_pages_max)
 		ramster_foreign_eph_pages_max = ramster_foreign_eph_pages;
 }
+static inline void dec_ramster_foreign_eph_pages(void)
+{
+	ramster_foreign_eph_pages = atomic_dec_return(
+			&ramster_foreign_eph_pages_atomic);
+}
 static ssize_t ramster_foreign_pers_pages;
 static atomic_t ramster_foreign_pers_pages_atomic = ATOMIC_INIT(0);
 static ssize_t ramster_foreign_pers_pages_max;
@@ -93,6 +102,11 @@ static inline void inc_ramster_foreign_pers_pages(void)
 	if (ramster_foreign_pers_pages > ramster_foreign_pers_pages_max)
 		ramster_foreign_pers_pages_max = ramster_foreign_pers_pages;
 }
+static inline void dec_ramster_foreign_pers_pages(void)
+{
+	ramster_foreign_pers_pages = atomic_dec_return(
+		&ramster_foreign_pers_pages_atomic);
+}
 static ssize_t ramster_eph_pages_remoted;
 static ssize_t ramster_pers_pages_remoted;
 static ssize_t ramster_eph_pages_remote_failed;
@@ -188,10 +202,8 @@ static struct flushlist_node *ramster_flnode_alloc(struct tmem_pool *pool)
 static void ramster_flnode_free(struct flushlist_node *flnode,
 				struct tmem_pool *pool)
 {
-	int flnodes;
-
-	flnodes = atomic_dec_return(&ramster_flnodes_atomic);
-	BUG_ON(flnodes < 0);
+	dec_ramster_flnodes();
+	BUG_ON(ramster_flnodes < 0);
 	kmem_cache_free(ramster_flnode_cache, flnode);
 }
 
@@ -484,26 +496,20 @@ void *ramster_pampd_free(void *pampd, struct tmem_pool *pool,
 
 void ramster_count_foreign_pages(bool eph, int count)
 {
-	int c;
-
 	BUG_ON(count != 1 && count != -1);
 	if (eph) {
 		if (count > 0) {
 			inc_ramster_foreign_eph_pages();
 		} else {
-			c = atomic_dec_return(&ramster_foreign_eph_pages_atomic);
-			WARN_ON_ONCE(c < 0);
+			dec_ramster_foreign_eph_pages();
+			WARN_ON_ONCE(ramster_foreign_eph_pages < 0);
 		}
-		ramster_foreign_eph_pages = c;
 	} else {
 		if (count > 0) {
 			inc_ramster_foreign_pers_pages();
 		} else {
-			c = atomic_dec_return(
-					&ramster_foreign_pers_pages_atomic);
-			WARN_ON_ONCE(c < 0);
+			WARN_ON_ONCE(ramster_foreign_pers_pages < 0);
 		}
-		ramster_foreign_pers_pages = c;
 	}
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
