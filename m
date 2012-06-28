Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id F37AE6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:42:28 -0400 (EDT)
Message-ID: <4FECEBF4.7010202@kernel.org>
Date: Fri, 29 Jun 2012 08:42:44 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: needed lru_add_drain_all() change
References: <20120626143703.396d6d66.akpm@linux-foundation.org> <4FEC0B3F.7070108@jp.fujitsu.com>
In-Reply-To: <4FEC0B3F.7070108@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 06/28/2012 04:43 PM, Kamezawa Hiroyuki wrote:

> (2012/06/27 6:37), Andrew Morton wrote:
>> https://bugzilla.kernel.org/show_bug.cgi?id=43811
>>
>> lru_add_drain_all() uses schedule_on_each_cpu().  But
>> schedule_on_each_cpu() hangs if a realtime thread is spinning, pinned
>> to a CPU.  There's no intention to change the scheduler behaviour, so I
>> think we should remove schedule_on_each_cpu() from the kernel.
>>
>> The biggest user of schedule_on_each_cpu() is lru_add_drain_all().
>>
>> Does anyone have any thoughts on how we can do this?  The obvious
>> approach is to declare these:
>>
>> static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>> static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>> static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
>>
>> to be irq-safe and use on_each_cpu().  lru_rotate_pvecs is already
>> irq-safe and converting lru_add_pvecs and lru_deactivate_pvecs looks
>> pretty simple.
>>
>> Thoughts?
>>
> 
> How about this kind of RCU synchronization ?
> ==
> /*
>  * Double buffered pagevec for quick drain.
>  * The usual per-cpu-pvec user need to take rcu_read_lock() before
> accessing.
>  * External drainer of pvecs will relpace pvec vector and call
> synchroize_rcu(),
>  * and drain all pages on unused pvecs in turn.
>  */
> static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS * 2], lru_pvecs);
> 
> atomic_t pvec_idx; /* must be placed onto some aligned address...*/
> 
> 
> struct pagevec *my_pagevec(enum lru)
> {
>     return  pvec = &__get_cpu_var(lru_pvecs[lru << atomic_read(pvec_idx)]);
> }
> 
> /*
>  * percpu pagevec access should be surrounded by these calls.
>  */
> static inline void pagevec_start_access()
> {
>     rcu_read_lock();
> }
> 
> static inline void pagevec_end_access()
> {
>     rcu_read_unlock();
> }
> 
> 
> /*
>  * changing pagevec array vec 0 <-> 1
>  */
> static void lru_pvec_update()
> {
>     if (atomic_read(&pvec_idx))
>         atomic_set(&pvec_idx, 0);
>     else
>         atomic_set(&pvec_idx, 1);
> }
> 
> /*
>  * drain all LRUS on per-cpu pagevecs.
>  */
> DEFINE_MUTEX(lru_add_drain_all_mutex);
> static void lru_add_drain_all()
> {
>     mutex_lock(&lru_add_drain_mutex);
>     lru_pvec_update();
>     synchronize_rcu();  /* waits for all accessors to pvec quits. */


I don't know RCU internal but conceptually, I understood synchronize_rcu need 
context switching of all CPU. If it's partly true, it could be a problem, too.

>     for_each_cpu(cpu)
>         drain_pvec_of_the_cpu(cpu);
>     mutex_unlock(&lru_add_drain_mutex);
> }
> ==
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
