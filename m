Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 784BA6B0092
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:58:17 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2BNwFta010076
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 08:58:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C015345DE51
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:58:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 98C0845DE4E
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:58:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D73FE38001
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:58:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 25EC21DB8037
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:58:14 +0900 (JST)
Date: Fri, 12 Mar 2010 08:54:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/3] memcg: oom notifier
Message-Id: <20100312085438.98c5fcc4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab1003110647q1b70c9a0j73867c2c33dd28ce@mail.gmail.com>
References: <20100311165315.c282d6d2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311165700.4468ef2a.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab1003110647q1b70c9a0j73867c2c33dd28ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Thank you.

On Thu, 11 Mar 2010 16:47:00 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Thu, Mar 11, 2010 at 9:57 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> > A  A  A  A /*
> > A  A  A  A  * Should we move charges of a task when a task is moved into this
> > A  A  A  A  * mem_cgroup ? And what type of charges should we move ?
> > @@ -282,9 +292,12 @@ enum charge_type {
> > A /* for encoding cft->private value on file */
> > A #define _MEM A  A  A  A  A  A  A  A  A  (0)
> > A #define _MEMSWAP A  A  A  A  A  A  A  (1)
> > +#define _OOM_TYPE A  A  A  A  A  A  A (2)
> > A #define MEMFILE_PRIVATE(x, val) A  A  A  A (((x) << 16) | (val))
> > A #define MEMFILE_TYPE(val) A  A  A (((val) >> 16) & 0xffff)
> > A #define MEMFILE_ATTR(val) A  A  A ((val) & 0xffff)
> > +/* Used for OOM nofiier */
> > +#define OOM_CONTROL A  A  A  A  A  A (0)
> >
> > A /*
> > A * Reclaim flags for mem_cgroup_hierarchical_reclaim
> > @@ -1351,6 +1364,8 @@ bool mem_cgroup_handle_oom(struct mem_cg
> > A  A  A  A  */
> > A  A  A  A if (!locked)
> > A  A  A  A  A  A  A  A prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> > + A  A  A  else
> > + A  A  A  A  A  A  A  mem_cgroup_oom_notify(mem);
> > A  A  A  A mutex_unlock(&memcg_oom_mutex);
> >
> > A  A  A  A if (locked)
> > @@ -3398,8 +3413,22 @@ static int compare_thresholds(const void
> > A  A  A  A return _a->threshold - _b->threshold;
> > A }
> >
> > -static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
> > - A  A  A  A  A  A  A  struct eventfd_ctx *eventfd, const char *args)
> > +static int mem_cgroup_oom_notify_cb(struct mem_cgroup *mem, void *data)
> > +{
> > + A  A  A  struct mem_cgroup_eventfd_list *ev;
> > +
> > + A  A  A  list_for_each_entry(ev, &mem->oom_notify, list)
> > + A  A  A  A  A  A  A  eventfd_signal(ev->eventfd, 1);
> > + A  A  A  return 0;
> > +}
> > +
> > +static void mem_cgroup_oom_notify(struct mem_cgroup *mem)
> > +{
> > + A  A  A  mem_cgroup_walk_tree(mem, NULL, mem_cgroup_oom_notify_cb);
> > +}
> > +
> > +static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
> > + A  A  A  struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
> > A {
> > A  A  A  A struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > A  A  A  A struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
> > @@ -3483,8 +3512,8 @@ unlock:
> > A  A  A  A return ret;
> > A }
> >
> > -static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
> > - A  A  A  A  A  A  A  struct eventfd_ctx *eventfd)
> > +static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
> > + A  A  A  struct cftype *cft, struct eventfd_ctx *eventfd)
> > A {
> > A  A  A  A struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > A  A  A  A struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
> > @@ -3568,13 +3597,66 @@ unlock:
> > A  A  A  A return ret;
> > A }
> >
> > +static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
> > + A  A  A  struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
> > +{
> > + A  A  A  struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > + A  A  A  struct mem_cgroup_eventfd_list *event;
> > + A  A  A  int type = MEMFILE_TYPE(cft->private);
> > + A  A  A  int ret = -ENOMEM;
> > +
> > + A  A  A  BUG_ON(type != _OOM_TYPE);
> > +
> > + A  A  A  mutex_lock(&memcg_oom_mutex);
> > +
> > + A  A  A  /* Allocate memory for new array of thresholds */
> 
> Irrelevant comment?
> 
> > + A  A  A  event = kmalloc(sizeof(*event), GFP_KERNEL);
> > + A  A  A  if (!event)
> > + A  A  A  A  A  A  A  goto unlock;
> > + A  A  A  /* Add new threshold */
> 
> Ditto.
> 
Ah...sorry for garbages..I'll clean these up.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
