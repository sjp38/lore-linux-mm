Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 874876B00C8
	for <linux-mm@kvack.org>; Tue, 26 May 2015 11:11:52 -0400 (EDT)
Received: by wgme6 with SMTP id e6so31645447wgm.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 08:11:51 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id ck8si1282796wib.55.2015.05.26.08.11.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 08:11:50 -0700 (PDT)
Received: by wizk4 with SMTP id k4so80966856wiz.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 08:11:50 -0700 (PDT)
Date: Tue, 26 May 2015 17:11:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150526151149.GJ14681@dhcp22.suse.cz>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150526141011.GA11065@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>

[CCing Greg who I forgot to add the to list - sorry about that. The
thread starts here: http://marc.info/?l=linux-mm&m=143264102317318&w=2]

On Tue 26-05-15 10:10:11, Johannes Weiner wrote:
> On Tue, May 26, 2015 at 01:50:06PM +0200, Michal Hocko wrote:
> > Please note that this patch introduces a USER VISIBLE CHANGE OF BEHAVIOR.
> > Without mm->owner _all_ tasks associated with the mm_struct would
> > initiate memcg migration while previously only owner of the mm_struct
> > could do that. The original behavior was awkward though because the user
> > task didn't have any means to find out the current owner (esp. after
> > mm_update_next_owner) so the migration behavior was not well defined
> > in general.
> > New cgroup API (unified hierarchy) will discontinue tasks file which
> > means that migrating threads will no longer be possible. In such a case
> > having CLONE_VM without CLONE_THREAD could emulate the thread behavior
> > but this patch prevents from isolating memcg controllers from others.
> > Nevertheless I am not convinced such a use case would really deserve
> > complications on the memcg code side.
> 
> I think such a change is okay.  The memcg semantics of moving threads
> with the same mm into separate groups have always been arbitrary.  No
> reasonable behavior can be expected of this, so what sane real life
> usecase would rely on it?

I can imagine that threads would go to different cgroups because of
other controllers (e.g. cpu or cpuset).
AFAIR google was doing threads distribution.

> > @@ -104,7 +105,12 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
> >  	bool match = false;
> >  
> >  	rcu_read_lock();
> > -	task_memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > +	/*
> > +	 * rcu_dereference would be better but mem_cgroup is not a complete
> > +	 * type here
> > +	 */
> > +	task_memcg = READ_ONCE(mm->memcg);
> > +	smp_read_barrier_depends();
> >  	if (task_memcg)
> >  		match = mem_cgroup_is_descendant(task_memcg, memcg);
> >  	rcu_read_unlock();
> 
> This function has only one user in rmap.  If you inline it there, you
> can use rcu_dereference() and get rid of the specialness & comment.

I am not sure I understand. struct mem_cgroup is defined in
mm/memcontrol.c so mm/rmap.c will not see it. Or do you suggest pulling
struct mem_cgroup out into a header with all the dependencies?

> > @@ -195,6 +201,10 @@ void mem_cgroup_split_huge_fixup(struct page *head);
> >  #else /* CONFIG_MEMCG */
> >  struct mem_cgroup;
> >  
> > +void mm_drop_memcg(struct mm_struct *mm)
> > +{}
> > +void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> > +{}
> 
> static inline?

Of course. Fixed.
 
[...]
> > @@ -469,6 +469,46 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
> >  	return mem_cgroup_from_css(css);
> >  }
> >  
> > +static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
> > +{
> > +	if (!p->mm)
> > +		return NULL;
> > +	return rcu_dereference(p->mm->memcg);
> > +}
> > +
> > +void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> > +{
> > +	if (memcg)
> > +		css_get(&memcg->css);
> > +	rcu_assign_pointer(mm->memcg, memcg);
> > +}
> > +
> > +void mm_drop_memcg(struct mm_struct *mm)
> > +{
> > +	/*
> > +	 * This is the last reference to mm so nobody can see
> > +	 * this memcg
> > +	 */
> > +	if (mm->memcg)
> > +		css_put(&mm->memcg->css);
> > +}
> 
> This is really simple and obvious and has only one caller, it would be
> better to inline this into mmput().  The comment would also be easier
> to understand in conjunction with the mmdrop() in the callsite:

Same case as rmap.c.

> 
> 	if (mm->memcg)
> 		css_put(&mm->memcg->css);
> 	/* We could reset mm->memcg, but this will free the mm: */
> 	mmdrop(mm);

I like your comment more. I will update it

> 
> The same goes for mm_set_memcg, there is no real need for obscuring a
> simple get-and-store.
> 
> > +static void mm_move_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> > +{
> > +	struct mem_cgroup *old_memcg;
> > +
> > +	mm_set_memcg(mm, memcg);
> > +
> > +	/*
> > +	 * wait for all current users of the old memcg before we
> > +	 * release the reference.
> > +	 */
> > +	old_memcg = mm->memcg;

Doh. Last minute changes... This is incorrect, of course, because I am
dropping the new memcg reference. Fixed

> > +	synchronize_rcu();
> > +	if (old_memcg)
> > +		css_put(&old_memcg->css);
> > +}
> 
> I'm not sure why we need that synchronize_rcu() in here, the css is
> itself protected by RCU and a failing tryget will prevent you from
> taking it outside a RCU-locked region.

Yeah, you are right. Removed.

> Aside from that, there is again exactly one place that performs this
> operation.  Please inline it into mem_cgroup_move_task().

OK, I will inline it there.

> > @@ -5204,6 +5251,12 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
> >  	struct mm_struct *mm = get_task_mm(p);
> >  
> >  	if (mm) {
> > +		/*
> > +		 * Commit to a new memcg. mc.to points to the destination
> > +		 * memcg even when the current charges are not moved.
> > +		 */
> > +		mm_move_memcg(mm, mc.to);
> > +
> >  		if (mc_move_charge())
> >  			mem_cgroup_move_charge(mm);
> >  		mmput(mm);
> 
> It's a little weird to use mc.to when not moving charges, as "mc"
> stands for "move charge".  Why not derive the destination from @css,
> just like can_attach does?  It's a mere cast.  That also makes patch
> #2 in your series unnecessary.

Good idea!

> Otherwise, the patch looks great to me.

Thanks for the review. Changes based on your feedback:
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 315ec1e58acb..50cf88c0249d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -201,10 +201,12 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
-void mm_drop_memcg(struct mm_struct *mm)
-{}
-void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
-{}
+static inline void mm_drop_memcg(struct mm_struct *mm)
+{
+}
+static inline void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
+{
+}
 static inline void mem_cgroup_events(struct mem_cgroup *memcg,
 				     enum mem_cgroup_events_index idx,
 				     unsigned int nr)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 950875eb7d89..2c5c336aca6e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -486,29 +486,13 @@ void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
 void mm_drop_memcg(struct mm_struct *mm)
 {
 	/*
-	 * This is the last reference to mm so nobody can see
-	 * this memcg
+	 * We could reset mm->memcg, but the mm goes away as this is the
+	 * last reference.
 	 */
 	if (mm->memcg)
 		css_put(&mm->memcg->css);
 }
 
-static void mm_move_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
-{
-	struct mem_cgroup *old_memcg;
-
-	mm_set_memcg(mm, memcg);
-
-	/*
-	 * wait for all current users of the old memcg before we
-	 * release the reference.
-	 */
-	old_memcg = mm->memcg;
-	synchronize_rcu();
-	if (old_memcg)
-		css_put(&old_memcg->css);
-}
-
 /* Writing them here to avoid exposing memcg's inner layout */
 #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
 
@@ -5252,10 +5236,15 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
 
 	if (mm) {
 		/*
-		 * Commit to a new memcg. mc.to points to the destination
-		 * memcg even when the current charges are not moved.
+		 * Commit to the target memcg even when we do not move
+		 * charges.
 		 */
-		mm_move_memcg(mm, mc.to);
+		struct mem_cgroup *old_memcg = READ_ONCE(mm->memcg);
+		struct mem_cgroup *new_memcg = mem_cgroup_from_css(css);
+
+		mm_set_memcg(mm, new_memcg);
+		if (old_memcg)
+			css_put(&old_memcg->css);
 
 		if (mc_move_charge())
 			mem_cgroup_move_charge(mm);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
