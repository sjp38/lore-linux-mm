Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 7B5EE6B0036
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 08:36:00 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 2 Sep 2013 17:56:41 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 27203E005A
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 18:06:37 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r82CbfYr35979426
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 18:07:41 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r82CZsxK013116
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 18:05:54 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 3/3] mm/vmalloc: move VM_UNINITIALIZED just before show_numa_info
Date: Mon,  2 Sep 2013 20:35:45 +0800
Message-Id: <1378125345-13228-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1378125345-13228-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1378125345-13228-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

The VM_UNINITIALIZED/VM_UNLIST flag introduced by commit f5252e00(mm: avoid 
null pointer access in vm_struct via /proc/vmallocinfo) is used to avoid 
accessing the pages field with unallocated page when show_numa_info() is 
called. This patch move the check just before show_numa_info in order that 
some messages still can be dumped via /proc/vmallocinfo.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmalloc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e3ec8b4..c4720cd 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2590,11 +2590,6 @@ static int s_show(struct seq_file *m, void *p)
 
 	v = va->vm;
 
-	/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
-	smp_rmb();
-	if (v->flags & VM_UNINITIALIZED)
-		return 0;
-
 	seq_printf(m, "0x%pK-0x%pK %7ld",
 		v->addr, v->addr + v->size, v->size);
 
@@ -2622,6 +2617,11 @@ static int s_show(struct seq_file *m, void *p)
 	if (v->flags & VM_VPAGES)
 		seq_printf(m, " vpages");
 
+	/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
+	smp_rmb();
+	if (v->flags & VM_UNINITIALIZED)
+		return;
+
 	show_numa_info(m, v);
 	seq_putc(m, '\n');
 	return 0;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
