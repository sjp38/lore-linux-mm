Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 75369900002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:19:45 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so1237667wes.35
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:19:44 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id h16si4615620wjs.102.2014.07.11.08.19.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 08:19:44 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id f8so1567168wiw.11
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:19:43 -0700 (PDT)
Date: Fri, 11 Jul 2014 17:19:37 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: vmstat: On demand vmstat workers V8
Message-ID: <20140711151935.GE26045@localhost.localdomain>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>
 <20140711132032.GB26045@localhost.localdomain>
 <alpine.DEB.2.11.1407110855030.25432@gentwo.org>
 <20140711135854.GD26045@localhost.localdomain>
 <alpine.DEB.2.11.1407111016040.26485@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407111016040.26485@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Fri, Jul 11, 2014 at 10:17:41AM -0500, Christoph Lameter wrote:
> On Fri, 11 Jul 2014, Frederic Weisbecker wrote:
> 
> > > Converted what? We still need to keep a cpumask around that tells us which
> > > processor have vmstat running and which do not.
> > >
> >
> > Converted to cpumask_var_t.
> >
> > I mean we spent dozens emails on that...
> 
> 
> Oh there is this outstanding fix, right.
> 
> 
> Subject: on demand vmstat: Do not open code alloc_cpumask_var
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Thanks :)

Maybe just merge both? The whole looks good.


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
>  	cpumask_copy(cpu_stat_off, cpu_online_mask);
> 
>  	schedule_delayed_work(&shepherd,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
