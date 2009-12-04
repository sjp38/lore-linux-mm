Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7FA6007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 02:35:05 -0500 (EST)
Date: Fri, 4 Dec 2009 16:29:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 4/7] memcg: improbe performance in moving charge
Message-Id: <20091204162918.98aed8c8.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091204161004.146ae715.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
	<20091204145049.261b001b.nishimura@mxp.nes.nec.co.jp>
	<20091204161004.146ae715.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009 16:10:04 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 4 Dec 2009 14:50:49 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch tries to reduce overheads in moving charge by:
> > 
> > - Instead of calling res_counter_uncharge against the old cgroup in
> >   __mem_cgroup_move_account everytime, call res_counter_uncharge at the end of
> >   task migration once.
> > - Instead of calling res_counter_charge(via __mem_cgroup_try_charge) repeatedly,
> >   call res_counter_charge(PAGE_SIZE * count) in can_attach() if possible.
> > - Adds a new arg(count) to __css_put and make it decrement the css->refcnt
> >   by "count", not 1.
> > - Add a new function(__css_get), which takes "count" as a arg and increment
> >   the css->recnt by "count".
> > - Instead of calling css_get/css_put repeatedly, call new __css_get/__css_put
> >   if possible.
> > - removed css_get(&to->css) from __mem_cgroup_move_account(callers should have
> >   already called css_get), and removed css_put(&to->css) too, which is called by
> >   callers of move_account on success of move_account.
> > 
> > These changes reduces the overhead from 1.7sec to 0.6sec to move charges of 1G
> > anonymous memory in my test environment.
> > 
> > Changelog: 2009/12/04
> > - new patch
> > 
> seems nice in general.
>
Thank you.
 
> 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  include/linux/cgroup.h |   12 +++-
> >  kernel/cgroup.c        |    5 +-
> >  mm/memcontrol.c        |  151 +++++++++++++++++++++++++++++++-----------------
> >  3 files changed, 109 insertions(+), 59 deletions(-)
> > 
> > diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> > index d4cc200..61f75ae 100644
> > --- a/include/linux/cgroup.h
> > +++ b/include/linux/cgroup.h
> > @@ -75,6 +75,12 @@ enum {
> >  	CSS_REMOVED, /* This CSS is dead */
> >  };
> >  
> > +/* Caller must verify that the css is not for root cgroup */
> > +static inline void __css_get(struct cgroup_subsys_state *css, int count)
> > +{
> > +	atomic_add(count, &css->refcnt);
> > +}
> > +
> >  /*
> >   * Call css_get() to hold a reference on the css; it can be used
> >   * for a reference obtained via:
> > @@ -86,7 +92,7 @@ static inline void css_get(struct cgroup_subsys_state *css)
> >  {
> >  	/* We don't need to reference count the root state */
> >  	if (!test_bit(CSS_ROOT, &css->flags))
> > -		atomic_inc(&css->refcnt);
> > +		__css_get(css, 1);
> >  }
> >  
> >  static inline bool css_is_removed(struct cgroup_subsys_state *css)
> > @@ -117,11 +123,11 @@ static inline bool css_tryget(struct cgroup_subsys_state *css)
> >   * css_get() or css_tryget()
> >   */
> >  
> > -extern void __css_put(struct cgroup_subsys_state *css);
> > +extern void __css_put(struct cgroup_subsys_state *css, int count);
> >  static inline void css_put(struct cgroup_subsys_state *css)
> >  {
> >  	if (!test_bit(CSS_ROOT, &css->flags))
> > -		__css_put(css);
> > +		__css_put(css, 1);
> >  }
> > 
> 
> Maybe it's better to divide cgroup part in other patches. Li or Paul has to review.
> 
>  
I agree.

> >  /* bits in struct cgroup flags field */
> > diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> > index d67d471..44f5924 100644
> > --- a/kernel/cgroup.c
> > +++ b/kernel/cgroup.c
> > @@ -3729,12 +3729,13 @@ static void check_for_release(struct cgroup *cgrp)
> >  	}
> >  }
> >  
> > -void __css_put(struct cgroup_subsys_state *css)
> > +/*  Caller must verify that the css is not for root cgroup */
> > +void __css_put(struct cgroup_subsys_state *css, int count)
> >  {
> >  	struct cgroup *cgrp = css->cgroup;
> >  	int val;
> >  	rcu_read_lock();
> > -	val = atomic_dec_return(&css->refcnt);
> > +	val = atomic_sub_return(count, &css->refcnt);
> >  	if (val == 1) {
> >  		if (notify_on_release(cgrp)) {
> >  			set_bit(CGRP_RELEASABLE, &cgrp->flags);
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e38f211..769b85a 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -252,6 +252,7 @@ struct move_charge_struct {
> >  	struct mem_cgroup *from;
> >  	struct mem_cgroup *to;
> >  	unsigned long precharge;
> > +	unsigned long moved_charge;
> >  };
> >  static struct move_charge_struct mc;
> >  
> > @@ -1532,14 +1533,23 @@ nomem:
> >   * This function is for that and do uncharge, put css's refcnt.
> >   * gotten by try_charge().
> >   */
> > -static void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
> > +static void __mem_cgroup_cancel_charge(struct mem_cgroup *mem,
> > +							unsigned long count)
> >  {
> >  	if (!mem_cgroup_is_root(mem)) {
> > -		res_counter_uncharge(&mem->res, PAGE_SIZE);
> > +		res_counter_uncharge(&mem->res, PAGE_SIZE * count);
> >  		if (do_swap_account)
> > -			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > +			res_counter_uncharge(&mem->memsw, PAGE_SIZE * count);
> > +		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
> > +		WARN_ON_ONCE(count > INT_MAX);
> 
> Hmm. is this WARN_ON necessary ? ...maybe res_counter_uncharge() will catch
> this, anyway.
> 
The arg of atomic_add/dec is "int", so IMHO, it would be better to check here
(I think we neve hit this in real use).

> > +		__css_put(&mem->css, (int)count);
> >  	}
> > -	css_put(&mem->css);
> > +	/* we don't need css_put for root */
> > +}
> > +
> > +static void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
> > +{
> > +	__mem_cgroup_cancel_charge(mem, 1);
> >  }
> >  
> >  /*
> > @@ -1645,17 +1655,20 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> >   * @pc:	page_cgroup of the page.
> >   * @from: mem_cgroup which the page is moved from.
> >   * @to:	mem_cgroup which the page is moved to. @from != @to.
> > + * @uncharge: whether we should call uncharge and css_put against @from.
> >   *
> >   * The caller must confirm following.
> >   * - page is not on LRU (isolate_page() is useful.)
> >   * - the pc is locked, used, and ->mem_cgroup points to @from.
> >   *
> > - * This function does "uncharge" from old cgroup but doesn't do "charge" to
> > - * new cgroup. It should be done by a caller.
> > + * This function doesn't do "charge" nor css_get to new cgroup. It should be
> > + * done by a caller(__mem_cgroup_try_charge would be usefull). If @uncharge is
> > + * true, this function does "uncharge" from old cgroup, but it doesn't if
> > + * @uncharge is false, so a caller should do "uncharge".
> >   */
> >  
> >  static void __mem_cgroup_move_account(struct page_cgroup *pc,
> > -	struct mem_cgroup *from, struct mem_cgroup *to)
> > +	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
> >  {
> >  	struct page *page;
> >  	int cpu;
> > @@ -1668,10 +1681,6 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
> >  	VM_BUG_ON(!PageCgroupUsed(pc));
> >  	VM_BUG_ON(pc->mem_cgroup != from);
> >  
> > -	if (!mem_cgroup_is_root(from))
> > -		res_counter_uncharge(&from->res, PAGE_SIZE);
> > -	mem_cgroup_charge_statistics(from, pc, false);
> > -
> >  	page = pc->page;
> >  	if (page_mapped(page) && !PageAnon(page)) {
> >  		cpu = smp_processor_id();
> > @@ -1687,12 +1696,12 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
> >  		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_FILE_MAPPED,
> >  						1);
> >  	}
> > +	mem_cgroup_charge_statistics(from, pc, false);
> > +	if (uncharge)
> > +		/* This is not "cancel", but cancel_charge does all we need. */
> > +		mem_cgroup_cancel_charge(from);
> >  
> > -	if (do_swap_account && !mem_cgroup_is_root(from))
> > -		res_counter_uncharge(&from->memsw, PAGE_SIZE);
> > -	css_put(&from->css);
> > -
> > -	css_get(&to->css);
> > +	/* caller should have done css_get */
> >  	pc->mem_cgroup = to;
> >  	mem_cgroup_charge_statistics(to, pc, true);
> >  	/*
> > @@ -1709,12 +1718,12 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
> >   * __mem_cgroup_move_account()
> >   */
> >  static int mem_cgroup_move_account(struct page_cgroup *pc,
> > -				struct mem_cgroup *from, struct mem_cgroup *to)
> > +		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
> >  {
> >  	int ret = -EINVAL;
> >  	lock_page_cgroup(pc);
> >  	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
> > -		__mem_cgroup_move_account(pc, from, to);
> > +		__mem_cgroup_move_account(pc, from, to, uncharge);
> >  		ret = 0;
> >  	}
> >  	unlock_page_cgroup(pc);
> > @@ -1750,11 +1759,9 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
> >  	if (ret || !parent)
> >  		goto put_back;
> >  
> > -	ret = mem_cgroup_move_account(pc, child, parent);
> > -	if (!ret)
> > -		css_put(&parent->css);	/* drop extra refcnt by try_charge() */
> > -	else
> > -		mem_cgroup_cancel_charge(parent);	/* does css_put */
> > +	ret = mem_cgroup_move_account(pc, child, parent, true);
> > +	if (ret)
> > +		mem_cgroup_cancel_charge(parent);
> >  put_back:
> >  	putback_lru_page(page);
> >  put:
> > @@ -3441,16 +3448,57 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
> >  }
> >  
> >  /* Handlers for move charge at task migration. */
> > -static int mem_cgroup_do_precharge(void)
> > +#define PRECHARGE_COUNT_AT_ONCE	256
> > +static int mem_cgroup_do_precharge(unsigned long count)
> >  {
> > -	int ret = -ENOMEM;
> > +	int ret = 0;
> > +	int batch_count = PRECHARGE_COUNT_AT_ONCE;
> >  	struct mem_cgroup *mem = mc.to;
> >  
> > -	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false, NULL);
> > -	if (ret || !mem)
> > -		return -ENOMEM;
> > -
> > -	mc.precharge++;
> > +	if (mem_cgroup_is_root(mem)) {
> > +		mc.precharge += count;
> > +		/* we don't need css_get for root */
> > +		return ret;
> > +	}
> > +	/* try to charge at once */
> > +	if (count > 1) {
> > +		struct res_counter *dummy;
> > +		/*
> > +		 * "mem" cannot be under rmdir() because we've already checked
> > +		 * by cgroup_lock_live_cgroup() that it is not removed and we
> > +		 * are still under the same cgroup_mutex. So we can postpone
> > +		 * css_get().
> > +		 */
> > +		if (res_counter_charge(&mem->res, PAGE_SIZE * count, &dummy))
> > +			goto one_by_one;
> 
>  if (do_swap_account) here.
> 
Ah, yes. you're right.

> > +		if (res_counter_charge(&mem->memsw,
> > +						PAGE_SIZE * count, &dummy)) {
> > +			res_counter_uncharge(&mem->res, PAGE_SIZE * count);
> > +			goto one_by_one;
> > +		}
> > +		mc.precharge += count;
> > +		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
> > +		WARN_ON_ONCE(count > INT_MAX);
> > +		__css_get(&mem->css, (int)count);
> > +		return ret;
> > +	}
> > +one_by_one:
> > +	/* fall back to one by one charge */
> > +	while (!ret && count--) {
> 
> !ret check seems unnecessary.
yes.. will remove.

> > +		if (signal_pending(current)) {
> > +			ret = -EINTR;
> > +			break;
> > +		}
> > +		if (!batch_count--) {
> > +			batch_count = PRECHARGE_COUNT_AT_ONCE;
> > +			cond_resched();
> > +		}
> > +		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem,
> > +								false, NULL);
> > +		if (ret || !mem)
> > +			return -ENOMEM;
> 
> returning without uncharge here ?
> 
If we return here with -ENOMEM, mem_cgroup_can_attach calls mem_cgroup_clear_mc,
which will do uncharge. I will add some comments.

Thank you for your careful review.


Regards,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
