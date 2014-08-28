Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id F1CAB6B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 02:04:09 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id at20so395628iec.33
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 23:04:09 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id r7si3053525icv.107.2014.08.27.23.04.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 23:04:09 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id r10so377265igi.4
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 23:04:08 -0700 (PDT)
Date: Wed, 27 Aug 2014 23:02:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers
 for scanner thread
In-Reply-To: <1408536628-29379-2-git-send-email-cpandya@codeaurora.org>
Message-ID: <alpine.LSU.2.11.1408272258050.10518@eggly.anvils>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org> <1408536628-29379-2-git-send-email-cpandya@codeaurora.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Hugh Dickins <hughd@google.com>

Sorry for holding you up, I'm slow. and needed to think about this more,

On Wed, 20 Aug 2014, Chintan Pandya wrote:

> KSM thread to scan pages is scheduled on definite timeout. That wakes up
> CPU from idle state and hence may affect the power consumption. Provide
> an optional support to use deferrable timer which suites low-power
> use-cases.
> 
> Typically, on our setup we observed, 10% less power consumption with some
> use-cases in which CPU goes to power collapse frequently. For example,
> playing audio on Soc which has HW based Audio encoder/decoder, CPU
> remains idle for longer duration of time. This idle state will save
> significant CPU power consumption if KSM don't wakes them up
> periodically.
> 
> Note that, deferrable timers won't be deferred if any CPU is active and
> not in IDLE state.
> 
> By default, deferrable timers is enabled. To disable deferrable timers,
> $ echo 0 > /sys/kernel/mm/ksm/deferrable_timer

I have now experimented.  And, much as I wanted to eliminate the
tunable, and just have deferrable timers on, I have come right back
to your original position.

I was impressed by how quiet ksmd goes when there's nothing much
happening on the machine; but equally, disappointed in how slow
it then is to fulfil the outstanding merge work.  I agree with your
original assessment, that not everybody will want deferrable timer,
the way it is working at present.

I expect that can be fixed, partly by doing more work on wakeup from
a deferred timer, according to how long it has been deferred; and
partly by not deferring on idle until two passes of the list have been
completed.  But that's easier said than done, and might turn out to
defeat deferring the timer in too many cases: a balance to be found.

I hope that you or I or another will find time to do that work soon,
maybe before 3.18 but likely not; but I think the advantage of your
option is too important to delay it further.  Once we are satisfied
with later improvements, then I would like to remove the tunable, or
at least default it to on.  But for now, the default should be off.

It's unclear whether I should still worry about ksmd's gross activity,
when the system is not actually idle, but all the activity is in non-
mergeable processes.  I'm ashamed of that hyper-activity, and still
think that fixing it would be better than using a deferrable timer -
deferring work (particularly intensive work of the kind which ksmd
does) until the system is otherwise busy, is not necessarily a good
strategy (too much work to do all at once).

But fixing that might require ksm hooks in hot locations where nobody
else would want them: I'm rather hoping we can strike a good enough
balance with your deferrable timer, that nobody will need any better.

So, with a few changes here and below, please add my
Acked-by: Hugh Dickins <hughd@google.com>
to patches 1 and 2, and resend to akpm - thank you!

Here (above), it's restore the text to V3's
To enable deferrable timer,
$ echo 1 > /sys/kernel/mm/ksm/deferrable_timer

> 
> Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> ---
> Changes:

Sorry, I'm asking for a V4-->V5 reversing V3-->V4!

> 
> V3-->V4:
> 	- Use deferrable timers by default
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
> 
>  Documentation/vm/ksm.txt |  6 ++++++
>  mm/ksm.c                 | 36 ++++++++++++++++++++++++++++++++++--
>  2 files changed, 40 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
> index f34a8ee..23e26c3 100644
> --- a/Documentation/vm/ksm.txt
> +++ b/Documentation/vm/ksm.txt
> @@ -87,6 +87,12 @@ pages_sharing    - how many more sites are sharing them i.e. how much saved
>  pages_unshared   - how many pages unique but repeatedly checked for merging
>  pages_volatile   - how many pages changing too fast to be placed in a tree
>  full_scans       - how many times all mergeable areas have been scanned
> +deferrable_timer - whether to use deferrable timers or not
> +                   e.g. "echo 1 > /sys/kernel/mm/ksm/deferrable_timer"
> +                   Default: 1 (means, we are using deferrable timers. Users
> +		   might want to clear deferrable_timer option if they want
> +		   ksm thread to wakeup CPU to carryout ksm activities thus
> +		   loosing on battery while gaining on memory savings.)

Please move this section to between the "sleep_millisecs" and
"merge_across_nodes" descriptions, separated from each by a blank line:

deferrable_timer - whether to save power by using a deferrable timer
                   e.g. "echo 1 > /sys/kernel/mm/ksm/deferrable_timer"
                   If set to 1, saves power by letting ksmd sleep for
                   longer than sleep_millisecs whenever the system is idle,
                   extending battery life but sometimes saving less memory.
                   Default: 0 (strict sleep timer as in earlier releases)
                   Warning: this default is likely to be changed to 1, and
                   deferrable_timer file then removed, in future releases.

>  
>  A high ratio of pages_sharing to pages_shared indicates good sharing, but
>  a high ratio of pages_unshared to pages_sharing indicates wasted effort.
> diff --git a/mm/ksm.c b/mm/ksm.c
> index fb75902..af90e30 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -223,6 +223,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
>  /* Milliseconds ksmd should sleep between batches */
>  static unsigned int ksm_thread_sleep_millisecs = 20;
>  
> +/* Boolean to indicate whether to use deferrable timer or not */
> +static bool use_deferrable_timer = 1;

s/ = 1//

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

I wonder what that "8" was for:
	return sprintf(buf, "%u\n", use_deferrable_timer);

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

It seems you misunderstood me, and never tested
$ echo 1 >/sys/kernel/mm/ksm/deferrable_timer
bash: echo: write error: Invalid argument

s/>=/>/

Or better, follow the rest of ksm.c's parsing, just
	if (err || enable > 1)
		return -EINVAL;

Thanks,
Hugh


> +		return -EINVAL;
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
