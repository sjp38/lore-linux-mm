Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 802EA6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:01:21 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so8095170pad.28
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:01:21 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id qm7si83005pbc.178.2014.09.11.01.01.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 01:01:20 -0700 (PDT)
Message-ID: <541156C9.1080203@codeaurora.org>
Date: Thu, 11 Sep 2014 13:31:13 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers
 for scanner thread
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org> <1408536628-29379-2-git-send-email-cpandya@codeaurora.org> <alpine.LSU.2.11.1408272258050.10518@eggly.anvils> <20140903095815.GK4783@worktop.ger.corp.intel.com> <alpine.LSU.2.11.1409080023100.1610@eggly.anvils> <20140908093949.GZ6758@twins.programming.kicks-ass.net> <alpine.LSU.2.11.1409091225310.8432@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1409091225310.8432@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

I don't mean to divert the thread too much. But just one suggestion 
offered by Harshad.

Why can't we stop invoking more of a KSM scanner thread when we are 
saturating from savings ? But again, to check whether savings are 
saturated or not, we may still want to rely upon timers and we have to 
wake the CPUs up from IDLE state.

>> here. Can't we create a new (timer) infrastructure that does the right
>> thing? Surely this isn't the only such case.
>
> A sleep-walking timer, that goes to sleep in one bed, but may wake in
> another; and defers while beds are empty?  I'd be happy to try using
> that for KSM if it already existed, and no doubt Chintan would too

This is interesting for sure :)

>
> But I don't think KSM presents a very good case for developing it.
> I think KSM's use of a sleep_millisecs timer is really just an apology
> for the amount of often wasted work that it does, and dates from before
> we niced it down 5.  I prefer the idea of a KSM which waits on activity
> amongst the restricted set of tasks it is tracking: as this patch tries.
>
> But my preference may be naive: doing lots of unnecessary work doesn't
> matter as much as waking cpus from deep sleep.

This is exactly the preference we are looking for. But yes, cannot be 
generalized for all.

>
>>
>> I know both RCU and some NOHZ_FULL muck already track when the system is
>> completely idle. This is yet another case of that.
>
> Hugh


-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
