Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 59F3A6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 18:31:20 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so54769558pac.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 15:31:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p23si23174507pfi.236.2015.12.10.15.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 15:31:19 -0800 (PST)
Date: Thu, 10 Dec 2015 15:31:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: vmstat: make vmstat_updater deferrable again and shut down on
 idle
Message-Id: <20151210153118.4f39d6a4f04c96189ce015c9@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org>
References: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp

On Thu, 10 Dec 2015 14:45:02 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:

> Currently the vmstat updater is not deferrable as a result of commit
> ba4877b9ca51f80b5d30f304a46762f0509e1635. This in turn can cause multiple
> interruptions of the applications because the vmstat updater may run at
> different times than tick processing. No good.
> 
> Make vmstate_update deferrable again and provide a function that
> folds the differentials when the processor is going to idle mode thus
> addressing the issue of the above commit in a clean way.
> 
> Note that the shepherd thread will continue scanning the differentials
> from another processor and will reenable the vmstat workers if it
> detects any changes.
> 
> Fixes: ba4877b9ca51f80b5d30f304a46762f0509e1635 (do not use deferrable delay)
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ...
>
>  /*
> + * Switch off vmstat processing and then fold all the remaining differentials
> + * until the diffs stay at zero. The function is used by NOHZ and can only be
> + * invoked when tick processing is not active.
> + */
> +void quiet_vmstat(void)
> +{
> +	do {
> +		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
> +			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
> +
> +	} while (refresh_cpu_vm_stats(false));
> +}

How do we know this will terminate in a reasonable amount of time if
other CPUs are pounding away?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
