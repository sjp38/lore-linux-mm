Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 739F06B0093
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 03:37:20 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o288bHZr017700
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 8 Mar 2010 17:37:17 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BF5645DE52
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 17:37:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 786B745DE4E
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 17:37:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BBC91DB8012
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 17:37:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AFF251DB8017
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 17:37:12 +0900 (JST)
Date: Mon, 8 Mar 2010 17:33:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] memcg: oom notifier
Message-Id: <20100308173340.c3786d80.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab1003080032u3451fb53u8ece3abf2d3f4852@mail.gmail.com>
References: <20100308162414.faaa9c5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308162544.e7372b38.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab1003080032u3451fb53u8ece3abf2d3f4852@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Mar 2010 10:32:59 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Mar 8, 2010 at 9:25 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Considering containers or other resource management softwares in userland,
> > event notification of OOM in memcg should be implemented.
> > Now, memcg has "threshold" notifier which uses eventfd, we can make
> > use of it for oom notification.
> >
> > This patch adds oom notification eventfd callback for memcg. The usage
> > is very similar to threshold notifier, but control file is
> > memory.oom_control and no arguments other than eventfd is required.
> >
> > A  A  A  A % cgroup_event_notifier /cgroup/A/memory.oom_control dummy
> > A  A  A  A (About cgroup_event_notifier, see Documentation/cgroup/)
> 
> Nice idea!
> 
> But I don't think that sharing mem_cgroup_(un)register_event()
> with thresholds is a good idea. There are too many
> "if (type != _OOM_TYPE)". Probably, it's cleaner to create separate
> register/unregister for oom events, since oom event is quite different
> from threshold. We, also, don't need RCU for oom events. It's not
> a critical path.
> 

Ah, okay. I'll write independent functions. I just wanted to reuse existing
good codes :)

Thanks,
-Kame


> > TODO:
> > A - add a knob to disable oom-kill under a memcg.
> > A - add read/write function to oom_control
> >
> > Changelog: 20100304
> > A - renewed implemnation.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A Documentation/cgroups/memory.txt | A  20 ++++-
> > A mm/memcontrol.c A  A  A  A  A  A  A  A  A | A 155 ++++++++++++++++++++++++++++-----------
> > A 2 files changed, 131 insertions(+), 44 deletions(-)
> >
> > Index: mmotm-2.6.33-Mar5/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Mar5.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Mar5/mm/memcontrol.c
> > @@ -159,6 +159,7 @@ struct mem_cgroup_threshold_ary {
> > A };
> >
> > A static void mem_cgroup_threshold(struct mem_cgroup *mem);
> > +static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
> >
> > A /*
> > A * The memory controller data structure. The memory controller controls both
> > @@ -220,6 +221,9 @@ struct mem_cgroup {
> > A  A  A  A /* thresholds for mem+swap usage. RCU-protected */
> > A  A  A  A struct mem_cgroup_threshold_ary *memsw_thresholds;
> >
> > + A  A  A  /* For oom notifier event fd */
> > + A  A  A  struct mem_cgroup_threshold_ary *oom_notify;
> > +
> > A  A  A  A /*
> > A  A  A  A  * Should we move charges of a task when a task is moved into this
> > A  A  A  A  * mem_cgroup ? And what type of charges should we move ?
> > @@ -282,9 +286,12 @@ enum charge_type {
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
> > @@ -1313,9 +1320,10 @@ bool mem_cgroup_handle_oom(struct mem_cg
> > A  A  A  A  A  A  A  A prepare_to_wait(&memcg_oom_waitq, &wait, TASK_KILLABLE);
> > A  A  A  A mutex_unlock(&memcg_oom_mutex);
> >
> > - A  A  A  if (locked)
> > + A  A  A  if (locked) {
> > + A  A  A  A  A  A  A  mem_cgroup_oom_notify(mem);
> > A  A  A  A  A  A  A  A mem_cgroup_out_of_memory(mem, mask);
> > - A  A  A  else {
> > + A  A  A  } else {
> > A  A  A  A  A  A  A  A schedule();
> > A  A  A  A  A  A  A  A finish_wait(&memcg_oom_waitq, &wait);
> > A  A  A  A }
> > @@ -3363,33 +3371,65 @@ static int compare_thresholds(const void
> > A  A  A  A return _a->threshold - _b->threshold;
> > A }
> >
> > +static int mem_cgroup_oom_notify_cb(struct mem_cgroup *mem, void *data)
> > +{
> > + A  A  A  struct mem_cgroup_threshold_ary *x;
> > + A  A  A  int i;
> > +
> > + A  A  A  rcu_read_lock();
> > + A  A  A  x = rcu_dereference(mem->oom_notify);
> > + A  A  A  for (i = 0; x && i < x->size; i++)
> > + A  A  A  A  A  A  A  eventfd_signal(x->entries[i].eventfd, 1);
> > + A  A  A  rcu_read_unlock();
> > + A  A  A  return 0;
> > +}
> > +
> > +static void mem_cgroup_oom_notify(struct mem_cgroup *mem)
> > +{
> > + A  A  A  mem_cgroup_walk_tree(mem, NULL, mem_cgroup_oom_notify_cb);
> > +}
> > +
> > A static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
> > A  A  A  A  A  A  A  A struct eventfd_ctx *eventfd, const char *args)
> > A {
> > A  A  A  A struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > A  A  A  A struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
> > A  A  A  A int type = MEMFILE_TYPE(cft->private);
> > - A  A  A  u64 threshold, usage;
> > + A  A  A  u64 threshold;
> > + A  A  A  u64 usage = 0;
> > A  A  A  A int size;
> > A  A  A  A int i, ret;
> >
> > - A  A  A  ret = res_counter_memparse_write_strategy(args, &threshold);
> > - A  A  A  if (ret)
> > - A  A  A  A  A  A  A  return ret;
> > + A  A  A  if (type != _OOM_TYPE) {
> > + A  A  A  A  A  A  A  ret = res_counter_memparse_write_strategy(args, &threshold);
> > + A  A  A  A  A  A  A  if (ret)
> > + A  A  A  A  A  A  A  A  A  A  A  return ret;
> > + A  A  A  } else if (mem_cgroup_is_root(memcg)) /* root cgroup ? */
> > + A  A  A  A  A  A  A  return -ENOTSUPP;
> >
> > A  A  A  A mutex_lock(&memcg->thresholds_lock);
> > - A  A  A  if (type == _MEM)
> > + A  A  A  /* For waiting OOM notify, "-1" is passed */
> > +
> > + A  A  A  switch (type) {
> > + A  A  A  case _MEM:
> > A  A  A  A  A  A  A  A thresholds = memcg->thresholds;
> > - A  A  A  else if (type == _MEMSWAP)
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  case _MEMSWAP:
> > A  A  A  A  A  A  A  A thresholds = memcg->memsw_thresholds;
> > - A  A  A  else
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  case _OOM_TYPE:
> > + A  A  A  A  A  A  A  thresholds = memcg->oom_notify;
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  default:
> > A  A  A  A  A  A  A  A BUG();
> > + A  A  A  }
> >
> > - A  A  A  usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
> > -
> > - A  A  A  /* Check if a threshold crossed before adding a new one */
> > - A  A  A  if (thresholds)
> > - A  A  A  A  A  A  A  __mem_cgroup_threshold(memcg, type == _MEMSWAP);
> > + A  A  A  if (type != _OOM_TYPE) {
> > + A  A  A  A  A  A  A  usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
> > + A  A  A  A  A  A  A  /* Check if a threshold crossed before adding a new one */
> > + A  A  A  A  A  A  A  if (thresholds)
> > + A  A  A  A  A  A  A  A  A  A  A  __mem_cgroup_threshold(memcg, type == _MEMSWAP);
> > + A  A  A  }
> >
> > A  A  A  A if (thresholds)
> > A  A  A  A  A  A  A  A size = thresholds->size + 1;
> > @@ -3416,27 +3456,34 @@ static int mem_cgroup_register_event(str
> > A  A  A  A thresholds_new->entries[size - 1].threshold = threshold;
> >
> > A  A  A  A /* Sort thresholds. Registering of new threshold isn't time-critical */
> > - A  A  A  sort(thresholds_new->entries, size,
> > + A  A  A  if (type != _OOM_TYPE) {
> > + A  A  A  A  A  A  A  sort(thresholds_new->entries, size,
> > A  A  A  A  A  A  A  A  A  A  A  A sizeof(struct mem_cgroup_threshold),
> > A  A  A  A  A  A  A  A  A  A  A  A compare_thresholds, NULL);
> > -
> > - A  A  A  /* Find current threshold */
> > - A  A  A  atomic_set(&thresholds_new->current_threshold, -1);
> > - A  A  A  for (i = 0; i < size; i++) {
> > - A  A  A  A  A  A  A  if (thresholds_new->entries[i].threshold < usage) {
> > - A  A  A  A  A  A  A  A  A  A  A  /*
> > - A  A  A  A  A  A  A  A  A  A  A  A * thresholds_new->current_threshold will not be used
> > - A  A  A  A  A  A  A  A  A  A  A  A * until rcu_assign_pointer(), so it's safe to increment
> > - A  A  A  A  A  A  A  A  A  A  A  A * it here.
> > - A  A  A  A  A  A  A  A  A  A  A  A */
> > - A  A  A  A  A  A  A  A  A  A  A  atomic_inc(&thresholds_new->current_threshold);
> > + A  A  A  A  A  A  A  /* Find current threshold */
> > + A  A  A  A  A  A  A  atomic_set(&thresholds_new->current_threshold, -1);
> > + A  A  A  A  A  A  A  for (i = 0; i < size; i++) {
> > + A  A  A  A  A  A  A  A  A  A  A  if (thresholds_new->entries[i].threshold < usage) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  /*
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * thresholds_new->current_threshold will not
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * be used until rcu_assign_pointer(), so it's
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * safe to increment it here.
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A */
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  atomic_inc(&thresholds_new->current_threshold);
> > + A  A  A  A  A  A  A  A  A  A  A  }
> > A  A  A  A  A  A  A  A }
> > A  A  A  A }
> > -
> > - A  A  A  if (type == _MEM)
> > + A  A  A  switch (type) {
> > + A  A  A  case _MEM:
> > A  A  A  A  A  A  A  A rcu_assign_pointer(memcg->thresholds, thresholds_new);
> > - A  A  A  else
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  case _MEMSWAP:
> > A  A  A  A  A  A  A  A rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  case _OOM_TYPE:
> > + A  A  A  A  A  A  A  rcu_assign_pointer(memcg->oom_notify, thresholds_new);
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  }
> >
> > A  A  A  A /* To be sure that nobody uses thresholds before freeing it */
> > A  A  A  A synchronize_rcu();
> > @@ -3454,17 +3501,25 @@ static int mem_cgroup_unregister_event(s
> > A  A  A  A struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > A  A  A  A struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
> > A  A  A  A int type = MEMFILE_TYPE(cft->private);
> > - A  A  A  u64 usage;
> > + A  A  A  u64 usage = 0;
> > A  A  A  A int size = 0;
> > A  A  A  A int i, j, ret;
> >
> > A  A  A  A mutex_lock(&memcg->thresholds_lock);
> > - A  A  A  if (type == _MEM)
> > + A  A  A  /* check eventfd is for OOM check or not */
> > + A  A  A  switch (type) {
> > + A  A  A  case _MEM:
> > A  A  A  A  A  A  A  A thresholds = memcg->thresholds;
> > - A  A  A  else if (type == _MEMSWAP)
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  case _MEMSWAP:
> > A  A  A  A  A  A  A  A thresholds = memcg->memsw_thresholds;
> > - A  A  A  else
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  case _OOM_TYPE:
> > + A  A  A  A  A  A  A  thresholds = memcg->oom_notify;
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  default:
> > A  A  A  A  A  A  A  A BUG();
> > + A  A  A  }
> >
> > A  A  A  A /*
> > A  A  A  A  * Something went wrong if we trying to unregister a threshold
> > @@ -3472,11 +3527,11 @@ static int mem_cgroup_unregister_event(s
> > A  A  A  A  */
> > A  A  A  A BUG_ON(!thresholds);
> >
> > - A  A  A  usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
> > -
> > - A  A  A  /* Check if a threshold crossed before removing */
> > - A  A  A  __mem_cgroup_threshold(memcg, type == _MEMSWAP);
> > -
> > + A  A  A  if (type != _OOM_TYPE) {
> > + A  A  A  A  A  A  A  usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
> > + A  A  A  A  A  A  A  /* Check if a threshold crossed before removing */
> > + A  A  A  A  A  A  A  __mem_cgroup_threshold(memcg, type == _MEMSWAP);
> > + A  A  A  }
> > A  A  A  A /* Calculate new number of threshold */
> > A  A  A  A for (i = 0; i < thresholds->size; i++) {
> > A  A  A  A  A  A  A  A if (thresholds->entries[i].eventfd != eventfd)
> > @@ -3500,13 +3555,15 @@ static int mem_cgroup_unregister_event(s
> > A  A  A  A thresholds_new->size = size;
> >
> > A  A  A  A /* Copy thresholds and find current threshold */
> > - A  A  A  atomic_set(&thresholds_new->current_threshold, -1);
> > + A  A  A  if (type != _OOM_TYPE)
> > + A  A  A  A  A  A  A  atomic_set(&thresholds_new->current_threshold, -1);
> > A  A  A  A for (i = 0, j = 0; i < thresholds->size; i++) {
> > A  A  A  A  A  A  A  A if (thresholds->entries[i].eventfd == eventfd)
> > A  A  A  A  A  A  A  A  A  A  A  A continue;
> >
> > A  A  A  A  A  A  A  A thresholds_new->entries[j] = thresholds->entries[i];
> > - A  A  A  A  A  A  A  if (thresholds_new->entries[j].threshold < usage) {
> > + A  A  A  A  A  A  A  if (type != _OOM_TYPE &&
> > + A  A  A  A  A  A  A  A  A  A  A  thresholds_new->entries[j].threshold < usage) {
> > A  A  A  A  A  A  A  A  A  A  A  A /*
> > A  A  A  A  A  A  A  A  A  A  A  A  * thresholds_new->current_threshold will not be used
> > A  A  A  A  A  A  A  A  A  A  A  A  * until rcu_assign_pointer(), so it's safe to increment
> > @@ -3518,11 +3575,17 @@ static int mem_cgroup_unregister_event(s
> > A  A  A  A }
> >
> > A assign:
> > - A  A  A  if (type == _MEM)
> > + A  A  A  switch (type) {
> > + A  A  A  case _MEM:
> > A  A  A  A  A  A  A  A rcu_assign_pointer(memcg->thresholds, thresholds_new);
> > - A  A  A  else
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  case _MEMSWAP:
> > A  A  A  A  A  A  A  A rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
> > -
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  case _OOM_TYPE:
> > + A  A  A  A  A  A  A  rcu_assign_pointer(memcg->oom_notify, thresholds_new);
> > + A  A  A  A  A  A  A  break;
> > + A  A  A  }
> > A  A  A  A /* To be sure that nobody uses thresholds before freeing it */
> > A  A  A  A synchronize_rcu();
> >
> > @@ -3588,6 +3651,12 @@ static struct cftype mem_cgroup_files[]
> > A  A  A  A  A  A  A  A .read_u64 = mem_cgroup_move_charge_read,
> > A  A  A  A  A  A  A  A .write_u64 = mem_cgroup_move_charge_write,
> > A  A  A  A },
> > + A  A  A  {
> > + A  A  A  A  A  A  A  .name = "oom_control",
> > + A  A  A  A  A  A  A  .register_event = mem_cgroup_register_event,
> > + A  A  A  A  A  A  A  .unregister_event = mem_cgroup_unregister_event,
> > + A  A  A  A  A  A  A  .private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
> > + A  A  A  },
> > A };
> >
> > A #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > Index: mmotm-2.6.33-Mar5/Documentation/cgroups/memory.txt
> > ===================================================================
> > --- mmotm-2.6.33-Mar5.orig/Documentation/cgroups/memory.txt
> > +++ mmotm-2.6.33-Mar5/Documentation/cgroups/memory.txt
> > @@ -184,6 +184,9 @@ limits on the root cgroup.
> >
> > A Note2: When panic_on_oom is set to "2", the whole system will panic.
> >
> > +When oom event notifier is registered, event will be delivered.
> > +(See oom_control section)
> > +
> > A 2. Locking
> >
> > A The memory controller uses the following hierarchy
> > @@ -486,7 +489,22 @@ threshold in any direction.
> >
> > A It's applicable for root and non-root cgroup.
> >
> > -10. TODO
> > +10. OOM Control
> > +
> > +Memory controler implements oom notifier using cgroup notification
> > +API (See cgroups.txt). It allows to register multiple oom notification
> > +delivery and gets notification when oom happens.
> > +
> > +To register a notifier, application need:
> > + - create an eventfd using eventfd(2)
> > + - open memory.oom_control file
> > + - write string like "<event_fd> <memory.oom_control>" to cgroup.event_control
> > +
> > +Application will be notifier through eventfd when oom happens.
> > +OOM notification doesn't work for root cgroup.
> > +
> > +
> > +11. TODO
> >
> > A 1. Add support for accounting huge pages (as a separate controller)
> > A 2. Make per-cgroup scanner reclaim not-shared pages first
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org. A For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
