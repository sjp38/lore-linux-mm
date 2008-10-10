Message-ID: <48EF2D5F.5010701@cs.columbia.edu>
Date: Fri, 10 Oct 2008 06:24:31 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v6][PATCH 3/9] x86 support for checkpoint/restart
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu> <1223461197-11513-4-git-send-email-orenl@cs.columbia.edu> <48EF2CB3.9040900@fr.ibm.com>
In-Reply-To: <48EF2CB3.9040900@fr.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>


Cedric Le Goater wrote:
>> +int cr_read_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
>> +{
>> +	struct thread_struct *thread = &t->thread;
>> +
>> +	/* i387 + MMU + SSE */
>> +
>> +	preempt_disable();
>> +
>> +	__clear_fpu(t);		/* in case we used FPU in user mode */
>> +
>> +	if (!hh->used_math)
>> +		clear_used_math();
>> +	else {
>> +		if (hh->has_fxsr != cpu_has_fxsr) {
>> +			force_sig(SIGFPE, t);
>> +			return -EINVAL;
>> +		}
> 
> don't you need an init_fpu() around here ? because the task you restart might 
> not have used FPU yet.
> 
>> +		memcpy(&thread->xstate, &hh->xstate, sizeof(thread->xstate));
> 
> also i'd used 'xstate_size' instead of sizeof(thread->xstate)
> 

Yes, that was broken, and already fixed in for next round.

Thanks,

Oren.

> 
> thanks,
> 
> C.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
