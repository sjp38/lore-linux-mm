Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 736776B0253
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 12:12:12 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l65so269343586wmf.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 09:12:12 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id bf3si9450019wjc.85.2016.01.22.09.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 09:12:11 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id b14so142582114wmb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 09:12:10 -0800 (PST)
Date: Fri, 22 Jan 2016 18:12:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
Message-ID: <20160122171208.GD19465@dhcp22.suse.cz>
References: <20160120212806.GA26965@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601201552590.26496@east.gentwo.org>
 <20160121082402.GA29520@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601210941540.7063@east.gentwo.org>
 <20160121165148.GF29520@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601211130580.7741@east.gentwo.org>
 <20160122140418.GB19465@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601220950290.17929@east.gentwo.org>
 <20160122161201.GC19465@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601221046020.17984@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1601221046020.17984@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri 22-01-16 10:46:14, Christoph Lameter wrote:
> On Fri, 22 Jan 2016, Michal Hocko wrote:
> 
> > Could you repost the patch with the updated description?
> 
> Subject: vmstat: Remove BUG_ON from vmstat_update
> 
> If we detect that there is nothing to do just set the flag and do not check
> if it was already set before. Races really do not matter. If the flag is
> set by any code then the shepherd will start dealing with the situation
> and reenable the vmstat workers when necessary again.
> 
> Since 0eb77e988032 ("vmstat: make vmstat_updater deferrable again and
> shut down on idle") quiet_vmstat might update cpu_stat_off and mark a
> particular cpu to be handled by vmstat_shepherd. This might trigger
> a VM_BUG_ON in vmstat_update because the work item might have been
> sleeping during the idle period and see the cpu_stat_off updated after
> the wake up. The VM_BUG_ON is therefore misleading and no more
> appropriate. Moreover it doesn't really suite any protection from real
> bugs because vmstat_shepherd will simply reschedule the vmstat_work
> anytime it sees a particular cpu set or vmstat_update would do the same
> from the worker context directly. Even when the two would race the
> result wouldn't be incorrect as the counters update is fully idempotent.
>

Fixes: 0eb77e988032 ("vmstat: make vmstat_updater deferrable again and shut down on idle"
Reported-by: Sasha Levin <sasha.levin@oracle.com>

Would be appropriate IMO

> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> 
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c
> +++ linux/mm/vmstat.c
> @@ -1408,17 +1408,7 @@ static void vmstat_update(struct work_st
>  		 * Defer the checking for differentials to the
>  		 * shepherd thread on a different processor.
>  		 */
> -		int r;
> -		/*
> -		 * Shepherd work thread does not race since it never
> -		 * changes the bit if its zero but the cpu
> -		 * online / off line code may race if
> -		 * worker threads are still allowed during
> -		 * shutdown / startup.
> -		 */
> -		r = cpumask_test_and_set_cpu(smp_processor_id(),
> -			cpu_stat_off);
> -		VM_BUG_ON(r);
> +		cpumask_set_cpu(smp_processor_id(), cpu_stat_off);
>  	}
>  }

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
