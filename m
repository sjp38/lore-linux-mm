Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 602D96B0038
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 11:44:37 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so12527866pac.18
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 08:44:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id go10si21456244pbd.184.2014.07.29.08.44.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 08:44:36 -0700 (PDT)
Message-ID: <53D7C11D.8050905@oracle.com>
Date: Tue, 29 Jul 2014 11:43:25 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V8
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <alpine.DEB.2.11.1407281353450.15405@gentwo.org> <20140729075637.GA19379@twins.programming.kicks-ass.net> <20140729120525.GA28366@mtj.dyndns.org> <20140729122303.GA3935@laptop> <20140729131226.GS7462@htj.dyndns.org> <alpine.DEB.2.11.1407291020470.21102@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1407291020470.21102@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

On 07/29/2014 11:22 AM, Christoph Lameter wrote:
> On Tue, 29 Jul 2014, Tejun Heo wrote:
> 
>> I'm not sure that's a viable way forward.  It's not like we can
>> readily trigger the problematic cases which can lead to long pauses
>> during cpu down.  Besides, we need the distinction at the API level,
>> which is the whole point of this.  The best way probably is converting
>> all the correctness ones (these are the minorities) over to
>> queue_work_on() so that the per-cpu requirement is explicit.
> 
> Ok so we would need this fix to avoid the message:
> 
> 
> Subject: vmstat: use schedule_delayed_work_on to avoid false positives
> 
> It seems that schedule_delayed_work_on will check for preemption even
> though none can occur. schedule_delayed_work_on will not do that. So
> use that function to suppress false positives.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c	2014-07-29 10:14:42.356988271 -0500
> +++ linux/mm/vmstat.c	2014-07-29 10:18:28.205920997 -0500
> @@ -1255,7 +1255,8 @@ static void vmstat_update(struct work_st
>  		 * to occur in the future. Keep on running the
>  		 * update worker thread.
>  		 */
> -		schedule_delayed_work(this_cpu_ptr(&vmstat_work),
> +		schedule_delayed_work_on(smp_processor_id(),
> +			this_cpu_ptr(&vmstat_work),
>  			round_jiffies_relative(sysctl_stat_interval));
>  	else {
>  		/*
> 

I've tested, and this patch doesn't fix neither of the bugs reported.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
