Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC846B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:13:12 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so3628796pdi.25
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 06:13:11 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id c9si2992797pds.195.2014.07.24.06.13.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 06:13:11 -0700 (PDT)
Message-ID: <53D10659.8080801@codeaurora.org>
Date: Thu, 24 Jul 2014 18:42:57 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: Provide support to use deferred timers for scanner
 thread
References: <1406106692-28590-1-git-send-email-cpandya@codeaurora.org> <20140723132130.68e0d8b7150f402546a3fae2@linux-foundation.org>
In-Reply-To: <20140723132130.68e0d8b7150f402546a3fae2@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lauraa@codeaurora.org

Thanks Andrew for reviewing. This is my first upstream patch :)

On 07/24/2014 01:51 AM, Andrew Morton wrote:
> On Wed, 23 Jul 2014 14:41:32 +0530 Chintan Pandya<cpandya@codeaurora.org>  wrote:
>
>> KSM thread to scan pages is getting schedule on definite timeout.
>> That wakes up CPU from idle state and hence may affect the power
>> consumption. Provide an optional support to use deferred timer
>> which suites low-power use-cases.
>
> Do you have any data on the effectiveness of this patch?  Because if it
> makes no useful difference, we shouldn't merge it!

Typically, we observed 10% less power consumption with some use-cases 
which in which CPU goes to power collapse frequently. For example, 
playing Audio on SoC where typically CPU is idle.

I will mention this in commit text also.
>
>> To enable deferred timers,
>> $ echo 1>  /sys/kernel/mm/ksm/deferred_timer
>
> It would be preferable to do this unconditionally (or automatically
> somehow) rather than adding yet another weird knob.

This has some trade-off. We have observed that KSM does maximum savings 
when system is idle. Where power is not concern but memory saving is, we 
may want KSM timer as non-deferrable. Considering that, I preferred to 
provide knob.
>
>> Signed-off-by: Chintan Pandya<cpandya@codeaurora.org>
>> ---
>>   Documentation/vm/ksm.txt |  7 ++++++
>>   mm/ksm.c                 | 65 +++++++++++++++++++++++++++++++++++++++++++++++-
>>   2 files changed, 71 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
>> index f34a8ee..f40b965 100644
>> --- a/Documentation/vm/ksm.txt
>> +++ b/Documentation/vm/ksm.txt
>> @@ -87,6 +87,13 @@ pages_sharing    - how many more sites are sharing them i.e. how much saved
>>   pages_unshared   - how many pages unique but repeatedly checked for merging
>>   pages_volatile   - how many pages changing too fast to be placed in a tree
>>   full_scans       - how many times all mergeable areas have been scanned
>> +deferred_timer   - whether to use deferred timers or not
>> +                 e.g. "echo 1>  /sys/kernel/mm/ksm/deferred_timer"
>> +                 Default: 0 (means, we are not using deferred timers. Users
>> +		 might want to set deferred_timer option if they donot want
>> +		 ksm thread to wakeup CPU to carryout ksm activities thus
>> +		 gaining on battery while compromising slightly on memory
>> +		 that could have been saved.)
>>
>>   A high ratio of pages_sharing to pages_shared indicates good sharing, but
>>   a high ratio of pages_unshared to pages_sharing indicates wasted effort.
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> index 346ddc9..e26ec3b 100644
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -223,6 +223,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
>>   /* Milliseconds ksmd should sleep between batches */
>>   static unsigned int ksm_thread_sleep_millisecs = 20;
>>
>> +/* Boolean to indicate whether to use deferred timer or not */
>> +static bool use_deferred_timer;
>> +
>>   #ifdef CONFIG_NUMA
>>   /* Zeroed when merging across nodes is not allowed */
>>   static unsigned int ksm_merge_across_nodes = 1;
>> @@ -1705,6 +1708,41 @@ static void ksm_do_scan(unsigned int scan_npages)
>>   	}
>>   }
>>
>> +static void process_timeout(unsigned long __data)
>> +{
>> +	wake_up_process((struct task_struct *)__data);
>> +}
>> +
>> +static signed long __sched deferred_schedule_timeout(signed long timeout)
>
> Should be called schedule_timeout_deferrable_interruptible() for
> consistency.
>
> And let's not start mixing "deferred" and "deferrable".

Sure. I will use schedule_timeout_deferrable_interruptible().

>
>> +{
>> +	struct timer_list timer;
>> +	unsigned long expire;
>> +
>> +	__set_current_state(TASK_INTERRUPTIBLE);
>> +	if (timeout<  0) {
>> +		pr_err("schedule_timeout: wrong timeout value %lx\n",
>
> 		^^^^^^^^^^^^^^^^ copy-n-paste?

My bad.

>> +							timeout);
>> +		__set_current_state(TASK_RUNNING);
>> +		goto out;
>> +	}
>> +
>> +	expire = timeout + jiffies;
>> +
>> +	setup_deferrable_timer_on_stack(&timer, process_timeout,
>> +			(unsigned long)current);
>> +	mod_timer(&timer, expire);
>> +	schedule();
>> +	del_singleshot_timer_sync(&timer);
>> +
>> +	/* Remove the timer from the object tracker */
>> +	destroy_timer_on_stack(&timer);
>> +
>> +	timeout = expire - jiffies;
>> +
>> +out:
>> +	return timeout<  0 ? 0 : timeout;
>> +}
>
> Methinks all this should be in kernel/timer.c (kernel/time/timer.c in
> linux-next).  And it should be documented.  That means a separate patch
> and review by Thomas Gleixner and probably others.

Ok. I will break this patch and upload again.

>
> I haven't looked, but I expect a lot of schedule_timeout() callsites
> could be converted to use such a thing.

 From our internal power experiments, we have seen only KSM waking up 
CPUs from sleep. Not sure about other use-cases. But an API would help all.

>
>>   static int ksmd_should_run(void)
>>   {
>>   	return (ksm_run&  KSM_RUN_MERGE)&&  !list_empty(&ksm_mm_head.mm_list);
>> @@ -1725,7 +1763,11 @@ static int ksm_scan_thread(void *nothing)
>>   		try_to_freeze();
>>
>>   		if (ksmd_should_run()) {
>> -			schedule_timeout_interruptible(
>> +			if (use_deferred_timer)
>> +				deferred_schedule_timeout(
>> +				msecs_to_jiffies(ksm_thread_sleep_millisecs));
>> +			else
>> +				schedule_timeout_interruptible(
>>   				msecs_to_jiffies(ksm_thread_sleep_millisecs));
>>   		} else {
>>   			wait_event_freezable(ksm_thread_wait,
>> @@ -2181,6 +2223,26 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
>>   }
>>   KSM_ATTR(run);
>>
>> +static ssize_t deferred_timer_show(struct kobject *kobj,
>> +				    struct kobj_attribute *attr, char *buf)
>> +{
>> +	return snprintf(buf, 8, "%d\n", use_deferred_timer);
>> +}
>> +
>> +static ssize_t deferred_timer_store(struct kobject *kobj,
>> +				     struct kobj_attribute *attr,
>> +				     const char *buf, size_t count)
>> +{
>> +	unsigned long enable;
>> +	int err;
>> +
>> +	err = kstrtoul(buf, 10,&enable);
>> +	use_deferred_timer = enable;
>
> We should check for legitimate values here.  ie: 0 or 1 only.

Ok.

>
>> +	return count;
>> +}
>> +KSM_ATTR(deferred_timer);
>> +
>>   #ifdef CONFIG_NUMA
>>   static ssize_t merge_across_nodes_show(struct kobject *kobj,
>>   				struct kobj_attribute *attr, char *buf)
>> @@ -2293,6 +2355,7 @@ static struct attribute *ksm_attrs[] = {
>>   	&pages_unshared_attr.attr,
>>   	&pages_volatile_attr.attr,
>>   	&full_scans_attr.attr,
>> +	&deferred_timer_attr.attr,
>>   #ifdef CONFIG_NUMA
>>   	&merge_across_nodes_attr.attr,
>>   #endif
>

I will re-share new patch set incorporating above comments, in some days.

-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
