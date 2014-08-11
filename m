Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 32CF86B0037
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 08:19:49 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so10762519pdb.27
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 05:19:48 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id hr10si13344252pac.24.2014.08.11.05.19.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 05:19:48 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so10707792pdb.13
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 05:19:47 -0700 (PDT)
Date: Mon, 11 Aug 2014 05:18:01 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 2/2] ksm: provide support to use deferrable timers
 for scanner thread
In-Reply-To: <1406793591-26793-3-git-send-email-cpandya@codeaurora.org>
Message-ID: <alpine.LSU.2.11.1408110332350.1500@eggly.anvils>
References: <1406793591-26793-2-git-send-email-cpandya@codeaurora.org> <1406793591-26793-3-git-send-email-cpandya@codeaurora.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Hugh Dickins <hughd@google.com>

On Thu, 31 Jul 2014, Chintan Pandya wrote:

> KSM thread to scan pages is scheduled on definite timeout.  That wakes up
> CPU from idle state and hence may affect the power consumption.  Provide
> an optional support to use deferrable timer which suites low-power
> use-cases.

Thanks for drawing attention to this: anything to stop KSM from being
such a CPU hog while it's giving no value, should be welcome.

(I wonder if KSM could draw more feedback from its own success,
and slow down when nothing is happening on VM_MERGEABLE areas;
but I guess that's a slightly different topic from your concern
with not-quite-idle power consumption, I'd better not divert us.)

> 
> Typically, on our setup we observed, 10% less power consumption with some
> use-cases in which CPU goes to power collapse frequently.  For example,
> playing audio while typically CPU remains idle.

I'm probably stupid, but I don't quite get your scenario from that
description: please would you spell it out a little more clearly for me?

Are you thinking of two CPUs, one of them running a process busily
streaming audio (with no VM_MERGEABLE areas to work on), most other
processes sleeping, and ksmd "pinned" to another, otherwise idle CPU?

I'm very inexperienced in scheduler (and audio) matters, but I'd like
to think that the scheduler would migrate ksmd to the mostly busy CPU
in that case - or is it actually 100% busy, with no room for ksmd too?

kernel/sched/core.c shows the CONFIG_NO_HZ_COMMON get_nohz_timer_target(),
which looks like it would migrate it if possible (and CONFIG_NO_HZ_COMMON
appears to be more prevalent than CONFIG_NO_HZ_FULL).

> 
> To enable deferrable timers,
> $ echo 1 > /sys/kernel/mm/ksm/deferrable_timer

I do share Andrew's original reservations: I'd much prefer this if we
can just go ahead and do the deferrable timer without a new tunable
to concern the user, simple though your "deferrable_timer" knob is.

In an earlier mail, you said "We have observed that KSM does maximum
savings when system is idle", as reason why some will prefer a non-
deferrable timer.  I am somewhat suspicious of that observation:
because KSM waits for a page's checksum to stabilize before it saves
it in its "unstable" tree of pages to compare against.  So when the
rest of the system goes idle, KSM is briefly more likely to find
matches; but that may be a short-lived "success" once the system
becomes active again.  So, I'm wondering if your observation just
reflects the mechanics of KSM, and is not actually a reason to
refrain from using a deferrable timer for everyone.

On the other hand, I have a worry about using deferrable timer here.
I think I understand the value of a deferrable timer, in doing a job
which is bound to a particular cpu (mm/slab.c's cache_reap() gives
me a good example of that).  But ksmd is potentially serving every
process, every cpu: we would not want it to be deferred indefinitely,
if other cpus (running processes with VM_MERGEABLE vmas) are active.

Perhaps the likelihood of that scenario is too low; or perhaps it's
a reason why we do need to offer your "deferrable_timer" knob.

Please, I need to understand better before acking this change.

By the way: perhaps KSM is the right place to start, but please take
a look also at THP in mm/huge_memory.c, whose khugepaged was originally
modelled on ksmd (but now seems to be using wait_event_freezable_timeout
rather than schedule_timeout_interruptible - I've not yet researched the
history behind that difference).  I expect it to need the same treatment.

Hugh

> 
> Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> ---
> Changes:
> 
> V2-->V3:
> 	- Handled error case properly
> 	- Corrected indentation in Documentation
> 	- Fixed build failure
> 	- Removed left over process_timeout()
> V1-->V2:
> 	- allowing only valid values to be updated as use_deferrable_timer
> 	- using only 'deferrable' and not 'deferred'
> 	- moved out schedule_timeout code for deferrable timer into timer.c
> 
>  Documentation/vm/ksm.txt |  7 +++++++
>  mm/ksm.c                 | 36 ++++++++++++++++++++++++++++++++++--
>  2 files changed, 41 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
> index f34a8ee..9735c87 100644
> --- a/Documentation/vm/ksm.txt
> +++ b/Documentation/vm/ksm.txt
> @@ -87,6 +87,13 @@ pages_sharing    - how many more sites are sharing them i.e. how much saved
>  pages_unshared   - how many pages unique but repeatedly checked for merging
>  pages_volatile   - how many pages changing too fast to be placed in a tree
>  full_scans       - how many times all mergeable areas have been scanned
> +deferrable_timer - whether to use deferrable timers or not
> +                   e.g. "echo 1 > /sys/kernel/mm/ksm/deferrable_timer"
> +                   Default: 0 (means, we are not using deferrable timers. Users
> +		   might want to set deferrable_timer option if they donot want
> +		   ksm thread to wakeup CPU to carryout ksm activities thus
> +		   gaining on battery while compromising slightly on memory
> +		   that could have been saved.)
>  
>  A high ratio of pages_sharing to pages_shared indicates good sharing, but
>  a high ratio of pages_unshared to pages_sharing indicates wasted effort.
> diff --git a/mm/ksm.c b/mm/ksm.c
> index fb75902..434a50a 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -223,6 +223,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
>  /* Milliseconds ksmd should sleep between batches */
>  static unsigned int ksm_thread_sleep_millisecs = 20;
>  
> +/* Boolean to indicate whether to use deferrable timer or not */
> +static bool use_deferrable_timer;
> +
>  #ifdef CONFIG_NUMA
>  /* Zeroed when merging across nodes is not allowed */
>  static unsigned int ksm_merge_across_nodes = 1;
> @@ -1725,8 +1728,13 @@ static int ksm_scan_thread(void *nothing)
>  		try_to_freeze();
>  
>  		if (ksmd_should_run()) {
> -			schedule_timeout_interruptible(
> -				msecs_to_jiffies(ksm_thread_sleep_millisecs));
> +			signed long to;
> +
> +			to = msecs_to_jiffies(ksm_thread_sleep_millisecs);
> +			if (use_deferrable_timer)
> +				schedule_timeout_deferrable_interruptible(to);
> +			else
> +				schedule_timeout_interruptible(to);
>  		} else {
>  			wait_event_freezable(ksm_thread_wait,
>  				ksmd_should_run() || kthread_should_stop());
> @@ -2175,6 +2183,29 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
>  }
>  KSM_ATTR(run);
>  
> +static ssize_t deferrable_timer_show(struct kobject *kobj,
> +				    struct kobj_attribute *attr, char *buf)
> +{
> +	return snprintf(buf, 8, "%d\n", use_deferrable_timer);
> +}
> +
> +static ssize_t deferrable_timer_store(struct kobject *kobj,
> +				     struct kobj_attribute *attr,
> +				     const char *buf, size_t count)
> +{
> +	unsigned long enable;
> +	int err;
> +
> +	err = kstrtoul(buf, 10, &enable);
> +	if (err < 0)
> +		return err;
> +	if (enable >= 1)
> +		return -EINVAL;

I haven't studied the patch itself, I'm still worrying about the concept.
But this caught my eye just before hitting Send: I don't think we need
a tunable which only accepts the value 0 ;)

> +	use_deferrable_timer = enable;
> +	return count;
> +}
> +KSM_ATTR(deferrable_timer);
> +
>  #ifdef CONFIG_NUMA
>  static ssize_t merge_across_nodes_show(struct kobject *kobj,
>  				struct kobj_attribute *attr, char *buf)
> @@ -2287,6 +2318,7 @@ static struct attribute *ksm_attrs[] = {
>  	&pages_unshared_attr.attr,
>  	&pages_volatile_attr.attr,
>  	&full_scans_attr.attr,
> +	&deferrable_timer_attr.attr,
>  #ifdef CONFIG_NUMA
>  	&merge_across_nodes_attr.attr,
>  #endif
> -- 
> Chintan Pandya
> 
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
