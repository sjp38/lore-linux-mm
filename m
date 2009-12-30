Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5E46060021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 10:58:16 -0500 (EST)
Received: by mail-fx0-f228.google.com with SMTP id 28so3274160fxm.6
        for <linux-mm@kvack.org>; Wed, 30 Dec 2009 07:58:14 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH v5 2/4] memcg: extract mem_group_usage() from mem_cgroup_read()
Date: Wed, 30 Dec 2009 17:57:57 +0200
Message-Id: <34fedc324199dd64149889ed6eac5d8f9441a9db.1262186098.git.kirill@shutemov.name>
In-Reply-To: <9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
References: <cover.1262186097.git.kirill@shutemov.name>
 <9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
In-Reply-To: <cover.1262186097.git.kirill@shutemov.name>
References: <cover.1262186097.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

Helper to get memory or mem+swap usage of the cgroup.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   54 ++++++++++++++++++++++++++++++++----------------------
 1 files changed, 32 insertions(+), 22 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 488b644..1d71cb4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2722,40 +2722,50 @@ mem_cgroup_get_recursive_idx_stat(struct mem_cgroup *mem,
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
-			val += idx_val;
-			val <<= PAGE_SHIFT;
-		} else
+		if (name == RES_USAGE)
+			val = mem_cgroup_usage(mem, true);
+		else
 			val = res_counter_read_u64(&mem->memsw, name);
 		break;
 	default:
-- 
1.6.5.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
