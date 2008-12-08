From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 1/4] memcg: don't trigger oom at page migration
Date: Mon, 8 Dec 2008 11:02:42 +0900
Message-ID: <20081208110242.477e0837.nishimura@mxp.nes.nec.co.jp>
References: <20081208105824.f8f5d67b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755903AbYLHCeC@vger.kernel.org>
In-Reply-To: <20081208105824.f8f5d67b.nishimura@mxp.nes.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-Id: linux-mm.kvack.org

I think triggering OOM at mem_cgroup_prepare_migration would be just a bit
overkill.
Returning -ENOMEM would be enough for mem_cgroup_prepare_migration.
The caller would handle the case anyway.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a4854a7..0683459 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1331,7 +1331,7 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 	unlock_page_cgroup(pc);
 
 	if (mem) {
-		ret = mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
 		css_put(&mem->css);
 	}
 	*ptr = mem;
