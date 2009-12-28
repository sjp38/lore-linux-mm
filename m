Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 309B760021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 23:18:01 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS4HwaT019234
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 13:17:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E820F45DE53
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:17:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B6F0545DE57
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:17:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 579FF1DB803C
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:17:57 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D7201DB805A
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:17:56 +0900 (JST)
Date: Mon, 28 Dec 2009 13:14:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 4/4] memcg: implement memory thresholds
Message-Id: <20091228131440.3a49a943.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab0912271923v4a4ed8cco168193c63efd44f@mail.gmail.com>
References: <cover.1261858972.git.kirill@shutemov.name>
	<3f29ccc3c93e2defd70fc1c4ca8c133908b70b0b.1261858972.git.kirill@shutemov.name>
	<59a7f92356bf1508f06d12c501a7aa4feffb1bbc.1261858972.git.kirill@shutemov.name>
	<c2379f3965225b6d62e64c64f8c0e67fee085d7f.1261858972.git.kirill@shutemov.name>
	<7a4e1d758b98ca633a0be06e883644ad8813c077.1261858972.git.kirill@shutemov.name>
	<20091228114325.e9b3b3d6.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab0912271923v4a4ed8cco168193c63efd44f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009 05:23:51 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Dec 28, 2009 at 4:43 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Sun, 27 Dec 2009 04:09:02 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
A /*
> >> A  * Statistics for memory cgroup.
> >> @@ -72,6 +79,8 @@ enum mem_cgroup_stat_index {
> >> A  A  A  MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> >> A  A  A  MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  used by soft limit implementation */
> >> + A  A  MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  used by threshold implementation */
> >>
> >> A  A  A  MEM_CGROUP_STAT_NSTATS,
> >> A };
> >> @@ -182,6 +191,20 @@ struct mem_cgroup_tree {
> >>
> >> A static struct mem_cgroup_tree soft_limit_tree __read_mostly;
> >>
> >> +struct mem_cgroup_threshold {
> >> + A  A  struct eventfd_ctx *eventfd;
> >> + A  A  u64 threshold;
> >> +};
> >> +
> >> +struct mem_cgroup_threshold_ary {
> >> + A  A  unsigned int size;
> >> + A  A  atomic_t cur;
> >> + A  A  struct mem_cgroup_threshold entries[0];
> >> +};
> >> +
> > Why "array" is a choice here ? IOW, why not list ?
> 
> We need be able to walk by thresholds in both directions to be fast.
> AFAIK, It's impossible with RCU-protected list.
> 
I couldn't read your code correctly. Could you add a comment on

  atomic_t cur; /* An array index points to XXXXX */

or use better name ?

> > How many waiters are expected as usual workload ?
> 
> Array of thresholds reads every 100 page in/out for every CPU.
> Write access only when registering new threshold.
> 



> >> +static bool mem_cgroup_threshold_check(struct mem_cgroup* mem);
> >> +static void mem_cgroup_threshold(struct mem_cgroup* mem);
> >> +
> >> A /*
> >> A  * The memory controller data structure. The memory controller controls both
> >> A  * page cache and RSS per cgroup. We would eventually like to provide
> >> @@ -233,6 +256,15 @@ struct mem_cgroup {
> >> A  A  A  /* set when res.limit == memsw.limit */
> >> A  A  A  bool A  A  A  A  A  A memsw_is_minimum;
> >>
> >> + A  A  /* protect arrays of thresholds */
> >> + A  A  struct mutex thresholds_lock;
> >> +
> >> + A  A  /* thresholds for memory usage. RCU-protected */
> >> + A  A  struct mem_cgroup_threshold_ary *thresholds;
> >> +
> >> + A  A  /* thresholds for mem+swap usage. RCU-protected */
> >> + A  A  struct mem_cgroup_threshold_ary *memsw_thresholds;
> >> +
> >> A  A  A  /*
> >> A  A  A  A * statistics. This must be placed at the end of memcg.
> >> A  A  A  A */
> >> @@ -525,6 +557,8 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> >> A  A  A  A  A  A  A  __mem_cgroup_stat_add_safe(cpustat,
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
> >> A  A  A  __mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT, -1);
> >> + A  A  __mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_THRESHOLDS, -1);
> >> +
> >> A  A  A  put_cpu();
> >> A }
> >>
> >> @@ -1510,6 +1544,8 @@ charged:
> >> A  A  A  if (mem_cgroup_soft_limit_check(mem))
> >> A  A  A  A  A  A  A  mem_cgroup_update_tree(mem, page);
> >> A done:
> >> + A  A  if (mem_cgroup_threshold_check(mem))
> >> + A  A  A  A  A  A  mem_cgroup_threshold(mem);
> >> A  A  A  return 0;
> >> A nomem:
> >> A  A  A  css_put(&mem->css);
> >> @@ -2075,6 +2111,8 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> >>
> >> A  A  A  if (mem_cgroup_soft_limit_check(mem))
> >> A  A  A  A  A  A  A  mem_cgroup_update_tree(mem, page);
> >> + A  A  if (mem_cgroup_threshold_check(mem))
> >> + A  A  A  A  A  A  mem_cgroup_threshold(mem);
> >> A  A  A  /* at swapout, this memcg will be accessed to record to swap */
> >> A  A  A  if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> >> A  A  A  A  A  A  A  css_put(&mem->css);
> >> @@ -3071,12 +3109,246 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
> >> A  A  A  return 0;
> >> A }
> >>
> >> +static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
> >> +{
> >> + A  A  bool ret = false;
> >> + A  A  int cpu;
> >> + A  A  s64 val;
> >> + A  A  struct mem_cgroup_stat_cpu *cpustat;
> >> +
> >> + A  A  cpu = get_cpu();
> >> + A  A  cpustat = &mem->stat.cpustat[cpu];
> >> + A  A  val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_THRESHOLDS);
> >> + A  A  if (unlikely(val < 0)) {
> >> + A  A  A  A  A  A  __mem_cgroup_stat_set(cpustat, MEM_CGROUP_STAT_THRESHOLDS,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  THRESHOLDS_EVENTS_THRESH);
> >> + A  A  A  A  A  A  ret = true;
> >> + A  A  }
> >> + A  A  put_cpu();
> >> + A  A  return ret;
> >> +}
> >> +
> >> +static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
> >> +{
> >> + A  A  struct mem_cgroup_threshold_ary *thresholds;
> >> + A  A  u64 usage = mem_cgroup_usage(memcg, swap);
> >> + A  A  int i, cur;
> >> +
> >> + A  A  rcu_read_lock();
> >> + A  A  if (!swap) {
> >> + A  A  A  A  A  A  thresholds = rcu_dereference(memcg->thresholds);
> >> + A  A  } else {
> >> + A  A  A  A  A  A  thresholds = rcu_dereference(memcg->memsw_thresholds);
> >> + A  A  }
> >> +
> >> + A  A  if (!thresholds)
> >> + A  A  A  A  A  A  goto unlock;
> >> +
> >> + A  A  cur = atomic_read(&thresholds->cur);
> >> +
> >> + A  A  /* Check if a threshold crossed in any direction */
> >> +
> >> + A  A  for(i = cur; i >= 0 &&
> >> + A  A  A  A  A  A  unlikely(thresholds->entries[i].threshold > usage); i--) {
> >> + A  A  A  A  A  A  atomic_dec(&thresholds->cur);
> >> + A  A  A  A  A  A  eventfd_signal(thresholds->entries[i].eventfd, 1);
> >> + A  A  }
> >> +
> >> + A  A  for(i = cur + 1; i < thresholds->size &&
> >> + A  A  A  A  A  A  unlikely(thresholds->entries[i].threshold <= usage); i++) {
> >> + A  A  A  A  A  A  atomic_inc(&thresholds->cur);
> >> + A  A  A  A  A  A  eventfd_signal(thresholds->entries[i].eventfd, 1);
> >> + A  A  }

Could you add explanation here ?

> >> +unlock:
> >> + A  A  rcu_read_unlock();
> >> +}
> >> +
> >> +static void mem_cgroup_threshold(struct mem_cgroup *memcg)
> >> +{
> >> + A  A  __mem_cgroup_threshold(memcg, false);
> >> + A  A  if (do_swap_account)
> >> + A  A  A  A  A  A  __mem_cgroup_threshold(memcg, true);
> >> +}
> >> +
> >> +static int compare_thresholds(const void *a, const void *b)
> >> +{
> >> + A  A  const struct mem_cgroup_threshold *_a = a;
> >> + A  A  const struct mem_cgroup_threshold *_b = b;
> >> +
> >> + A  A  return _a->threshold - _b->threshold;
> >> +}
> >> +
> >> +static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
> >> + A  A  A  A  A  A  struct eventfd_ctx *eventfd, const char *args)
> >> +{
> >> + A  A  struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> >> + A  A  struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
> >> + A  A  int type = MEMFILE_TYPE(cft->private);
> >> + A  A  u64 threshold, usage;
> >> + A  A  int size;
> >> + A  A  int i, ret;
> >> +
> >> + A  A  ret = res_counter_memparse_write_strategy(args, &threshold);
> >> + A  A  if (ret)
> >> + A  A  A  A  A  A  return ret;
> >> +
> >> + A  A  mutex_lock(&memcg->thresholds_lock);
> >> + A  A  if (type == _MEM)
> >> + A  A  A  A  A  A  thresholds = memcg->thresholds;
> >> + A  A  else if (type == _MEMSWAP)
> >> + A  A  A  A  A  A  thresholds = memcg->memsw_thresholds;
> >> + A  A  else
> >> + A  A  A  A  A  A  BUG();
> >> +
> >> + A  A  usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
> >> +
> >> + A  A  /* Check if a threshold crossed before adding a new one */
> >> + A  A  if (thresholds)
> >> + A  A  A  A  A  A  __mem_cgroup_threshold(memcg, type == _MEMSWAP);
> >> +
> >> + A  A  if (thresholds)
> >> + A  A  A  A  A  A  size = thresholds->size + 1;
> >> + A  A  else
> >> + A  A  A  A  A  A  size = 1;
> >> +
> >> + A  A  /* Allocate memory for new array of thresholds */
> >> + A  A  thresholds_new = kmalloc(sizeof(*thresholds_new) +
> >> + A  A  A  A  A  A  A  A  A  A  size * sizeof(struct mem_cgroup_threshold),
> >> + A  A  A  A  A  A  A  A  A  A  GFP_KERNEL);
> >> + A  A  if (!thresholds_new) {
> >> + A  A  A  A  A  A  ret = -ENOMEM;
> >> + A  A  A  A  A  A  goto unlock;
> >> + A  A  }
> >> + A  A  thresholds_new->size = size;
> >> +
> >> + A  A  /* Copy thresholds (if any) to new array */
> >> + A  A  if (thresholds)
> >> + A  A  A  A  A  A  memcpy(thresholds_new->entries, thresholds->entries,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  thresholds->size *
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  sizeof(struct mem_cgroup_threshold));
> >> + A  A  /* Add new threshold */
> >> + A  A  thresholds_new->entries[size - 1].eventfd = eventfd;
> >> + A  A  thresholds_new->entries[size - 1].threshold = threshold;
> >> +
> >> + A  A  /* Sort thresholds. Registering of new threshold isn't time-critical */
> >> + A  A  sort(thresholds_new->entries, size,
> >> + A  A  A  A  A  A  A  A  A  A  sizeof(struct mem_cgroup_threshold),
> >> + A  A  A  A  A  A  A  A  A  A  compare_thresholds, NULL);
> >> +
> >> + A  A  /* Find current threshold */
> >> + A  A  atomic_set(&thresholds_new->cur, -1);
> >> + A  A  for(i = 0; i < size; i++) {
> >> + A  A  A  A  A  A  if (thresholds_new->entries[i].threshold < usage)
> >> + A  A  A  A  A  A  A  A  A  A  atomic_inc(&thresholds_new->cur);
> >> + A  A  }
> >> +
> >> + A  A  /*
> >> + A  A  A * We need to increment refcnt to be sure that all thresholds
> >> + A  A  A * will be unregistered before calling __mem_cgroup_free()
> >> + A  A  A */
> >> + A  A  mem_cgroup_get(memcg);
> >> +
> >> + A  A  if (type == _MEM)
> >> + A  A  A  A  A  A  rcu_assign_pointer(memcg->thresholds, thresholds_new);
> >> + A  A  else
> >> + A  A  A  A  A  A  rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
> >> +
> >> + A  A  synchronize_rcu();
> >
> > Could you add explanation when you use synchronize_rcu() ?
> 
> It uses before freeing old array of thresholds to be sure than nobody uses it.
> 
> >> + A  A  kfree(thresholds);
> >
> > Can't this be freed by RCU instead of synchronize_rcu() ?
> 
> Yes, this can. But I don't think that (un)registering os thresholds is
> time critical.
> I think my variant is more clean.
> 
I don't ;) But ok, this is a nitpick. Ignore me but add an explanation
commentary in codes.



> >> +unlock:
> >> + A  A  mutex_unlock(&memcg->thresholds_lock);
> >> +
> >> + A  A  return ret;
> >> +}
> >> +
> >> +static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
> >> + A  A  A  A  A  A  struct eventfd_ctx *eventfd)
> >> +{
> >> + A  A  struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> >> + A  A  struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
> >> + A  A  int type = MEMFILE_TYPE(cft->private);
> >> + A  A  u64 usage;
> >> + A  A  int size = 0;
> >> + A  A  int i, j, ret;
> >> +
> >> + A  A  mutex_lock(&memcg->thresholds_lock);
> >> + A  A  if (type == _MEM)
> >> + A  A  A  A  A  A  thresholds = memcg->thresholds;
> >> + A  A  else if (type == _MEMSWAP)
> >> + A  A  A  A  A  A  thresholds = memcg->memsw_thresholds;
> >> + A  A  else
> >> + A  A  A  A  A  A  BUG();
> >> +
> >> + A  A  /*
> >> + A  A  A * Something went wrong if we trying to unregister a threshold
> >> + A  A  A * if we don't have thresholds
> >> + A  A  A */
> >> + A  A  BUG_ON(!thresholds);
> >> +
> >> + A  A  usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
> >> +
> >> + A  A  /* Check if a threshold crossed before removing */
> >> + A  A  __mem_cgroup_threshold(memcg, type == _MEMSWAP);
> >> +
> >> + A  A  /* Calculate new number of threshold */
> >> + A  A  for(i = 0; i < thresholds->size; i++) {
> >> + A  A  A  A  A  A  if (thresholds->entries[i].eventfd != eventfd)
> >> + A  A  A  A  A  A  A  A  A  A  size++;
> >> + A  A  }
> >> +
> >> + A  A  /* Set thresholds array to NULL if we don't have thresholds */
> >> + A  A  if (!size) {
> >> + A  A  A  A  A  A  thresholds_new = NULL;
> >> + A  A  A  A  A  A  goto assign;
> >> + A  A  }
> >> +
> >> + A  A  /* Allocate memory for new array of thresholds */
> >> + A  A  thresholds_new = kmalloc(sizeof(*thresholds_new) +
> >> + A  A  A  A  A  A  A  A  A  A  size * sizeof(struct mem_cgroup_threshold),
> >> + A  A  A  A  A  A  A  A  A  A  GFP_KERNEL);
> >> + A  A  if (!thresholds_new) {
> >> + A  A  A  A  A  A  ret = -ENOMEM;
> >> + A  A  A  A  A  A  goto unlock;
> >> + A  A  }
> >> + A  A  thresholds_new->size = size;
> >> +
> >> + A  A  /* Copy thresholds and find current threshold */
> >> + A  A  atomic_set(&thresholds_new->cur, -1);
> >> + A  A  for(i = 0, j = 0; i < thresholds->size; i++) {
> >> + A  A  A  A  A  A  if (thresholds->entries[i].eventfd == eventfd)
> >> + A  A  A  A  A  A  A  A  A  A  continue;
> >> +
> >> + A  A  A  A  A  A  thresholds_new->entries[j] = thresholds->entries[i];
> >> + A  A  A  A  A  A  if (thresholds_new->entries[j].threshold < usage)
> >> + A  A  A  A  A  A  A  A  A  A  atomic_inc(&thresholds_new->cur);
> > It's better to do atomic set after loop.
> 
> We need one more counter to do this. Do you like it?
> 
Please add a comment that "cur" is for what or use better name. 
Honestly, I don't understand fully how "cur" moves. I'm not sure
whether updating at insert/delete is really necessary or not.


> >> + A  A  A  A  A  A  j++;
> >> + A  A  }
> >
> > Hmm..is this "copy array" usual coding style for handling eventfd ?
> 
> Since we store only pointer to struct eventfd_ctx, I don't see a problem.
> 
Following is just an suggestion after brief look...

IMO, "cur" is not necessary in the 1st version.
Using simple list and do full-scan always will be good as first step.
(And do necessary optimization later.)
Then, size of patch will be dramatically small.

I think the "cur" magic complicates details too much.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
