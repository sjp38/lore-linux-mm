Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 987166B000A
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:51:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i66so2881569wmc.1
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:51:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k38si1527222ede.321.2018.04.13.05.51.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 05:51:03 -0700 (PDT)
Date: Fri, 13 Apr 2018 14:51:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-ID: <20180413125101.GO17484@dhcp22.suse.cz>
References: <ed75d18c-f516-2feb-53a8-6d2836e1da59@virtuozzo.com>
 <20180413110200.GG17484@dhcp22.suse.cz>
 <06931a83-91d2-3dcf-31cf-0b98d82e957f@virtuozzo.com>
 <20180413112036.GH17484@dhcp22.suse.cz>
 <6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
 <20180413113855.GI17484@dhcp22.suse.cz>
 <8a81c801-35c8-767d-54b0-df9f1ca0abc0@virtuozzo.com>
 <20180413115454.GL17484@dhcp22.suse.cz>
 <abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
 <20180413121433.GM17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413121433.GM17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-04-18 14:14:33, Michal Hocko wrote:
[...]
> Well, this is probably a matter of taste. I will not argue. I will not
> object if Johannes is OK with your patch. But the whole thing confused
> hell out of me so I would rather un-clutter it...

In other words, this

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8c2ed1c2b72c..ca7e981a8a1a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4351,6 +4351,14 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
 
+	/*
+	 * We are trying to remove the idr key when the last memcg
+	 * reference drops which can be sooner than when the last
+	 * css reference is dropped to recycle ids faster.
+	 */
+	if (memcg->id.id > 0)
+		idr_remove(&mem_cgroup_idr, memcg->id.id);
+
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->stat_cpu);
@@ -4411,8 +4419,6 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
 fail:
-	if (memcg->id.id > 0)
-		idr_remove(&mem_cgroup_idr, memcg->id.id);
 	__mem_cgroup_free(memcg);
 	return NULL;
 }
-- 
Michal Hocko
SUSE Labs
