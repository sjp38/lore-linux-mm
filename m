Message-ID: <485A806A.2090602@goop.org>
Date: Thu, 19 Jun 2008 08:51:06 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [BUG][PATCH -mm] avoid BUG() in __stop_machine_run()
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <485A03E6.2090509@hitachi.com> <200806192012.44459.rusty@rustcorp.com.au>
In-Reply-To: <200806192012.44459.rusty@rustcorp.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, sugita <yumiko.sugita.yf@hitachi.com>, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Rusty Russell wrote:
> On Thursday 19 June 2008 16:59:50 Hidehiro Kawai wrote:
>   
>> When a process loads a kernel module, __stop_machine_run() is called, and
>> it calls sched_setscheduler() to give newly created kernel threads highest
>> priority.  However, the process can have no CAP_SYS_NICE which required
>> for sched_setscheduler() to increase the priority.  For example, SystemTap
>> loads its module with only CAP_SYS_MODULE.  In this case,
>> sched_setscheduler() returns -EPERM, then BUG() is called.
>>     
>
> Hi Hidehiro,
>
> 	Nice catch.  This can happen in the current code, it just doesn't
> BUG().
>
>   
>> Failure of sched_setscheduler() wouldn't be a real problem, so this
>> patch just ignores it.
>>     
>
> 	Well, it can mean that the stop_machine blocks indefinitely.  Better
> than a BUG(), but we should aim higher.
>
>   
>> Or, should we give the CAP_SYS_NICE capability temporarily?
>>     
>
>         I don't think so.  It can be seen from another thread, and in theory
> that should not see something random.  Worse, they can change it from
> another thread.
>
> How's this?
>
> sched_setscheduler: add a flag to control access checks
>
> Hidehiro Kawai noticed that sched_setscheduler() can fail in
> stop_machine: it calls sched_setscheduler() from insmod, which can
> have CAP_SYS_MODULE without CAP_SYS_NICE.
>
> This simply introduces a flag to allow us to disable the capability
> checks for internal callers (this is simpler than splitting the
> sched_setscheduler() function, since it loops checking permissions).
>   
What about?

int sched_setscheduler(struct task_struct *p, int policy,
		       struct sched_param *param)
{
	return __sched_setscheduler(p, policy, param, true);
}


int sched_setscheduler_nocheck(struct task_struct *p, int policy,
		               struct sched_param *param)
{
	return __sched_setscheduler(p, policy, param, false);
}


(With the appropriate transformation of sched_setscheduler -> __)

Better than scattering stray true/falses around the code.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
