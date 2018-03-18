Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0B66B0009
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 16:24:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j8so8394341pfh.13
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 13:24:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h70sor1838026pgc.377.2018.03.18.13.24.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 18 Mar 2018 13:24:53 -0700 (PDT)
Date: Sun, 18 Mar 2018 13:24:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm: memcg: remote memcg charging for kmem allocations
 fix
In-Reply-To: <20180305182951.34462-2-shakeelb@google.com>
Message-ID: <alpine.DEB.2.20.1803181318530.241887@chino.kir.corp.google.com>
References: <20180305182951.34462-1-shakeelb@google.com> <20180305182951.34462-2-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

fix build warning for CONFIG_SLOB:

mm/memcontrol.c:706:27: warning: 'get_mem_cgroup' defined but not used [-Wunused-function]
static struct mem_cgroup *get_mem_cgroup(struct mem_cgroup *memcg)

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -701,15 +701,6 @@ struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
-static struct mem_cgroup *get_mem_cgroup(struct mem_cgroup *memcg)
-{
-	rcu_read_lock();
-	if (!css_tryget_online(&memcg->css))
-		memcg = NULL;
-	rcu_read_unlock();
-	return memcg;
-}
-
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
@@ -2128,6 +2119,15 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 }
 
 #ifndef CONFIG_SLOB
+static struct mem_cgroup *get_mem_cgroup(struct mem_cgroup *memcg)
+{
+	rcu_read_lock();
+	if (!css_tryget_online(&memcg->css))
+		memcg = NULL;
+	rcu_read_unlock();
+	return memcg;
+}
+
 static int memcg_alloc_cache_id(void)
 {
 	int id, size;
