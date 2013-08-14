Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 1F02F6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 16:44:33 -0400 (EDT)
Date: Wed, 14 Aug 2013 13:44:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8] mm: make lru_add_drain_all() selective
Message-Id: <20130814134430.50cb8d609643620b00ab3705@linux-foundation.org>
In-Reply-To: <201308142029.r7EKTMRw023404@farm-0002.internal.tilera.com>
References: <20130814200748.GI28628@htj.dyndns.org>
	<201308142029.r7EKTMRw023404@farm-0002.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Wed, 14 Aug 2013 16:22:18 -0400 Chris Metcalf <cmetcalf@tilera.com> wrote:

> This change makes lru_add_drain_all() only selectively interrupt
> the cpus that have per-cpu free pages that can be drained.
> 
> This is important in nohz mode where calling mlockall(), for
> example, otherwise will interrupt every core unnecessarily.
> 

I think the patch will work, but it's a bit sad to no longer gain the
general ability to do schedule_on_some_cpus().  Oh well.

> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -247,7 +247,7 @@ extern void activate_page(struct page *);
>  extern void mark_page_accessed(struct page *);
>  extern void lru_add_drain(void);
>  extern void lru_add_drain_cpu(int cpu);
> -extern int lru_add_drain_all(void);
> +extern void lru_add_drain_all(void);
>  extern void rotate_reclaimable_page(struct page *page);
>  extern void deactivate_page(struct page *page);
>  extern void swap_setup(void);
> diff --git a/mm/swap.c b/mm/swap.c
> index 4a1d0d2..8d19543 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -405,6 +405,11 @@ static void activate_page_drain(int cpu)
>  		pagevec_lru_move_fn(pvec, __activate_page, NULL);
>  }
>  
> +static bool need_activate_page_drain(int cpu)
> +{
> +	return pagevec_count(&per_cpu(activate_page_pvecs, cpu)) != 0;
> +}

static int need_activate_page_drain(int cpu)
{
	return pagevec_count(&per_cpu(activate_page_pvecs, cpu));
}

would be shorter and faster.  bool rather sucks that way.  It's a
performance-vs-niceness thing.  I guess one has to look at the call
frequency when deciding.

>  void activate_page(struct page *page)
>  {
>  	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> @@ -422,6 +427,11 @@ static inline void activate_page_drain(int cpu)
>  {
>  }
>  
> +static bool need_activate_page_drain(int cpu)
> +{
> +	return false;
> +}
> +
>  void activate_page(struct page *page)
>  {
>  	struct zone *zone = page_zone(page);
> @@ -678,12 +688,36 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
>  	lru_add_drain();
>  }
>  
> -/*
> - * Returns 0 for success
> - */
> -int lru_add_drain_all(void)
> +static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
> +
> +void lru_add_drain_all(void)
>  {
> -	return schedule_on_each_cpu(lru_add_drain_per_cpu);
> +	static DEFINE_MUTEX(lock);
> +	static struct cpumask has_work;
> +	int cpu;
> +
> +	mutex_lock(&lock);

This is a bit scary but I expect it will be OK - later threads will
just twiddle thumbs while some other thread does all or most of their
work for them.

> +	get_online_cpus();
> +	cpumask_clear(&has_work);
> +
> +	for_each_online_cpu(cpu) {
> +		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
> +
> +		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
> +		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
> +		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
> +		    need_activate_page_drain(cpu)) {
> +			INIT_WORK(work, lru_add_drain_per_cpu);

This initialization is only needed once per boot but I don't see a
convenient way of doing this.

> +			schedule_work_on(cpu, work);
> +			cpumask_set_cpu(cpu, &has_work);
> +		}
> +	}
> +
> +	for_each_cpu(cpu, &has_work)

for_each_online_cpu()?

> +		flush_work(&per_cpu(lru_add_drain_work, cpu));
> +
> +	put_online_cpus();
> +	mutex_unlock(&lock);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
