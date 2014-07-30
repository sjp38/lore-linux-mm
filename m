Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3F57A6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 23:03:41 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so697162pac.18
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 20:03:40 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id fx12si388615pdb.502.2014.07.29.20.03.39
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 20:03:40 -0700 (PDT)
Message-ID: <53D860DB.40806@cn.fujitsu.com>
Date: Wed, 30 Jul 2014 11:04:59 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V8
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <20140711132032.GB26045@localhost.localdomain> <alpine.DEB.2.11.1407110855030.25432@gentwo.org> <20140711135854.GD26045@localhost.localdomain> <alpine.DEB.2.11.1407111016040.26485@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1407111016040.26485@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On 07/11/2014 11:17 PM, Christoph Lameter wrote:
> On Fri, 11 Jul 2014, Frederic Weisbecker wrote:
> 
>>> Converted what? We still need to keep a cpumask around that tells us which
>>> processor have vmstat running and which do not.
>>>
>>
>> Converted to cpumask_var_t.
>>
>> I mean we spent dozens emails on that...
> 
> 
> Oh there is this outstanding fix, right.
> 
> 
> Subject: on demand vmstat: Do not open code alloc_cpumask_var
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c	2014-07-11 10:15:55.356856916 -0500
> +++ linux/mm/vmstat.c	2014-07-11 10:15:55.352856994 -0500
> @@ -1244,7 +1244,7 @@
>  #ifdef CONFIG_SMP
>  static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
>  int sysctl_stat_interval __read_mostly = HZ;
> -struct cpumask *cpu_stat_off;
> +cpumask_var_t cpu_stat_off;
> 
>  static void vmstat_update(struct work_struct *w)
>  {
> @@ -1338,7 +1338,8 @@
>  		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
>  			vmstat_update);
> 
> -	cpu_stat_off = kmalloc(cpumask_size(), GFP_KERNEL);
> +	if (!alloc_cpumask_var(&cpu_stat_off, GFP_KERNEL))
> +		BUG();

	BUG_ON(!alloc_cpumask_var(&cpu_stat_off, GFP_KERNEL));

>  	cpumask_copy(cpu_stat_off, cpu_online_mask);
> 
>  	schedule_delayed_work(&shepherd,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
