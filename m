Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA7576B025E
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 14:17:57 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so51221500pad.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 11:17:57 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0075.outbound.protection.outlook.com. [104.47.0.75])
        by mx.google.com with ESMTPS id k62si46261515pfb.69.2016.08.30.11.17.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 11:17:56 -0700 (PDT)
Subject: Re: [PATCH v14 04/14] task_isolation: add initial support
References: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
 <1470774596-17341-5-git-send-email-cmetcalf@mellanox.com>
 <20160811181132.GD4214@lerouge>
 <alpine.DEB.2.20.1608111349190.1644@east.gentwo.org>
 <c675d2b6-c380-2a3f-6d49-b5e8b48eae1f@mellanox.com>
 <20160830005550.GB32720@lerouge>
 <69cbe2bd-3d39-b3ae-2ebc-6399125fc782@mellanox.com>
 <20160830171003.GA14200@lerouge>
 <aea6b90e-4b43-302a-636f-36516f30f5d6@mellanox.com>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <107bd666-dbcf-7fa5-ff9c-f79358899712@mellanox.com>
Date: Tue, 30 Aug 2016 14:17:27 -0400
MIME-Version: 1.0
In-Reply-To: <aea6b90e-4b43-302a-636f-36516f30f5d6@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter
 Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 8/30/2016 1:36 PM, Chris Metcalf wrote:
>>> See the other thread with Peter Z for the longer discussion of this.
>>> At this point I'm leaning towards replacing the set_tsk_need_resched() with
>>>
>>>      set_current_state(TASK_INTERRUPTIBLE);
>>>      schedule();
>>>      __set_current_state(TASK_RUNNING);
>> I don't see how that helps. What will wake the thread up except a signal?
>
> The answer is that the scheduler will keep bringing us back to this
> point (either after running another runnable task if there is one,
> or else just returning to this point immediately without doing a
> context switch), and we will then go around the "prepare exit to
> userspace" loop and perhaps discover that enough time has gone
> by that the last dyntick interrupt has triggered and the kernel has
> quiesced the dynticks.  At that point we stop calling schedule()
> over and over and can return normally to userspace. 

Oops, you're right that if I set TASK_INTERRUPTIBLE, then if I call
schedule(), I never get control back.  So I don't want to do that.

I suppose I could do a schedule_timeout() here instead and try
to figure out how long to wait for the next dyntick.  But since we
don't expect anything else running on the core anyway, it seems
like we are probably working too hard at this point.  I don't think
it's worth it just to go into the idle task and (possibly) save some
power for a few microseconds.

The more I think about this, the more I think I am micro-optimizing
by trying to poke the scheduler prior to some external thing setting
need_resched, so I think the thing to do here is in fact, nothing.
I won't worry about rescheduling but will just continue going around
the prepare-exit-to-userspace loop until the last dyn tick fires.

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
