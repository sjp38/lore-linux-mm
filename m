Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E00396B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 05:23:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5U9OcNn022837
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Jun 2009 18:24:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7753945DD7B
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:24:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 43F1345DD7D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:24:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D40B1DB803C
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:24:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DE981DB8045
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:24:37 +0900 (JST)
Date: Tue, 30 Jun 2009 18:23:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] cgroup: exlclude release rmdir
Message-Id: <20090630182304.8049039c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jun 2009 02:15:03 -0700
Paul Menage <menage@google.com> wrote:

> On Tue, Jun 30, 2009 at 2:03 AM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Paul Menage pointed out that css_get()/put() only for avoiding race with
> > rmdir() is complicated and these should be treated as it is for.
> >
> > This adds
> > A  - cgroup_exclude_rmdir() ....prevent rmdir() for a while.
> > A  - cgroup_release_rmdir() ....rerun rmdir() if necessary.
> > And hides cgroup_wakeup_rmdir_waiter() into kernel/cgroup.c, again.
> 
> Wouldn't it be better to merge these into a single patch? Having one
> patch that exposes complexity only to take it away in the following
> patch seems unnecessary; the combined patch would be simpler than the
> constituents.
> 
This patch is _not_ tested by Nishimura.
What I want is patch 1/2, it's BUGFIX and passed tests by him.
I trust his test very much.
I want the patch 1/2 should be on fast-path as BUGFIX.

But, I think this patch 2/2 is not for fast-path.
This is something new but just a refactoring.

Anyway, I can postpone this until things are settled. Only merging patch 1/2
is okay for me now.

Thanks,
-Kame


> Paul
> 
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > ---
> > A include/linux/cgroup.h | A  21 +++++++++++----------
> > A kernel/cgroup.c A  A  A  A | A  17 +++++++++++++++--
> > A mm/memcontrol.c A  A  A  A | A  12 ++++--------
> > A 3 files changed, 30 insertions(+), 20 deletions(-)
> >
> > Index: mmotm-2.6.31-Jun25/include/linux/cgroup.h
> > ===================================================================
> > --- mmotm-2.6.31-Jun25.orig/include/linux/cgroup.h
> > +++ mmotm-2.6.31-Jun25/include/linux/cgroup.h
> > @@ -366,17 +366,18 @@ int cgroup_task_count(const struct cgrou
> > A int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task);
> >
> > A /*
> > - * Allow to use CGRP_WAIT_ON_RMDIR flag to check race with rmdir() for subsys.
> > - * Subsys can call this function if it's necessary to call pre_destroy() again
> > - * because it adds not-temporary refs to css after or while pre_destroy().
> > - * The caller of this function should use css_tryget(), too.
> > + * When the subsys has to access css and may add permanent refcnt to css,
> > + * it should take care of racy conditions with rmdir(). Following set of
> > + * functions, is for stop/restart rmdir if necessary.
> > + * Because these will call css_get/put, "css" should be alive css.
> > + *
> > + * A cgroup_exclude_rmdir();
> > + * A ...do some jobs which may access arbitrary empty cgroup
> > + * A cgroup_release_rmdir();
> > A */
> > -void __cgroup_wakeup_rmdir_waiters(void);
> > -static inline void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
> > -{
> > - A  A  A  if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> > - A  A  A  A  A  A  A  __cgroup_wakeup_rmdir_waiters();
> > -}
> > +
> > +void cgroup_exclude_rmdir(struct cgroup_subsys_state *css);
> > +void cgroup_release_rmdir(struct cgroup_subsys_state *css);
> >
> > A /*
> > A * Control Group subsystem type.
> > Index: mmotm-2.6.31-Jun25/kernel/cgroup.c
> > ===================================================================
> > --- mmotm-2.6.31-Jun25.orig/kernel/cgroup.c
> > +++ mmotm-2.6.31-Jun25/kernel/cgroup.c
> > @@ -738,11 +738,24 @@ static void cgroup_d_remove_dir(struct d
> > A */
> > A DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
> >
> > -void __cgroup_wakeup_rmdir_waiters(void)
> > +static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
> > A {
> > - A  A  A  wake_up_all(&cgroup_rmdir_waitq);
> > + A  A  A  if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> > + A  A  A  A  A  A  A  wake_up_all(&cgroup_rmdir_waitq);
> > A }
> >
> > +void cgroup_exclude_rmdir(struct cgroup_subsys_state *css)
> > +{
> > + A  A  A  css_get(css);
> > +}
> > +
> > +void cgroup_release_rmdir(struct cgroup_subsys_state *css)
> > +{
> > + A  A  A  cgroup_wakeup_rmdir_waiter(css->cgroup);
> > + A  A  A  css_put(css);
> > +}
> > +
> > +
> > A static int rebind_subsystems(struct cgroupfs_root *root,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A unsigned long final_bits)
> > A {
> > Index: mmotm-2.6.31-Jun25/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.31-Jun25.orig/mm/memcontrol.c
> > +++ mmotm-2.6.31-Jun25/mm/memcontrol.c
> > @@ -1461,7 +1461,7 @@ __mem_cgroup_commit_charge_swapin(struct
> > A  A  A  A  A  A  A  A return;
> > A  A  A  A if (!ptr)
> > A  A  A  A  A  A  A  A return;
> > - A  A  A  css_get(&ptr->css);
> > + A  A  A  cgroup_exclude_rmdir(&ptr->css);
> > A  A  A  A pc = lookup_page_cgroup(page);
> > A  A  A  A mem_cgroup_lru_del_before_commit_swapcache(page);
> > A  A  A  A __mem_cgroup_commit_charge(ptr, pc, ctype);
> > @@ -1496,9 +1496,7 @@ __mem_cgroup_commit_charge_swapin(struct
> > A  A  A  A  * So, rmdir()->pre_destroy() can be called while we do this charge.
> > A  A  A  A  * In that case, we need to call pre_destroy() again. check it here.
> > A  A  A  A  */
> > - A  A  A  cgroup_wakeup_rmdir_waiter(ptr->css.cgroup);
> > - A  A  A  css_put(&ptr->css);
> > -
> > + A  A  A  cgroup_release_rmdir(&ptr->css);
> > A }
> >
> > A void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> > @@ -1704,7 +1702,7 @@ void mem_cgroup_end_migration(struct mem
> >
> > A  A  A  A if (!mem)
> > A  A  A  A  A  A  A  A return;
> > - A  A  A  css_get(&mem->css);
> > + A  A  A  cgroup_exclude_rmdir(&mem->css);
> > A  A  A  A /* at migration success, oldpage->mapping is NULL. */
> > A  A  A  A if (oldpage->mapping) {
> > A  A  A  A  A  A  A  A target = oldpage;
> > @@ -1749,9 +1747,7 @@ void mem_cgroup_end_migration(struct mem
> > A  A  A  A  * So, rmdir()->pre_destroy() can be called while we do this charge.
> > A  A  A  A  * In that case, we need to call pre_destroy() again. check it here.
> > A  A  A  A  */
> > - A  A  A  cgroup_wakeup_rmdir_waiter(mem->css.cgroup);
> > - A  A  A  css_put(&mem->css);
> > -
> > + A  A  A  cgroup_release_rmdir(&mem->css);
> > A }
> >
> > A /*
> >
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
