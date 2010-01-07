Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 23D546B00AB
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 23:09:29 -0500 (EST)
Date: Thu, 7 Jan 2010 13:06:09 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm] build fix for
 memcg-move-charges-of-anonymous-swap.patch
Message-Id: <20100107130609.31fe83dc.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100107120233.f244d4b7.kamezawa.hiroyu@jp.fujitsu.com>
References: <201001062259.o06MxQrp023236@imap1.linux-foundation.org>
	<20100106171058.f1d6f393.randy.dunlap@oracle.com>
	<20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
	<20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107115901.594330d0.nishimura@mxp.nes.nec.co.jp>
	<20100107120233.f244d4b7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

build fix in !CONFIG_SWAP case.

  CC      mm/memcontrol.o
mm/memcontrol.c: In function 'is_target_pte_for_mc':
mm/memcontrol.c:3648: error: implicit declaration of function 'mem_cgroup_count_swap_user'
make[1]: *** [mm/memcontrol.o] Error 1
make: *** [mm] Error 2

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
This can be applied after memcg-move-charges-of-anonymous-swap.patch.

 include/linux/swap.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d9b06f7..2e1d5c9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -287,6 +287,10 @@ extern int shmem_unuse(swp_entry_t entry, struct page *page);
 
 extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+extern int mem_cgroup_count_swap_user(swp_entry_t ent, struct page **pagep);
+#endif
+
 #ifdef CONFIG_SWAP
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
@@ -356,7 +360,6 @@ static inline void disable_swap_token(void)
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
-extern int mem_cgroup_count_swap_user(swp_entry_t ent, struct page **pagep);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
