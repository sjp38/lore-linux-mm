Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id EAC0A6B0033
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 21:03:08 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so5309102pdj.36
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 18:03:08 -0700 (PDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 25 Sep 2013 11:03:01 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 8EC522BB0052
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:02:58 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8P12jJT10682856
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:02:47 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8P12uht021714
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:02:56 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v7 3/4] mm/vmalloc: revert "mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead of show_numa_info"
Date: Wed, 25 Sep 2013 09:02:43 +0800
Message-Id: <1380070964-12975-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1380070964-12975-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1380070964-12975-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
 mm/vmalloc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7647e69..e523a14 100644
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
@@ -2587,11 +2592,6 @@ static int s_show(struct seq_file *m, void *p)
 
 	v = va->vm;
 
-	/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
-	smp_rmb();
-	if (v->flags & VM_UNINITIALIZED)
-		return 0;
-
 	seq_printf(m, "0x%pK-0x%pK %7ld",
 		v->addr, v->addr + v->size, v->size);
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
