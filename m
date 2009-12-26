Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E940D620002
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 19:31:28 -0500 (EST)
Received: by mail-fx0-f228.google.com with SMTP id 28so417439fxm.6
        for <linux-mm@kvack.org>; Fri, 25 Dec 2009 16:31:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH v3 3/4] memcg: rework usage of stats by soft limit
Date: Sat, 26 Dec 2009 02:30:59 +0200
Message-Id: <8e6612d3d0cb5fcf9ab6495bbaf2578578ce8e91.1261786326.git.kirill@shutemov.name>
In-Reply-To: <4d7e4854676423c2d63663f6dbafb1eb9eecd500.1261786326.git.kirill@shutemov.name>
References: <cover.1261786326.git.kirill@shutemov.name>
 <d7bfc1a5360d5cb03ad263767cd2c3ad11cb5fc6.1261786326.git.kirill@shutemov.name>
 <4d7e4854676423c2d63663f6dbafb1eb9eecd500.1261786326.git.kirill@shutemov.name>
In-Reply-To: <cover.1261786326.git.kirill@shutemov.name>
References: <cover.1261786326.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

Instead of incrementing counter on each page in/out and comparing it
with constant, we set counter to constant, decrement counter on each
page in/out and compare it with zero. We want to make comparing as fast
as possible. On many RISC systems (probably not only RISC) comparing
with zero is more effective than comparing with a constant, since not
every constant can be immediate operand for compare instruction.

Also, I've renamed MEM_CGROUP_STAT_EVENTS to MEM_CGROUP_STAT_SOFTLIMIT,
since really it's not a generic counter.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1d71cb4..36eb7af 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -69,8 +69,9 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
-	MEM_CGROUP_STAT_EVENTS,	/* sum of pagein + pageout for internal use */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
+					used by soft limit implementation */
 
 	MEM_CGROUP_STAT_NSTATS,
 };
@@ -90,6 +91,13 @@ __mem_cgroup_stat_reset_safe(struct mem_cgroup_stat_cpu *stat,
 	stat->count[idx] = 0;
 }
 
+static inline void
+__mem_cgroup_stat_set(struct mem_cgroup_stat_cpu *stat,
+		enum mem_cgroup_stat_index idx, s64 val)
+{
+	stat->count[idx] = val;
+}
+
 static inline s64
 __mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
 				enum mem_cgroup_stat_index idx)
@@ -380,9 +388,10 @@ static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
 
 	cpu = get_cpu();
 	cpustat = &mem->stat.cpustat[cpu];
-	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
-	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
-		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
+	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_SOFTLIMIT);
+	if (unlikely(val < 0)) {
+		__mem_cgroup_stat_set(cpustat, MEM_CGROUP_STAT_SOFTLIMIT,
+				SOFTLIMIT_EVENTS_THRESH);
 		ret = true;
 	}
 	put_cpu();
@@ -515,7 +524,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 	else
 		__mem_cgroup_stat_add_safe(cpustat,
 				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_EVENTS, 1);
+	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT, -1);
 	put_cpu();
 }
 
-- 
1.6.5.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
