Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DC10360032A
	for <linux-mm@kvack.org>; Fri, 28 May 2010 00:33:47 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id o4S4XUQK016688
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:33:30 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4S4Xib3430272
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:33:44 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4S4XgfJ022117
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:33:43 +1000
Date: Fri, 28 May 2010 10:03:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100528043339.GZ3519@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100527180431.GP13035@uudg.org>
 <20100527183319.GA22313@redhat.com>
 <20100528090357.7DFB.A69D9226@jp.fujitsu.com>
 <20100528035147.GD11364@uudg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100528035147.GD11364@uudg.org>
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

* Luis Claudio R. Goncalves <lclaudio@uudg.org> [2010-05-28 00:51:47]:

> @@ -382,6 +382,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>   */
>  static void __oom_kill_task(struct task_struct *p, int verbose)
>  {
> +	struct sched_param param;
> +
>  	if (is_global_init(p)) {
>  		WARN_ON(1);
>  		printk(KERN_WARNING "tried to kill init!\n");
> @@ -413,8 +415,9 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
>  	 */
>  	p->rt.time_slice = HZ;
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
> -
>  	force_sig(SIGKILL, p);
> +	param.sched_priority = MAX_RT_PRIO-1;
> +	sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
>  }
>

I would like to understand the visible benefits of this patch. Have
you seen an OOM kill tasked really get bogged down. Should this task
really be competing with other important tasks for run time?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
