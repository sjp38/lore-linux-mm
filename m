Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 43C3D6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 06:01:02 -0500 (EST)
Date: Tue, 2 Mar 2010 12:00:58 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 2/3] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100302110058.GA1921@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
 <1267478620-5276-3-git-send-email-arighi@develer.com>
 <cc557aab1003020204k16038838ta537357aeeb67b11@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cc557aab1003020204k16038838ta537357aeeb67b11@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 02, 2010 at 12:04:53PM +0200, Kirill A. Shutemov wrote:
[snip]
> > +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> > +{
> > +       return -ENOMEM;
> 
> Why ENOMEM? Probably, EINVAL or ENOSYS?

OK, ENOSYS is more appropriate IMHO.

> > +static s64 mem_cgroup_get_local_page_stat(struct mem_cgroup *memcg,
> > +                               enum mem_cgroup_page_stat_item item)
> > +{
> > +       s64 ret;
> > +
> > +       switch (item) {
> > +       case MEMCG_NR_DIRTYABLE_PAGES:
> > +               ret = res_counter_read_u64(&memcg->res, RES_LIMIT) -
> > +                       res_counter_read_u64(&memcg->res, RES_USAGE);
> > +               /* Translate free memory in pages */
> > +               ret >>= PAGE_SHIFT;
> > +               ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_FILE) +
> > +                       mem_cgroup_read_stat(memcg, LRU_INACTIVE_FILE);
> > +               if (mem_cgroup_can_swap(memcg))
> > +                       ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_ANON) +
> > +                               mem_cgroup_read_stat(memcg, LRU_INACTIVE_ANON);
> > +               break;
> > +       case MEMCG_NR_RECLAIM_PAGES:
> > +               ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_DIRTY) +
> > +                       mem_cgroup_read_stat(memcg,
> > +                                       MEM_CGROUP_STAT_UNSTABLE_NFS);
> > +               break;
> > +       case MEMCG_NR_WRITEBACK:
> > +               ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
> > +               break;
> > +       case MEMCG_NR_DIRTY_WRITEBACK_PAGES:
> > +               ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK) +
> > +                       mem_cgroup_read_stat(memcg,
> > +                               MEM_CGROUP_STAT_UNSTABLE_NFS);
> > +               break;
> > +       default:
> > +               ret = 0;
> > +               WARN_ON_ONCE(1);
> 
> I think it's a bug, not warning.

OK.

> > +       }
> > +       return ret;
> > +}
> > +
> > +static int mem_cgroup_page_stat_cb(struct mem_cgroup *mem, void *data)
> > +{
> > +       struct mem_cgroup_page_stat *stat = (struct mem_cgroup_page_stat *)data;
> > +
> > +       stat->value += mem_cgroup_get_local_page_stat(mem, stat->item);
> > +       return 0;
> > +}
> > +
> > +s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> > +{
> > +       struct mem_cgroup_page_stat stat = {};
> > +       struct mem_cgroup *memcg;
> > +
> > +       if (mem_cgroup_disabled())
> > +               return -ENOMEM;
> 
> EINVAL/ENOSYS?

OK.

> 
> > +       rcu_read_lock();
> > +       memcg = mem_cgroup_from_task(current);
> > +       if (memcg) {
> > +               /*
> > +                * Recursively evaulate page statistics against all cgroup
> > +                * under hierarchy tree
> > +                */
> > +               stat.item = item;
> > +               mem_cgroup_walk_tree(memcg, &stat, mem_cgroup_page_stat_cb);
> > +       } else
> > +               stat.value = -ENOMEM;
> 
> ditto.

OK.

> 
> > +       rcu_read_unlock();
> > +
> > +       return stat.value;
> > +}
> > +
> >  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
> >  {
> >        int *val = data;
> > @@ -1263,14 +1418,16 @@ static void record_last_oom(struct mem_cgroup *mem)
> >  }
> >
> >  /*
> > - * Currently used to update mapped file statistics, but the routine can be
> > - * generalized to update other statistics as well.
> > + * Generalized routine to update memory cgroup statistics.
> >  */
> > -void mem_cgroup_update_file_mapped(struct page *page, int val)
> > +void mem_cgroup_update_stat(struct page *page,
> > +                       enum mem_cgroup_stat_index idx, int val)
> 
> EXPORT_SYMBOL_GPL(mem_cgroup_update_stat) is needed, since
> it uses by filesystems.

Agreed.

> > +static int
> > +mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
> > +{
> > +       struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +       int type = cft->private;
> > +
> > +       if (cgrp->parent == NULL)
> > +               return -EINVAL;
> > +       if (((type == MEM_CGROUP_DIRTY_RATIO) ||
> > +               (type == MEM_CGROUP_DIRTY_BACKGROUND_RATIO)) && (val > 100))
> 
> Too many unnecessary brackets
> 
>        if ((type == MEM_CGROUP_DIRTY_RATIO ||
>                type == MEM_CGROUP_DIRTY_BACKGROUND_RATIO) && val > 100)
> 

OK.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
