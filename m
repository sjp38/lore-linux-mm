Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 12E18600368
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 18:38:03 -0400 (EDT)
Date: Wed, 17 Mar 2010 23:37:58 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 4/5] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100317223758.GB8467@linux.develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <1268609202-15581-5-git-send-email-arighi@develer.com>
 <20100316113238.f7d74848.nishimura@mxp.nes.nec.co.jp>
 <20100316141150.GC9144@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100316141150.GC9144@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 16, 2010 at 10:11:50AM -0400, Vivek Goyal wrote:
> On Tue, Mar 16, 2010 at 11:32:38AM +0900, Daisuke Nishimura wrote:
> 
> [..]
> > > + * mem_cgroup_page_stat() - get memory cgroup file cache statistics
> > > + * @item:	memory statistic item exported to the kernel
> > > + *
> > > + * Return the accounted statistic value, or a negative value in case of error.
> > > + */
> > > +s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item)
> > > +{
> > > +	struct mem_cgroup_page_stat stat = {};
> > > +	struct mem_cgroup *mem;
> > > +
> > > +	rcu_read_lock();
> > > +	mem = mem_cgroup_from_task(current);
> > > +	if (mem && !mem_cgroup_is_root(mem)) {
> > > +		/*
> > > +		 * If we're looking for dirtyable pages we need to evaluate
> > > +		 * free pages depending on the limit and usage of the parents
> > > +		 * first of all.
> > > +		 */
> > > +		if (item == MEMCG_NR_DIRTYABLE_PAGES)
> > > +			stat.value = memcg_get_hierarchical_free_pages(mem);
> > > +		/*
> > > +		 * Recursively evaluate page statistics against all cgroup
> > > +		 * under hierarchy tree
> > > +		 */
> > > +		stat.item = item;
> > > +		mem_cgroup_walk_tree(mem, &stat, mem_cgroup_page_stat_cb);
> > > +	} else
> > > +		stat.value = -EINVAL;
> > > +	rcu_read_unlock();
> > > +
> > > +	return stat.value;
> > > +}
> > > +
> > hmm, mem_cgroup_page_stat() can return negative value, but you place BUG_ON()
> > in [5/5] to check it returns negative value. What happens if the current is moved
> > to root between mem_cgroup_has_dirty_limit() and mem_cgroup_page_stat() ?
> > How about making mem_cgroup_has_dirty_limit() return the target mem_cgroup, and
> > passing the mem_cgroup to mem_cgroup_page_stat() ?
> > 
> 
> Hmm, if mem_cgroup_has_dirty_limit() retrun pointer to memcg, then one
> shall have to use rcu_read_lock() and that will look ugly.
> 
> Why don't we simply look at the return value and if it is negative, we
> fall back to using global stats and get rid of BUG_ON()?

I vote for this one. IMHO the caller of mem_cgroup_page_stat() should
fallback to the equivalent global stats. This allows to keep the things
separated and put in mm/memcontrol.c only the memcg stuff.

> 
> Or, modify mem_cgroup_page_stat() to return global stats if it can't
> determine per cgroup stat for some reason. (mem=NULL or root cgroup etc).
> 
> Vivek

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
