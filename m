Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 9834E6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 23:26:49 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3103D3EE0B6
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:26:48 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 15E0E45DE51
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:26:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFF0845DE4D
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:26:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E21B7E08001
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:26:47 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 917D71DB8037
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:26:47 +0900 (JST)
Message-ID: <4FED1FF1.7000901@jp.fujitsu.com>
Date: Fri, 29 Jun 2012 12:24:33 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: needed lru_add_drain_all() change
References: <20120626143703.396d6d66.akpm@linux-foundation.org> <4FEC0B3F.7070108@jp.fujitsu.com> <4FECEBF4.7010202@kernel.org>
In-Reply-To: <4FECEBF4.7010202@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

(2012/06/29 8:42), Minchan Kim wrote:
> On 06/28/2012 04:43 PM, Kamezawa Hiroyuki wrote:
>
>> (2012/06/27 6:37), Andrew Morton wrote:
>>> https://bugzilla.kernel.org/show_bug.cgi?id=43811
>>>
>>> lru_add_drain_all() uses schedule_on_each_cpu().  But
>>> schedule_on_each_cpu() hangs if a realtime thread is spinning, pinned
>>> to a CPU.  There's no intention to change the scheduler behaviour, so I
>>> think we should remove schedule_on_each_cpu() from the kernel.
>>>
>>> The biggest user of schedule_on_each_cpu() is lru_add_drain_all().
>>>
>>> Does anyone have any thoughts on how we can do this?  The obvious
>>> approach is to declare these:
>>>
>>> static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>>> static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>>> static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
>>>
>>> to be irq-safe and use on_each_cpu().  lru_rotate_pvecs is already
>>> irq-safe and converting lru_add_pvecs and lru_deactivate_pvecs looks
>>> pretty simple.
>>>
>>> Thoughts?
>>>
>>
>> How about this kind of RCU synchronization ?
>> ==
>> /*
>>   * Double buffered pagevec for quick drain.
>>   * The usual per-cpu-pvec user need to take rcu_read_lock() before
>> accessing.
>>   * External drainer of pvecs will relpace pvec vector and call
>> synchroize_rcu(),
>>   * and drain all pages on unused pvecs in turn.
>>   */
>> static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS * 2], lru_pvecs);
>>
>> atomic_t pvec_idx; /* must be placed onto some aligned address...*/
>>
>>
>> struct pagevec *my_pagevec(enum lru)
>> {
>>      return  pvec = &__get_cpu_var(lru_pvecs[lru << atomic_read(pvec_idx)]);
>> }
>>
>> /*
>>   * percpu pagevec access should be surrounded by these calls.
>>   */
>> static inline void pagevec_start_access()
>> {
>>      rcu_read_lock();
>> }
>>
>> static inline void pagevec_end_access()
>> {
>>      rcu_read_unlock();
>> }
>>
>>
>> /*
>>   * changing pagevec array vec 0 <-> 1
>>   */
>> static void lru_pvec_update()
>> {
>>      if (atomic_read(&pvec_idx))
>>          atomic_set(&pvec_idx, 0);
>>      else
>>          atomic_set(&pvec_idx, 1);
>> }
>>
>> /*
>>   * drain all LRUS on per-cpu pagevecs.
>>   */
>> DEFINE_MUTEX(lru_add_drain_all_mutex);
>> static void lru_add_drain_all()
>> {
>>      mutex_lock(&lru_add_drain_mutex);
>>      lru_pvec_update();
>>      synchronize_rcu();  /* waits for all accessors to pvec quits. */
>
>
> I don't know RCU internal but conceptually, I understood synchronize_rcu need
> context switching of all CPU. If it's partly true, it could be a problem, too.
>

Hmm, from Documenatation/RCU/stallwarn.txt
==

o       For !CONFIG_PREEMPT kernels, a CPU looping anywhere in the kernel
         without invoking schedule().

o       A CPU-bound real-time task in a CONFIG_PREEMPT kernel, which might
         happen to preempt a low-priority task in the middle of an RCU
         read-side critical section.   This is especially damaging if
         that low-priority task is not permitted to run on any other CPU,
         in which case the next RCU grace period can never complete, which
         will eventually cause the system to run out of memory and hang.
         While the system is in the process of running itself out of
         memory, you might see stall-warning messages.

o       A CPU-bound real-time task in a CONFIG_PREEMPT_RT kernel that
         is running at a higher priority than the RCU softirq threads.
         This will prevent RCU callbacks from ever being invoked,
         and in a CONFIG_TREE_PREEMPT_RCU kernel will further prevent
         RCU grace periods from ever completing.  Either way, the
         system will eventually run out of memory and hang.  In the
         CONFIG_TREE_PREEMPT_RCU case, you might see stall-warning
         messages.
==
you're right. (RCU stall warning seems to be shown per 60secs at default.)

I'm wondering to do sync without RCU...
==
pvec_start_access(struct pagevec *pvec)
{
	atomic_inc(&pvec->using);
}

pvec_end_access(struct pagevec *pvec)
{
	atomic_dec(&pvec->using);
}

synchronize_pvec()
{
	for_each_cpu(cpu)
		wait for pvec->using to be 0.
}

static void lru_add_drain_all()
{
	mutex_lock();
	lru_pvec_update(); //switch pvec
	synchronize_pvec(); // wait for all user exits
	for_each_cpu()
		drain pages in pvec
	mutex_unlock()
}
==

"disable_irq() + intterupt()" will be easier.

What is the cost of IRQ-disable v.s. atomic_inc() for local variable...

Regards,
-Kame











--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
