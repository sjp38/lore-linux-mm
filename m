Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 92A216B0070
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 23:51:29 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 3 Oct 2012 09:21:26 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q933pO1O39256146
	for <linux-mm@kvack.org>; Wed, 3 Oct 2012 09:21:24 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q933pNTC008947
	for <linux-mm@kvack.org>; Wed, 3 Oct 2012 13:51:23 +1000
Message-ID: <506BB612.5090504@linux.vnet.ibm.com>
Date: Wed, 03 Oct 2012 09:20:42 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, slab: release slab_mutex earlier in kmem_cache_destroy()
 (was Re: Lockdep complains about commit 1331e7a1bb ("rcu: Remove _rcu_barrier()
 dependency on __stop_machine()"))
References: <alpine.LNX.2.00.1210021810350.23544@pobox.suse.cz> <20121002170149.GC2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210022324050.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022331130.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022356370.23544@pobox.suse.cz> <20121002233138.GD2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030142570.23544@pobox.suse.cz> <20121003001530.GF2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz>
In-Reply-To: <alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paul.mckenney@linaro.org>, Josh Triplett <josh@joshtriplett.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/03/2012 06:15 AM, Jiri Kosina wrote:
> On Tue, 2 Oct 2012, Paul E. McKenney wrote:
> 
>> On Wed, Oct 03, 2012 at 01:48:21AM +0200, Jiri Kosina wrote:
>>> On Tue, 2 Oct 2012, Paul E. McKenney wrote:
>>>
>>>> Indeed.  Slab seems to be doing an rcu_barrier() in a CPU hotplug 
>>>> notifier, which doesn't sit so well with rcu_barrier() trying to exclude 
>>>> CPU hotplug events.  I could go back to the old approach, but it is 
>>>> significantly more complex.  I cannot say that I am all that happy about 
>>>> anyone calling rcu_barrier() from a CPU hotplug notifier because it 
>>>> doesn't help CPU hotplug latency, but that is a separate issue.
>>>>
>>>> But the thing is that rcu_barrier()'s assumptions work just fine if either
>>>> (1) it excludes hotplug operations or (2) if it is called from a hotplug
>>>> notifier.  You see, either way, the CPU cannot go away while rcu_barrier()
>>>> is executing.  So the right way to resolve this seems to be to do the
>>>> get_online_cpus() only if rcu_barrier() is -not- executing in the context
>>>> of a hotplug notifier.  Should be fixable without too much hassle...
>>>
>>> Sorry, I don't think I understand what you are proposing just yet.
>>>
>>> If I understand it correctly, you are proposing to introduce some magic 
>>> into _rcu_barrier() such as (pseudocode of course):
>>>
>>> 	if (!being_called_from_hotplug_notifier_callback)
>>> 		get_online_cpus()
>>>
>>> How does that protect from the scenario I've outlined before though?
>>>
>>> 	CPU 0                           CPU 1
>>> 	kmem_cache_destroy()
>>> 	mutex_lock(slab_mutex)
>>> 					_cpu_up()
>>> 					cpu_hotplug_begin()
>>> 					mutex_lock(cpu_hotplug.lock)
>>> 	rcu_barrier()
>>> 	_rcu_barrier()
>>> 	get_online_cpus()
>>> 	mutex_lock(cpu_hotplug.lock)
>>> 	 (blocks, CPU 1 has the mutex)
>>> 					__cpu_notify()
>>> 					mutex_lock(slab_mutex)	
>>>
>>> CPU 0 grabs both locks anyway (it's not running from notifier callback). 
>>> CPU 1 grabs both locks as well, as there is no _rcu_barrier() being called 
>>> from notifier callback either.
>>>
>>> What did I miss?
>>
>> You didn't miss anything, I was suffering a failure to read carefully.
>>
>> So my next stupid question is "Why can't kmem_cache_destroy drop
>> slab_mutex early?" like the following:
>>
>> 	void kmem_cache_destroy(struct kmem_cache *cachep)
>> 	{
>> 		BUG_ON(!cachep || in_interrupt());
>>
>> 		/* Find the cache in the chain of caches. */
>> 		get_online_cpus();
>> 		mutex_lock(&slab_mutex);
>> 		/*
>> 		 * the chain is never empty, cache_cache is never destroyed
>> 		 */
>> 		list_del(&cachep->list);
>> 		if (__cache_shrink(cachep)) {
>> 			slab_error(cachep, "Can't free all objects");
>> 			list_add(&cachep->list, &slab_caches);
>> 			mutex_unlock(&slab_mutex);
>> 			put_online_cpus();
>> 			return;
>> 		}
>> 		mutex_unlock(&slab_mutex);
>>
>> 		if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
>> 			rcu_barrier();
>>
>> 		__kmem_cache_destroy(cachep);
>> 		put_online_cpus();
>> 	}
>>
>> Or did I miss some reason why __kmem_cache_destroy() needs that lock?
>> Looks to me like it is just freeing now-disconnected memory.
> 
> Good question. I believe it should be safe to drop slab_mutex earlier, as 
> cachep has already been unlinked. I am adding slab people and linux-mm to 
> CC (the whole thread on LKML can be found at 
> https://lkml.org/lkml/2012/10/2/296 for reference).
> 
> How about the patch below? Pekka, Christoph, please?
> 
> It makes the lockdep happy again, and obviously removes the deadlock (I 
> tested it).
> 
> 
> 
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: mm, slab: release slab_mutex earlier in kmem_cache_destroy()
> 
> Commit 1331e7a1bbe1 ("rcu: Remove _rcu_barrier() dependency on
> __stop_machine()") introduced slab_mutex -> cpu_hotplug.lock
> dependency through kmem_cache_destroy() -> rcu_barrier() ->
> _rcu_barrier() -> get_online_cpus().
> 
> This opens a possibilty for deadlock:
> 
>         CPU 0                           CPU 1
> 	        kmem_cache_destroy()
> 	        mutex_lock(slab_mutex)
> 	                                        _cpu_up()
> 	                                        cpu_hotplug_begin()
> 	                                        mutex_lock(cpu_hotplug.lock)
> 	        rcu_barrier()
> 	        _rcu_barrier()
> 	        get_online_cpus()
> 	        mutex_lock(cpu_hotplug.lock)
> 	         (blocks, CPU 1 has the mutex)
> 	                                        __cpu_notify()
> 	                                        mutex_lock(slab_mutex)

Hmm.. no, this should *never* happen IMHO!

If I am seeing the code right, kmem_cache_destroy() wraps its entire content
inside get/put_online_cpus(), which means it cannot run concurrently with cpu_up()
or cpu_down(). Are we really hitting a corner case where the refcounting logic
in get/put_online_cpus() is failing and allowing a hotplug writer to run in
parallel with a hotplug reader? If yes, *that* is the problem we have to fix..

Regards,
Srivatsa S. Bhat

> 
> It turns out that slab's kmem_cache_destroy() might release slab_mutex
> earlier before calling out to rcu_barrier(), as cachep has already been
> unlinked.
> 
> This patch removes the AB-BA dependency by calling rcu_barrier() with 
> slab_mutex already unlocked.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  mm/slab.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 1133911..693c7cb 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2801,12 +2801,12 @@ void kmem_cache_destroy(struct kmem_cache *cachep)
>  		put_online_cpus();
>  		return;
>  	}
> +	mutex_unlock(&slab_mutex);
> 
>  	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
>  		rcu_barrier();
> 
>  	__kmem_cache_destroy(cachep);
> -	mutex_unlock(&slab_mutex);
>  	put_online_cpus();
>  }
>  EXPORT_SYMBOL(kmem_cache_destroy);
> 


-- 
Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
