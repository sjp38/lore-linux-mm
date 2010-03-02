Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CB37B6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 17:25:06 -0500 (EST)
Date: Tue, 2 Mar 2010 23:24:55 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 2/3] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100302222455.GE2369@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
 <1267478620-5276-3-git-send-email-arighi@develer.com>
 <49b004811003021008t4fae71bbu8d56192e48c32f39@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <49b004811003021008t4fae71bbu8d56192e48c32f39@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 02, 2010 at 10:08:17AM -0800, Greg Thelen wrote:
> Comments below.  Yet to be tested on my end, but I will test it.
> 
> On Mon, Mar 1, 2010 at 1:23 PM, Andrea Righi <arighi@develer.com> wrote:
> > Infrastructure to account dirty pages per cgroup and add dirty limit
> > interfaces in the cgroupfs:
> >
> >  - Direct write-out: memory.dirty_ratio, memory.dirty_bytes
> >
> >  - Background write-out: memory.dirty_background_ratio, memory.dirty_background_bytes
> >
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > ---
> >  include/linux/memcontrol.h |   77 ++++++++++-
> >  mm/memcontrol.c            |  336 ++++++++++++++++++++++++++++++++++++++++----
> >  2 files changed, 384 insertions(+), 29 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 1f9b119..cc88b2e 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -19,12 +19,50 @@
> >
> >  #ifndef _LINUX_MEMCONTROL_H
> >  #define _LINUX_MEMCONTROL_H
> > +
> > +#include <linux/writeback.h>
> >  #include <linux/cgroup.h>
> > +
> >  struct mem_cgroup;
> >  struct page_cgroup;
> >  struct page;
> >  struct mm_struct;
> >
> > +/* Cgroup memory statistics items exported to the kernel */
> > +enum mem_cgroup_page_stat_item {
> > +       MEMCG_NR_DIRTYABLE_PAGES,
> > +       MEMCG_NR_RECLAIM_PAGES,
> > +       MEMCG_NR_WRITEBACK,
> > +       MEMCG_NR_DIRTY_WRITEBACK_PAGES,
> > +};
> > +
> > +/*
> > + * Statistics for memory cgroup.
> > + */
> > +enum mem_cgroup_stat_index {
> > +       /*
> > +        * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> > +        */
> > +       MEM_CGROUP_STAT_CACHE,     /* # of pages charged as cache */
> > +       MEM_CGROUP_STAT_RSS,       /* # of pages charged as anon rss */
> > +       MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> > +       MEM_CGROUP_STAT_PGPGIN_COUNT,   /* # of pages paged in */
> > +       MEM_CGROUP_STAT_PGPGOUT_COUNT,  /* # of pages paged out */
> > +       MEM_CGROUP_STAT_EVENTS, /* sum of pagein + pageout for internal use */
> > +       MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > +       MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> > +                                       used by soft limit implementation */
> > +       MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> > +                                       used by threshold implementation */
> > +       MEM_CGROUP_STAT_FILE_DIRTY,   /* # of dirty pages in page cache */
> > +       MEM_CGROUP_STAT_WRITEBACK,   /* # of pages under writeback */
> > +       MEM_CGROUP_STAT_WRITEBACK_TEMP,   /* # of pages under writeback using
> > +                                               temporary buffers */
> > +       MEM_CGROUP_STAT_UNSTABLE_NFS,   /* # of NFS unstable pages */
> > +
> > +       MEM_CGROUP_STAT_NSTATS,
> > +};
> > +
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> >  /*
> >  * All "charge" functions with gfp_mask should use GFP_KERNEL or
> > @@ -117,6 +155,13 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> >  extern int do_swap_account;
> >  #endif
> >
> > +extern long mem_cgroup_dirty_ratio(void);
> > +extern unsigned long mem_cgroup_dirty_bytes(void);
> > +extern long mem_cgroup_dirty_background_ratio(void);
> > +extern unsigned long mem_cgroup_dirty_background_bytes(void);
> > +
> > +extern s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item);
> > +
> >  static inline bool mem_cgroup_disabled(void)
> >  {
> >        if (mem_cgroup_subsys.disabled)
> > @@ -125,7 +170,8 @@ static inline bool mem_cgroup_disabled(void)
> >  }
> >
> >  extern bool mem_cgroup_oom_called(struct task_struct *task);
> > -void mem_cgroup_update_file_mapped(struct page *page, int val);
> > +void mem_cgroup_update_stat(struct page *page,
> > +                       enum mem_cgroup_stat_index idx, int val);
> >  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >                                                gfp_t gfp_mask, int nid,
> >                                                int zid);
> > @@ -300,8 +346,8 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> >  {
> >  }
> >
> > -static inline void mem_cgroup_update_file_mapped(struct page *page,
> > -                                                       int val)
> > +static inline void mem_cgroup_update_stat(struct page *page,
> > +                       enum mem_cgroup_stat_index idx, int val)
> >  {
> >  }
> >
> > @@ -312,6 +358,31 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >        return 0;
> >  }
> >
> > +static inline long mem_cgroup_dirty_ratio(void)
> > +{
> > +       return vm_dirty_ratio;
> > +}
> > +
> > +static inline unsigned long mem_cgroup_dirty_bytes(void)
> > +{
> > +       return vm_dirty_bytes;
> > +}
> > +
> > +static inline long mem_cgroup_dirty_background_ratio(void)
> > +{
> > +       return dirty_background_ratio;
> > +}
> > +
> > +static inline unsigned long mem_cgroup_dirty_background_bytes(void)
> > +{
> > +       return dirty_background_bytes;
> > +}
> > +
> > +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> > +{
> > +       return -ENOMEM;
> > +}
> > +
> >  #endif /* CONFIG_CGROUP_MEM_CONT */
> >
> >  #endif /* _LINUX_MEMCONTROL_H */
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index a443c30..e74cf66 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -66,31 +66,16 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
> >  #define SOFTLIMIT_EVENTS_THRESH (1000)
> >  #define THRESHOLDS_EVENTS_THRESH (100)
> >
> > -/*
> > - * Statistics for memory cgroup.
> > - */
> > -enum mem_cgroup_stat_index {
> > -       /*
> > -        * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> > -        */
> > -       MEM_CGROUP_STAT_CACHE,     /* # of pages charged as cache */
> > -       MEM_CGROUP_STAT_RSS,       /* # of pages charged as anon rss */
> > -       MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> > -       MEM_CGROUP_STAT_PGPGIN_COUNT,   /* # of pages paged in */
> > -       MEM_CGROUP_STAT_PGPGOUT_COUNT,  /* # of pages paged out */
> > -       MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > -       MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> > -                                       used by soft limit implementation */
> > -       MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> > -                                       used by threshold implementation */
> > -
> > -       MEM_CGROUP_STAT_NSTATS,
> > -};
> > -
> >  struct mem_cgroup_stat_cpu {
> >        s64 count[MEM_CGROUP_STAT_NSTATS];
> >  };
> >
> > +/* Per cgroup page statistics */
> > +struct mem_cgroup_page_stat {
> > +       enum mem_cgroup_page_stat_item item;
> > +       s64 value;
> > +};
> > +
> >  /*
> >  * per-zone information in memory controller.
> >  */
> > @@ -157,6 +142,15 @@ struct mem_cgroup_threshold_ary {
> >  static bool mem_cgroup_threshold_check(struct mem_cgroup *mem);
> >  static void mem_cgroup_threshold(struct mem_cgroup *mem);
> >
> > +enum mem_cgroup_dirty_param {
> > +       MEM_CGROUP_DIRTY_RATIO,
> > +       MEM_CGROUP_DIRTY_BYTES,
> > +       MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> > +       MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> > +
> > +       MEM_CGROUP_DIRTY_NPARAMS,
> > +};
> > +
> >  /*
> >  * The memory controller data structure. The memory controller controls both
> >  * page cache and RSS per cgroup. We would eventually like to provide
> > @@ -205,6 +199,9 @@ struct mem_cgroup {
> >
> >        unsigned int    swappiness;
> >
> > +       /* control memory cgroup dirty pages */
> > +       unsigned long dirty_param[MEM_CGROUP_DIRTY_NPARAMS];
> > +
> >        /* set when res.limit == memsw.limit */
> >        bool            memsw_is_minimum;
> >
> > @@ -1021,6 +1018,164 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
> >        return swappiness;
> >  }
> >
> > +static unsigned long get_dirty_param(struct mem_cgroup *memcg,
> > +                       enum mem_cgroup_dirty_param idx)
> > +{
> > +       unsigned long ret;
> > +
> > +       VM_BUG_ON(idx >= MEM_CGROUP_DIRTY_NPARAMS);
> > +       spin_lock(&memcg->reclaim_param_lock);
> > +       ret = memcg->dirty_param[idx];
> > +       spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +       return ret;
> > +}
> > +
> 
> > +long mem_cgroup_dirty_ratio(void)
> > +{
> > +       struct mem_cgroup *memcg;
> > +       long ret = vm_dirty_ratio;
> > +
> > +       if (mem_cgroup_disabled())
> > +               return ret;
> > +       /*
> > +        * It's possible that "current" may be moved to other cgroup while we
> > +        * access cgroup. But precise check is meaningless because the task can
> > +        * be moved after our access and writeback tends to take long time.
> > +        * At least, "memcg" will not be freed under rcu_read_lock().
> > +        */
> > +       rcu_read_lock();
> > +       memcg = mem_cgroup_from_task(current);
> > +       if (likely(memcg))
> > +               ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_RATIO);
> > +       rcu_read_unlock();
> > +
> > +       return ret;
> > +}
> > +
> > +unsigned long mem_cgroup_dirty_bytes(void)
> > +{
> > +       struct mem_cgroup *memcg;
> > +       unsigned long ret = vm_dirty_bytes;
> > +
> > +       if (mem_cgroup_disabled())
> > +               return ret;
> > +       rcu_read_lock();
> > +       memcg = mem_cgroup_from_task(current);
> > +       if (likely(memcg))
> > +               ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BYTES);
> > +       rcu_read_unlock();
> > +
> > +       return ret;
> > +}
> > +
> > +long mem_cgroup_dirty_background_ratio(void)
> > +{
> > +       struct mem_cgroup *memcg;
> > +       long ret = dirty_background_ratio;
> > +
> > +       if (mem_cgroup_disabled())
> > +               return ret;
> > +       rcu_read_lock();
> > +       memcg = mem_cgroup_from_task(current);
> > +       if (likely(memcg))
> > +               ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_RATIO);
> > +       rcu_read_unlock();
> > +
> > +       return ret;
> > +}
> > +
> > +unsigned long mem_cgroup_dirty_background_bytes(void)
> > +{
> > +       struct mem_cgroup *memcg;
> > +       unsigned long ret = dirty_background_bytes;
> > +
> > +       if (mem_cgroup_disabled())
> > +               return ret;
> > +       rcu_read_lock();
> > +       memcg = mem_cgroup_from_task(current);
> > +       if (likely(memcg))
> > +               ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_BYTES);
> > +       rcu_read_unlock();
> > +
> > +       return ret;
> > +}
> 
> Given that mem_cgroup_dirty_[background_]{ratio,bytes}() are similar,
> should we refactor the majority of them into a single routine?

Agreed.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
