Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m9AALs3x179066
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 10:21:54 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9AALr432801700
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 11:21:53 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9AALk0F002792
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 11:21:47 +0100
Message-ID: <48EF2CB3.9040900@fr.ibm.com>
Date: Fri, 10 Oct 2008 12:21:39 +0200
From: Cedric Le Goater <clg@fr.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC v6][PATCH 3/9] x86 support for checkpoint/restart
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu> <1223461197-11513-4-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1223461197-11513-4-git-send-email-orenl@cs.columbia.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> +int cr_read_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
> +{
> +	struct thread_struct *thread = &t->thread;
> +
> +	/* i387 + MMU + SSE */
> +
> +	preempt_disable();
> +
> +	__clear_fpu(t);		/* in case we used FPU in user mode */
> +
> +	if (!hh->used_math)
> +		clear_used_math();
> +	else {
> +		if (hh->has_fxsr != cpu_has_fxsr) {
> +			force_sig(SIGFPE, t);
> +			return -EINVAL;
> +		}

don't you need an init_fpu() around here ? because the task you restart might 
not have used FPU yet.

> +		memcpy(&thread->xstate, &hh->xstate, sizeof(thread->xstate));

also i'd used 'xstate_size' instead of sizeof(thread->xstate)


thanks,

C.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
