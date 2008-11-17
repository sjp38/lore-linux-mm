Date: Tue, 18 Nov 2008 00:27:19 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: [PATCH mmotm] memcg: fix argument for kunmap_atomic
Message-Id: <20081118002719.532ce4cf.d-nishimura@mtf.biglobe.ne.jp>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Li Zefan <lizf@cn.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

kunmap_atomic() should take kmapped address as argument.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
This patch is fix for memcg-swap-cgroup-for-remembering-usage.patch

 mm/page_cgroup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index b0ea401..9c6ead1 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -350,7 +350,7 @@ struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
 	sc += pos;
 	old = sc->val;
 	sc->val = mem;
-	kunmap_atomic(mappage, KM_USER0);
+	kunmap_atomic((void *)sc, KM_USER0);
 	spin_unlock_irqrestore(&ctrl->lock, flags);
 	return old;
 }
@@ -384,7 +384,7 @@ struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
 	sc = kmap_atomic(mappage, KM_USER0);
 	sc += pos;
 	ret = sc->val;
-	kunmap_atomic(mappage, KM_USER0);
+	kunmap_atomic((void *)sc, KM_USER0);
 	spin_unlock_irqrestore(&ctrl->lock, flags);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
