Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 442696B0069
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 06:23:32 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 24 Jun 2013 15:47:30 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 1BE1AE0055
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 15:52:56 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5OANcFE30670906
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 15:53:38 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5OANOtr005963
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:23:24 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 3/3] mm/slab: Fix /proc/slabinfo unwriteable for slab 
Date: Mon, 24 Jun 2013 18:23:14 +0800
Message-Id: <1372069394-26167-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
 mm/slab_common.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index d161b81..7fdde79 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -631,10 +631,20 @@ static const struct file_operations proc_slabinfo_operations = {
 	.release	= seq_release,
 };
 
+#ifdef CONFIG_SLAB
+static int __init slab_proc_init(void)
+{
+	proc_create("slabinfo", S_IWUSR | S_IRUSR, NULL, &proc_slabinfo_operations);
+	return 0;
+}
+#endif
+#ifdef CONFIG_SLUB
 static int __init slab_proc_init(void)
 {
 	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
 	return 0;
 }
+#endif
+
 module_init(slab_proc_init);
 #endif /* CONFIG_SLABINFO */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
