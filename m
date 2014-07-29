Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id EF3FD6B0038
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 12:00:02 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id cm18so9534245qab.32
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 09:00:01 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTPS id t73si38383961qge.118.2014.07.29.08.59.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 08:59:58 -0700 (PDT)
Date: Tue, 29 Jul 2014 10:59:46 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <53D7C1F8.5040800@oracle.com>
Message-ID: <alpine.DEB.2.11.1407291057410.21390@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <alpine.DEB.2.11.1407281353450.15405@gentwo.org> <20140729075637.GA19379@twins.programming.kicks-ass.net> <20140729120525.GA28366@mtj.dyndns.org> <20140729122303.GA3935@laptop>
 <20140729131226.GS7462@htj.dyndns.org> <alpine.DEB.2.11.1407291009320.21102@gentwo.org> <20140729151415.GF4791@htj.dyndns.org> <alpine.DEB.2.11.1407291038160.21390@gentwo.org> <53D7C1F8.5040800@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

On Tue, 29 Jul 2014, Sasha Levin wrote:

> > Index: linux/mm/vmstat.c
> > ===================================================================
> > --- linux.orig/mm/vmstat.c	2014-07-29 10:22:45.073884943 -0500
> > +++ linux/mm/vmstat.c	2014-07-29 10:34:45.083369228 -0500
> > @@ -1277,8 +1277,8 @@ static int vmstat_cpuup_callback(struct
> >  		break;
> >  	case CPU_DOWN_PREPARE:
> >  	case CPU_DOWN_PREPARE_FROZEN:
> > -		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
> >  		per_cpu(vmstat_work, cpu).work.func = NULL;
> > +		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
> >  		break;
> >  	case CPU_DOWN_FAILED:
> >  	case CPU_DOWN_FAILED_FROZEN:
> >
>
> I'm slightly confused here. The on demand vmstat workers patch did this:
>
>         case CPU_DOWN_PREPARE_FROZEN:
> -               cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
> -               per_cpu(vmstat_work, cpu).work.func = NULL;
> +               if (!cpumask_test_and_set_cpu(cpu, cpu_stat_off))
> +                       cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
>
> So your new patch doesn't apply on top of it, and doesn't make sense before it.

Tejun was looking at upsteram and so I fixed upstream ;-)

Is it really necessary to set the work.func to NULL? If so then the
work.func will have to be initialized when a processor is brought online.

Canceling the work should be enough to disable the execution of the
function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
