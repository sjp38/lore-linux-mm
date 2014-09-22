Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3796B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 10:42:11 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id ft15so4479857pdb.23
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 07:42:11 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id go11si16110879pbd.9.2014.09.22.07.42.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 07:42:10 -0700 (PDT)
Date: Mon, 22 Sep 2014 18:41:58 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140922144158.GC20398@esperanza>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 19, 2014 at 09:22:08AM -0400, Johannes Weiner wrote:
> Memory is internally accounted in bytes, using spinlock-protected
> 64-bit counters, even though the smallest accounting delta is a page.
> The counter interface is also convoluted and does too many things.
> 
> Introduce a new lockless word-sized page counter API, then change all
> memory accounting over to it and remove the old one.  The translation
> from and to bytes then only happens when interfacing with userspace.
> 
> Aside from the locking costs, this gets rid of the icky unsigned long
> long types in the very heart of memcg, which is great for 32 bit and
> also makes the code a lot more readable.

Overall, I like this change. A few comments below.

> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  Documentation/cgroups/hugetlb.txt          |   2 +-
>  Documentation/cgroups/memory.txt           |   4 +-
>  Documentation/cgroups/resource_counter.txt | 197 --------
>  include/linux/hugetlb_cgroup.h             |   1 -
>  include/linux/memcontrol.h                 |  37 +-
>  include/linux/res_counter.h                | 223 ---------
>  include/net/sock.h                         |  25 +-
>  init/Kconfig                               |   9 +-
>  kernel/Makefile                            |   1 -
>  kernel/res_counter.c                       | 211 --------
>  mm/hugetlb_cgroup.c                        | 100 ++--
>  mm/memcontrol.c                            | 740 ++++++++++++++++-------------
>  net/ipv4/tcp_memcontrol.c                  |  83 ++--
>  13 files changed, 541 insertions(+), 1092 deletions(-)
>  delete mode 100644 Documentation/cgroups/resource_counter.txt
>  delete mode 100644 include/linux/res_counter.h
>  delete mode 100644 kernel/res_counter.c
> 
[...]
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 19df5d857411..bf8fb1a05597 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -54,6 +54,38 @@ struct mem_cgroup_reclaim_cookie {
>  };
>  
>  #ifdef CONFIG_MEMCG
> +
> +struct page_counter {

I'd place it in a separate file, say

	include/linux/page_counter.h
	mm/page_counter.c

just to keep mm/memcontrol.c clean.

> +	atomic_long_t count;
> +	unsigned long limit;
> +	struct page_counter *parent;
> +
> +	/* legacy */
> +	unsigned long watermark;
> +	unsigned long limited;

IMHO, failcnt would fit better.

> +};
> +
> +#if BITS_PER_LONG == 32
> +#define PAGE_COUNTER_MAX ULONG_MAX
> +#else
> +#define PAGE_COUNTER_MAX (ULONG_MAX / PAGE_SIZE)
> +#endif
> +
> +static inline void page_counter_init(struct page_counter *counter,
> +				     struct page_counter *parent)
> +{
> +	atomic_long_set(&counter->count, 0);
> +	counter->limit = PAGE_COUNTER_MAX;
> +	counter->parent = parent;
> +}
> +
> +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);

When I first saw this function, I couldn't realize by looking at its
name what it's intended to do. I think

	page_counter_cancel_local_charge()

would fit better.

> +int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
> +			struct page_counter **fail);
> +int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
> +int page_counter_limit(struct page_counter *counter, unsigned long limit);

Hmm, why not page_counter_set_limit?

> +int page_counter_memparse(const char *buf, unsigned long *nr_pages);
> +
[...]
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 515a4d01e932..f41749982668 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -55,7 +55,6 @@
>  #include <linux/slab.h>
>  #include <linux/uaccess.h>
>  #include <linux/memcontrol.h>
> -#include <linux/res_counter.h>
>  #include <linux/static_key.h>
>  #include <linux/aio.h>
>  #include <linux/sched.h>
> @@ -1066,7 +1065,7 @@ enum cg_proto_flags {
>  };
>  
>  struct cg_proto {
> -	struct res_counter	memory_allocated;	/* Current allocated memory. */
> +	struct page_counter	memory_allocated;	/* Current allocated memory. */
>  	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
>  	int			memory_pressure;
>  	long			sysctl_mem[3];
> @@ -1218,34 +1217,26 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
>  					      unsigned long amt,
>  					      int *parent_status)
>  {
> -	struct res_counter *fail;
> -	int ret;
> +	page_counter_charge(&prot->memory_allocated, amt, NULL);
>  
> -	ret = res_counter_charge_nofail(&prot->memory_allocated,
> -					amt << PAGE_SHIFT, &fail);
> -	if (ret < 0)
> +	if (atomic_long_read(&prot->memory_allocated.count) >
> +	    prot->memory_allocated.limit)

I don't like your equivalent of res_counter_charge_nofail.

Passing NULL to page_counter_charge might be useful if one doesn't have
a back-off strategy, but still want to fail on hitting the limit. With
your interface the user must pass something to the function then, which
isn't convenient.

Besides, it depends on the internal implementation of the page_counter
struct. I'd encapsulate this.

>  		*parent_status = OVER_LIMIT;
>  }
>  
>  static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
>  					      unsigned long amt)
>  {
> -	res_counter_uncharge(&prot->memory_allocated, amt << PAGE_SHIFT);
> -}
> -
> -static inline u64 memcg_memory_allocated_read(struct cg_proto *prot)
> -{
> -	u64 ret;
> -	ret = res_counter_read_u64(&prot->memory_allocated, RES_USAGE);
> -	return ret >> PAGE_SHIFT;
> +	page_counter_uncharge(&prot->memory_allocated, amt);
>  }
>  
>  static inline long
>  sk_memory_allocated(const struct sock *sk)
>  {
>  	struct proto *prot = sk->sk_prot;
> +
>  	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		return memcg_memory_allocated_read(sk->sk_cgrp);
> +		return atomic_long_read(&sk->sk_cgrp->memory_allocated.count);

page_counter_read?

>  
>  	return atomic_long_read(prot->memory_allocated);
>  }
> @@ -1259,7 +1250,7 @@ sk_memory_allocated_add(struct sock *sk, int amt, int *parent_status)
>  		memcg_memory_allocated_add(sk->sk_cgrp, amt, parent_status);
>  		/* update the root cgroup regardless */
>  		atomic_long_add_return(amt, prot->memory_allocated);
> -		return memcg_memory_allocated_read(sk->sk_cgrp);
> +		return atomic_long_read(&sk->sk_cgrp->memory_allocated.count);
>  	}
>  
>  	return atomic_long_add_return(amt, prot->memory_allocated);
> diff --git a/init/Kconfig b/init/Kconfig
> index 0471be99ec38..1cf42b563834 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -975,15 +975,8 @@ config CGROUP_CPUACCT
>  	  Provides a simple Resource Controller for monitoring the
>  	  total CPU consumed by the tasks in a cgroup.
>  
> -config RESOURCE_COUNTERS
> -	bool "Resource counters"
> -	help
> -	  This option enables controller independent resource accounting
> -	  infrastructure that works with cgroups.
> -
>  config MEMCG
>  	bool "Memory Resource Controller for Control Groups"
> -	depends on RESOURCE_COUNTERS
>  	select EVENTFD
>  	help
>  	  Provides a memory resource controller that manages both anonymous
> @@ -1051,7 +1044,7 @@ config MEMCG_KMEM
>  
>  config CGROUP_HUGETLB
>  	bool "HugeTLB Resource Controller for Control Groups"
> -	depends on RESOURCE_COUNTERS && HUGETLB_PAGE
> +	depends on MEMCG && HUGETLB_PAGE

So now the hugetlb controller depends on memcg only because it needs the
page_counter, which is supposed to be a kind of independent. Is that OK?

>  	default n
>  	help
>  	  Provides a cgroup Resource Controller for HugeTLB pages.
[...]
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index a67c26e0f360..e619b6b62f1f 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
[...]
> @@ -213,7 +212,6 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
>  				  struct page *page)
>  {
>  	struct hugetlb_cgroup *h_cg;
> -	unsigned long csize = nr_pages * PAGE_SIZE;
>  
>  	if (hugetlb_cgroup_disabled())
>  		return;
> @@ -222,61 +220,73 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
>  	if (unlikely(!h_cg))
>  		return;
>  	set_hugetlb_cgroup(page, NULL);
> -	res_counter_uncharge(&h_cg->hugepage[idx], csize);
> +	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
>  	return;
>  }
>  
>  void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
>  				    struct hugetlb_cgroup *h_cg)
>  {
> -	unsigned long csize = nr_pages * PAGE_SIZE;
> -
>  	if (hugetlb_cgroup_disabled() || !h_cg)
>  		return;
>  
>  	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
>  		return;
>  
> -	res_counter_uncharge(&h_cg->hugepage[idx], csize);
> +	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
>  	return;
>  }
>  
> +enum {
> +	RES_USAGE,
> +	RES_LIMIT,
> +	RES_MAX_USAGE,
> +	RES_FAILCNT,
> +};
> +
>  static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
>  				   struct cftype *cft)
>  {
> -	int idx, name;
> +	struct page_counter *counter;
>  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
>  
> -	idx = MEMFILE_IDX(cft->private);
> -	name = MEMFILE_ATTR(cft->private);
> +	counter = &h_cg->hugepage[MEMFILE_IDX(cft->private)];
>  
> -	return res_counter_read_u64(&h_cg->hugepage[idx], name);
> +	switch (MEMFILE_ATTR(cft->private)) {
> +	case RES_USAGE:
> +		return (u64)atomic_long_read(&counter->count) * PAGE_SIZE;

page_counter_read?

> +	case RES_LIMIT:
> +		return (u64)counter->limit * PAGE_SIZE;

page_counter_get_limit?

> +	case RES_MAX_USAGE:
> +		return (u64)counter->watermark * PAGE_SIZE;

page_counter_read_watermark?

> +	case RES_FAILCNT:
> +		return counter->limited;
> +	default:
> +		BUG();
> +	}
>  }
>  
>  static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
>  				    char *buf, size_t nbytes, loff_t off)
>  {
> -	int idx, name, ret;
> -	unsigned long long val;
> +	int ret, idx;
> +	unsigned long nr_pages;
>  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
>  
> +	if (hugetlb_cgroup_is_root(h_cg)) /* Can't set limit on root */
> +		return -EINVAL;
> +
>  	buf = strstrip(buf);
> +	ret = page_counter_memparse(buf, &nr_pages);
> +	if (ret)
> +		return ret;
> +
>  	idx = MEMFILE_IDX(of_cft(of)->private);
> -	name = MEMFILE_ATTR(of_cft(of)->private);
>  
> -	switch (name) {
> +	switch (MEMFILE_ATTR(of_cft(of)->private)) {
>  	case RES_LIMIT:
> -		if (hugetlb_cgroup_is_root(h_cg)) {
> -			/* Can't set limit on root */
> -			ret = -EINVAL;
> -			break;
> -		}
> -		/* This function does all necessary parse...reuse it */
> -		ret = res_counter_memparse_write_strategy(buf, &val);
> -		if (ret)
> -			break;
> -		val = ALIGN(val, 1ULL << huge_page_shift(&hstates[idx]));
> -		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
> +		nr_pages = ALIGN(nr_pages, huge_page_shift(&hstates[idx]));

This is incorrect. Here we should have something like:

	nr_pages = ALIGN(nr_pages, 1UL << huge_page_order(&hstates[idx]));

> +		ret = page_counter_limit(&h_cg->hugepage[idx], nr_pages);
>  		break;
>  	default:
>  		ret = -EINVAL;
> @@ -288,18 +298,18 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
>  static ssize_t hugetlb_cgroup_reset(struct kernfs_open_file *of,
>  				    char *buf, size_t nbytes, loff_t off)
>  {
> -	int idx, name, ret = 0;
> +	int ret = 0;
> +	struct page_counter *counter;
>  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
>  
> -	idx = MEMFILE_IDX(of_cft(of)->private);
> -	name = MEMFILE_ATTR(of_cft(of)->private);
> +	counter = &h_cg->hugepage[MEMFILE_IDX(of_cft(of)->private)];
>  
> -	switch (name) {
> +	switch (MEMFILE_ATTR(of_cft(of)->private)) {
>  	case RES_MAX_USAGE:
> -		res_counter_reset_max(&h_cg->hugepage[idx]);
> +		counter->watermark = atomic_long_read(&counter->count);

page_counter_reset_watermark?

>  		break;
>  	case RES_FAILCNT:
> -		res_counter_reset_failcnt(&h_cg->hugepage[idx]);
> +		counter->limited = 0;

page_counter_reset_failcnt?

>  		break;
>  	default:
>  		ret = -EINVAL;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2def11f1ec1..dfd3b15a57e8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -25,7 +25,6 @@
>   * GNU General Public License for more details.
>   */
>  
> -#include <linux/res_counter.h>
>  #include <linux/memcontrol.h>
>  #include <linux/cgroup.h>
>  #include <linux/mm.h>
> @@ -66,6 +65,117 @@
>  
>  #include <trace/events/vmscan.h>
>  
> +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
> +{
> +	long new;
> +
> +	new = atomic_long_sub_return(nr_pages, &counter->count);
> +
> +	if (WARN_ON(unlikely(new < 0)))

Max value on 32 bit is ULONG_MAX, right? Then the WARN_ON is incorrect.

> +		atomic_long_set(&counter->count, 0);
> +
> +	return new > 1;

Nobody outside page_counter internals uses this retval. Why is it public
then?

BTW, why not new > 0?

> +}
> +
> +int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
> +			struct page_counter **fail)
> +{
> +	struct page_counter *c;
> +
> +	for (c = counter; c; c = c->parent) {
> +		for (;;) {
> +			unsigned long count;
> +			unsigned long new;
> +
> +			count = atomic_long_read(&c->count);
> +
> +			new = count + nr_pages;
> +			if (new > c->limit) {
> +				c->limited++;
> +				if (fail) {

So we increase 'limited' even if ain't limited. Sounds weird.

> +					*fail = c;
> +					goto failed;
> +				}
> +			}
> +
> +			if (atomic_long_cmpxchg(&c->count, count, new) != count)
> +				continue;
> +
> +			if (new > c->watermark)
> +				c->watermark = new;
> +
> +			break;
> +		}
> +	}
> +	return 0;
> +
> +failed:
> +	for (c = counter; c != *fail; c = c->parent)
> +		page_counter_cancel(c, nr_pages);
> +
> +	return -ENOMEM;
> +}
> +
> +int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages)
> +{
> +	struct page_counter *c;
> +	int ret = 1;
> +
> +	for (c = counter; c; c = c->parent) {
> +		int remainder;
> +
> +		remainder = page_counter_cancel(c, nr_pages);
> +		if (c == counter && !remainder)
> +			ret = 0;
> +	}
> +
> +	return ret;

The only user of this retval is memcg_uncharge_kmem, which is going to
be removed by your "mm: memcontrol: remove obsolete kmemcg pinning
tricks" patch. Is it still worth having?

> +}
> +
> +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> +{
> +	for (;;) {
> +		unsigned long count;
> +		unsigned long old;
> +
> +		count = atomic_long_read(&counter->count);
> +
> +		old = xchg(&counter->limit, limit);
> +
> +		if (atomic_long_read(&counter->count) != count) {
> +			counter->limit = old;

I wonder what can happen if two threads execute this function
concurrently... or may be it's not supposed to be smp-safe?

> +			continue;
> +		}
> +
> +		if (count > limit) {
> +			counter->limit = old;
> +			return -EBUSY;
> +		}
> +
> +		return 0;
> +	}
> +}
[...]
> @@ -1490,12 +1605,23 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
>   */
>  static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
>  {
> -	unsigned long long margin;

Why is it still ULL?

> +	unsigned long margin = 0;
> +	unsigned long count;
> +	unsigned long limit;
>  
> -	margin = res_counter_margin(&memcg->res);
> -	if (do_swap_account)
> -		margin = min(margin, res_counter_margin(&memcg->memsw));
> -	return margin >> PAGE_SHIFT;
> +	count = atomic_long_read(&memcg->memory.count);
> +	limit = ACCESS_ONCE(memcg->memory.limit);
> +	if (count < limit)
> +		margin = limit - count;
> +
> +	if (do_swap_account) {
> +		count = atomic_long_read(&memcg->memsw.count);
> +		limit = ACCESS_ONCE(memcg->memsw.limit);
> +		if (count < limit)
> +			margin = min(margin, limit - count);
> +	}
> +
> +	return margin;
>  }
[...]
> @@ -4155,13 +4255,13 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>  	 * after this point, because it has at least one child already.
>  	 */
>  	if (memcg_kmem_is_active(parent))
> -		ret = __memcg_activate_kmem(memcg, RES_COUNTER_MAX);
> +		ret = __memcg_activate_kmem(memcg, ULONG_MAX);

PAGE_COUNTER_MAX?

>  	mutex_unlock(&activate_kmem_mutex);
>  	return ret;
>  }
>  #else
>  static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
> -				   unsigned long long val)
> +				   unsigned long limit)
>  {
>  	return -EINVAL;
>  }
[...]
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index 1d191357bf88..9a448bdb19e9 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
[...]
> @@ -60,20 +60,17 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
>  	if (!cg_proto)
>  		return -EINVAL;
>  
> -	if (val > RES_COUNTER_MAX)
> -		val = RES_COUNTER_MAX;
> -
> -	ret = res_counter_set_limit(&cg_proto->memory_allocated, val);
> +	ret = page_counter_limit(&cg_proto->memory_allocated, nr_pages);
>  	if (ret)
>  		return ret;
>  
>  	for (i = 0; i < 3; i++)
> -		cg_proto->sysctl_mem[i] = min_t(long, val >> PAGE_SHIFT,
> +		cg_proto->sysctl_mem[i] = min_t(long, nr_pages,
>  						sysctl_tcp_mem[i]);
>  
> -	if (val == RES_COUNTER_MAX)
> +	if (nr_pages == ULONG_MAX / PAGE_SIZE)

PAGE_COUNTER_MAX?

>  		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
> -	else if (val != RES_COUNTER_MAX) {
> +	else {
>  		/*
>  		 * The active bit needs to be written after the static_key
>  		 * update. This is what guarantees that the socket activation
[...]
> @@ -126,43 +130,35 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
>  	return ret ?: nbytes;
>  }
>  
> -static u64 tcp_read_stat(struct mem_cgroup *memcg, int type, u64 default_val)
> -{
> -	struct cg_proto *cg_proto;
> -
> -	cg_proto = tcp_prot.proto_cgroup(memcg);
> -	if (!cg_proto)
> -		return default_val;
> -
> -	return res_counter_read_u64(&cg_proto->memory_allocated, type);
> -}
> -
> -static u64 tcp_read_usage(struct mem_cgroup *memcg)
> -{
> -	struct cg_proto *cg_proto;
> -
> -	cg_proto = tcp_prot.proto_cgroup(memcg);
> -	if (!cg_proto)
> -		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
> -
> -	return res_counter_read_u64(&cg_proto->memory_allocated, RES_USAGE);
> -}
> -
>  static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	struct cg_proto *cg_proto = tcp_prot.proto_cgroup(memcg);
>  	u64 val;
>  
>  	switch (cft->private) {
>  	case RES_LIMIT:
> -		val = tcp_read_stat(memcg, RES_LIMIT, RES_COUNTER_MAX);
> +		if (!cg_proto)
> +			return PAGE_COUNTER_MAX;
> +		val = cg_proto->memory_allocated.limit;
> +		val *= PAGE_SIZE;
>  		break;
>  	case RES_USAGE:
> -		val = tcp_read_usage(memcg);
> +		if (!cg_proto)
> +			return atomic_long_read(&tcp_memory_allocated);

Forgot << PAGE_SHIFT?

> +		val = atomic_long_read(&cg_proto->memory_allocated.count);
> +		val *= PAGE_SIZE;
>  		break;
>  	case RES_FAILCNT:
> +		if (!cg_proto)
> +			return 0;
> +		val = cg_proto->memory_allocated.limited;
> +		break;
>  	case RES_MAX_USAGE:
> -		val = tcp_read_stat(memcg, cft->private, 0);
> +		if (!cg_proto)
> +			return 0;
> +		val = cg_proto->memory_allocated.watermark;
> +		val *= PAGE_SIZE;
>  		break;
>  	default:
>  		BUG();

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
