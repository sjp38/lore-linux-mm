Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id F11786B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 20:17:22 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 36FC43EE0C2
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:17:21 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 132B645DE50
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:17:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E67DA45DE4D
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:17:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DAA5E1DB802F
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:17:20 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87EAA1DB803B
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:17:20 +0900 (JST)
Date: Wed, 29 Feb 2012 10:15:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/9] memcg: dirty page accounting support routines
Message-Id: <20120229101549.1d4ef3f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120228144507.acd70d1e.akpm@linux-foundation.org>
References: <20120228140022.614718843@intel.com>
	<20120228144747.124608935@intel.com>
	<20120228144507.acd70d1e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 28 Feb 2012 14:45:07 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 28 Feb 2012 22:00:26 +0800
> Fengguang Wu <fengguang.wu@intel.com> wrote:
> 
> > From: Greg Thelen <gthelen@google.com>
> > 
> > Added memcg dirty page accounting support routines.  These routines are
> > used by later changes to provide memcg aware writeback and dirty page
> > limiting.  A mem_cgroup_dirty_info() tracepoint is is also included to
> > allow for easier understanding of memcg writeback operation.
> > 
> > ...
> >
> > +/*
> > + * Return the number of additional pages that the @memcg cgroup could allocate.
> > + * If use_hierarchy is set, then this involves checking parent mem cgroups to
> > + * find the cgroup with the smallest free space.
> > + */
> 
> Comment needs revisting - use_hierarchy does not exist.
> 
> > +static unsigned long
> > +mem_cgroup_hierarchical_free_pages(struct mem_cgroup *memcg)
> > +{
> > +	u64 free;
> > +	unsigned long min_free;
> > +
> > +	min_free = global_page_state(NR_FREE_PAGES);
> > +
> > +	while (memcg) {
> > +		free = mem_cgroup_margin(memcg);
> > +		min_free = min_t(u64, min_free, free);
> > +		memcg = parent_mem_cgroup(memcg);
> > +	}
> > +
> > +	return min_free;
> > +}
> > +
> > +/*
> > + * mem_cgroup_page_stat() - get memory cgroup file cache statistics
> > + * @memcg:     memory cgroup to query
> > + * @item:      memory statistic item exported to the kernel
> > + *
> > + * Return the accounted statistic value.
> > + */
> > +unsigned long mem_cgroup_page_stat(struct mem_cgroup *memcg,
> > +				   enum mem_cgroup_page_stat_item item)
> > +{
> > +	struct mem_cgroup *iter;
> > +	s64 value;
> > +
> > +	/*
> > +	 * If we're looking for dirtyable pages we need to evaluate free pages
> > +	 * depending on the limit and usage of the parents first of all.
> > +	 */
> > +	if (item == MEMCG_NR_DIRTYABLE_PAGES)
> > +		value = mem_cgroup_hierarchical_free_pages(memcg);
> > +	else
> > +		value = 0;
> > +
> > +	/*
> > +	 * Recursively evaluate page statistics against all cgroup under
> > +	 * hierarchy tree
> > +	 */
> > +	for_each_mem_cgroup_tree(iter, memcg)
> > +		value += mem_cgroup_local_page_stat(iter, item);
> 
> What's the locking rule for for_each_mem_cgroup_tree()?  It's unobvious
> from the code and isn't documented?
> 

Because for_each_mem_cgroup_tree() uses rcu_read_lock() and referernce counting
internally, it's not required to take any lock in callers.
One rule is the caller shoud call mem_cgroup_iter_break() if he want to break
the loop.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
