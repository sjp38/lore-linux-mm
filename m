Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 35A146B0036
	for <linux-mm@kvack.org>; Sat, 14 Sep 2013 19:45:56 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 15 Sep 2013 05:08:50 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 2A88F1258051
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:15:56 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8ENlvA836831446
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:17:57 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8ENjo8e017533
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:15:50 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [RESEND PATCH v5 3/4] mm/vmalloc: revert "mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead of show_numa_info"
Date: Sun, 15 Sep 2013 07:45:41 +0800
Message-Id: <1379202342-23140-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 *v2 -> v3: revert commit d157a558 directly

The VM_UNINITIALIZED/VM_UNLIST flag introduced by commit f5252e00(mm: avoid
null pointer access in vm_struct via /proc/vmallocinfo) is used to avoid
accessing the pages field with unallocated page when show_numa_info() is
called. This patch move the check just before show_numa_info in order that
some messages still can be dumped via /proc/vmallocinfo. This patch revert 
commit d157a558 (mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead 
of show_numa_info);

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmalloc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e3ec8b4..5368b17 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2562,6 +2562,11 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 		if (!counters)
 			return;
 
+		/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
+		smp_rmb();
+		if (v->flags & VM_UNINITIALIZED)
+			return;
+
 		memset(counters, 0, nr_node_ids * sizeof(unsigned int));
 
 		for (nr = 0; nr < v->nr_pages; nr++)
@@ -2590,11 +2595,6 @@ static int s_show(struct seq_file *m, void *p)
 
 	v = va->vm;
 
-	/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
-	smp_rmb();
-	if (v->flags & VM_UNINITIALIZED)
-		return 0;
-
 	seq_printf(m, "0x%pK-0x%pK %7ld",
 		v->addr, v->addr + v->size, v->size);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
