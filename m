Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E099D6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 12:03:41 -0400 (EDT)
Message-ID: <520BAA5B.9070407@tilera.com>
Date: Wed, 14 Aug 2013 12:03:39 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 2/2] mm: make lru_add_drain_all() selective
References: <520AAF9C.1050702@tilera.com> <201308132307.r7DN74M5029053@farm-0021.internal.tilera.com> <20130813232904.GJ28996@mtj.dyndns.org> <520AC215.4050803@tilera.com> <20130813234629.4ce2ec70.akpm@linux-foundation.org>
In-Reply-To: <20130813234629.4ce2ec70.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On 8/14/2013 2:46 AM, Andrew Morton wrote:
> On Tue, 13 Aug 2013 19:32:37 -0400 Chris Metcalf <cmetcalf@tilera.com> wrote:
>
>> On 8/13/2013 7:29 PM, Tejun Heo wrote:
>>> Hello,
>>>
>>> On Tue, Aug 13, 2013 at 06:53:32PM -0400, Chris Metcalf wrote:
>>>>  int lru_add_drain_all(void)
>>>>  {
>>>> -	return schedule_on_each_cpu(lru_add_drain_per_cpu);
>>>> +	return schedule_on_each_cpu_cond(lru_add_drain_per_cpu,
>>>> +					 lru_add_drain_cond, NULL);
> This version looks nice to me.  It's missing the conversion of
> schedule_on_each_cpu(), but I suppose that will be pretty simple.

I assume you were thinking of something like a NULL "cond" function pointer
meaning "no condition" in the implementation, and then schedule_on_each_cpu
just calls schedule_on_each_cpu_cond(work, NULL, NULL)?

>>> It won't nest and doing it simultaneously won't buy anything, right?
>> Correct on both counts, I think.
> I'm glad you understood the question :(
>
> What does "nest" mean?  lru_add_drain_all() calls itself recursively,
> presumably via some ghastly alloc_percpu()->alloc_pages(GFP_KERNEL)
> route?  If that ever happens then we'd certainly want to know about it.
> Hopefully PF_MEMALLOC would prevent infinite recursion.

Well, I think "it won't nest" is true in exactly the way you say - or
maybe we want to say "it shouldn't nest".  Catching the condition would
obviously be a good thing.

> If "nest" means something else then please enlighten me!
>
> As for "doing it simultaneously", I assume we're referring to
> concurrent execution from separate threads.  If so, why would that "buy
> us anything"?  Confused.  As long as each thread sees "all pages which
> were in pagevecs at the time I called lru_add_drain_all() get spilled
> onto the LRU" then we're good.  afaict the implementation will do this.

If we can avoid doing it simultaneously, we avoid having to do any
allocation at all, which seems like a win.  Let's consider if we
simply do a mutex_lock() around the routine.  If we also then test to
see which cpus need to be drained before issuing the drain, the result
for two cpus that both try to drain simultaneously would be that one
succeeds and drains everything; the second blocks on the mutex until
the first is done, then quickly enters the code, finds that no cpus
require draining, and returns, faster than would have been the case in
the current code when it would also have fired drain requests at every
cpu, concurrently with the earlier cpus firing its drain requests.
Frankly, this seems like a pretty reasonable solution.  We can
implement it purely in swap.c using existing workqueue APIs.

Note that lru_add_drain_all() always returns success this way, so I've
changed the API to make it a void function.  Considering none of the
callers currently check the error return value anyway, that seemed like
a straightforward thing to do.  :-)

Unfortunately DEFINE_PER_CPU doesn't work at function scope, so
I have to make it file-static.

Assuming the existence of my "need_activate_page_drain()" helper from
the earlier versions of the patch set, lru_add_drain_all() looks
like the following:


static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);

void lru_add_drain_all(void)
{
	static DEFINE_MUTEX(lock);
	int cpu;

	mutex_lock(&lock);
	get_online_cpus();

	for_each_online_cpu(cpu) {
		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);

		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
		    need_activate_page_drain(cpu)) {
			INIT_WORK(work, lru_add_drain_per_cpu);
			schedule_work_on(cpu, work);
		} else {
			work->entry.next = NULL;
		}
	}

	for_each_online_cpu(cpu) {
		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);

		if (work->entry.next)
			flush_work(work);
	}

	put_online_cpus();
	mutex_unlock(&lock);
}

Tejun, I don't know if you have a better idea for how to mark a
work_struct as being "not used" so we can set and test it here.
Is setting entry.next to NULL good?  Should we offer it as an API
in the workqueue header?

We could wrap the whole thing in a new workqueue API too, of course
(schedule_on_each_cpu_cond_sequential??) but it seems better at this
point to wait until we find another caller with similar needs, and only
then factor the code into a new workqueue API.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
