Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5F23F6B0254
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 19:23:48 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id g62so223336660wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 16:23:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 2si1044383wmt.25.2016.02.23.16.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 16:23:47 -0800 (PST)
Date: Tue, 23 Feb 2016 16:23:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] vmstat: Get rid of the ugly cpu_stat_off variable
Message-Id: <20160223162345.51f8494cb1484ad5cb7f8eab@linux-foundation.org>
In-Reply-To: <20160222181049.953663183@linux.com>
References: <20160222181040.553533936@linux.com>
	<20160222181049.953663183@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hannes@cmpxchg.org, mgorman@suse.de

On Mon, 22 Feb 2016 12:10:42 -0600 Christoph Lameter <cl@linux.com> wrote:

> The cpu_stat_off variable is unecessary since we can check if
> a workqueue request is pending otherwise. This makes it pretty
> easy for the shepherd to ensure that the proper things happen.
> 
> Removing the state also removes all races related to it.
> Should a workqueue not be scheduled as needed for vmstat_update
> then the shepherd will notice and schedule it as needed.
> Should a workqueue be unecessarily scheduled then the vmstat
> updater will disable it.
> 
> Thus vmstat_idle can also be simplified.

I'm getting rather a lot of rejects from this one.

>  
> @@ -1436,11 +1426,8 @@ void quiet_vmstat(void)
>  	if (system_state != SYSTEM_RUNNING)
>  		return;
>  
> -	do {
> -		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
> -			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
> -
> -	} while (refresh_cpu_vm_stats(false));
> +	refresh_cpu_vm_stats(false);
> +	cancel_delayed_work(this_cpu_ptr(&vmstat_work));
>  }

I can't find a quiet_vmstat() which looks like this.  What tree are you
patching?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
