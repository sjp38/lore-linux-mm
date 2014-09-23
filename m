Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F44D6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 07:06:55 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id eu11so4656227pac.24
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 04:06:55 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id zx9si19937085pac.187.2014.09.23.04.06.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 04:06:54 -0700 (PDT)
Date: Tue, 23 Sep 2014 15:06:34 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140923110634.GH18526@esperanza>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144158.GC20398@esperanza>
 <20140922185736.GB6630@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140922185736.GB6630@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 22, 2014 at 02:57:36PM -0400, Johannes Weiner wrote:
> On Mon, Sep 22, 2014 at 06:41:58PM +0400, Vladimir Davydov wrote:
> > On Fri, Sep 19, 2014 at 09:22:08AM -0400, Johannes Weiner wrote:
> > > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > > index 19df5d857411..bf8fb1a05597 100644
> > > --- a/include/linux/memcontrol.h
> > > +++ b/include/linux/memcontrol.h
> > > @@ -54,6 +54,38 @@ struct mem_cgroup_reclaim_cookie {
> > >  };
> > >  
> > >  #ifdef CONFIG_MEMCG
> > > +
> > > +struct page_counter {
> > 
> > I'd place it in a separate file, say
> > 
> > 	include/linux/page_counter.h
> > 	mm/page_counter.c
> > 
> > just to keep mm/memcontrol.c clean.
> 
> The page counters are the very core of the memory controller and, as I
> said to Michal, I want to integrate the hugetlb controller into memcg
> as well, at which point there won't be any outside users anymore.  So
> I think this is the right place for it.

Hmm, there might be memcg users out there that don't want to pay for
hugetlb accounting. Or is the overhead supposed to be negligible?

Anyway, I still don't think it's a good idea to keep all the definitions
in the same file. memcontrol.c is already huge. Adding more code to it
is not desirable, especially if it can naturally live in a separate
file. And since the page_counter is independent of the memcg core and
*looks* generic, I believe we should keep it separately.

> > > +	atomic_long_t count;
> > > +	unsigned long limit;
> > > +	struct page_counter *parent;
> > > +
> > > +	/* legacy */
> > > +	unsigned long watermark;
> > > +	unsigned long limited;
> > 
> > IMHO, failcnt would fit better.
> 
> I never liked the failcnt name, but also have to admit that "limited"
> is crap.  Let's leave it at failcnt for now.
> 
> > > +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
> > 
> > When I first saw this function, I couldn't realize by looking at its
> > name what it's intended to do. I think
> > 
> > 	page_counter_cancel_local_charge()
> > 
> > would fit better.
> 
> It's a fairly unwieldy name.  How about page_counter_sub()?  local_sub()?

The _sub suffix doesn't match _charge/_uncharge. May be
page_counter_local_uncharge, or _uncharge_local?

> 
> > > +int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
> > > +			struct page_counter **fail);
> > > +int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
> > > +int page_counter_limit(struct page_counter *counter, unsigned long limit);
> > 
> > Hmm, why not page_counter_set_limit?
> 
> Limit is used as a verb here, "to limit".  Getters and setters are
> usually wrappers around unusual/complex data structure access,

Not necessarily. Look at percpu_counter_read e.g. It's a one-line
getter, which we could easily live w/o, but still it's there.

> but this function does a lot more, so I'm not fond of _set_limit().

Nevertheless, everything it does can be perfectly described in one
sentence "it tries to set the new value of the limit", so it does
function as a setter. And if there's a setter, there must be a getter
IMO.

> > > @@ -1218,34 +1217,26 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
> > >  					      unsigned long amt,
> > >  					      int *parent_status)
> > >  {
> > > -	struct res_counter *fail;
> > > -	int ret;
> > > +	page_counter_charge(&prot->memory_allocated, amt, NULL);
> > >  
> > > -	ret = res_counter_charge_nofail(&prot->memory_allocated,
> > > -					amt << PAGE_SHIFT, &fail);
> > > -	if (ret < 0)
> > > +	if (atomic_long_read(&prot->memory_allocated.count) >
> > > +	    prot->memory_allocated.limit)
> > 
> > I don't like your equivalent of res_counter_charge_nofail.
> > 
> > Passing NULL to page_counter_charge might be useful if one doesn't have
> > a back-off strategy, but still want to fail on hitting the limit. With
> > your interface the user must pass something to the function then, which
> > isn't convenient.
> > 
> > Besides, it depends on the internal implementation of the page_counter
> > struct. I'd encapsulate this.
> 
> Thinking about this more, I don't like my version either; not because
> of how @fail must always be passed, but because of how it changes the
> behavior.  I changed the API to
> 
> void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
> int page_counter_try_charge(struct page_counter *counter, unsigned long nr_pages,
>                             struct page_counter **fail);

That looks good to me. I would also add something like

  bool page_counter_exceeds_limit(struct page_counter *counter);

to use instead of this

+	if (atomic_long_read(&prot->memory_allocated.count) >
+	    prot->memory_allocated.limit)

> We could make @fail optional in the try_charge(), but all callsites
> pass it at this time, so for now I kept it mandatory for simplicity.

It doesn't really matter to me. Both variants are fine.

[...]
> > > @@ -222,61 +220,73 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
> > >  	if (unlikely(!h_cg))
> > >  		return;
> > >  	set_hugetlb_cgroup(page, NULL);
> > > -	res_counter_uncharge(&h_cg->hugepage[idx], csize);
> > > +	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
> > >  	return;
> > >  }
> > >  
> > >  void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
> > >  				    struct hugetlb_cgroup *h_cg)
> > >  {
> > > -	unsigned long csize = nr_pages * PAGE_SIZE;
> > > -
> > >  	if (hugetlb_cgroup_disabled() || !h_cg)
> > >  		return;
> > >  
> > >  	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
> > >  		return;
> > >  
> > > -	res_counter_uncharge(&h_cg->hugepage[idx], csize);
> > > +	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
> > >  	return;
> > >  }
> > >  
> > > +enum {
> > > +	RES_USAGE,
> > > +	RES_LIMIT,
> > > +	RES_MAX_USAGE,
> > > +	RES_FAILCNT,
> > > +};
> > > +
> > >  static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
> > >  				   struct cftype *cft)
> > >  {
> > > -	int idx, name;
> > > +	struct page_counter *counter;
> > >  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
> > >  
> > > -	idx = MEMFILE_IDX(cft->private);
> > > -	name = MEMFILE_ATTR(cft->private);
> > > +	counter = &h_cg->hugepage[MEMFILE_IDX(cft->private)];
> > >  
> > > -	return res_counter_read_u64(&h_cg->hugepage[idx], name);
> > > +	switch (MEMFILE_ATTR(cft->private)) {
> > > +	case RES_USAGE:
> > > +		return (u64)atomic_long_read(&counter->count) * PAGE_SIZE;
> > 
> > page_counter_read?
> > 
> > > +	case RES_LIMIT:
> > > +		return (u64)counter->limit * PAGE_SIZE;
> > 
> > page_counter_get_limit?
> > 
> > > +	case RES_MAX_USAGE:
> > > +		return (u64)counter->watermark * PAGE_SIZE;
> > 
> > page_counter_read_watermark?
> 
> I added page_counter_read() to abstract away the fact that we use a
> signed counter internally, but it still returns the number of pages as
> unsigned long.

That's exactly what I meant.

> The entire counter API is based on pages now, and only the userspace
> interface translates back and forth into bytes, so that's where the
> translation should be located.

Absolutely right.

[...]
> > > @@ -288,18 +298,18 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
> > >  static ssize_t hugetlb_cgroup_reset(struct kernfs_open_file *of,
> > >  				    char *buf, size_t nbytes, loff_t off)
> > >  {
> > > -	int idx, name, ret = 0;
> > > +	int ret = 0;
> > > +	struct page_counter *counter;
> > >  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
> > >  
> > > -	idx = MEMFILE_IDX(of_cft(of)->private);
> > > -	name = MEMFILE_ATTR(of_cft(of)->private);
> > > +	counter = &h_cg->hugepage[MEMFILE_IDX(of_cft(of)->private)];
> > >  
> > > -	switch (name) {
> > > +	switch (MEMFILE_ATTR(of_cft(of)->private)) {
> > >  	case RES_MAX_USAGE:
> > > -		res_counter_reset_max(&h_cg->hugepage[idx]);
> > > +		counter->watermark = atomic_long_read(&counter->count);
> > 
> > page_counter_reset_watermark?
> 
> Yes, that operation deserves a wrapper.
> 
> > >  		break;
> > >  	case RES_FAILCNT:
> > > -		res_counter_reset_failcnt(&h_cg->hugepage[idx]);
> > > +		counter->limited = 0;
> > 
> > page_counter_reset_failcnt?
> 
> That would be more obscure than counter->failcnt = 0, I think.

There's one thing that bothers me about this patch. Before, all the
functions operating on res_counter were mutually smp-safe, now they
aren't. E.g. if the failcnt reset races with the falcnt increment from
page_counter_try_charge, the reset might be skipped. You only use the
atomic type for the counter, but my guess is that failcnt and watermark
should be atomic too, at least if we're not going to get rid of them
soon. Otherwise, it should be clearly stated that failcnt and watermark
are racy.

Anyway, that's where the usefulness of res_counter_reset_failcnt
reveals. If one decides to make it race-free one day, they won't have to
modify code outside the page_counter definition.

> > > @@ -66,6 +65,117 @@
> > >  
> > >  #include <trace/events/vmscan.h>
> > >  
> > > +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
> > > +{
> > > +	long new;
> > > +
> > > +	new = atomic_long_sub_return(nr_pages, &counter->count);
> > > +
> > > +	if (WARN_ON(unlikely(new < 0)))
> > 
> > Max value on 32 bit is ULONG_MAX, right? Then the WARN_ON is incorrect.
> 
> Since this is a page counter, this would overflow at 8 petabyte on 32
> bit.  So even though the maximum is ULONG_MAX, in practice we should
> never even reach LONG_MAX, and ULONG_MAX was only chosen for backward
> compatibility with the default unlimited value.
> 
> This is actually not the only place that assumes we never go negative;
> the userspace read functions' u64 cast of a long would sign-extend any
> negative value and return ludicrous numbers.
> 
> But thinking longer about this, it's probably not worth to have these
> gotchas in the code just to maintain the default unlimited value.  I
> changed PAGE_COUNTER_MAX to LONG_MAX and LONG_MAX / PAGE_SIZE, resp.

That sounds sane. We only have to maintain the user interface, not the
internal implementation.

> > > +		atomic_long_set(&counter->count, 0);
> > > +
> > > +	return new > 1;
> > 
> > Nobody outside page_counter internals uses this retval. Why is it public
> > then?
> 
> kmemcg still uses this for the pinning trick, but I'll update the
> patch that removes it to also change the interface.
> 
> > BTW, why not new > 0?
> 
> That's a plain bug - probably a left-over from rephrasing this
> underflow test several times.  Thanks for catching.
> 
> > > +int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
> > > +			struct page_counter **fail)
> > > +{
> > > +	struct page_counter *c;
> > > +
> > > +	for (c = counter; c; c = c->parent) {
> > > +		for (;;) {
> > > +			unsigned long count;
> > > +			unsigned long new;
> > > +
> > > +			count = atomic_long_read(&c->count);
> > > +
> > > +			new = count + nr_pages;
> > > +			if (new > c->limit) {
> > > +				c->limited++;
> > > +				if (fail) {
> > 
> > So we increase 'limited' even if ain't limited. Sounds weird.
> 
> The old code actually did that too, but I removed it now in the
> transition to separate charge and try_charge functions.
> 
> > > +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> > > +{
> > > +	for (;;) {
> > > +		unsigned long count;
> > > +		unsigned long old;
> > > +
> > > +		count = atomic_long_read(&counter->count);
> > > +
> > > +		old = xchg(&counter->limit, limit);
> > > +
> > > +		if (atomic_long_read(&counter->count) != count) {
> > > +			counter->limit = old;
> > 
> > I wonder what can happen if two threads execute this function
> > concurrently... or may be it's not supposed to be smp-safe?
> 
> memcg already holds the set_limit_mutex here.  I updated the tcp and
> hugetlb controllers accordingly to take limit locks as well.

I would prefer page_counter to handle it internally, because we won't
need the set_limit_mutex once memsw is converted to plain swap
accounting. Besides, memcg_update_kmem_limit doesn't take it. Any chance
to achieve that w/o spinlocks, using only atomic variables?

> > > @@ -1490,12 +1605,23 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
> > >   */
> > >  static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
> > >  {
> > > -	unsigned long long margin;
> > 
> > Why is it still ULL?
> 
> Hm?  This is a removal.  Too many longs...

Sorry, I missed the minus sign.

[...]
> Here is the delta patch:
[...]

If I were you, I'd separate the patch introducing the page_counter API
and implementation from the rest. I think it'd ease the review.

A couple of extra notes about the patch:

 - I think having comments to function definitions would be nice.

 - Your implementation of try_charge uses CAS, but this is a really
   costly operation (the most costly of all atomic primitives). Have
   you considered using FAA? Something like this:

   try_charge(pc, nr):

     limit = pc->limit;
     count = atomic_add_return(&pc->count, nr);
     if (count > limit) {
         atomic_sub(&pc->count, nr);
         return -ENOMEM;
     }
     return 0;

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
