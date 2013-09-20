Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 65FE16B0033
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 08:32:05 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so327813pdj.12
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 05:32:05 -0700 (PDT)
Date: Fri, 20 Sep 2013 13:31:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 46/50] sched: numa: Prevent parallel updates to group
 stats during placement
Message-ID: <20130920123151.GX22421@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-47-git-send-email-mgorman@suse.de>
 <20130920095526.GT9326@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130920095526.GT9326@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 20, 2013 at 11:55:26AM +0200, Peter Zijlstra wrote:
> On Tue, Sep 10, 2013 at 10:32:26AM +0100, Mel Gorman wrote:
> > Having multiple tasks in a group go through task_numa_placement
> > simultaneously can lead to a task picking a wrong node to run on, because
> > the group stats may be in the middle of an update. This patch avoids
> > parallel updates by holding the numa_group lock during placement
> > decisions.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  kernel/sched/fair.c | 35 +++++++++++++++++++++++------------
> >  1 file changed, 23 insertions(+), 12 deletions(-)
> > 
> > diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> > index 3a92c58..4653f71 100644
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -1231,6 +1231,7 @@ static void task_numa_placement(struct task_struct *p)
> >  {
> >  	int seq, nid, max_nid = -1, max_group_nid = -1;
> >  	unsigned long max_faults = 0, max_group_faults = 0;
> > +	spinlock_t *group_lock = NULL;
> >  
> >  	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
> >  	if (p->numa_scan_seq == seq)
> > @@ -1239,6 +1240,12 @@ static void task_numa_placement(struct task_struct *p)
> >  	p->numa_migrate_seq++;
> >  	p->numa_scan_period_max = task_scan_max(p);
> >  
> > +	/* If the task is part of a group prevent parallel updates to group stats */
> > +	if (p->numa_group) {
> > +		group_lock = &p->numa_group->lock;
> > +		spin_lock(group_lock);
> > +	}
> > +
> >  	/* Find the node with the highest number of faults */
> >  	for_each_online_node(nid) {
> >  		unsigned long faults = 0, group_faults = 0;
> > @@ -1277,20 +1284,24 @@ static void task_numa_placement(struct task_struct *p)
> >  		}
> >  	}
> >  
> > +	if (p->numa_group) {
> > +		/*
> > +		 * If the preferred task and group nids are different, 
> > +		 * iterate over the nodes again to find the best place.
> > +		 */
> > +		if (max_nid != max_group_nid) {
> > +			unsigned long weight, max_weight = 0;
> > +
> > +			for_each_online_node(nid) {
> > +				weight = task_weight(p, nid) + group_weight(p, nid);
> > +				if (weight > max_weight) {
> > +					max_weight = weight;
> > +					max_nid = nid;
> > +				}
> >  			}
> >  		}
> > +
> > +		spin_unlock(group_lock);
> >  	}
> >  
> >  	/* Preferred node as the node with the most faults */
> 
> If you're going to hold locks you can also do away with all that
> atomic_long_*() nonsense :-)

Yep! Easily done, patch is untested but should be straight-forward.

---8<---
sched: numa: use longs for numa group fault stats

As Peter says "If you're going to hold locks you can also do away with all
that atomic_long_*() nonsense". Lock aquisition moved slightly to protect
the updates. numa_group faults stats type are still "long" to add a basic
sanity check for fault counts going negative.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 54 ++++++++++++++++++++++++-----------------------------
 1 file changed, 24 insertions(+), 30 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 04a2963..c09687d 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -897,8 +897,8 @@ struct numa_group {
 	struct list_head task_list;
 
 	struct rcu_head rcu;
-	atomic_long_t total_faults;
-	atomic_long_t faults[0];
+	long total_faults;
+	long faults[0];
 };
 
 pid_t task_numa_group_id(struct task_struct *p)
@@ -925,8 +925,7 @@ static inline unsigned long group_faults(struct task_struct *p, int nid)
 	if (!p->numa_group)
 		return 0;
 
-	return atomic_long_read(&p->numa_group->faults[2*nid]) +
-	       atomic_long_read(&p->numa_group->faults[2*nid+1]);
+	return p->numa_group->faults[2*nid] + p->numa_group->faults[2*nid+1];
 }
 
 /*
@@ -952,17 +951,10 @@ static inline unsigned long task_weight(struct task_struct *p, int nid)
 
 static inline unsigned long group_weight(struct task_struct *p, int nid)
 {
-	unsigned long total_faults;
-
-	if (!p->numa_group)
-		return 0;
-
-	total_faults = atomic_long_read(&p->numa_group->total_faults);
-
-	if (!total_faults)
+	if (!p->numa_group || !p->numa_group->total_faults)
 		return 0;
 
-	return 1200 * group_faults(p, nid) / total_faults;
+	return 1200 * group_faults(p, nid) / p->numa_group->total_faults;
 }
 
 static unsigned long weighted_cpuload(const int cpu);
@@ -1267,9 +1259,9 @@ static void task_numa_placement(struct task_struct *p)
 			p->total_numa_faults += diff;
 			if (p->numa_group) {
 				/* safe because we can only change our own group */
-				atomic_long_add(diff, &p->numa_group->faults[i]);
-				atomic_long_add(diff, &p->numa_group->total_faults);
-				group_faults += atomic_long_read(&p->numa_group->faults[i]);
+				p->numa_group->faults[i] += diff;
+				p->numa_group->total_faults += diff;
+				group_faults += p->numa_group->faults[i];
 			}
 		}
 
@@ -1343,7 +1335,7 @@ static void task_numa_group(struct task_struct *p, int cpupid)
 
 	if (unlikely(!p->numa_group)) {
 		unsigned int size = sizeof(struct numa_group) +
-			            2*nr_node_ids*sizeof(atomic_long_t);
+			            2*nr_node_ids*sizeof(long);
 
 		grp = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 		if (!grp)
@@ -1355,9 +1347,9 @@ static void task_numa_group(struct task_struct *p, int cpupid)
 		grp->gid = p->pid;
 
 		for (i = 0; i < 2*nr_node_ids; i++)
-			atomic_long_set(&grp->faults[i], p->numa_faults[i]);
+			grp->faults[i] = p->numa_faults[i];
 
-		atomic_long_set(&grp->total_faults, p->total_numa_faults);
+		grp->total_faults = p->total_numa_faults;
 
 		list_add(&p->numa_entry, &grp->task_list);
 		grp->nr_tasks++;
@@ -1402,14 +1394,15 @@ unlock:
 	if (!join)
 		return;
 
+	double_lock(&my_grp->lock, &grp->lock);
+
 	for (i = 0; i < 2*nr_node_ids; i++) {
-		atomic_long_sub(p->numa_faults[i], &my_grp->faults[i]);
-		atomic_long_add(p->numa_faults[i], &grp->faults[i]);
+		my_grp->faults[i] -= p->numa_faults[i];
+		grp->faults[i] -= p->numa_faults[i];
+		WARN_ON_ONCE(grp->faults[i] < 0);
 	}
-	atomic_long_sub(p->total_numa_faults, &my_grp->total_faults);
-	atomic_long_add(p->total_numa_faults, &grp->total_faults);
-
-	double_lock(&my_grp->lock, &grp->lock);
+	my_grp->total_faults -= p->total_numa_faults;
+	grp->total_faults -= p->total_numa_faults;
 
 	list_move(&p->numa_entry, &grp->task_list);
 	my_grp->nr_tasks--;
@@ -1430,12 +1423,13 @@ void task_numa_free(struct task_struct *p)
 	void *numa_faults = p->numa_faults;
 
 	if (grp) {
-		for (i = 0; i < 2*nr_node_ids; i++)
-			atomic_long_sub(p->numa_faults[i], &grp->faults[i]);
-
-		atomic_long_sub(p->total_numa_faults, &grp->total_faults);
-
 		spin_lock(&grp->lock);
+		for (i = 0; i < 2*nr_node_ids; i++) {
+			grp->faults[i] -= p->numa_faults[i];
+			WARN_ON_ONCE(grp->faults[i] < 0);
+		}
+		grp->total_faults -= p->total_numa_faults;
+
 		list_del(&p->numa_entry);
 		grp->nr_tasks--;
 		spin_unlock(&grp->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
