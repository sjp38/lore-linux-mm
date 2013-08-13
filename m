Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 624EC6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 21:53:15 -0400 (EDT)
Message-ID: <52099187.80301@tilera.com>
Date: Mon, 12 Aug 2013 21:53:11 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/2] mm: make lru_add_drain_all() selective
References: <5202CEAA.9040204@linux.vnet.ibm.com> <201308072335.r77NZZwl022494@farm-0012.internal.tilera.com> <20130812140520.c6a2255d2176a690fadf9ba7@linux-foundation.org>
In-Reply-To: <20130812140520.c6a2255d2176a690fadf9ba7@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On 8/12/2013 5:05 PM, Andrew Morton wrote:
> On Wed, 7 Aug 2013 16:52:22 -0400 Chris Metcalf <cmetcalf@tilera.com> wrote:
>
>> This change makes lru_add_drain_all() only selectively interrupt
>> the cpus that have per-cpu free pages that can be drained.
>>
>> This is important in nohz mode where calling mlockall(), for
>> example, otherwise will interrupt every core unnecessarily.
>>
>> ...
>>
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -405,6 +405,11 @@ static void activate_page_drain(int cpu)
>>  		pagevec_lru_move_fn(pvec, __activate_page, NULL);
>>  }
>>  
>> +static bool need_activate_page_drain(int cpu)
>> +{
>> +	return pagevec_count(&per_cpu(activate_page_pvecs, cpu)) != 0;
>> +}
>> +
>>  void activate_page(struct page *page)
>>  {
>>  	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
>> @@ -422,6 +427,11 @@ static inline void activate_page_drain(int cpu)
>>  {
>>  }
>>  
>> +static bool need_activate_page_drain(int cpu)
>> +{
>> +	return false;
>> +}
>> +
>>  void activate_page(struct page *page)
>>  {
>>  	struct zone *zone = page_zone(page);
>> @@ -683,7 +693,32 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
>>   */
>>  int lru_add_drain_all(void)
>>  {
>> -	return schedule_on_each_cpu(lru_add_drain_per_cpu);
>> +	cpumask_var_t mask;
>> +	int cpu, rc;
>> +
>> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
>> +		return -ENOMEM;
> Newly adding a GFP_KERNEL allocation attempt into lru_add_drain_all()
> is dangerous and undesirable.  I took a quick look at all the callsites
> and didn't immediately see a bug, but it's hard because they're
> splattered all over the place.  It would be far better if we were to
> not do this.

I think it should be safe, given that we already did alloc_percpu() to do
schedule_on_each_cpu(), and that is documented as doing GFP_KERNEL allocation
(pcpu_create_chunk will call alloc_pages with GFP_KERNEL).

> Rather than tossing this hang-grenade in there we should at a reluctant
> minimum change lru_add_drain_all() to take a gfp_t argument and then
> carefully review and update the callers.
>
>> +	cpumask_clear(mask);
>> +
>> +	/*
>> +	 * Figure out which cpus need flushing.  It's OK if we race
>> +	 * with changes to the per-cpu lru pvecs, since it's no worse
>> +	 * than if we flushed all cpus, since a cpu could still end
>> +	 * up putting pages back on its pvec before we returned.
>> +	 * And this avoids interrupting other cpus unnecessarily.
>> +	 */
>> +	for_each_online_cpu(cpu) {
>> +		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
>> +		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
>> +		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
>> +		    need_activate_page_drain(cpu))
>> +			cpumask_set_cpu(cpu, mask);
>> +	}
>> +
>> +	rc = schedule_on_cpu_mask(lru_add_drain_per_cpu, mask);
> And it seems pretty easy to avoid the allocation.  Create a single
> cpumask at boot (or, preferably, at compile-time) and whenever we add a
> page to a drainable pagevec, do
>
> 	cpumask_set_cpu(smp_processor_id(), global_cpumask);
>
> and to avoid needlessly dirtying a cacheline,
>
> 	if (!cpu_isset(smp_processor_id(), global_cpumask))
> 		cpumask_set_cpu(smp_processor_id(), global_cpumask);
>
>
> This means that lru_add_drain_all() will need to clear the mask at some
> point and atomicity issues arise.  It would be better to do the
> clearing within schedule_on_cpu_mask() itself, using
> cpumask_test_and_clear_cpu().

The atomicity issue isn't that big a deal (given that the drain is
racy anyway, you just need to make sure to do cpumask_set_cpu after
the pagevec_add), but you do need to clear the cpumask before doing
the actual drain, and that either means inflicting that semantics
on schedule_on_cpu_mask(), which seems a little unnatural, or else
doing a copy of the mask, which gets us back to where we started
with GFP_KERNEL allocations.

Alternately, you could imagine a workqueue API that just took a function
pointer that returned for each cpu whether or not to schedule work on
that cpu:

  typedef bool (*check_work_func_t)(void *data, int cpu);
  schedule_on_some_cpus(work_func_t func, check_work_func_t checker, void *data);

For the lru stuff we wouldn't need to use a "data" pointer but I'd include
it since it's cheap, pretty standard, and makes the API more general.

Or, I suppose, one other possibility is just a compile-time struct
cpumask that we guard with a lock.  It seems a bit like overkill for
the very common case of not specifying CPUMASK_OFFSTACK.

All that said, I still tend to like the simple cpumask data-driven approach,
assuming you're comfortable with the possible GFP_KERNEL allocation.

> Also, what's up with the get_online_cpus() handling? 
> schedule_on_each_cpu() does it, lru_add_drain_all() does not do it and
> the schedule_on_cpu_mask() documentation forgot to mention it.

The missing get_online_cpus() for lru_add_drain_all() is in v6 of the
patch from Aug 9 (v5 had Tejun's feedback for doing validity-checking
on the schedule_on_cpu_mask() mask argument, and v6 added his Ack
and the missing get/put_online_cpus).

schedule_on_each_cpu() obviously uses get/put_online_cpus and needs it;
I would argue that there's no need to mention it in the docs for
schedule_on_cpu_mask() since if you're going to pass the cpu_online_mask
you'd better know that you should get/put_online_cpus().

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
