Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 368756B0055
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 10:52:20 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id ft15so7090975pdb.18
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 07:52:19 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id k17si23679271pdj.114.2014.09.09.07.52.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 07:52:19 -0700 (PDT)
Message-ID: <540F141B.9060603@codeaurora.org>
Date: Tue, 09 Sep 2014 20:22:11 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers
 for scanner thread
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org> <1408536628-29379-2-git-send-email-cpandya@codeaurora.org> <alpine.LSU.2.11.1408272258050.10518@eggly.anvils> <20140903095815.GK4783@worktop.ger.corp.intel.com> <alpine.LSU.2.11.1409080023100.1610@eggly.anvils> <20140908093949.GZ6758@twins.programming.kicks-ass.net>
In-Reply-To: <20140908093949.GZ6758@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

Hello All,

Before its too late to discuss this basic question, allow me to share my 
view on the deferrable timer approach.

I believe KSM at this point is tunable with predictable outcomes. When 
it will get triggered, how many pages it will scan etc. This aggression 
control is with user who can implement any complex logic based on its 
own flashy parameters. Along the same line, I was seeing this deferrable 
timer knob.

Here I was hoping the same level of predictability with this knob. 
Kernel still won't do smart work and user is free to play smart/complex 
with the knob. I believe that there are many use-cases where a single 
strategy of "to make KSM perform better while saving power at the same 
time" may not work. So,


> On Mon, Sep 08, 2014 at 01:25:36AM -0700, Hugh Dickins wrote:
>> Well, yes, but... how do we know when there is no more work to do?
>
> Yeah, I figured that out _after_ I send that email..
>
>> Thomas has given reason why KSM might simply fail to do its job if we
>> rely on the deferrable timer.

With deferrable timer, KSM thread will be scheduled on the 'active' CPU 
at that very same time. Yes, I understood from Thomas's clarification 
that if that very CPU goes IDLE, KSM task will get deferred even if at 
the timeout, we have some CPUs running. I think, this situation can be 
avoided potentially very small timeout value (?). But in totality, this 
is where KSM will be idle for sure, may be that is unwanted.

>>
>> Chintan, even if the scheduler guys turn out to hate it, please would
>> you give the patch below a try, to see how well it works in your
>> environment, whether it seems to go better or worse than your own patch.
>>
>> If it works well enough for you, maybe we can come up with ideas to
>> make it more palatable.  I do think your issue is an important one
>> to fix, one way or another.

It is taking a little more time for me to grasp your change :) So, after 
Peter's comment, do you want me to try this out or you are looking 
forward for even better idea ? BTW, if deferrable timer patch gets any 
green signal, I will publish new patch with your comments on v4.

>>
>> Thanks,
>> Hugh
>>
>> [PATCH] ksm: avoid periodic wakeup while mergeable mms are quiet
>>
>> Description yet to be written!
>>
>> Reported-by: Chintan Pandya<cpandya@codeaurora.org>
>> Not-Signed-off-by: Hugh Dickins<hughd@google.com>


 >>> So looking at Hughs test results I'm quite sure that the deferrable
 >>> timer is just another tunable bandaid with dubious value and the
 >>> potential of predictable bug/regresssion reports.

Here I am naive in understanding the obvious disadvantages of 'one more 
knob'. And hence was inclined towards deferrable timer knob. Thomas, 
could you explain what kind of bug/regression you foresee with such 
approach ?

-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
