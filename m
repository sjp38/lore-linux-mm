Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 05B506B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 10:09:46 -0400 (EDT)
Received: by wgck11 with SMTP id k11so224890856wgc.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 07:09:45 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id s4si5042728wiw.68.2015.07.09.07.09.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 07:09:44 -0700 (PDT)
Received: by wiwl6 with SMTP id l6so19973770wiw.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 07:09:44 -0700 (PDT)
Date: Thu, 9 Jul 2015 16:09:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] memcg: get rid of mm_struct::owner
Message-ID: <20150709140941.GG13872@dhcp22.suse.cz>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-8-git-send-email-mhocko@kernel.org>
 <20150708173251.GG2436@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150708173251.GG2436@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-07-15 20:32:51, Vladimir Davydov wrote:
> I like the gist of this patch. A few comments below.
> 
> On Wed, Jul 08, 2015 at 02:27:51PM +0200, Michal Hocko wrote:
[...]
> > +/**
> > + * mm_inherit_memcg - Initialize mm_struct::memcg from an existing mm_struct
> > + * @newmm: new mm struct
> > + * @oldmm: old mm struct to inherit from
> > + *
> > + * Should be called for each new mm_struct.
> > + */
> > +static inline
> > +void mm_inherit_memcg(struct mm_struct *newmm, struct mm_struct *oldmm)
> > +{
> > +	struct mem_cgroup *memcg = oldmm->memcg;
> 
> FWIW, if CONFIG_SPARSE_RCU_POINTER is on, this will trigger a compile
> time warning, as well as any unannotated dereference of mm_struct->memcg
> below.

The idea was that this would be a false positive because the
oldmm->memcg should be stable. But now that I am reading your race
scenario below I am not so sure anymore and we may need to use rcu
locking here. More below

> 
> > +
> > +	__mm_set_memcg(newmm, memcg);
> > +}
> > +
> > +/**
> > + * mm_drop_iter - drop mm_struct::memcg association
> 
> s/mm_drop_iter/mm_drop_memcg

Thanks

> 
> > + * @mm: mm struct
> > + *
> > + * Should be called after the mm has been removed from all tasks
> > + * and before it is freed (e.g. from mmput)
> > + */
> > +static inline void mm_drop_memcg(struct mm_struct *mm)
> > +{
> > +	if (mm->memcg)
> > +		css_put(&mm->memcg->css);
> > +	mm->memcg = NULL;
> > +}
[...]
> > @@ -474,7 +519,7 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> >  		return;
> >  
> >  	rcu_read_lock();
> > -	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > +	memcg = rcu_dereference(mm->memcg);
> >  	if (unlikely(!memcg))
> >  		goto out;
> >  
> 
> If I'm not mistaken, mm->memcg equals NULL for any task in the root
> memory cgroup

right

> (BTW, it it's true, it's worth mentioning in the comment
> to mm->memcg definition IMO). As a result, we won't account the stats
> for such tasks, will we?

well spotted! This is certainly a bug. There are more places which are
checking for mm->memcg being NULL and falling back to root_mem_cgroup. I
think it would be better to simply use root_mem_cgroup right away. We
can setup init_mm.memcg = root_mem_cgroup during initialization and be
done with it. What do you think? The diff is in the very end of the
email (completely untested yet).

[...]
> > +	 * No need to take a reference here because the memcg is pinned by the
> > +	 * mm_struct.
> > +	 */
> 
> But after we drop the reference to the mm below, mc.from can pass away
> and we can get use-after-free in mem_cgroup_move_task, can't we?

Right, the comment is a left over from the previous attempt when I was
holding the reference throughout the migration.
But then I managed to convince myself that...

> AFAIU the real reason why we can skip taking a reference to mc.from, as
> well as to mc.to, is that task migration proceeds under cgroup_mutex,
> which blocks cgroup destruction.

is true. But now that I am thinking about that again I think I just
misled myself. If a task p is moving from A -> B but p->mm->memcg = C
then we are not protected. I will think about this some more.

[...]

> > @@ -4932,14 +4943,26 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
> >  {
> >  	struct task_struct *p = cgroup_taskset_first(tset);
> >  	struct mm_struct *mm = get_task_mm(p);
> > +	struct mem_cgroup *old_memcg = NULL;
> >  
> >  	if (mm) {
> > +		old_memcg = READ_ONCE(mm->memcg);
> > +		__mm_set_memcg(mm, mem_cgroup_from_css(css));
> > +
> >  		if (mc.to)
> >  			mem_cgroup_move_charge(mm);
> >  		mmput(mm);
> >  	}
> >  	if (mc.to)
> >  		mem_cgroup_clear_mc();
> > +
> > +	/*
> > +	 * Be careful and drop the reference only after we are done because
> > +	 * p's task_css memcg might be different from p->memcg and nothing else
> > +	 * might be pinning the old memcg.
> > +	 */
> > +	if (old_memcg)
> > +		css_put(&old_memcg->css);
> 
> Please explain why the following race is impossible:
> 
> CPU0					CPU1
> ----					----
> [current = T]
> dup_mm or exec_mmap
>  mm_inherit_memcg
>   memcg = current->mm->memcg;
> 					mem_cgroup_move_task
> 					 p = T;
> 					 mm = get_task_mm(p);
> 					 old_memcg = mm->memcg;
> 					 css_put(&old_memcg->css);
> 					 /* old_memcg can be freed now */
>   css_get(memcg); /*  BUG */

I guess you are right. The window seem to be very small but CPU0 simly
might get preempted by the moving task and so even cgroup pinning
wouldn't help here.

I guess we need
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b3e7e30b5a74..6fbd33273b6d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -300,9 +300,17 @@ void __mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
 static inline
 void mm_inherit_memcg(struct mm_struct *newmm, struct mm_struct *oldmm)
 {
-	struct mem_cgroup *memcg = oldmm->memcg;
+	struct mem_cgroup *memcg;
 
+	/*
+	 * oldmm might be under move and just replacing its memcg (see
+	 * mem_cgroup_move_task) so we have to protect from its memcg
+	 * going away between we dereference and take a reference.
+	 */
+	rcu_read_lock();
+	memcg = rcu_dereference(oldmm->memcg);
 	__mm_set_memcg(newmm, memcg);
+	rcu_read_unlock();
 }
 
 /**


Make sure that all tasks have non NULL memcg.
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f23e29f3d4fa..b3e7e30b5a74 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -286,8 +286,7 @@ extern struct cgroup_subsys_state *mem_cgroup_root_css;
 static inline
 void __mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
 {
-	if (memcg)
-		css_get(&memcg->css);
+	css_get(&memcg->css);
 	rcu_assign_pointer(mm->memcg, memcg);
 }
 
@@ -307,7 +306,7 @@ void mm_inherit_memcg(struct mm_struct *newmm, struct mm_struct *oldmm)
 }
 
 /**
- * mm_drop_iter - drop mm_struct::memcg association
+ * mm_drop_memcg - drop mm_struct::memcg association
  * @mm: mm struct
  *
  * Should be called after the mm has been removed from all tasks
@@ -315,8 +314,7 @@ void mm_inherit_memcg(struct mm_struct *newmm, struct mm_struct *oldmm)
  */
 static inline void mm_drop_memcg(struct mm_struct *mm)
 {
-	if (mm->memcg)
-		css_put(&mm->memcg->css);
+	css_put(&mm->memcg->css);
 	mm->memcg = NULL;
 }
 
@@ -382,8 +380,7 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 
 	rcu_read_lock();
 	task_memcg = rcu_dereference(mm->memcg);
-	if (task_memcg)
-		match = mem_cgroup_is_descendant(task_memcg, memcg);
+	match = mem_cgroup_is_descendant(task_memcg, memcg);
 	rcu_read_unlock();
 	return match;
 }
@@ -526,8 +523,6 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 
 	rcu_read_lock();
 	memcg = rcu_dereference(mm->memcg);
-	if (unlikely(!memcg))
-		goto out;
 
 	switch (idx) {
 	case PGFAULT:
@@ -539,7 +534,6 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 	default:
 		BUG();
 	}
-out:
 	rcu_read_unlock();
 }
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e7169a9f7a47..23ee92c396e2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -801,11 +801,8 @@ static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 		 */
 		if (unlikely(!mm))
 			memcg = root_mem_cgroup;
-		else {
+		else
 			memcg = rcu_dereference(mm->memcg);
-			if (unlikely(!memcg))
-				memcg = root_mem_cgroup;
-		}
 	} while (!css_tryget_online(&memcg->css));
 	rcu_read_unlock();
 	return memcg;
@@ -4176,6 +4173,11 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
+		/*
+		 * Make sure all tasks will inherit root_mem_cgroup
+		 * implicitly.
+		 */
+		__mm_set_memcg(&init_mm, root_mem_cgroup);
 	}
 
 	memcg->last_scanned_node = MAX_NUMNODES;
@@ -4787,8 +4789,6 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 	 * mm_struct.
 	 */
 	from = READ_ONCE(mm->memcg);
-	if (!from)
-		from = root_mem_cgroup;
 	if (from == to)
 		goto out;
 
@@ -4979,8 +4979,7 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
 	 * p's task_css memcg might be different from p->memcg and nothing else
 	 * might be pinning the old memcg.
 	 */
-	if (old_memcg)
-		css_put(&old_memcg->css);
+	css_put(&old_memcg->css);
 }
 #else	/* !CONFIG_MMU */
 static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
