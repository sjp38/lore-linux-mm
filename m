Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CB0326B00B2
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 07:12:53 -0400 (EDT)
Received: by wyf23 with SMTP id 23so1895004wyf.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 04:12:51 -0700 (PDT)
Date: Thu, 28 Oct 2010 13:12:41 +0200
From: Dan Carpenter <error27@gmail.com>
Subject: [patch] memcg: null dereference on allocation failure
Message-ID: <20101028111241.GC6062@bicker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The original code had a null dereference if alloc_percpu() failed.
This was introduced in 711d3d2c9bc3 "memcg: cpu hotplug aware percpu
count updates"

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9a99cfa..2efa8ea 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4208,15 +4208,17 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 
 	memset(mem, 0, size);
 	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
-	if (!mem->stat) {
-		if (size < PAGE_SIZE)
-			kfree(mem);
-		else
-			vfree(mem);
-		mem = NULL;
-	}
+	if (!mem->stat)
+		goto out_free;
 	spin_lock_init(&mem->pcp_counter_lock);
 	return mem;
+
+out_free:
+	if (size < PAGE_SIZE)
+		kfree(mem);
+	else
+		vfree(mem);
+	return NULL;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
