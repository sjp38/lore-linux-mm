Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C15E16B007E
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 16:50:22 -0500 (EST)
Date: Tue, 2 Mar 2010 22:50:16 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 2/3] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100302215016.GA2369@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
 <1267478620-5276-3-git-send-email-arighi@develer.com>
 <20100302130223.GF3212@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100302130223.GF3212@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 02, 2010 at 06:32:24PM +0530, Balbir Singh wrote:

[snip]

> > +extern long mem_cgroup_dirty_ratio(void);
> > +extern unsigned long mem_cgroup_dirty_bytes(void);
> > +extern long mem_cgroup_dirty_background_ratio(void);
> > +extern unsigned long mem_cgroup_dirty_background_bytes(void);
> > +
> > +extern s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item);
> > +
> 
> Docstyle comments for each function would be appreciated

OK.

> >  /*
> >   * The memory controller data structure. The memory controller controls both
> >   * page cache and RSS per cgroup. We would eventually like to provide
> > @@ -205,6 +199,9 @@ struct mem_cgroup {
> > 
> >  	unsigned int	swappiness;
> > 
> > +	/* control memory cgroup dirty pages */
> > +	unsigned long dirty_param[MEM_CGROUP_DIRTY_NPARAMS];
> > +
> 
> Could you mention what protects this field, is it the reclaim_lock?

Yes, it is.

Actually, we could avoid the lock completely for dirty_param[], using a
validation routine to check for incoherencies after any read with
get_dirty_param(), and retry if the validation fails. In practice, the
same approach we're using to read global vm_dirty_ratio, vm_dirty_bytes,
etc...

Considering that those values are rarely written and read often we can
protect them in a RCU way.


> BTW, is unsigned long sufficient to represent dirty_param(s)?

Yes, I think. It's the same type used for the equivalent global values.

> 
> >  	/* set when res.limit == memsw.limit */
> >  	bool		memsw_is_minimum;
> > 
> > @@ -1021,6 +1018,164 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
> >  	return swappiness;
> >  }
> > 
> > +static unsigned long get_dirty_param(struct mem_cgroup *memcg,
> > +			enum mem_cgroup_dirty_param idx)
> > +{
> > +	unsigned long ret;
> > +
> > +	VM_BUG_ON(idx >= MEM_CGROUP_DIRTY_NPARAMS);
> > +	spin_lock(&memcg->reclaim_param_lock);
> > +	ret = memcg->dirty_param[idx];
> > +	spin_unlock(&memcg->reclaim_param_lock);
> 
> Do we need a spinlock if we protect it using RCU? Is precise data very
> important?

See above.

> > +unsigned long mem_cgroup_dirty_background_bytes(void)
> > +{
> > +	struct mem_cgroup *memcg;
> > +	unsigned long ret = dirty_background_bytes;
> > +
> > +	if (mem_cgroup_disabled())
> > +		return ret;
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	if (likely(memcg))
> > +		ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_BYTES);
> > +	rcu_read_unlock();
> > +
> > +	return ret;
> > +}
> > +
> > +static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
> > +{
> > +	return do_swap_account ?
> > +			res_counter_read_u64(&memcg->memsw, RES_LIMIT) :
> 
> Shouldn't you do a res_counter_read_u64(...) > 0 for readability?

OK.

> What happens if memcg->res, RES_LIMIT == memcg->memsw, RES_LIMIT?

OK, we should also check memcg->memsw_is_minimum.

> >  static struct cgroup_subsys_state * __ref
> >  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  {
> > @@ -3776,8 +4031,37 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	mem->last_scanned_child = 0;
> >  	spin_lock_init(&mem->reclaim_param_lock);
> > 
> > -	if (parent)
> > +	if (parent) {
> >  		mem->swappiness = get_swappiness(parent);
> > +
> > +		spin_lock(&parent->reclaim_param_lock);
> > +		copy_dirty_params(mem, parent);
> > +		spin_unlock(&parent->reclaim_param_lock);
> > +	} else {
> > +		/*
> > +		 * XXX: should we need a lock here? we could switch from
> > +		 * vm_dirty_ratio to vm_dirty_bytes or vice versa but we're not
> > +		 * reading them atomically. The same for dirty_background_ratio
> > +		 * and dirty_background_bytes.
> > +		 *
> > +		 * For now, try to read them speculatively and retry if a
> > +		 * "conflict" is detected.a
> 
> The do while loop is subtle, can we add a validate check,share it with
> the write routine and retry if validation fails?

Agreed.

> 
> > +		 */
> > +		do {
> > +			mem->dirty_param[MEM_CGROUP_DIRTY_RATIO] =
> > +						vm_dirty_ratio;
> > +			mem->dirty_param[MEM_CGROUP_DIRTY_BYTES] =
> > +						vm_dirty_bytes;
> > +		} while (mem->dirty_param[MEM_CGROUP_DIRTY_RATIO] &&
> > +			 mem->dirty_param[MEM_CGROUP_DIRTY_BYTES]);
> > +		do {
> > +			mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_RATIO] =
> > +						dirty_background_ratio;
> > +			mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_BYTES] =
> > +						dirty_background_bytes;
> > +		} while (mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_RATIO] &&
> > +			mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_BYTES]);
> > +	}
> >  	atomic_set(&mem->refcnt, 1);
> >  	mem->move_charge_at_immigrate = 0;
> >  	mutex_init(&mem->thresholds_lock);

Many thanks for reviewing,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
