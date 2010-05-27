Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 58EE36B01B2
	for <linux-mm@kvack.org>; Thu, 27 May 2010 14:35:01 -0400 (EDT)
Date: Thu, 27 May 2010 20:33:19 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100527183319.GA22313@redhat.com>
References: <20100527180431.GP13035@uudg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100527180431.GP13035@uudg.org>
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On 05/27, Luis Claudio R. Goncalves wrote:
>
> It sounds plausible giving the dying task an even higher priority to be
> sure it will be scheduled sooner and free the desired memory.

As usual, I can't really comment the changes in oom logic, just minor
nits...

> @@ -413,6 +415,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
>  	 */
>  	p->rt.time_slice = HZ;
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
> +	param.sched_priority = MAX_RT_PRIO-1;
> +	sched_setscheduler(p, SCHED_FIFO, &param);
>
>  	force_sig(SIGKILL, p);

Probably sched_setscheduler_nocheck() makes more sense.

Minor, but perhaps it would be a bit better to send SIGKILL first,
then raise its prio.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
