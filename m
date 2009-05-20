Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2003B6B0055
	for <linux-mm@kvack.org>; Wed, 20 May 2009 05:17:48 -0400 (EDT)
Date: Wed, 20 May 2009 11:17:58 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH 3/7] percpu: clean up percpu variable definitions
Message-ID: <20090520091758.GO11363@kernel.dk>
References: <1242805059-18338-1-git-send-email-tj@kernel.org> <1242805059-18338-4-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1242805059-18338-4-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org, x86@kernel.org, ink@jurassic.park.msu.ru, rth@twiddle.net, linux@arm.linux.org.uk, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, jesper.nilsson@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, tony.luck@intel.com, takata@linux-m32r.org, geert@linux-m68k.org, monstr@monstr.eu, ralf@linux-mips.org, kyle@mcmartin.ca, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, jdike@addtoit.com, chris@zankel.net, rusty@rustcorp.com.au, Dave Jones <davej@redhat.com>, Jeremy Fitzhardinge <jeremy@xensource.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 20 2009, Tejun Heo wrote:
> Percpu variable definition is about to be updated such that
> 
> * percpu symbols must be unique even the static ones
> 
> * in-function static definition is not allowed
> 
> Update percpu variable definitions accoringly.
> 
> * as,cfq: rename ioc_count uniquely
> 
> * cpufreq: rename cpu_dbs_info uniquely
> 
> * xen: move nesting_count out of xen_evtchn_do_upcall() and rename it
> 
> * mm: move ratelimits out of balance_dirty_pages_ratelimited_nr() and
>   rename it
> 
> * ipv4,6: rename cookie_scratch uniquely
> 
> While at it, make cris:use DECLARE_PER_CPU() instead of extern
> volatile DEFINE_PER_CPU() for declaration.
> 
> [ Impact: percpu usage cleanups, no duplicate static percpu var names ]

The block bits looks fine.

Acked-by: Jens Axboe <jens.axboe@oracle.com>

> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
> Cc: Jens Axboe <jens.axboe@oracle.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: Jeremy Fitzhardinge <jeremy@xensource.com>
> Cc: linux-mm <linux-mm@kvack.org>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  arch/cris/include/asm/mmu_context.h    |    2 +-
>  block/as-iosched.c                     |   10 +++++-----
>  block/cfq-iosched.c                    |   10 +++++-----
>  drivers/cpufreq/cpufreq_conservative.c |   12 ++++++------
>  drivers/cpufreq/cpufreq_ondemand.c     |   15 ++++++++-------
>  drivers/xen/events.c                   |    9 +++++----
>  mm/page-writeback.c                    |    5 +++--
>  net/ipv4/syncookies.c                  |    4 ++--
>  net/ipv6/syncookies.c                  |    4 ++--
>  9 files changed, 37 insertions(+), 34 deletions(-)
> 
> diff --git a/arch/cris/include/asm/mmu_context.h b/arch/cris/include/asm/mmu_context.h
> index 72ba08d..00de1a0 100644
> --- a/arch/cris/include/asm/mmu_context.h
> +++ b/arch/cris/include/asm/mmu_context.h
> @@ -17,7 +17,7 @@ extern void switch_mm(struct mm_struct *prev, struct mm_struct *next,
>   * registers like cr3 on the i386
>   */
>  
> -extern volatile DEFINE_PER_CPU(pgd_t *,current_pgd); /* defined in arch/cris/mm/fault.c */
> +DECLARE_PER_CPU(pgd_t *,current_pgd); /* defined in arch/cris/mm/fault.c */
>  
>  static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
>  {
> diff --git a/block/as-iosched.c b/block/as-iosched.c
> index c48fa67..96ff4d1 100644
> --- a/block/as-iosched.c
> +++ b/block/as-iosched.c
> @@ -146,7 +146,7 @@ enum arq_state {
>  #define RQ_STATE(rq)	((enum arq_state)(rq)->elevator_private2)
>  #define RQ_SET_STATE(rq, state)	((rq)->elevator_private2 = (void *) state)
>  
> -static DEFINE_PER_CPU(unsigned long, ioc_count);
> +static DEFINE_PER_CPU(unsigned long, as_ioc_count);
>  static struct completion *ioc_gone;
>  static DEFINE_SPINLOCK(ioc_gone_lock);
>  
> @@ -161,7 +161,7 @@ static void as_antic_stop(struct as_data *ad);
>  static void free_as_io_context(struct as_io_context *aic)
>  {
>  	kfree(aic);
> -	elv_ioc_count_dec(ioc_count);
> +	elv_ioc_count_dec(as_ioc_count);
>  	if (ioc_gone) {
>  		/*
>  		 * AS scheduler is exiting, grab exit lock and check
> @@ -169,7 +169,7 @@ static void free_as_io_context(struct as_io_context *aic)
>  		 * complete ioc_gone and set it back to NULL.
>  		 */
>  		spin_lock(&ioc_gone_lock);
> -		if (ioc_gone && !elv_ioc_count_read(ioc_count)) {
> +		if (ioc_gone && !elv_ioc_count_read(as_ioc_count)) {
>  			complete(ioc_gone);
>  			ioc_gone = NULL;
>  		}
> @@ -211,7 +211,7 @@ static struct as_io_context *alloc_as_io_context(void)
>  		ret->seek_total = 0;
>  		ret->seek_samples = 0;
>  		ret->seek_mean = 0;
> -		elv_ioc_count_inc(ioc_count);
> +		elv_ioc_count_inc(as_ioc_count);
>  	}
>  
>  	return ret;
> @@ -1509,7 +1509,7 @@ static void __exit as_exit(void)
>  	ioc_gone = &all_gone;
>  	/* ioc_gone's update must be visible before reading ioc_count */
>  	smp_wmb();
> -	if (elv_ioc_count_read(ioc_count))
> +	if (elv_ioc_count_read(as_ioc_count))
>  		wait_for_completion(&all_gone);
>  	synchronize_rcu();
>  }
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index a55a9bd..deea748 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -48,7 +48,7 @@ static int cfq_slice_idle = HZ / 125;
>  static struct kmem_cache *cfq_pool;
>  static struct kmem_cache *cfq_ioc_pool;
>  
> -static DEFINE_PER_CPU(unsigned long, ioc_count);
> +static DEFINE_PER_CPU(unsigned long, cfq_ioc_count);
>  static struct completion *ioc_gone;
>  static DEFINE_SPINLOCK(ioc_gone_lock);
>  
> @@ -1423,7 +1423,7 @@ static void cfq_cic_free_rcu(struct rcu_head *head)
>  	cic = container_of(head, struct cfq_io_context, rcu_head);
>  
>  	kmem_cache_free(cfq_ioc_pool, cic);
> -	elv_ioc_count_dec(ioc_count);
> +	elv_ioc_count_dec(cfq_ioc_count);
>  
>  	if (ioc_gone) {
>  		/*
> @@ -1432,7 +1432,7 @@ static void cfq_cic_free_rcu(struct rcu_head *head)
>  		 * complete ioc_gone and set it back to NULL
>  		 */
>  		spin_lock(&ioc_gone_lock);
> -		if (ioc_gone && !elv_ioc_count_read(ioc_count)) {
> +		if (ioc_gone && !elv_ioc_count_read(cfq_ioc_count)) {
>  			complete(ioc_gone);
>  			ioc_gone = NULL;
>  		}
> @@ -1558,7 +1558,7 @@ cfq_alloc_io_context(struct cfq_data *cfqd, gfp_t gfp_mask)
>  		INIT_HLIST_NODE(&cic->cic_list);
>  		cic->dtor = cfq_free_io_context;
>  		cic->exit = cfq_exit_io_context;
> -		elv_ioc_count_inc(ioc_count);
> +		elv_ioc_count_inc(cfq_ioc_count);
>  	}
>  
>  	return cic;
> @@ -2663,7 +2663,7 @@ static void __exit cfq_exit(void)
>  	 * this also protects us from entering cfq_slab_kill() with
>  	 * pending RCU callbacks
>  	 */
> -	if (elv_ioc_count_read(ioc_count))
> +	if (elv_ioc_count_read(cfq_ioc_count))
>  		wait_for_completion(&all_gone);
>  	cfq_slab_kill();
>  }
> diff --git a/drivers/cpufreq/cpufreq_conservative.c b/drivers/cpufreq/cpufreq_conservative.c
> index 2ecd95e..e0faa3e 100644
> --- a/drivers/cpufreq/cpufreq_conservative.c
> +++ b/drivers/cpufreq/cpufreq_conservative.c
> @@ -80,7 +80,7 @@ struct cpu_dbs_info_s {
>  	int cpu;
>  	unsigned int enable:1;
>  };
> -static DEFINE_PER_CPU(struct cpu_dbs_info_s, cpu_dbs_info);
> +static DEFINE_PER_CPU(struct cpu_dbs_info_s, cs_cpu_dbs_info);
>  
>  static unsigned int dbs_enable;	/* number of CPUs using this policy */
>  
> @@ -150,7 +150,7 @@ dbs_cpufreq_notifier(struct notifier_block *nb, unsigned long val,
>  		     void *data)
>  {
>  	struct cpufreq_freqs *freq = data;
> -	struct cpu_dbs_info_s *this_dbs_info = &per_cpu(cpu_dbs_info,
> +	struct cpu_dbs_info_s *this_dbs_info = &per_cpu(cs_cpu_dbs_info,
>  							freq->cpu);
>  
>  	struct cpufreq_policy *policy;
> @@ -323,7 +323,7 @@ static ssize_t store_ignore_nice_load(struct cpufreq_policy *policy,
>  	/* we need to re-evaluate prev_cpu_idle */
>  	for_each_online_cpu(j) {
>  		struct cpu_dbs_info_s *dbs_info;
> -		dbs_info = &per_cpu(cpu_dbs_info, j);
> +		dbs_info = &per_cpu(cs_cpu_dbs_info, j);
>  		dbs_info->prev_cpu_idle = get_cpu_idle_time(j,
>  						&dbs_info->prev_cpu_wall);
>  		if (dbs_tuners_ins.ignore_nice)
> @@ -413,7 +413,7 @@ static void dbs_check_cpu(struct cpu_dbs_info_s *this_dbs_info)
>  		cputime64_t cur_wall_time, cur_idle_time;
>  		unsigned int idle_time, wall_time;
>  
> -		j_dbs_info = &per_cpu(cpu_dbs_info, j);
> +		j_dbs_info = &per_cpu(cs_cpu_dbs_info, j);
>  
>  		cur_idle_time = get_cpu_idle_time(j, &cur_wall_time);
>  
> @@ -553,7 +553,7 @@ static int cpufreq_governor_dbs(struct cpufreq_policy *policy,
>  	unsigned int j;
>  	int rc;
>  
> -	this_dbs_info = &per_cpu(cpu_dbs_info, cpu);
> +	this_dbs_info = &per_cpu(cs_cpu_dbs_info, cpu);
>  
>  	switch (event) {
>  	case CPUFREQ_GOV_START:
> @@ -573,7 +573,7 @@ static int cpufreq_governor_dbs(struct cpufreq_policy *policy,
>  
>  		for_each_cpu(j, policy->cpus) {
>  			struct cpu_dbs_info_s *j_dbs_info;
> -			j_dbs_info = &per_cpu(cpu_dbs_info, j);
> +			j_dbs_info = &per_cpu(cs_cpu_dbs_info, j);
>  			j_dbs_info->cur_policy = policy;
>  
>  			j_dbs_info->prev_cpu_idle = get_cpu_idle_time(j,
> diff --git a/drivers/cpufreq/cpufreq_ondemand.c b/drivers/cpufreq/cpufreq_ondemand.c
> index 338f428..2eaf88f 100644
> --- a/drivers/cpufreq/cpufreq_ondemand.c
> +++ b/drivers/cpufreq/cpufreq_ondemand.c
> @@ -87,7 +87,7 @@ struct cpu_dbs_info_s {
>  	unsigned int enable:1,
>  		sample_type:1;
>  };
> -static DEFINE_PER_CPU(struct cpu_dbs_info_s, cpu_dbs_info);
> +static DEFINE_PER_CPU(struct cpu_dbs_info_s, od_cpu_dbs_info);
>  
>  static unsigned int dbs_enable;	/* number of CPUs using this policy */
>  
> @@ -162,7 +162,8 @@ static unsigned int powersave_bias_target(struct cpufreq_policy *policy,
>  	unsigned int freq_hi, freq_lo;
>  	unsigned int index = 0;
>  	unsigned int jiffies_total, jiffies_hi, jiffies_lo;
> -	struct cpu_dbs_info_s *dbs_info = &per_cpu(cpu_dbs_info, policy->cpu);
> +	struct cpu_dbs_info_s *dbs_info = &per_cpu(od_cpu_dbs_info,
> +						   policy->cpu);
>  
>  	if (!dbs_info->freq_table) {
>  		dbs_info->freq_lo = 0;
> @@ -207,7 +208,7 @@ static void ondemand_powersave_bias_init(void)
>  {
>  	int i;
>  	for_each_online_cpu(i) {
> -		struct cpu_dbs_info_s *dbs_info = &per_cpu(cpu_dbs_info, i);
> +		struct cpu_dbs_info_s *dbs_info = &per_cpu(od_cpu_dbs_info, i);
>  		dbs_info->freq_table = cpufreq_frequency_get_table(i);
>  		dbs_info->freq_lo = 0;
>  	}
> @@ -322,7 +323,7 @@ static ssize_t store_ignore_nice_load(struct cpufreq_policy *policy,
>  	/* we need to re-evaluate prev_cpu_idle */
>  	for_each_online_cpu(j) {
>  		struct cpu_dbs_info_s *dbs_info;
> -		dbs_info = &per_cpu(cpu_dbs_info, j);
> +		dbs_info = &per_cpu(od_cpu_dbs_info, j);
>  		dbs_info->prev_cpu_idle = get_cpu_idle_time(j,
>  						&dbs_info->prev_cpu_wall);
>  		if (dbs_tuners_ins.ignore_nice)
> @@ -416,7 +417,7 @@ static void dbs_check_cpu(struct cpu_dbs_info_s *this_dbs_info)
>  		unsigned int load, load_freq;
>  		int freq_avg;
>  
> -		j_dbs_info = &per_cpu(cpu_dbs_info, j);
> +		j_dbs_info = &per_cpu(od_cpu_dbs_info, j);
>  
>  		cur_idle_time = get_cpu_idle_time(j, &cur_wall_time);
>  
> @@ -573,7 +574,7 @@ static int cpufreq_governor_dbs(struct cpufreq_policy *policy,
>  	unsigned int j;
>  	int rc;
>  
> -	this_dbs_info = &per_cpu(cpu_dbs_info, cpu);
> +	this_dbs_info = &per_cpu(od_cpu_dbs_info, cpu);
>  
>  	switch (event) {
>  	case CPUFREQ_GOV_START:
> @@ -595,7 +596,7 @@ static int cpufreq_governor_dbs(struct cpufreq_policy *policy,
>  
>  		for_each_cpu(j, policy->cpus) {
>  			struct cpu_dbs_info_s *j_dbs_info;
> -			j_dbs_info = &per_cpu(cpu_dbs_info, j);
> +			j_dbs_info = &per_cpu(od_cpu_dbs_info, j);
>  			j_dbs_info->cur_policy = policy;
>  
>  			j_dbs_info->prev_cpu_idle = get_cpu_idle_time(j,
> diff --git a/drivers/xen/events.c b/drivers/xen/events.c
> index 30963af..4dbe5c0 100644
> --- a/drivers/xen/events.c
> +++ b/drivers/xen/events.c
> @@ -596,6 +596,8 @@ irqreturn_t xen_debug_interrupt(int irq, void *dev_id)
>  	return IRQ_HANDLED;
>  }
>  
> +static DEFINE_PER_CPU(unsigned, xed_nesting_count);
> +
>  /*
>   * Search the CPUs pending events bitmasks.  For each one found, map
>   * the event number to an irq, and feed it into do_IRQ() for
> @@ -611,7 +613,6 @@ void xen_evtchn_do_upcall(struct pt_regs *regs)
>  	struct pt_regs *old_regs = set_irq_regs(regs);
>  	struct shared_info *s = HYPERVISOR_shared_info;
>  	struct vcpu_info *vcpu_info = __get_cpu_var(xen_vcpu);
> -	static DEFINE_PER_CPU(unsigned, nesting_count);
>   	unsigned count;
>  
>  	exit_idle();
> @@ -622,7 +623,7 @@ void xen_evtchn_do_upcall(struct pt_regs *regs)
>  
>  		vcpu_info->evtchn_upcall_pending = 0;
>  
> -		if (__get_cpu_var(nesting_count)++)
> +		if (__get_cpu_var(xed_nesting_count)++)
>  			goto out;
>  
>  #ifndef CONFIG_X86 /* No need for a barrier -- XCHG is a barrier on x86. */
> @@ -647,8 +648,8 @@ void xen_evtchn_do_upcall(struct pt_regs *regs)
>  
>  		BUG_ON(!irqs_disabled());
>  
> -		count = __get_cpu_var(nesting_count);
> -		__get_cpu_var(nesting_count) = 0;
> +		count = __get_cpu_var(xed_nesting_count);
> +		__get_cpu_var(xed_nesting_count) = 0;
>  	} while(count != 1);
>  
>  out:
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index bb553c3..0e0c9de 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -606,6 +606,8 @@ void set_page_dirty_balance(struct page *page, int page_mkwrite)
>  	}
>  }
>  
> +static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
> +
>  /**
>   * balance_dirty_pages_ratelimited_nr - balance dirty memory state
>   * @mapping: address_space which was dirtied
> @@ -623,7 +625,6 @@ void set_page_dirty_balance(struct page *page, int page_mkwrite)
>  void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
>  					unsigned long nr_pages_dirtied)
>  {
> -	static DEFINE_PER_CPU(unsigned long, ratelimits) = 0;
>  	unsigned long ratelimit;
>  	unsigned long *p;
>  
> @@ -636,7 +637,7 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
>  	 * tasks in balance_dirty_pages(). Period.
>  	 */
>  	preempt_disable();
> -	p =  &__get_cpu_var(ratelimits);
> +	p =  &__get_cpu_var(bdp_ratelimits);
>  	*p += nr_pages_dirtied;
>  	if (unlikely(*p >= ratelimit)) {
>  		*p = 0;
> diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
> index b35a950..70ee18c 100644
> --- a/net/ipv4/syncookies.c
> +++ b/net/ipv4/syncookies.c
> @@ -37,12 +37,12 @@ __initcall(init_syncookies);
>  #define COOKIEBITS 24	/* Upper bits store count */
>  #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
>  
> -static DEFINE_PER_CPU(__u32, cookie_scratch)[16 + 5 + SHA_WORKSPACE_WORDS];
> +static DEFINE_PER_CPU(__u32, ipv4_cookie_scratch)[16 + 5 + SHA_WORKSPACE_WORDS];
>  
>  static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
>  		       u32 count, int c)
>  {
> -	__u32 *tmp = __get_cpu_var(cookie_scratch);
> +	__u32 *tmp = __get_cpu_var(ipv4_cookie_scratch);
>  
>  	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
>  	tmp[0] = (__force u32)saddr;
> diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
> index 711175e..348e38c 100644
> --- a/net/ipv6/syncookies.c
> +++ b/net/ipv6/syncookies.c
> @@ -74,12 +74,12 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
>  	return child;
>  }
>  
> -static DEFINE_PER_CPU(__u32, cookie_scratch)[16 + 5 + SHA_WORKSPACE_WORDS];
> +static DEFINE_PER_CPU(__u32, ipv6_cookie_scratch)[16 + 5 + SHA_WORKSPACE_WORDS];
>  
>  static u32 cookie_hash(struct in6_addr *saddr, struct in6_addr *daddr,
>  		       __be16 sport, __be16 dport, u32 count, int c)
>  {
> -	__u32 *tmp = __get_cpu_var(cookie_scratch);
> +	__u32 *tmp = __get_cpu_var(ipv6_cookie_scratch);
>  
>  	/*
>  	 * we have 320 bits of information to hash, copy in the remaining
> -- 
> 1.6.0.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
