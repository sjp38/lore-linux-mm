Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 9A33E6B0033
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 20:50:18 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 3 Jul 2013 10:47:24 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 7C4983578053
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:50:11 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r630o2Jt54329584
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 10:50:02 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r630oAZv006954
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 10:50:11 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 3/5] mm/slab: Fix /proc/slabinfo unwriteable for slab
Date: Wed,  3 Jul 2013 08:49:51 +0800
Message-Id: <1372812593-7617-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Slab have some tunables like limit, batchcount, and sharedfactor can be
tuned through function slabinfo_write. Commit (b7454ad3: mm/sl[au]b: Move
slabinfo processing to slab_common.c) uncorrectly change /proc/slabinfo
unwriteable for slab, this patch fix it by revert to original mode.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slab_common.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index d161b81..6a5deda 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -497,6 +497,13 @@ void __init create_kmalloc_caches(unsigned long flags)
 
 
 #ifdef CONFIG_SLABINFO
+
+#ifdef CONFIG_SLAB
+#define SLABINFO_RIGHTS (S_IWUSR | S_IRUSR)
+#else
+#define SLABINFO_RIGHTS S_IRUSR
+#endif
+
 void print_slabinfo_header(struct seq_file *m)
 {
 	/*
@@ -633,7 +640,8 @@ static const struct file_operations proc_slabinfo_operations = {
 
 static int __init slab_proc_init(void)
 {
-	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
+	proc_create("slabinfo", SLABINFO_RIGHTS, NULL,
+						&proc_slabinfo_operations);
 	return 0;
 }
 module_init(slab_proc_init);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
