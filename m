Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 828ED4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 04:58:34 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id w123so66678580pfb.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 01:58:34 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sm10si22975190pab.78.2016.02.05.01.58.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 01:58:33 -0800 (PST)
Date: Fri, 5 Feb 2016 12:58:21 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/3] mm: memcontrol: make tree_{stat,events} fetch all
 stats
Message-ID: <20160205095821.GA29522@esperanza>
References: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
 <20160204204540.GD8208@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160204204540.GD8208@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 04, 2016 at 03:45:40PM -0500, Johannes Weiner wrote:
> On Thu, Feb 04, 2016 at 04:03:37PM +0300, Vladimir Davydov wrote:
> > Currently, tree_{stat,events} helpers can only get one stat index at a
> > time, so when there are a lot of stats to be reported one has to call it
> > over and over again (see memory_stat_show). This is neither effective,
> > nor does it look good. Instead, let's make these helpers take a snapshot
> > of all available counters.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> This looks much better, and most of the callstacks involved here are
> very flat, so the increased stack consumption should be alright.
> 
> The only exception there is the threshold code, which can happen from
> the direct reclaim path and thus with a fairly deep stack already.

Yeah, I missed this case. Thought mem_cgroup_usage is only used for
reporting to userspace. Thanks for catching this.

> 
> Would it be better to leave mem_cgroup_usage() alone, open-code it,
> and then use tree_stat() and tree_events() only for v2 memory.stat?
> 

Definitely.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 59f74074c04c..4f2afb9a2d67 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2745,14 +2745,20 @@ static void tree_events(struct mem_cgroup *memcg, unsigned long *events)
 
 static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
-	unsigned long stat[MEMCG_NR_STAT];
-	unsigned long val;
+	unsigned long val = 0;
 
 	if (mem_cgroup_is_root(memcg)) {
-		tree_stat(memcg, stat);
-		val = stat[MEM_CGROUP_STAT_CACHE] + stat[MEM_CGROUP_STAT_RSS];
-		if (swap)
-			val += stat[MEM_CGROUP_STAT_SWAP];
+		struct mem_cgroup *iter;
+
+		for_each_mem_cgroup_tree(iter, memcg) {
+			val += mem_cgroup_read_stat(iter,
+					MEM_CGROUP_STAT_CACHE);
+			val += mem_cgroup_read_stat(iter,
+					MEM_CGROUP_STAT_RSS);
+			if (swap)
+				val += mem_cgroup_read_stat(iter,
+						MEM_CGROUP_STAT_SWAP);
+		}
 	} else {
 		if (!swap)
 			val = page_counter_read(&memcg->memory);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
