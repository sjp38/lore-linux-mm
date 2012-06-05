Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8C5DD6B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 11:06:05 -0400 (EDT)
Date: Tue, 5 Jun 2012 09:30:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/5] vmstat: Implement refresh_vm_stats()
In-Reply-To: <1338553446-22292-1-git-send-email-anton.vorontsov@linaro.org>
Message-ID: <alpine.DEB.2.00.1206050921050.26490@router.home>
References: <20120601122118.GA6128@lizard> <1338553446-22292-1-git-send-email-anton.vorontsov@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, 1 Jun 2012, Anton Vorontsov wrote:

> This function forcibly flushes per-cpu vmstat diff counters to the
> global counters.

Why is it necessary to have a function that does not expire the pcps? Is
that side effect important? We use refresh_vm_cpu_stats(cpu) in
page_alloc.c already to flush the vmstat counters. Is the flushing of the
pcps in 2 seconds insteads of 3 once really that important?

Also if we do this

Can we therefore also name the function in a different way like

	flush_vmstats()


> @@ -456,11 +457,15 @@ void refresh_cpu_vm_stats(int cpu)
>  				local_irq_restore(flags);
>  				atomic_long_add(v, &zone->vm_stat[i]);
>  				global_diff[i] += v;
> +				if (!drain_pcp)
> +					continue;
>  #ifdef CONFIG_NUMA
>  				/* 3 seconds idle till flush */
>  				p->expire = 3;
>  #endif

Erm. This should be

#ifdef CONFIG_NUMA
	if (drain_pcp)
		p->expire = 3;
#endif

The construct using "continue" is weird.


>  			}
> +		if (!drain_pcp)
> +			continue;
>  		cond_resched();
>  #ifdef CONFIG_NUMA
>  		/*
> @@ -495,6 +500,21 @@ void refresh_cpu_vm_stats(int cpu)
>  			atomic_long_add(global_diff[i], &vm_stat[i]);
>  }
>
> +void refresh_cpu_vm_stats(int cpu)
> +{
> +	__refresh_cpu_vm_stats(cpu, 1);
> +}

Fold __refresh_cpu_vm_stats into this function and modify the caller
of refresh_cpu_vm_stats instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
