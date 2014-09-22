Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 994946B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 14:57:43 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id x48so1991701wes.15
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 11:57:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hg13si9242009wib.37.2014.09.22.11.57.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 11:57:42 -0700 (PDT)
Date: Mon, 22 Sep 2014 14:57:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140922185736.GB6630@cmpxchg.org>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144158.GC20398@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140922144158.GC20398@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Vladimir,

On Mon, Sep 22, 2014 at 06:41:58PM +0400, Vladimir Davydov wrote:
> On Fri, Sep 19, 2014 at 09:22:08AM -0400, Johannes Weiner wrote:
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 19df5d857411..bf8fb1a05597 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -54,6 +54,38 @@ struct mem_cgroup_reclaim_cookie {
> >  };
> >  
> >  #ifdef CONFIG_MEMCG
> > +
> > +struct page_counter {
> 
> I'd place it in a separate file, say
> 
> 	include/linux/page_counter.h
> 	mm/page_counter.c
> 
> just to keep mm/memcontrol.c clean.

The page counters are the very core of the memory controller and, as I
said to Michal, I want to integrate the hugetlb controller into memcg
as well, at which point there won't be any outside users anymore.  So
I think this is the right place for it.

> > +	atomic_long_t count;
> > +	unsigned long limit;
> > +	struct page_counter *parent;
> > +
> > +	/* legacy */
> > +	unsigned long watermark;
> > +	unsigned long limited;
> 
> IMHO, failcnt would fit better.

I never liked the failcnt name, but also have to admit that "limited"
is crap.  Let's leave it at failcnt for now.

> > +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
> 
> When I first saw this function, I couldn't realize by looking at its
> name what it's intended to do. I think
> 
> 	page_counter_cancel_local_charge()
> 
> would fit better.

It's a fairly unwieldy name.  How about page_counter_sub()?  local_sub()?

> > +int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
> > +			struct page_counter **fail);
> > +int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
> > +int page_counter_limit(struct page_counter *counter, unsigned long limit);
> 
> Hmm, why not page_counter_set_limit?

Limit is used as a verb here, "to limit".  Getters and setters are
usually wrappers around unusual/complex data structure access, but
this function does a lot more, so I'm not fond of _set_limit().

> > @@ -1218,34 +1217,26 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
> >  					      unsigned long amt,
> >  					      int *parent_status)
> >  {
> > -	struct res_counter *fail;
> > -	int ret;
> > +	page_counter_charge(&prot->memory_allocated, amt, NULL);
> >  
> > -	ret = res_counter_charge_nofail(&prot->memory_allocated,
> > -					amt << PAGE_SHIFT, &fail);
> > -	if (ret < 0)
> > +	if (atomic_long_read(&prot->memory_allocated.count) >
> > +	    prot->memory_allocated.limit)
> 
> I don't like your equivalent of res_counter_charge_nofail.
> 
> Passing NULL to page_counter_charge might be useful if one doesn't have
> a back-off strategy, but still want to fail on hitting the limit. With
> your interface the user must pass something to the function then, which
> isn't convenient.
> 
> Besides, it depends on the internal implementation of the page_counter
> struct. I'd encapsulate this.

Thinking about this more, I don't like my version either; not because
of how @fail must always be passed, but because of how it changes the
behavior.  I changed the API to

void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
int page_counter_try_charge(struct page_counter *counter, unsigned long nr_pages,
                            struct page_counter **fail);

We could make @fail optional in the try_charge(), but all callsites
pass it at this time, so for now I kept it mandatory for simplicity.

What do you think?

> > @@ -975,15 +975,8 @@ config CGROUP_CPUACCT
> >  	  Provides a simple Resource Controller for monitoring the
> >  	  total CPU consumed by the tasks in a cgroup.
> >  
> > -config RESOURCE_COUNTERS
> > -	bool "Resource counters"
> > -	help
> > -	  This option enables controller independent resource accounting
> > -	  infrastructure that works with cgroups.
> > -
> >  config MEMCG
> >  	bool "Memory Resource Controller for Control Groups"
> > -	depends on RESOURCE_COUNTERS
> >  	select EVENTFD
> >  	help
> >  	  Provides a memory resource controller that manages both anonymous
> > @@ -1051,7 +1044,7 @@ config MEMCG_KMEM
> >  
> >  config CGROUP_HUGETLB
> >  	bool "HugeTLB Resource Controller for Control Groups"
> > -	depends on RESOURCE_COUNTERS && HUGETLB_PAGE
> > +	depends on MEMCG && HUGETLB_PAGE
> 
> So now the hugetlb controller depends on memcg only because it needs the
> page_counter, which is supposed to be a kind of independent. Is that OK?

As mentioned before, I want to integrate the hugetlb controller into
memcg anyway, so this should be fine, and it keeps things simpler.

> > @@ -222,61 +220,73 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
> >  	if (unlikely(!h_cg))
> >  		return;
> >  	set_hugetlb_cgroup(page, NULL);
> > -	res_counter_uncharge(&h_cg->hugepage[idx], csize);
> > +	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
> >  	return;
> >  }
> >  
> >  void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
> >  				    struct hugetlb_cgroup *h_cg)
> >  {
> > -	unsigned long csize = nr_pages * PAGE_SIZE;
> > -
> >  	if (hugetlb_cgroup_disabled() || !h_cg)
> >  		return;
> >  
> >  	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
> >  		return;
> >  
> > -	res_counter_uncharge(&h_cg->hugepage[idx], csize);
> > +	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
> >  	return;
> >  }
> >  
> > +enum {
> > +	RES_USAGE,
> > +	RES_LIMIT,
> > +	RES_MAX_USAGE,
> > +	RES_FAILCNT,
> > +};
> > +
> >  static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
> >  				   struct cftype *cft)
> >  {
> > -	int idx, name;
> > +	struct page_counter *counter;
> >  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
> >  
> > -	idx = MEMFILE_IDX(cft->private);
> > -	name = MEMFILE_ATTR(cft->private);
> > +	counter = &h_cg->hugepage[MEMFILE_IDX(cft->private)];
> >  
> > -	return res_counter_read_u64(&h_cg->hugepage[idx], name);
> > +	switch (MEMFILE_ATTR(cft->private)) {
> > +	case RES_USAGE:
> > +		return (u64)atomic_long_read(&counter->count) * PAGE_SIZE;
> 
> page_counter_read?
> 
> > +	case RES_LIMIT:
> > +		return (u64)counter->limit * PAGE_SIZE;
> 
> page_counter_get_limit?
> 
> > +	case RES_MAX_USAGE:
> > +		return (u64)counter->watermark * PAGE_SIZE;
> 
> page_counter_read_watermark?

I added page_counter_read() to abstract away the fact that we use a
signed counter internally, but it still returns the number of pages as
unsigned long.

The entire counter API is based on pages now, and only the userspace
interface translates back and forth into bytes, so that's where the
translation should be located.

> >  static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
> >  				    char *buf, size_t nbytes, loff_t off)
> >  {
> > -	int idx, name, ret;
> > -	unsigned long long val;
> > +	int ret, idx;
> > +	unsigned long nr_pages;
> >  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
> >  
> > +	if (hugetlb_cgroup_is_root(h_cg)) /* Can't set limit on root */
> > +		return -EINVAL;
> > +
> >  	buf = strstrip(buf);
> > +	ret = page_counter_memparse(buf, &nr_pages);
> > +	if (ret)
> > +		return ret;
> > +
> >  	idx = MEMFILE_IDX(of_cft(of)->private);
> > -	name = MEMFILE_ATTR(of_cft(of)->private);
> >  
> > -	switch (name) {
> > +	switch (MEMFILE_ATTR(of_cft(of)->private)) {
> >  	case RES_LIMIT:
> > -		if (hugetlb_cgroup_is_root(h_cg)) {
> > -			/* Can't set limit on root */
> > -			ret = -EINVAL;
> > -			break;
> > -		}
> > -		/* This function does all necessary parse...reuse it */
> > -		ret = res_counter_memparse_write_strategy(buf, &val);
> > -		if (ret)
> > -			break;
> > -		val = ALIGN(val, 1ULL << huge_page_shift(&hstates[idx]));
> > -		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
> > +		nr_pages = ALIGN(nr_pages, huge_page_shift(&hstates[idx]));
> 
> This is incorrect. Here we should have something like:
>
> 	nr_pages = ALIGN(nr_pages, 1UL << huge_page_order(&hstates[idx]));

Good catch, thanks.

> > @@ -288,18 +298,18 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
> >  static ssize_t hugetlb_cgroup_reset(struct kernfs_open_file *of,
> >  				    char *buf, size_t nbytes, loff_t off)
> >  {
> > -	int idx, name, ret = 0;
> > +	int ret = 0;
> > +	struct page_counter *counter;
> >  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
> >  
> > -	idx = MEMFILE_IDX(of_cft(of)->private);
> > -	name = MEMFILE_ATTR(of_cft(of)->private);
> > +	counter = &h_cg->hugepage[MEMFILE_IDX(of_cft(of)->private)];
> >  
> > -	switch (name) {
> > +	switch (MEMFILE_ATTR(of_cft(of)->private)) {
> >  	case RES_MAX_USAGE:
> > -		res_counter_reset_max(&h_cg->hugepage[idx]);
> > +		counter->watermark = atomic_long_read(&counter->count);
> 
> page_counter_reset_watermark?

Yes, that operation deserves a wrapper.

> >  		break;
> >  	case RES_FAILCNT:
> > -		res_counter_reset_failcnt(&h_cg->hugepage[idx]);
> > +		counter->limited = 0;
> 
> page_counter_reset_failcnt?

That would be more obscure than counter->failcnt = 0, I think.

> > @@ -66,6 +65,117 @@
> >  
> >  #include <trace/events/vmscan.h>
> >  
> > +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
> > +{
> > +	long new;
> > +
> > +	new = atomic_long_sub_return(nr_pages, &counter->count);
> > +
> > +	if (WARN_ON(unlikely(new < 0)))
> 
> Max value on 32 bit is ULONG_MAX, right? Then the WARN_ON is incorrect.

Since this is a page counter, this would overflow at 8 petabyte on 32
bit.  So even though the maximum is ULONG_MAX, in practice we should
never even reach LONG_MAX, and ULONG_MAX was only chosen for backward
compatibility with the default unlimited value.

This is actually not the only place that assumes we never go negative;
the userspace read functions' u64 cast of a long would sign-extend any
negative value and return ludicrous numbers.

But thinking longer about this, it's probably not worth to have these
gotchas in the code just to maintain the default unlimited value.  I
changed PAGE_COUNTER_MAX to LONG_MAX and LONG_MAX / PAGE_SIZE, resp.

> > +		atomic_long_set(&counter->count, 0);
> > +
> > +	return new > 1;
> 
> Nobody outside page_counter internals uses this retval. Why is it public
> then?

kmemcg still uses this for the pinning trick, but I'll update the
patch that removes it to also change the interface.

> BTW, why not new > 0?

That's a plain bug - probably a left-over from rephrasing this
underflow test several times.  Thanks for catching.

> > +int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
> > +			struct page_counter **fail)
> > +{
> > +	struct page_counter *c;
> > +
> > +	for (c = counter; c; c = c->parent) {
> > +		for (;;) {
> > +			unsigned long count;
> > +			unsigned long new;
> > +
> > +			count = atomic_long_read(&c->count);
> > +
> > +			new = count + nr_pages;
> > +			if (new > c->limit) {
> > +				c->limited++;
> > +				if (fail) {
> 
> So we increase 'limited' even if ain't limited. Sounds weird.

The old code actually did that too, but I removed it now in the
transition to separate charge and try_charge functions.

> > +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> > +{
> > +	for (;;) {
> > +		unsigned long count;
> > +		unsigned long old;
> > +
> > +		count = atomic_long_read(&counter->count);
> > +
> > +		old = xchg(&counter->limit, limit);
> > +
> > +		if (atomic_long_read(&counter->count) != count) {
> > +			counter->limit = old;
> 
> I wonder what can happen if two threads execute this function
> concurrently... or may be it's not supposed to be smp-safe?

memcg already holds the set_limit_mutex here.  I updated the tcp and
hugetlb controllers accordingly to take limit locks as well.

> > @@ -1490,12 +1605,23 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
> >   */
> >  static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
> >  {
> > -	unsigned long long margin;
> 
> Why is it still ULL?

Hm?  This is a removal.  Too many longs...

> > @@ -4155,13 +4255,13 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
> >  	 * after this point, because it has at least one child already.
> >  	 */
> >  	if (memcg_kmem_is_active(parent))
> > -		ret = __memcg_activate_kmem(memcg, RES_COUNTER_MAX);
> > +		ret = __memcg_activate_kmem(memcg, ULONG_MAX);
> 
> PAGE_COUNTER_MAX?

Good catch, thanks.  That was a left-over from several iterations of
trying to find a value that's suitable for both 32 bit and 64 bit.

> > @@ -60,20 +60,17 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
> >  	if (!cg_proto)
> >  		return -EINVAL;
> >  
> > -	if (val > RES_COUNTER_MAX)
> > -		val = RES_COUNTER_MAX;
> > -
> > -	ret = res_counter_set_limit(&cg_proto->memory_allocated, val);
> > +	ret = page_counter_limit(&cg_proto->memory_allocated, nr_pages);
> >  	if (ret)
> >  		return ret;
> >  
> >  	for (i = 0; i < 3; i++)
> > -		cg_proto->sysctl_mem[i] = min_t(long, val >> PAGE_SHIFT,
> > +		cg_proto->sysctl_mem[i] = min_t(long, nr_pages,
> >  						sysctl_tcp_mem[i]);
> >  
> > -	if (val == RES_COUNTER_MAX)
> > +	if (nr_pages == ULONG_MAX / PAGE_SIZE)
> 
> PAGE_COUNTER_MAX?

Same.

> > @@ -126,43 +130,35 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
> >  	return ret ?: nbytes;
> >  }
> >  
> > -static u64 tcp_read_stat(struct mem_cgroup *memcg, int type, u64 default_val)
> > -{
> > -	struct cg_proto *cg_proto;
> > -
> > -	cg_proto = tcp_prot.proto_cgroup(memcg);
> > -	if (!cg_proto)
> > -		return default_val;
> > -
> > -	return res_counter_read_u64(&cg_proto->memory_allocated, type);
> > -}
> > -
> > -static u64 tcp_read_usage(struct mem_cgroup *memcg)
> > -{
> > -	struct cg_proto *cg_proto;
> > -
> > -	cg_proto = tcp_prot.proto_cgroup(memcg);
> > -	if (!cg_proto)
> > -		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
> > -
> > -	return res_counter_read_u64(&cg_proto->memory_allocated, RES_USAGE);
> > -}
> > -
> >  static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
> >  {
> >  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> > +	struct cg_proto *cg_proto = tcp_prot.proto_cgroup(memcg);
> >  	u64 val;
> >  
> >  	switch (cft->private) {
> >  	case RES_LIMIT:
> > -		val = tcp_read_stat(memcg, RES_LIMIT, RES_COUNTER_MAX);
> > +		if (!cg_proto)
> > +			return PAGE_COUNTER_MAX;
> > +		val = cg_proto->memory_allocated.limit;
> > +		val *= PAGE_SIZE;
> >  		break;
> >  	case RES_USAGE:
> > -		val = tcp_read_usage(memcg);
> > +		if (!cg_proto)
> > +			return atomic_long_read(&tcp_memory_allocated);
> 
> Forgot << PAGE_SHIFT?

Yes, indeed.

Thanks for your thorough review, Vladimir!

Here is the delta patch:

---
