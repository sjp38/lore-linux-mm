Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D45146B0069
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 01:04:12 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Sun, 20 Nov 2011 11:34:08 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAK63xrs4173860
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 11:34:01 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAK63wIn000377
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 17:03:58 +1100
Message-ID: <4EC8984E.30005@linux.vnet.ibm.com>
Date: Sun, 20 Nov 2011 11:33:58 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com> <201111192257.19763.rjw@sisk.pl>
In-Reply-To: <201111192257.19763.rjw@sisk.pl>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On 11/20/2011 03:27 AM, Rafael J. Wysocki wrote:
> On Thursday, November 17, 2011, Srivatsa S. Bhat wrote:
>> The lock_system_sleep() function is used in the memory hotplug code at
>> several places in order to implement mutual exclusion with hibernation.
>> However, this function tries to acquire the 'pm_mutex' lock using
>> mutex_lock() and hence blocks in TASK_UNINTERRUPTIBLE state if it doesn't
>> get the lock. This would lead to task freezing failures and hence
>> hibernation failure as a consequence, even though the hibernation call path
>> successfully acquired the lock.
>>
>> This patch fixes this issue by modifying lock_system_sleep() to use
>> mutex_trylock() in a loop until the lock is acquired, instead of using
>> mutex_lock(), in order to avoid going to uninterruptible sleep.
>> Also, we use msleep() to avoid busy looping and breaking expectations
>> that we go to sleep when we fail to acquire the lock.
>> And we also call try_to_freeze() in order to cooperate with the freezer,
>> without which we would end up in almost the same situation as mutex_lock(),
>> due to uninterruptible sleep caused by msleep().
>>
>> v3: Tejun suggested avoiding busy-looping by adding an msleep() since
>>     it is not guaranteed that we will get frozen immediately.
>>
>> v2: Tejun pointed problems with using mutex_lock_interruptible() in a
>>     while loop, when signals not related to freezing are involved.
>>     So, replaced it with mutex_trylock().
>>
>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>> ---
>>
>>  include/linux/suspend.h |   37 ++++++++++++++++++++++++++++++++++++-
>>  1 files changed, 36 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/suspend.h b/include/linux/suspend.h
>> index 57a6924..0af3048 100644
>> --- a/include/linux/suspend.h
>> +++ b/include/linux/suspend.h
>> @@ -5,6 +5,8 @@
>>  #include <linux/notifier.h>
>>  #include <linux/init.h>
>>  #include <linux/pm.h>
>> +#include <linux/freezer.h>
>> +#include <linux/delay.h>
>>  #include <linux/mm.h>
>>  #include <asm/errno.h>
>>  
>> @@ -380,7 +382,40 @@ static inline void unlock_system_sleep(void) {}
>>  
>>  static inline void lock_system_sleep(void)
>>  {
>> -	mutex_lock(&pm_mutex);
>> +	/*
>> +	 * "To sleep, or not to sleep, that is the question!"
>> +	 *
>> +	 * We should not use mutex_lock() here because, in case we fail to
>> +	 * acquire the lock, it would put us to sleep in TASK_UNINTERRUPTIBLE
>> +	 * state, which would lead to task freezing failures. As a
>> +	 * consequence, hibernation would fail (even though it had acquired
>> +	 * the 'pm_mutex' lock).
>> +	 * Using mutex_lock_interruptible() in a loop is not a good idea,
>> +	 * because we could end up treating non-freezing signals badly.
>> +	 * So we use mutex_trylock() in a loop instead.
>> +	 *
>> +	 * Also, we add try_to_freeze() to the loop, to co-operate with the
>> +	 * freezer, to avoid task freezing failures due to busy-looping.
>> +	 *
>> +	 * But then, since it is not guaranteed that we will get frozen
>> +	 * rightaway, we could keep spinning for some time, breaking the
>> +	 * expectation that we go to sleep when we fail to acquire the lock.
>> +	 * So we add an msleep() to the loop, to dampen the spin (but we are
>> +	 * careful enough not to sleep for too long at a stretch, lest the
>> +	 * freezer whine and give up again!).
>> +	 *
>> +	 * Now that we no longer busy-loop, try_to_freeze() becomes all the
>> +	 * more important, due to a subtle reason: if we don't cooperate with
>> +	 * the freezer at this point, we could end up in a situation very
>> +	 * similar to mutex_lock() due to the usage of msleep() (which sleeps
>> +	 * uninterruptibly).
>> +	 *
>> +	 * Phew! What a delicate balance!
>> +	 */
>> +	while (!mutex_trylock(&pm_mutex)) {
>> +		try_to_freeze();
>> +		msleep(10);
> 
> The number here seems to be somewhat arbitrary.  Is there any reason not to
> use 100 or any other number?
> 

Short answer:

The number is not arbitrary. It is designed to match the frequency at which
the freezer re-tries to freeze tasks in a loop for 20 seconds (after which
it gives up).

Long answer:

Let us define 'time-to-freeze-this-task' as the duration of time between the
setting of TIF_FREEZE flag for this task (after the task enters the while
loop in this patch) and the time at which this task is considered frozen
by the freezer.

There are 2 constraints we are trying to handle here:

[And let us see extreme case solutions for these constraints, to start with]

1. We want task freezing to be fast, to make hibernation fast.
Hence, we don't want to use msleep() here at all, just the
try_to_freeze() within the while loop would fit well.

2. As Tejun suggested, considering that we might not get frozen immediately,
we don't want to hurt cpu power management during that time. So, we
want to sleep when possible. Which means we can sleep for ~20 seconds at a
stretch and still manage to prevent freezing failures.

But obviously we need to strike a balance between these 2 contradictions.
Hence, we observe that the freezer goes in a loop and tries to freeze
tasks, and waits for 10ms before retrying (and continues this procedure
for 20 seconds).

Since we want time-to-freeze-this-task as small as possible, we have to
minimize the number of iterations the freezer does waiting for us.
Hence we choose to sleep for 10ms, which means, in the worst case,
our time-to-freeze-task will be one iteration of the freezer, IOW 10ms.
[That way, actually sleeping for 9ms would do best, but we probably don't
want to get that specific here, or should we?]

I think I have given a slight hint about this issue in the comment as well...

I prefer not to #define 10 and use it in freezer's loop and in this above
msleep() because, good design means, "Keep the freezer internals internal
to the freezer!". But all of us agree that this patch is only a temporary
hack (which unfortunately needs to know about freezer's internal working)..
and also that, we need to fix this whole issue at a design level sooner
or later.
So having 10ms msleep(), as well as hard-coding this value here, are both
justified, IMHO.

As for the comment, I don't know if I should be expanding that "slight hint"
into a full-fledged explanation, since Tejun is already complaining about
its verbosity ;-)

By the way, for somebody who is looking from a purely memory-hotplug point
of view and is not that familiar with the freezer, the "slight hint" in
the comment "careful enough not to sleep for too long at a stretch...
freezing failure..." is supposed to be interpreted as : "Oh when does
freezing fail? Let me look up the freezer code.. ah, 20 seconds.
By the way, I spot a 10ms sleep in the freezer loop as well..
Oh yes, *now* it all makes sense!" :-)

Or perhaps, adding the same justification I gave above (about the 10ms
sleep) to the changelog should do, right?

>> +	}
>>  }
>>  
>>  static inline void unlock_system_sleep(void)
> 

Thanks,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
