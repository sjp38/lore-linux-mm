Date: Fri, 26 Sep 2008 13:05:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/12] memcg updates v5
Message-Id: <20080926130534.e16c9317.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926120019.33d58ca4.nishimura@mxp.nes.nec.co.jp>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926113228.ee377330.nishimura@mxp.nes.nec.co.jp>
	<20080926115810.b5fbae51.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926120408.39187294.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926120019.33d58ca4.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 12:00:19 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> I'll test it with updated version of 9-11 and report you back.
> 
Thank you. below is the new one...(Sorry!)

-Kame
==
Check LRU bit under lru_lock.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -340,11 +340,12 @@ void mem_cgroup_move_lists(struct page *
 	if (!trylock_page_cgroup(pc))
 		return;
 
-	if (PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
+	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
-		__mem_cgroup_move_lists(pc, lru);
+		if (PageCgroupLRU(pc))
+			__mem_cgroup_move_lists(pc, lru);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 	}
 	unlock_page_cgroup(pc);
@@ -564,8 +565,8 @@ __release_page_cgroup(struct memcg_percp
 			spin_lock(&mz->lru_lock);
 		}
 		if (!PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
-			__mem_cgroup_remove_list(mz, pc);
 			ClearPageCgroupLRU(pc);
+			__mem_cgroup_remove_list(mz, pc);
 		}
 	}
 	if (prev_mz)
@@ -597,8 +598,8 @@ __set_page_cgroup_lru(struct memcg_percp
 			spin_lock(&mz->lru_lock);
 		}
 		if (PageCgroupUsed(pc) && !PageCgroupLRU(pc)) {
-			SetPageCgroupLRU(pc);
 			__mem_cgroup_add_list(mz, pc);
+			SetPageCgroupLRU(pc);
 		}
 	}
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
