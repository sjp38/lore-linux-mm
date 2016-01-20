Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B30FD6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:28:10 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id b14so50591888wmb.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 13:28:10 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id uc9si55990678wjc.194.2016.01.20.13.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 13:28:09 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id 123so149898748wmz.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 13:28:09 -0800 (PST)
Date: Wed, 20 Jan 2016 22:28:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
Message-ID: <20160120212806.GA26965@dhcp22.suse.cz>
References: <5674A5C3.1050504@oracle.com>
 <20160120143719.GF14187@dhcp22.suse.cz>
 <569FA01A.4070200@oracle.com>
 <20160120151007.GG14187@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org>
 <569FAC90.5030407@oracle.com>
 <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 20-01-16 09:55:22, Christoph Lameter wrote:
[...]
> Subject: vmstat: Remove BUG_ON from vmstat_update
> 
> If we detect that there is nothing to do just set the flag and do not check
> if it was already set before. Races really do not matter. If the flag is
> set by any code then the shepherd will start dealing with the situation
> and reenable the vmstat workers when necessary again.
> 
> Concurrent actions could be onlining and offlining of processors or be a
> result of concurrency issues when updating the cpumask from multiple
> processors.

Now that 7e988032 ("vmstat: make vmstat_updater deferrable again and
shut down on idle) is merged the VM_BUG_ON is simply bogus because
vmstat_update might "race" with quiet_vmstat. The changelog should
reflect that. What about the following wording?

"
Since 0eb77e988032 ("vmstat: make vmstat_updater deferrable again and
shut down on idle") quiet_vmstat might update cpu_stat_off and mark a
particular cpu to be handled by vmstat_shepherd. This might trigger
a VM_BUG_ON in vmstat_update because the work item might have been
sleeping during the idle period and see the cpu_stat_off updated after
the wake up. The VM_BUG_ON is therefore misleading and no more
appropriate. Moreover it doesn't really suite any protection from real
bugs because vmstat_shepherd will simply reschedule the vmstat_work
anytime it sees a particular cpu set or vmstat_update would do the same
from the worker context directly. Even when the two would race the
result wouldn't be incorrect as the counters update is fully idempotent.

Fixes: 0eb77e988032 ("vmstat: make vmstat_updater deferrable again and
shut down on idle")
CC: stable # 4.4+
"

> Signed-off-by: Christoph Lameter <cl@linux.com>
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
