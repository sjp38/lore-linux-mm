Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 55D2B6B0044
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 17:59:36 -0500 (EST)
Received: by mail-fx0-f213.google.com with SMTP id 5so1597054fxm.28
        for <linux-mm@kvack.org>; Fri, 11 Dec 2009 14:59:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH RFC v2 2/4] memcg: extract mem_group_usage() from mem_cgroup_read()
Date: Sat, 12 Dec 2009 00:59:17 +0200
Message-Id: <c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
In-Reply-To: <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
References: <cover.1260571675.git.kirill@shutemov.name>
 <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
In-Reply-To: <cover.1260571675.git.kirill@shutemov.name>
References: <cover.1260571675.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

Helper to get memory or mem+swap usage of the cgroup.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |   53 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c31a310..0ff65ed 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2510,39 +2510,50 @@ mem_cgroup_get_recursive_idx_stat(struct mem_cgroup *mem,
 	*val = d.val;
 }
 
+static inline u64 mem_cgroup_usage(struct mem_cgroup *mem, bool swap)
+{
+	u64 idx_val, val;
+
+	if (!mem_cgroup_is_root(mem)) {
+		if (!swap)
+			return res_counter_read_u64(&mem->res, RES_USAGE);
+		else
+			return res_counter_read_u64(&mem->memsw, RES_USAGE);
+	}
+
+	mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_CACHE, &idx_val);
+	val = idx_val;
+	mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_RSS, &idx_val);
+	val += idx_val;
+
+	if (swap) {
+		mem_cgroup_get_recursive_idx_stat(mem,
+				MEM_CGROUP_STAT_SWAPOUT, &idx_val);
+		val += idx_val;
+	}
+
+	return val << PAGE_SHIFT;
+}
+
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	u64 idx_val, val;
+	u64 val;
 	int type, name;
 
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
 	switch (type) {
 	case _MEM:
-		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_CACHE, &idx_val);
-			val = idx_val;
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_RSS, &idx_val);
-			val += idx_val;
-			val <<= PAGE_SHIFT;
-		} else
+		if (name == RES_USAGE)
+			val = mem_cgroup_usage(mem, false);
+		else
 			val = res_counter_read_u64(&mem->res, name);
 		break;
 	case _MEMSWAP:
-		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_CACHE, &idx_val);
-			val = idx_val;
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_RSS, &idx_val);
-			val += idx_val;
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_SWAPOUT, &idx_val);
-			val <<= PAGE_SHIFT;
-		} else
+		if (name == RES_USAGE)
+			val = mem_cgroup_usage(mem, true);
+		else
 			val = res_counter_read_u64(&mem->memsw, name);
 		break;
 	default:
-- 
1.6.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
