Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9E46B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 07:28:02 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g22-v6so2268235ioh.5
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 04:28:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x124-v6si3267388ite.101.2018.06.21.04.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 04:28:00 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
Date: Thu, 21 Jun 2018 20:27:41 +0900
MIME-Version: 1.0
In-Reply-To: <20180621073142.GA10465@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 2018/06/21 7:36, David Rientjes wrote:
>> @@ -1010,6 +1010,33 @@ int unregister_oom_notifier(struct notifier_block *nb)
>>  EXPORT_SYMBOL_GPL(unregister_oom_notifier);
>>  
>>  /**
>> + * try_oom_notifier - Try to reclaim memory from OOM notifier list.
>> + *
>> + * Returns non-zero if notifier callbacks released something, zero otherwise.
>> + */
>> +unsigned long try_oom_notifier(void)
> 
> It certainly is tried, but based on its usage it would probably be better 
> to describe what is being returned (it's going to set *did_some_progress, 
> which is a page count).

Well, it depends on what the callbacks are doing. Currently, we have 5 users.

  arch/powerpc/platforms/pseries/cmm.c
  arch/s390/mm/cmm.c
  drivers/gpu/drm/i915/i915_gem_shrinker.c
  drivers/virtio/virtio_balloon.c
  kernel/rcu/tree_plugin.h

Speak of rcu_oom_notify() in kernel/rcu/tree_plugin.h , we can't tell whether
the callback helped releasing memory, for it does not update the "freed" argument.

>> +{
>> +	static DEFINE_MUTEX(oom_notifier_lock);
>> +	unsigned long freed = 0;
>> +
>> +	/*
>> +	 * Since OOM notifier callbacks must not depend on __GFP_DIRECT_RECLAIM
>> +	 * && !__GFP_NORETRY memory allocation, waiting for mutex here is safe.
>> +	 * If lockdep reports possible deadlock dependency, it will be a bug in
>> +	 * OOM notifier callbacks.
>> +	 *
>> +	 * If SIGKILL is pending, it is likely that current thread was selected
>> +	 * as an OOM victim. In that case, current thread should return as soon
>> +	 * as possible using memory reserves.
>> +	 */
>> +	if (mutex_lock_killable(&oom_notifier_lock))
>> +		return 0;
>> +	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
>> +	mutex_unlock(&oom_notifier_lock);
>> +	return freed;
>> +}
> 
> If __blocking_notifier_call_chain() used down_read_killable(), could we 
> eliminate oom_notifier_lock?

I don't think we can eliminate it now, for it is a serialization lock
(while trying to respond to SIGKILL as soon as possible) which is currently
achieved by mutex_trylock(&oom_lock).

(1) rcu_oom_notify() in kernel/rcu/tree_plugin.h is not prepared for being
    called concurrently.

----------
static int rcu_oom_notify(struct notifier_block *self,
			  unsigned long notused, void *nfreed)
{
	int cpu;

	/* Wait for callbacks from earlier instance to complete. */
	wait_event(oom_callback_wq, atomic_read(&oom_callback_count) == 0); // <= Multiple threads can pass this line at the same time.
	smp_mb(); /* Ensure callback reuse happens after callback invocation. */

	/*
	 * Prevent premature wakeup: ensure that all increments happen
	 * before there is a chance of the counter reaching zero.
	 */
	atomic_set(&oom_callback_count, 1); // <= Multiple threads can execute this line at the same time.

	for_each_online_cpu(cpu) {
		smp_call_function_single(cpu, rcu_oom_notify_cpu, NULL, 1);
		cond_resched_tasks_rcu_qs();
	}

	/* Unconditionally decrement: no need to wake ourselves up. */
	atomic_dec(&oom_callback_count); // <= Multiple threads can execute this line at the same time, making oom_callback_count < 0 ?

	return NOTIFY_OK;
}
----------

    The counter inconsistency problem could be fixed by

-	atomic_set(&oom_callback_count, 1);
+	atomic_inc(&oom_callback_count);

    but who becomes happy if rcu_oom_notify() became ready to be called
    concurrently? We want to wait for the callback to complete before
    proceeding to the OOM killer. I think that we should save CPU resource
    by serializing concurrent callers.

(2) i915_gem_shrinker_oom() in drivers/gpu/drm/i915/i915_gem_shrinker.c depends
    on mutex_trylock() from shrinker_lock() from i915_gem_shrink() from
    i915_gem_shrink_all() to return 1 (i.e. succeed) before need_resched()
    becomes true in order to avoid returning without reclaiming memory.

> This patch is certainly an improvement because it does the last 
> get_page_from_freelist() call after invoking the oom notifiers that can 
> free memory and we've otherwise pointlessly redirected it elsewhere.

Thanks, but this patch might break subtle balance which is currently
achieved by mutex_trylock(&oom_lock) serialization/exclusion.

(3) virtballoon_oom_notify() in drivers/virtio/virtio_balloon.c by default
    tries to release 256 pages. Since this value is configurable, one might
    set 1048576 pages. If virtballoon_oom_notify() is concurrently called by
    many threads, it might needlessly deflate the memory balloon.

We might want to remember and reuse the last result among serialized callers
(feedback mechanism) like

{
	static DEFINE_MUTEX(oom_notifier_lock);
	static unsigned long last_freed;
	unsigned long freed = 0;
	if (mutex_trylock(&oom_notifier_lock)) {
		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
		last_freed = freed;
	} else {
		mutex_lock(&oom_notifier_lock);
		freed = last_freed;
	}
	mutex_unlock(&oom_notifier_lock);
	return freed;

}

or

{
	static DEFINE_MUTEX(oom_notifier_lock);
	static unsigned long last_freed;
	unsigned long freed = 0;
	if (mutex_lock_killable(&oom_notifier_lock)) {
		freed = last_freed;
		last_freed >>= 1;
		return freed;
	} else if (last_freed) {
		freed = last_freed;
		last_freed >>= 1;
	} else {
		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
		last_freed = freed;
	}
	mutex_unlock(&oom_notifier_lock);
	return freed;
}

. Without feedback mechanism, mutex_lock_killable(&oom_notifier_lock) serialization
could still needlessly deflate the memory balloon compared to mutex_trylock(&oom_lock)
serialization/exclusion. Maybe virtballoon_oom_notify() (and two CMM users) would
implement feedback mechanism themselves, by examining watermark from OOM notifier
hooks.



On 2018/06/21 16:31, Michal Hocko wrote:
> On Wed 20-06-18 15:36:45, David Rientjes wrote:
> [...]
>> That makes me think that "oom_notify_list" isn't very intuitive: it can 
>> free memory as a last step prior to oom kill.  OOM notify, to me, sounds 
>> like its only notifying some callbacks about the condition.  Maybe 
>> oom_reclaim_list and then rename this to oom_reclaim_pages()?
> 
> Yes agreed and that is the reason I keep saying we want to get rid of
> this yet-another-reclaim mechanism. We already have shrinkers which are
> the main source of non-lru pages reclaim. Why do we even need
> oom_reclaim_pages? What is fundamentally different here? Sure those
> pages should be reclaimed as the last resort but we already do have
> priority for slab shrinking so we know that the system is struggling
> when reaching the lowest priority. Isn't that enough to express the need
> for current oom notifier implementations?
> 

Even if we update OOM notifier users to use shrinker hooks, they will need a
subtle balance which is currently achieved by mutex_trylock(&oom_lock).

Removing OOM notifier is not doable right now. It is not suitable as a regression
fix for commit 27ae357fa82be5ab ("mm, oom: fix concurrent munlock and oom reaper
unmap, v3"). What we could afford for this regression is
https://patchwork.kernel.org/patch/9842889/ which is exactly what you suggested
in a thread at https://www.spinics.net/lists/linux-mm/msg117896.html .
