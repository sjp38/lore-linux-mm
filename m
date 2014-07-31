Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DD8216B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 01:37:50 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so2915507pad.35
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 22:37:50 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ma10si2312489pdb.461.2014.07.30.22.37.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jul 2014 22:37:50 -0700 (PDT)
Message-ID: <53D9D628.5050800@codeaurora.org>
Date: Thu, 31 Jul 2014 11:07:44 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] ksm: Provide support to use deferrable timers
 for scanner thread
References: <1406299698-6357-1-git-send-email-cpandya@codeaurora.org>	<1406299698-6357-2-git-send-email-cpandya@codeaurora.org> <20140730144752.8c931d9ed997324632d5f2fd@linux-foundation.org>
In-Reply-To: <20140730144752.8c931d9ed997324632d5f2fd@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tglx@linutronix.de, john.stultz@linaro.org, peterz@infradead.org, mingo@redhat.com, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/31/2014 03:17 AM, Andrew Morton wrote:
> On Fri, 25 Jul 2014 20:18:18 +0530 Chintan Pandya<cpandya@codeaurora.org>  wrote:
>
>> KSM thread to scan pages is scheduled on definite timeout. That wakes
>> up CPU from idle state and hence may affect the power consumption.
>> Provide an optional support to use deferrable timer which suites
>> low-power use-cases.
>>
>> Typically, on our setup we observed, 10% less power consumption with
>> some use-cases in which CPU goes to power collapse frequently. For
>> example, playing audio while typically CPU remains idle.
>>
>> To enable deferrable timers,
>> $ echo 1>  /sys/kernel/mm/ksm/deferrable_timer
>
> This could not have been the version which you tested.  What's up?

My bad :( I will be careful next time
>
> --- a/mm/ksm.c~ksm-provide-support-to-use-deferrable-timers-for-scanner-thread-fix-fix-2
> +++ a/mm/ksm.c
> @@ -1720,8 +1720,6 @@ static int ksmd_should_run(void)
>
>   static int ksm_scan_thread(void *nothing)
>   {
> -	signed long to;
> -
>   	set_freezable();
>   	set_user_nice(current, 5);
>
> @@ -1735,7 +1733,9 @@ static int ksm_scan_thread(void *nothing
>   		try_to_freeze();
>
>   		if (ksmd_should_run()) {
> -			timeout = msecs_to_jiffies(ksm_thread_sleep_millisecs);
> +			signed long to;
> +
> +			to = msecs_to_jiffies(ksm_thread_sleep_millisecs);
>   			if (use_deferrable_timer)
>   				schedule_timeout_deferrable_interruptible(to);
>   			else
> _
>


-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
