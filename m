Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9FD6280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 02:34:19 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id c9so7852539plr.10
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 23:34:19 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e1si4239726plt.833.2018.01.16.23.34.17
        for <linux-mm@kvack.org>;
        Tue, 16 Jan 2018 23:34:18 -0800 (PST)
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to load
 balance console writes
From: Byungchul Park <byungchul.park@lge.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
Message-ID: <9f0ef69d-49e7-abf1-2f61-5f0f44ffcf7b@lge.com>
Date: Wed, 17 Jan 2018 16:34:14 +0900
MIME-Version: 1.0
In-Reply-To: <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 1/17/2018 11:19 AM, Byungchul Park wrote:
> On 1/10/2018 10:24 PM, Petr Mladek wrote:
>> From: Steven Rostedt <rostedt@goodmis.org>
>>
>> From: Steven Rostedt (VMware) <rostedt@goodmis.org>
>>
>> This patch implements what I discussed in Kernel Summit. I added
>> lockdep annotation (hopefully correctly), and it hasn't had any splats
>> (since I fixed some bugs in the first iterations). It did catch
>> problems when I had the owner covering too much. But now that the owner
>> is only set when actively calling the consoles, lockdep has stayed
>> quiet.
>>
>> Here's the design again:
>>
>> I added a "console_owner" which is set to a task that is actively
>> writing to the consoles. It is *not* the same as the owner of the
>> console_lock. It is only set when doing the calls to the console
>> functions. It is protected by a console_owner_lock which is a raw spin
>> lock.
>>
>> There is a console_waiter. This is set when there is an active console
>> owner that is not current, and waiter is not set. This too is protected
>> by console_owner_lock.
>>
>> In printk() when it tries to write to the consoles, we have:
>>
>> A A A A if (console_trylock())
>> A A A A A A A  console_unlock();
>>
>> Now I added an else, which will check if there is an active owner, and
>> no current waiter. If that is the case, then console_waiter is set, and
>> the task goes into a spin until it is no longer set.
>>
>> When the active console owner finishes writing the current message to
>> the consoles, it grabs the console_owner_lock and sees if there is a
>> waiter, and clears console_owner.
>>
>> If there is a waiter, then it breaks out of the loop, clears the waiter
>> flag (because that will release the waiter from its spin), and exits.
>> Note, it does *not* release the console semaphore. Because it is a
>> semaphore, there is no owner. Another task may release it. This means
>> that the waiter is guaranteed to be the new console owner! Which it
>> becomes.
>>
>> Then the waiter calls console_unlock() and continues to write to the
>> consoles.
>>
>> If another task comes along and does a printk() it too can become the
>> new waiter, and we wash rinse and repeat!
>>
>> By Petr Mladek about possible new deadlocks:
>>
>> The thing is that we move console_sem only to printk() call
>> that normally calls console_unlock() as well. It means that
>> the transferred owner should not bring new type of dependencies.
>> As Steven said somewhere: "If there is a deadlock, it was
>> there even before."
>>
>> We could look at it from this side. The possible deadlock would
>> look like:
>>
>> CPU0A A A A A A A A A A A A A A A A A A A A A A A A A A A  CPU1
>>
>> console_unlock()
>>
>> A A  console_owner = current;
>>
>> A A A A A A A A A A A A A A A  spin_lockA()
>> A A A A A A A A A A A A A A A A A  printk()
>> A A A A A A A A A A A A A A A A A A A  spin = true;
>> A A A A A A A A A A A A A A A A A A A  while (...)
>>
>> A A A A  call_console_drivers()
>> A A A A A A  spin_lockA()
>>
>> This would be a deadlock. CPU0 would wait for the lock A.
>> While CPU1 would own the lockA and would wait for CPU0
>> to finish calling the console drivers and pass the console_sem
>> owner.
>>
>> But if the above is true than the following scenario was
>> already possible before:
>>
>> CPU0
>>
>> spin_lockA()
>> A A  printk()
>> A A A A  console_unlock()
>> A A A A A A  call_console_drivers()
>> A A A A spin_lockA()
>>
>> By other words, this deadlock was there even before. Such
>> deadlocks are prevented by using printk_deferred() in
>> the sections guarded by the lock A.
> 
> Hello,
> 
> I didn't see what you did, at the last version. You were
> tring to transfer the semaphore owner and make it taken
> over. I see.
> 
> But, what I mentioned last time is still valid. See below.
> 
>> Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
>> [pmladek@suse.com: Commit message about possible deadlocks]
>> ---
>> A  kernel/printk/printk.c | 108 
>> ++++++++++++++++++++++++++++++++++++++++++++++++-
>> A  1 file changed, 107 insertions(+), 1 deletion(-)
>>
>> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
>> index b9006617710f..7e6459abba43 100644
>> --- a/kernel/printk/printk.c
>> +++ b/kernel/printk/printk.c
>> @@ -86,8 +86,15 @@ EXPORT_SYMBOL_GPL(console_drivers);
>> A  static struct lockdep_map console_lock_dep_map = {
>> A A A A A  .name = "console_lock"
>> A  };
>> +static struct lockdep_map console_owner_dep_map = {
>> +A A A  .name = "console_owner"
>> +};
>> A  #endif
>> +static DEFINE_RAW_SPINLOCK(console_owner_lock);
>> +static struct task_struct *console_owner;
>> +static bool console_waiter;
>> +
>> A  enum devkmsg_log_bits {
>> A A A A A  __DEVKMSG_LOG_BIT_ON = 0,
>> A A A A A  __DEVKMSG_LOG_BIT_OFF,
>> @@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility, int 
>> level,
>> A A A A A A A A A A  * semaphore.A  The release will print out buffers and wake up
>> A A A A A A A A A A  * /dev/kmsg and syslog() users.
>> A A A A A A A A A A  */
>> -A A A A A A A  if (console_trylock())
>> +A A A A A A A  if (console_trylock()) {
>> A A A A A A A A A A A A A  console_unlock();
>> +A A A A A A A  } else {
>> +A A A A A A A A A A A  struct task_struct *owner = NULL;
>> +A A A A A A A A A A A  bool waiter;
>> +A A A A A A A A A A A  bool spin = false;
>> +
>> +A A A A A A A A A A A  printk_safe_enter_irqsave(flags);
>> +
>> +A A A A A A A A A A A  raw_spin_lock(&console_owner_lock);
>> +A A A A A A A A A A A  owner = READ_ONCE(console_owner);
>> +A A A A A A A A A A A  waiter = READ_ONCE(console_waiter);
>> +A A A A A A A A A A A  if (!waiter && owner && owner != current) {
>> +A A A A A A A A A A A A A A A  WRITE_ONCE(console_waiter, true);
>> +A A A A A A A A A A A A A A A  spin = true;
>> +A A A A A A A A A A A  }
>> +A A A A A A A A A A A  raw_spin_unlock(&console_owner_lock);
>> +
>> +A A A A A A A A A A A  /*
>> +A A A A A A A A A A A A  * If there is an active printk() writing to the
>> +A A A A A A A A A A A A  * consoles, instead of having it write our data too,
>> +A A A A A A A A A A A A  * see if we can offload that load from the active
>> +A A A A A A A A A A A A  * printer, and do some printing ourselves.
>> +A A A A A A A A A A A A  * Go into a spin only if there isn't already a waiter
>> +A A A A A A A A A A A A  * spinning, and there is an active printer, and
>> +A A A A A A A A A A A A  * that active printer isn't us (recursive printk?).
>> +A A A A A A A A A A A A  */
>> +A A A A A A A A A A A  if (spin) {
>> +A A A A A A A A A A A A A A A  /* We spin waiting for the owner to release us */
>> +A A A A A A A A A A A A A A A  spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
>> +A A A A A A A A A A A A A A A  /* Owner will clear console_waiter on hand off */
>> +A A A A A A A A A A A A A A A  while (READ_ONCE(console_waiter))
>> +A A A A A A A A A A A A A A A A A A A  cpu_relax();
>> +
>> +A A A A A A A A A A A A A A A  spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> 
> Why don't you move this over "while (READ_ONCE(console_waiter))" and
> right after acquire()?
> 
> As I said last time, only acquisitions between acquire() and release()
> are meaningful. Are you taking care of acquisitions within cpu_relax()?
> If so, leave it.

In addition, this way would be correct if you intended to use
cross-lock's map here, assuming cross-release alive..

But anyway this is just a typical acquire/release pair so we
don't usually use the pair in this way.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
