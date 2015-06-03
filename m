Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7D0900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 11:21:10 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so9778581pdb.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 08:21:10 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id x5si1473113pbt.0.2015.06.03.08.21.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 08:21:09 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so9736418pdb.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 08:21:09 -0700 (PDT)
Date: Thu, 4 Jun 2015 00:21:01 +0900
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 -mm 2/2] memcg: convert mem_cgroup->under_oom from
 atomic_t to int
Message-ID: <20150603152101.GG20091@mtj.duckdns.org>
References: <20150603023824.GA7579@mtj.duckdns.org>
 <20150603023859.GB7579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603023859.GB7579@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

memcg->under_oom tracks whether the memcg is under OOM conditions and
is an atomic_t counter managed with mem_cgroup_[un]mark_under_oom().
While atomic_t appears to be simple synchronization-wise, when used as
a synchronization construct like here, it's trickier and more
error-prone due to weak memory ordering rules, especially around
atomic_read(), and false sense of security.

For example, both non-trivial read sites of memcg->under_oom are a bit
problematic although not being actually broken.

* mem_cgroup_oom_register_event()

  It isn't explicit what guarantees the memory ordering between event
  addition and memcg->under_oom check.  This isn't broken only because
  memcg_oom_lock is used for both event list and memcg->oom_lock.

* memcg_oom_recover()

  The lockless test doesn't have any explanation why this would be
  safe.

mem_cgroup_[un]mark_under_oom() are very cold paths and there's no
point in avoiding locking memcg_oom_lock there.  This patch converts
memcg->under_oom from atomic_t to int, puts their modifications under
memcg_oom_lock and documents why the lockless test in
memcg_oom_recover() is safe.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
Update of the 1/2 patch causes a trivial context conflict.  Refreshed.

Thanks.

 mm/memcontrol.c |   29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -285,8 +285,9 @@ struct mem_cgroup {
 	 */
 	bool use_hierarchy;
 
+	/* protected by memcg_oom_lock */
 	bool		oom_lock;
-	atomic_t	under_oom;
+	int		under_oom;
 
 	int	swappiness;
 	/* OOM-Killer disable */
@@ -1809,8 +1810,10 @@ static void mem_cgroup_mark_under_oom(st
 {
 	struct mem_cgroup *iter;
 
+	spin_lock(&memcg_oom_lock);
 	for_each_mem_cgroup_tree(iter, memcg)
-		atomic_inc(&iter->under_oom);
+		iter->under_oom++;
+	spin_unlock(&memcg_oom_lock);
 }
 
 static void mem_cgroup_unmark_under_oom(struct mem_cgroup *memcg)
@@ -1819,11 +1822,13 @@ static void mem_cgroup_unmark_under_oom(
 
 	/*
 	 * When a new child is created while the hierarchy is under oom,
-	 * mem_cgroup_oom_lock() may not be called. We have to use
-	 * atomic_add_unless() here.
+	 * mem_cgroup_oom_lock() may not be called. Watch for underflow.
 	 */
+	spin_lock(&memcg_oom_lock);
 	for_each_mem_cgroup_tree(iter, memcg)
-		atomic_add_unless(&iter->under_oom, -1, 0);
+		if (iter->under_oom > 0)
+			iter->under_oom--;
+	spin_unlock(&memcg_oom_lock);
 }
 
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
@@ -1851,7 +1856,15 @@ static int memcg_oom_wake_function(wait_
 
 static void memcg_oom_recover(struct mem_cgroup *memcg)
 {
-	if (memcg && atomic_read(&memcg->under_oom))
+	/*
+	 * For the following lockless ->under_oom test, the only required
+	 * guarantee is that it must see the state asserted by an OOM when
+	 * this function is called as a result of userland actions
+	 * triggered by the notification of the OOM.  This is trivially
+	 * achieved by invoking mem_cgroup_mark_under_oom() before
+	 * triggering notification.
+	 */
+	if (memcg && memcg->under_oom)
 		__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
 }
 
@@ -3860,7 +3873,7 @@ static int mem_cgroup_oom_register_event
 	list_add(&event->list, &memcg->oom_notify);
 
 	/* already in OOM ? */
-	if (atomic_read(&memcg->under_oom))
+	if (memcg->under_oom)
 		eventfd_signal(eventfd, 1);
 	spin_unlock(&memcg_oom_lock);
 
@@ -3889,7 +3902,7 @@ static int mem_cgroup_oom_control_read(s
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(sf));
 
 	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
-	seq_printf(sf, "under_oom %d\n", (bool)atomic_read(&memcg->under_oom));
+	seq_printf(sf, "under_oom %d\n", (bool)memcg->under_oom);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
