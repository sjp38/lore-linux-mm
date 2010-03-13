Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E82536B016D
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 09:56:38 -0500 (EST)
Received: by fxm2 with SMTP id 2so16299fxm.6
        for <linux-mm@kvack.org>; Sat, 13 Mar 2010 06:56:36 -0800 (PST)
Date: Sat, 13 Mar 2010 17:56:21 +0300
From: Dan Carpenter <error27@gmail.com>
Subject: [patch] memcontrol: fix potential null deref
Message-ID: <20100313145621.GA3569@bicker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

There was a potential null deref introduced in:
c62b1a3b31b5 memcg: use generic percpu instead of private implementation

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7973b52..e1e0996 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3691,8 +3691,10 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	else
 		mem = vmalloc(size);
 
-	if (mem)
-		memset(mem, 0, size);
+	if (!mem)
+		return NULL;
+
+	memset(mem, 0, size);
 	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!mem->stat) {
 		if (size < PAGE_SIZE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
