Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0794C6B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 19:56:06 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5SNvpmQ007269
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 29 Jun 2009 08:57:51 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F0A232AF77D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 08:57:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C833C1EF085
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 08:57:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C1781DB805E
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 08:57:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D1D221DB8062
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 08:57:49 +0900 (JST)
Date: Mon, 29 Jun 2009 08:56:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: cgroup fix rmdir hang
Message-Id: <20090629085616.7c523508.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090629085026.82e0674d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090626141020.849a081e.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830906261316x52d6c115t720b87ba16b3617@mail.gmail.com>
	<20090629085026.82e0674d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jun 2009 08:50:26 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > Maybe we should name this wakeup_rmdir_waiter() to emphasise that fact
> > that there will only be one waiter (the thread doing the rmdir).
> > 
> Hm, but, there is no guarantee that there will "an" waiter.
> 
Ignore above comment....I forget inode->mutex is held.

Thanks,
-Kame

> 
> > > - A  A  A  if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> > > - A  A  A  A  A  A  A  wake_up_all(&cgroup_rmdir_waitq);
> > > + A  A  A  wake_up_all(&cgroup_rmdir_waitq);
> > > A }
> > >
> > > A static int rebind_subsystems(struct cgroupfs_root *root,
> > > @@ -2696,33 +2695,40 @@ again:
> > > A  A  A  A mutex_unlock(&cgroup_mutex);
> > >
> > > A  A  A  A /*
> > > + A  A  A  A * css_put/get is provided for subsys to grab refcnt to css. In typical
> > > + A  A  A  A * case, subsystem has no reference after pre_destroy(). But, under
> > > + A  A  A  A * hierarchy management, some *temporal* refcnt can be hold.
> > 
> > This sentence needs improvement/clarification. (Yes, I know it's just
> > copied from later in the file, but it wasn't clear there either :-) )
> > 
> ok, I'll modify here. How about this ?
> ==
> In general, subsystem has no css->refcnt after pre_destroy(). But in racy cases,
> subsystem may have to get css->refcnt after pre_destroy() and it makes rmdir
> return with -EBUSY. But we don't like frequent -EBUSY. To avoid that, we use
> waitqueue for cgroup's rmdir. CGROUP_WAIT_ON_RMDIR bit is for synchronizing
> rmdir waitqueue and subsystem behavior. Please see css_get()/put()/tryget()
> implementation, it allows subsystem to avoid unnecessary failure of rmdir().
> If css_put()/get()/tryget() is not enough, cgroup_wakeup_rmdir_waiter() can be
> used.
> ==
> 
> 
> > 
> > > + A  A  A  A * To avoid returning -EBUSY to a user, waitqueue is used. If subsys
> > > + A  A  A  A * is really busy, it should return -EBUSY at pre_destroy(). wake_up
> > > + A  A  A  A * is called when css_put() is called and refcnt goes down to 0.
> > > + A  A  A  A * And this WAIT_ON_RMDIR flag is cleared when subsys detect a race
> > > + A  A  A  A * condition under pre_destroy()->rmdir.
> > 
> > What exactly do you mean by pre_destroy()->rmdir ?
> > 
> Ah, between pre_destroy() and "cgroup is removed" state. I'll remove this.
> Maybe above comment is enough.
> 
> 
> > > If flag is cleared, we need
> > > + A  A  A  A * to call pre_destroy(), again.
> > > + A  A  A  A */
> > > + A  A  A  set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> > > +
> > > + A  A  A  /*
> > > A  A  A  A  * Call pre_destroy handlers of subsys. Notify subsystems
> > > A  A  A  A  * that rmdir() request comes.
> > > A  A  A  A  */
> > > A  A  A  A ret = cgroup_call_pre_destroy(cgrp);
> > > - A  A  A  if (ret)
> > > + A  A  A  if (ret) {
> > > + A  A  A  A  A  A  A  clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> > > A  A  A  A  A  A  A  A return ret;
> > > + A  A  A  }
> > >
> > > A  A  A  A mutex_lock(&cgroup_mutex);
> > > A  A  A  A parent = cgrp->parent;
> > > A  A  A  A if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
> > > + A  A  A  A  A  A  A  clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> > > A  A  A  A  A  A  A  A mutex_unlock(&cgroup_mutex);
> > > A  A  A  A  A  A  A  A return -EBUSY;
> > > A  A  A  A }
> > > - A  A  A  /*
> > > - A  A  A  A * css_put/get is provided for subsys to grab refcnt to css. In typical
> > > - A  A  A  A * case, subsystem has no reference after pre_destroy(). But, under
> > > - A  A  A  A * hierarchy management, some *temporal* refcnt can be hold.
> > > - A  A  A  A * To avoid returning -EBUSY to a user, waitqueue is used. If subsys
> > > - A  A  A  A * is really busy, it should return -EBUSY at pre_destroy(). wake_up
> > > - A  A  A  A * is called when css_put() is called and refcnt goes down to 0.
> > > - A  A  A  A */
> > > - A  A  A  set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> > > A  A  A  A prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
> > > -
> > > A  A  A  A if (!cgroup_clear_css_refs(cgrp)) {
> > > A  A  A  A  A  A  A  A mutex_unlock(&cgroup_mutex);
> > > - A  A  A  A  A  A  A  schedule();
> > > + A  A  A  A  A  A  A  if (test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags))
> > > + A  A  A  A  A  A  A  A  A  A  A  schedule();
> > 
> > The need for this test_bit() should be commented, I think - at first
> > sight it doesn't seem necessary since if we've already been woken up,
> > then the schedule() is logically a no-op anyway. We only need it
> > because we are worried about the case where someone calls
> > wakeup_rmdir_waiters() prior to the prepare_to_wait()
> > 
> > 
> yes. will add comments.
> 
> 
> > > ===================================================================
> > > --- mmotm-2.6.31-Jun25.orig/mm/memcontrol.c
> > > +++ mmotm-2.6.31-Jun25/mm/memcontrol.c
> > > @@ -1234,6 +1234,12 @@ static int mem_cgroup_move_account(struc
> > > A  A  A  A ret = 0;
> > > A out:
> > > A  A  A  A unlock_page_cgroup(pc);
> > > + A  A  A  /*
> > > + A  A  A  A * We charges against "to" which may not have any tasks. Then, "to"
> > > + A  A  A  A * can be under rmdir(). But in current implementation, caller of
> > > + A  A  A  A * this function is just force_empty() and it's garanteed that
> > > + A  A  A  A * "to" is never removed. So, we don't check rmdir status here.
> > > + A  A  A  A */
> > > A  A  A  A return ret;
> > > A }
> > >
> > > @@ -1455,6 +1461,7 @@ __mem_cgroup_commit_charge_swapin(struct
> > > A  A  A  A  A  A  A  A return;
> > > A  A  A  A if (!ptr)
> > > A  A  A  A  A  A  A  A return;
> > > + A  A  A  css_get(&ptr->css);
> > > A  A  A  A pc = lookup_page_cgroup(page);
> > > A  A  A  A mem_cgroup_lru_del_before_commit_swapcache(page);
> > > A  A  A  A __mem_cgroup_commit_charge(ptr, pc, ctype);
> > > @@ -1484,7 +1491,13 @@ __mem_cgroup_commit_charge_swapin(struct
> > > A  A  A  A  A  A  A  A }
> > > A  A  A  A  A  A  A  A rcu_read_unlock();
> > > A  A  A  A }
> > > - A  A  A  /* add this page(page_cgroup) to the LRU we want. */
> > > + A  A  A  /*
> > > + A  A  A  A * At swapin, we may charge account against cgroup which has no tasks.
> > > + A  A  A  A * So, rmdir()->pre_destroy() can be called while we do this charge.
> > > + A  A  A  A * In that case, we need to call pre_destroy() again. check it here.
> > > + A  A  A  A */
> > > + A  A  A  cgroup_wakeup_rmdir_waiters(ptr->css.cgroup);
> > > + A  A  A  css_put(&ptr->css);
> > >
> > > A }
> > >
> > > @@ -1691,7 +1704,7 @@ void mem_cgroup_end_migration(struct mem
> > >
> > > A  A  A  A if (!mem)
> > > A  A  A  A  A  A  A  A return;
> > > -
> > > + A  A  A  css_get(&mem->css);
> > > A  A  A  A /* at migration success, oldpage->mapping is NULL. */
> > > A  A  A  A if (oldpage->mapping) {
> > > A  A  A  A  A  A  A  A target = oldpage;
> > > @@ -1731,6 +1744,14 @@ void mem_cgroup_end_migration(struct mem
> > > A  A  A  A  */
> > > A  A  A  A if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> > > A  A  A  A  A  A  A  A mem_cgroup_uncharge_page(target);
> > > + A  A  A  /*
> > > + A  A  A  A * At migration, we may charge account against cgroup which has no tasks
> > > + A  A  A  A * So, rmdir()->pre_destroy() can be called while we do this charge.
> > > + A  A  A  A * In that case, we need to call pre_destroy() again. check it here.
> > > + A  A  A  A */
> > > + A  A  A  cgroup_wakeup_rmdir_waiters(mem->css.cgroup);
> > > + A  A  A  css_put(&mem->css);
> > 
> > Having to do an extra get/put purely in order to seems unfortunate -
> > is that purely to force the cgroup_clear_css_refs() to fail?
> > 
> yes.
> 
> > Maybe we could wrap the get and the wakeup/put inside functions named
> > "cgroup_exclude_rmdir()" "cgroup_release_rmdir()" so that the mm
> > cgroup code is more self-explanatory.
> > 
> Ah, it sounds nice idea. I'll prepare that as [2/2] patch.
> 
> Thanks,
> -Kame
> 
> 
> > Paul
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
