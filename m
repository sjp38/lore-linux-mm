Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3C25F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:43:08 -0400 (EDT)
Date: Wed, 3 Jun 2009 11:50:27 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH mmotm 2/2] memcg: allow mem.limit bigger than memsw.limit
 iff unlimited
Message-Id: <20090603115027.80f9169b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
References: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Now users cannot set mem.limit bigger than memsw.limit.
This patch allows mem.limit bigger than memsw.limit iff mem.limit==unlimited.

By this, users can set memsw.limit without setting mem.limit.
I think it's usefull if users want to limit memsw only.
They must set mem.limit first and memsw.limit to the same value now for this purpose.
They can save the first step by this patch.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6629ed2..2b63cb1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1742,11 +1742,12 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		/*
 		 * Rather than hide all in some function, I do this in
 		 * open coded manner. You see what this really does.
-		 * We have to guarantee mem->res.limit < mem->memsw.limit.
+		 * We have to guarantee mem->res.limit < mem->memsw.limit,
+		 * except for mem->res.limit == RESOURCE_MAX(unlimited) case.
 		 */
 		mutex_lock(&set_limit_mutex);
 		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-		if (memswlimit < val) {
+		if (val != RESOURCE_MAX && memswlimit < val) {
 			ret = -EINVAL;
 			mutex_unlock(&set_limit_mutex);
 			break;
@@ -1789,11 +1790,12 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		/*
 		 * Rather than hide all in some function, I do this in
 		 * open coded manner. You see what this really does.
-		 * We have to guarantee mem->res.limit < mem->memsw.limit.
+		 * We have to guarantee mem->res.limit < mem->memsw.limit,
+		 * except for mem->res.limit == RESOURCE_MAX(unlimited) case.
 		 */
 		mutex_lock(&set_limit_mutex);
 		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-		if (memlimit > val) {
+		if (memlimit != RESOURCE_MAX && memlimit > val) {
 			ret = -EINVAL;
 			mutex_unlock(&set_limit_mutex);
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
