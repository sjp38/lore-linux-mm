Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 680156B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 03:45:21 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EFD893EE0BC
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:45:19 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3BE245DE51
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:45:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BB38A45DE4F
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:45:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AA6831DB802F
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:45:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 57E151DB803E
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:45:19 +0900 (JST)
Date: Tue, 14 Feb 2012 17:43:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/6 v4] memcg: use new logic for page stat accounting
Message-Id: <20120214174354.d5a3b73d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAHH2K0a45xCTFz5qD-M_wX4DqsyfOZeL_G2JSs5NdHp1ZLHT_g@mail.gmail.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20120214121424.91a1832b.kamezawa.hiroyu@jp.fujitsu.com>
	<CAHH2K0a45xCTFz5qD-M_wX4DqsyfOZeL_G2JSs5NdHp1ZLHT_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, 13 Feb 2012 23:22:22 -0800
Greg Thelen <gthelen@google.com> wrote:

> On Mon, Feb 13, 2012 at 7:14 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From ad2905362ef58a44d96a325193ab384739418050 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 2 Feb 2012 11:49:59 +0900
> > Subject: [PATCH 4/6] memcg: use new logic for page stat accounting.
> >
> > Now, page-stat-per-memcg is recorded into per page_cgroup flag by
> > duplicating page's status into the flag. The reason is that memcg
> > has a feature to move a page from a group to another group and we
> > have race between "move" and "page stat accounting",
> >
> > Under current logic, assume CPU-A and CPU-B. CPU-A does "move"
> > and CPU-B does "page stat accounting".
> >
> > When CPU-A goes 1st,
> >
> > A  A  A  A  A  A CPU-A A  A  A  A  A  A  A  A  A  A  A  A  A  CPU-B
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A update "struct page" info.
> > A  A move_lock_mem_cgroup(memcg)
> > A  A see flags
> 
> pc->flags?
> 
yes.


> > A  A copy page stat to new group
> > A  A overwrite pc->mem_cgroup.
> > A  A move_unlock_mem_cgroup(memcg)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A move_lock_mem_cgroup(mem)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A set pc->flags
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A update page stat accounting
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A move_unlock_mem_cgroup(mem)
> >
> > stat accounting is guarded by move_lock_mem_cgroup() and "move"
> > logic (CPU-A) doesn't see changes in "struct page" information.
> >
> > But it's costly to have the same information both in 'struct page' and
> > 'struct page_cgroup'. And, there is a potential problem.
> >
> > For example, assume we have PG_dirty accounting in memcg.
> > PG_..is a flag for struct page.
> > PCG_ is a flag for struct page_cgroup.
> > (This is just an example. The same problem can be found in any
> > A kind of page stat accounting.)
> >
> > A  A  A  A  A CPU-A A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  CPU-B
> > A  A  A TestSet PG_dirty
> > A  A  A (delay) A  A  A  A  A  A  A  A  A  A  A  A TestClear PG_dirty_
> 
> PG_dirty
> 
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (TestClear(PCG_dirty))
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A memcg->nr_dirty--
> > A  A  A if (TestSet(PCG_dirty))
> > A  A  A  A  A memcg->nr_dirty++
> >
> 
> > @@ -141,6 +141,31 @@ static inline bool mem_cgroup_disabled(void)
> > A  A  A  A return false;
> > A }
> >
> > +void __mem_cgroup_begin_update_page_stat(struct page *page,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  bool *lock, unsigned long *flags);
> > +
> > +static inline void mem_cgroup_begin_update_page_stat(struct page *page,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  bool *lock, unsigned long *flags)
> > +{
> > + A  A  A  if (mem_cgroup_disabled())
> > + A  A  A  A  A  A  A  return;
> > + A  A  A  rcu_read_lock();
> > + A  A  A  *lock = false;
> 
> This seems like a strange place to set *lock=false.  I think it's
> clearer if __mem_cgroup_begin_update_page_stat() is the only routine
> that sets or clears *lock.  But I do see that in patch 6/6 'memcg: fix
> performance of mem_cgroup_begin_update_page_stat()' this position is
> required.
> 

Ah, yes. Hmm, it was better to move this to the body of function.



> > + A  A  A  return __mem_cgroup_begin_update_page_stat(page, lock, flags);
> > +}
> 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index ecf8856..30afea5 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1877,32 +1877,54 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
> > A * If there is, we take a lock.
> > A */
> >
> > +void __mem_cgroup_begin_update_page_stat(struct page *page,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  bool *lock, unsigned long *flags)
> > +{
> > + A  A  A  struct mem_cgroup *memcg;
> > + A  A  A  struct page_cgroup *pc;
> > +
> > + A  A  A  pc = lookup_page_cgroup(page);
> > +again:
> > + A  A  A  memcg = pc->mem_cgroup;
> > + A  A  A  if (unlikely(!memcg || !PageCgroupUsed(pc)))
> > + A  A  A  A  A  A  A  return;
> > + A  A  A  if (!mem_cgroup_stealed(memcg))
> > + A  A  A  A  A  A  A  return;
> > +
> > + A  A  A  move_lock_mem_cgroup(memcg, flags);
> > + A  A  A  if (memcg != pc->mem_cgroup || !PageCgroupUsed(pc)) {
> > + A  A  A  A  A  A  A  move_unlock_mem_cgroup(memcg, flags);
> > + A  A  A  A  A  A  A  goto again;
> > + A  A  A  }
> > + A  A  A  *lock = true;
> > +}
> > +
> > +void __mem_cgroup_end_update_page_stat(struct page *page,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  bool *lock, unsigned long *flags)
> 
> 'lock' looks like an unused parameter.  If so, then remove it.
> 

Ok.

> > +{
> > + A  A  A  struct page_cgroup *pc = lookup_page_cgroup(page);
> > +
> > + A  A  A  /*
> > + A  A  A  A * It's guaranteed that pc->mem_cgroup never changes while
> > + A  A  A  A * lock is held
> 
> Please continue comment describing what provides this guarantee.  I
> assume it is because rcu_read_lock() is held by
> mem_cgroup_begin_update_page_stat().  Maybe it's best to to just make
> small reference to the locking protocol description in
> mem_cgroup_start_move().
> 
Ok, I will update this.


> > + A  A  A  A */
> > + A  A  A  move_unlock_mem_cgroup(pc->mem_cgroup, flags);
> > +}
> > +
> > +
> 
> I think it would be useful to add a small comment here declaring that
> all callers of this routine must be in a
> mem_cgroup_begin_update_page_stat(), mem_cgroup_end_update_page_stat()
> critical section to keep pc->mem_cgroup stable.
> 

Sure, will do.

Thank you for review.
-Kame


> > A void mem_cgroup_update_page_stat(struct page *page,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  enum mem_cgroup_page_stat_item idx, int val)
> > A {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
