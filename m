Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7606B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 08:08:49 -0400 (EDT)
Received: by obctp1 with SMTP id tp1so64677633obc.2
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:08:49 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ds10si11994089oeb.77.2015.10.23.05.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 05:08:48 -0700 (PDT)
Received: by pasz6 with SMTP id z6so117129546pas.2
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:08:47 -0700 (PDT)
Date: Fri, 23 Oct 2015 21:07:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: Make vmstat deferrable again (was Re: [PATCH] mm,vmscan: Use
 accurate values for zone_reclaimable() checks)
Message-ID: <20151023120728.GA462@swordfish>
References: <20151021145505.GE8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510221031090.24250@east.gentwo.org>
 <20151023083719.GD2410@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510230642210.5612@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.20.1510230642210.5612@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (10/23/15 06:43), Christoph Lameter wrote:
> Is this ok?

kernel/sched/loadavg.c: In function a??calc_load_enter_idlea??:
kernel/sched/loadavg.c:195:2: error: implicit declaration of function a??quiet_vmstata?? [-Werror=implicit-function-declaration]
  quiet_vmstat();
    ^

> Subject: Fix vmstat: make vmstat_updater deferrable again and shut down on idle
> 
> Currently the vmstat updater is not deferrable as a result of commit
> ba4877b9ca51f80b5d30f304a46762f0509e1635. This in turn can cause multiple
> interruptions of the applications because the vmstat updater may run at
> different times than tick processing. No good.
> 
> Make vmstate_update deferrable again and provide a function that
> shuts down the vmstat updater when we go idle by folding the differentials.
> Shut it down from the load average calculation logic introduced by nohz.
> 
> Note that the shepherd thread will continue scanning the differentials
> from another processor and will reenable the vmstat workers if it
> detects any changes.
> 
> Fixes: ba4877b9ca51f80b5d30f304a46762f0509e1635 (do not use deferrable delay)
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c
> +++ linux/mm/vmstat.c
> @@ -1395,6 +1395,20 @@ static void vmstat_update(struct work_st
>  }
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

shouldn't preemption be disable for smp_processor_id() here?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
