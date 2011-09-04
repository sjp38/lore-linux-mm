Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D02D1900146
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 21:15:50 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH] memcg: drain all stocks for the cgroup before read usage
Date: Sun,  4 Sep 2011 04:15:33 +0300
Message-Id: <1315098933-29464-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

From: "Kirill A. Shutemov" <kirill@shutemov.name>

Currently, mem_cgroup_usage() for non-root cgroup returns usage
including stocks.

Let's drain all socks before read resource counter value. It makes
memory{,.memcg}.usage_in_bytes and memory.stat consistent.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ebd1e86..e091022 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3943,6 +3943,7 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *mem, bool swap)
 	u64 val;
 
 	if (!mem_cgroup_is_root(mem)) {
+		drain_all_stock_sync(mem);
 		if (!swap)
 			return res_counter_read_u64(&mem->res, RES_USAGE);
 		else
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
