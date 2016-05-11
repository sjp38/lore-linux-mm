Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0257C6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 08:20:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so40713600wmw.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 05:19:59 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id um4si9026985wjc.139.2016.05.11.05.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 05:19:58 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r12so9091059wme.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 05:19:58 -0700 (PDT)
Date: Wed, 11 May 2016 14:19:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmstat: Get rid of the ugly cpu_stat_off variable V2
Message-ID: <20160511121957.GK16677@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1605061306460.17934@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1605061306460.17934@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Fri 06-05-16 13:09:49, Christoph Lameter wrote:
> The cpu_stat_off variable is unecessary since we can check if
> a workqueue request is pending otherwise. Removal of
> cpu_stat_off makes it pretty easy for the vmstat shepherd to
> ensure that the proper things happen.

OK, this looks good to me. It is racy ...

vmstat_shepherd						vmstat_update
  delayed_work_pending() # false
  need_update()						  refresh_cpu_vm_stats()
  queue_delayed_work_on()				  queue_delayed_work_on()

... but it doesn't matter because queue_delayed_work_on is a noop
if the work is already queued.

> Removing the state also removes all races related to it.

Do we have any races left? I do not see any.

> Should a workqueue not be scheduled as needed for vmstat_update
> then the shepherd will notice and schedule it as needed.
> Should a workqueue be unecessarily scheduled then the vmstat
> updater will disable it.

The code simplification is really nice!

> V1->V2:
>  - Rediff to proper upstream version
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Michal Hocko <mhocko@suse.com>

A nit below

> @@ -1475,20 +1454,11 @@ static void vmstat_shepherd(struct work_
> 
>  	get_online_cpus();
>  	/* Check processors whose vmstat worker threads have been disabled */
> -	for_each_cpu(cpu, cpu_stat_off) {
> +	for_each_online_cpu(cpu) {
>  		struct delayed_work *dw = &per_cpu(vmstat_work, cpu);
> 
> -		if (need_update(cpu)) {
> -			if (cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
> +		if (!delayed_work_pending(dw) && need_update(cpu))
>  				queue_delayed_work_on(cpu, vmstat_wq, dw, 0);

Indentation here...

> -		} else {
> -			/*
> -			 * Cancel the work if quiet_vmstat has put this
> -			 * cpu on cpu_stat_off because the work item might
> -			 * be still scheduled
> -			 */
> -			cancel_delayed_work(dw);
> -		}
>  	}
>  	put_online_cpus();
> 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
