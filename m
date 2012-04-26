Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 5E4446B007E
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 19:48:38 -0400 (EDT)
Date: Fri, 27 Apr 2012 01:48:19 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcg: count pte references from every member of
 the reclaimed hierarchy
Message-ID: <20120426234819.GB1788@cmpxchg.org>
References: <1335296144-29381-1-git-send-email-hannes@cmpxchg.org>
 <1335296144-29381-2-git-send-email-hannes@cmpxchg.org>
 <20120426143729.10f672ae.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120426143729.10f672ae.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Apr 26, 2012 at 02:37:29PM -0700, Andrew Morton wrote:
> On Tue, 24 Apr 2012 21:35:44 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -78,6 +78,7 @@ extern void mem_cgroup_uncharge_cache_page(struct page *page);
> >  
> >  extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >  				     int order);
> > +bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *, struct mem_cgroup *);
> 
> I dunno about you guys, but this practice of omitting the names of the
> arguments in the declaration drives me bats.  It really does throw away
> a *lot* of information.  It looks OK when one is initially reading the
> code, but when I actually go in there and do some work on the code, it
> makes things significantly harder.

Humm, I only look at headers to roughly gauge an API, and jump to the
definitions anyway when figuring out how to actually use them (because
of the documentation, and because function names can be deceiving).

But I don't mind adding the names, so I'll try to remember it.

> >  int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
> >  
> >  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
> > @@ -91,10 +92,13 @@ static inline
> >  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> >  {
> >  	struct mem_cgroup *memcg;
> > +	int match;
> > +
> >  	rcu_read_lock();
> >  	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
> > +	match = memcg && __mem_cgroup_same_or_subtree(cgroup, memcg);
> >  	rcu_read_unlock();
> > -	return cgroup == memcg;
> > +	return match;
> >  }
> 
> mm_match_cgroup() really wants to return a bool type, no?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcg: clean up mm_match_cgroup() signature

It really should return a boolean for match/no match.  And since it
takes a memcg, not a cgroup, fix that parameter name as well.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 76f9d9b..d3038a9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -89,14 +89,14 @@ extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
 extern struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont);
 
 static inline
-int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
+bool mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *memcg)
 {
-	struct mem_cgroup *memcg;
-	int match;
+	struct mem_cgroup *task_memcg;
+	bool match;
 
 	rcu_read_lock();
-	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
-	match = memcg && __mem_cgroup_same_or_subtree(cgroup, memcg);
+	task_memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
+	match = task_memcg && __mem_cgroup_same_or_subtree(memcg, task_memcg);
 	rcu_read_unlock();
 	return match;
 }
@@ -281,10 +281,10 @@ static inline struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm
 	return NULL;
 }
 
-static inline int mm_match_cgroup(struct mm_struct *mm,
+static inline bool mm_match_cgroup(struct mm_struct *mm,
 		struct mem_cgroup *memcg)
 {
-	return 1;
+	return true;
 }
 
 static inline int task_in_mem_cgroup(struct task_struct *task,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
