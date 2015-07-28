Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id BF57A6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 13:37:47 -0400 (EDT)
Received: by ykax123 with SMTP id x123so102048477yka.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:37:47 -0700 (PDT)
Received: from mail-yk0-x234.google.com (mail-yk0-x234.google.com. [2607:f8b0:4002:c07::234])
        by mx.google.com with ESMTPS id l124si16034809ywb.21.2015.07.28.10.37.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 10:37:47 -0700 (PDT)
Received: by ykfw194 with SMTP id w194so101920510ykf.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:37:47 -0700 (PDT)
Date: Tue, 28 Jul 2015 13:37:44 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 08/14] rcu: Convert RCU gp kthreads into kthread
 worker API
Message-ID: <20150728173744.GE5322@mtj.duckdns.org>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-9-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438094371-8326-9-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 28, 2015 at 04:39:25PM +0200, Petr Mladek wrote:
...
> -static int __noreturn rcu_gp_kthread(void *arg)
> +static void rcu_gp_kthread_func(struct kthread_work *work)
>  {
>  	int fqs_state;
>  	int gf;
>  	unsigned long j;
>  	int ret;
> -	struct rcu_state *rsp = arg;
> +	struct rcu_state *rsp = container_of(work, struct rcu_state, gp_work);
>  	struct rcu_node *rnp = rcu_get_root(rsp);
>  
> -	rcu_bind_gp_kthread();
> +	/* Handle grace-period start. */
>  	for (;;) {
> +		trace_rcu_grace_period(rsp->name,
> +				       READ_ONCE(rsp->gpnum),
> +				       TPS("reqwait"));
> +		rsp->gp_state = RCU_GP_WAIT_GPS;
> +		wait_event_interruptible(rsp->gp_wq,
> +					 READ_ONCE(rsp->gp_flags) &
> +					 RCU_GP_FLAG_INIT);

Same here.  Why not convert the waker into a queueing event?

> +		/* Locking provides needed memory barrier. */
> +		if (rcu_gp_init(rsp))
> +			break;
> +		cond_resched_rcu_qs();
> +		WRITE_ONCE(rsp->gp_activity, jiffies);
> +		WARN_ON(signal_pending(current));
> +		trace_rcu_grace_period(rsp->name,
> +				       READ_ONCE(rsp->gpnum),
> +				       TPS("reqwaitsig"));
> +	}

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
