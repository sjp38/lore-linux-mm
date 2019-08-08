Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FAAEC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 11:48:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F9EF21881
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 11:48:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F9EF21881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3F806B0003; Thu,  8 Aug 2019 07:48:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEEBE6B0006; Thu,  8 Aug 2019 07:48:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB59E6B0007; Thu,  8 Aug 2019 07:48:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD376B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 07:48:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w25so58020191edu.11
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 04:48:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PCTROE2Vr480DbUw+aSPYsLyLeWozMnXxRU4eDxnkfU=;
        b=dp0HhriwF60jnaUcFFLI39yCL9O2ZsNVzrD1qkibFaXQTdzZ16dRfVew1EdveQiUrB
         sIXuYy4zhzcnTRF8vgH68vatyDCaNJekw78SJDKdqJSXHGDoKawWUc7onEvKEGdRysiH
         JvgEoEv7zIFYS8IiWTVflx8GLS3kaRwD5q7UXs9gLvymKyMyRRelfSC5VPq2dWTY9ZRs
         TvcalKdLQZwbNo/7RUspdjt5pCAjVVqT57XV68GdeYWTOEOZdKQA5lSdf2ks7S20YBxv
         6hcH28jgRnWt73KKnzl/RfLdtb59tYSLNShT2wHQN25BOon0VAasqCXpo0JyejkfoQ8+
         /a1g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX0K1azfWnbrJF4Nkhb0PtRS/fH22Jne2WksNkaREywqmT8yB0W
	PzgapyUUj18LEszPj66zCdiKysrCQJaYmH0NB27vJMhoUA2OSHO3wFMfSEvzXio5PqjfCwsnzKP
	W9homBCZPZMvJpswidVglUsdvnxiiD2/bwEJ+pE/E7hEKAIhsm0A4zCJWBCnnVVs=
X-Received: by 2002:a17:907:217c:: with SMTP id rl28mr12787350ejb.131.1565264910879;
        Thu, 08 Aug 2019 04:48:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUzF+WebWyJaD8v/yapt41/d40M83/6WAUamq75BJ48wfR/PWlQMZ/5Oa40MYhe/1Ejwwk
X-Received: by 2002:a17:907:217c:: with SMTP id rl28mr12787263ejb.131.1565264909415;
        Thu, 08 Aug 2019 04:48:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565264909; cv=none;
        d=google.com; s=arc-20160816;
        b=xkFA3OrEsPpdh6uWP0Ro4ZrtYHiC98w5mFRdtSGL5MzIi6xHPJPCcDe1L3dOzcfBbN
         qT2e70E5NOJI3uK4GQvT2NUfR3L0PiYloSVzNbjQjMqiQ044O/5Jc7LsnVnTrS7CYCTj
         oZ9bDtL4U+JYzKwMV+QB4xkWljK+IiX2ffS1dZ1ySPHyvBGSfL/8vaVwxQB2LEqI4iZh
         XAm4VqDhgs63++Xh+x9bjTYhr7K6/VaAYBH7bUi2/UVWb7Kz5ubscFDqWXxrqcgK5CwB
         uObgDMDdAc9PHsbeMh1GHwEo9DWCru2+k885dGB/CwC/rnVVGa0mSNhwXJnQEVY/jHTy
         F7tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PCTROE2Vr480DbUw+aSPYsLyLeWozMnXxRU4eDxnkfU=;
        b=W4/fs+ZZvQD+88WnVOO8bkuTFplJh2BNhGo0lzxAtoT5CkBqE3n9IeBPZ9KFDsEWoK
         mbog+RSe3eIzG+nN2DPB/WX2Hef1AFvsuwp1sdoHan8Tj0iMIbfKR8VNCnI4wfXOfHV9
         B+RT5q3xfKgKNXEz1DGlzTcafslV5Duh1XGFrfBKLYjrvdOlm4fW3CGfuaka25fwn0sz
         NIaJ9rk5lJgsbM7q3B5fX6bxdBwvEFAoZOt0er3No6BqtS1n2iyI2ZurrXY0XIZ39DBV
         6OQIzijwFJeze6FDlqpF6SGOi6QoPk0NtgKlY9AXeQ7cCfUMX2AJK6qltzVR3czYArau
         MIhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s35si35854369edb.337.2019.08.08.04.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 04:48:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BF094AD78;
	Thu,  8 Aug 2019 11:48:28 +0000 (UTC)
Date: Thu, 8 Aug 2019 13:48:26 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190808114826.GC18351@dhcp22.suse.cz>
References: <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org>
 <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807205138.GA24222@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 07-08-19 16:51:38, Johannes Weiner wrote:
[...]
> >From 9efda85451062dea4ea287a886e515efefeb1545 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 5 Aug 2019 13:15:16 -0400
> Subject: [PATCH] psi: trigger the OOM killer on severe thrashing
> 
> Over the last few years we have had many reports that the kernel can
> enter an extended livelock situation under sufficient memory
> pressure. The system becomes unresponsive and fully IO bound for
> indefinite periods of time, and often the user has no choice but to
> reboot.

or sysrq+f

> Even though the system is clearly struggling with a shortage
> of memory, the OOM killer is not engaging reliably.
> 
> The reason is that with bigger RAM, and in particular with faster
> SSDs, page reclaim does not necessarily fail in the traditional sense
> anymore. In the time it takes the CPU to run through the vast LRU
> lists, there are almost always some cache pages that have finished
> reading in and can be reclaimed, even before userspace had a chance to
> access them. As a result, reclaim is nominally succeeding, but
> userspace is refault-bound and not making significant progress.
> 
> While this is clearly noticable to human beings, the kernel could not
> actually determine this state with the traditional memory event
> counters. We might see a certain rate of reclaim activity or refaults,
> but how long, or whether at all, userspace is unproductive because of
> it depends on IO speed, readahead efficiency, as well as memory access
> patterns and concurrency of the userspace applications. The same
> number of the VM events could be unnoticed in one system / workload
> combination, and result in an indefinite lockup in a different one.
> 
> However, eb414681d5a0 ("psi: pressure stall information for CPU,
> memory, and IO") introduced a memory pressure metric that quantifies
> the share of wallclock time in which userspace waits on reclaim,
> refaults, swapins. By using absolute time, it encodes all the above
> mentioned variables of hardware capacity and workload behavior. When
> memory pressure is 40%, it means that 40% of the time the workload is
> stalled on memory, period. This is the actual measure for the lack of
> forward progress that users can experience. It's also something they
> expect the kernel to manage and remedy if it becomes non-existent.
> 
> To accomplish this, this patch implements a thrashing cutoff for the
> OOM killer. If the kernel determines a sustained high level of memory
> pressure, and thus a lack of forward progress in userspace, it will
> trigger the OOM killer to reduce memory contention.
> 
> Per default, the OOM killer will engage after 15 seconds of at least
> 80% memory pressure. These values are tunable via sysctls
> vm.thrashing_oom_period and vm.thrashing_oom_level.

As I've said earlier I would be somehow more comfortable with a kernel
command line/module parameter based tuning because it is less of a
stable API and potential future stall detector might be completely
independent on PSI and the current metric exported. But I can live with
that because a period and level sounds quite generic.

> Ideally, this would be standard behavior for the kernel, but since it
> involves a new metric and OOM killing, let's be safe and make it an
> opt-in via CONFIG_THRASHING_OOM. Setting vm.thrashing_oom_level to 0
> also disables the feature at runtime.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reported-by: "Artem S. Tashkinov" <aros@gmx.com>

I am not deeply familiar with PSI internals but from a quick look it
seems that update_averages is called from the OOM safe context (worker).

I have scratched my head how to deal with this "progress is made but it
is all in vain" problem inside the reclaim path but I do not think this
will ever work and having a watchdog like this sound like step in the
right direction. I didn't even expect it would look as simple. Really a
nice work Johannes!

Let's see how this ends up working in practice though.

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  Documentation/admin-guide/sysctl/vm.rst | 24 ++++++++
>  include/linux/psi.h                     |  5 ++
>  include/linux/psi_types.h               |  6 ++
>  kernel/sched/psi.c                      | 74 +++++++++++++++++++++++++
>  kernel/sysctl.c                         | 20 +++++++
>  mm/Kconfig                              | 20 +++++++
>  6 files changed, 149 insertions(+)
> 
> diff --git a/Documentation/admin-guide/sysctl/vm.rst b/Documentation/admin-guide/sysctl/vm.rst
> index 64aeee1009ca..0332cb52bcfc 100644
> --- a/Documentation/admin-guide/sysctl/vm.rst
> +++ b/Documentation/admin-guide/sysctl/vm.rst
> @@ -66,6 +66,8 @@ files can be found in mm/swap.c.
>  - stat_interval
>  - stat_refresh
>  - numa_stat
> +- thrashing_oom_level
> +- thrashing_oom_period
>  - swappiness
>  - unprivileged_userfaultfd
>  - user_reserve_kbytes
> @@ -825,6 +827,28 @@ When page allocation performance is not a bottleneck and you want all
>  	echo 1 > /proc/sys/vm/numa_stat
>  
>  
> +thrashing_oom_level
> +===================
> +
> +This defines the memory pressure level for severe thrashing at which
> +the OOM killer will be engaged.
> +
> +The default is 80. This means the system is considered to be thrashing
> +severely when all active tasks are collectively stalled on memory
> +(waiting for page reclaim, refaults, swapins etc) for 80% of the time.
> +
> +A setting of 0 will disable thrashing-based OOM killing.
> +
> +
> +thrashing_oom_period
> +===================
> +
> +This defines the number of seconds the system must sustain severe
> +thrashing at thrashing_oom_level before the OOM killer is invoked.
> +
> +The default is 15.
> +
> +
>  swappiness
>  ==========
>  
> diff --git a/include/linux/psi.h b/include/linux/psi.h
> index 7b3de7321219..661ce45900f9 100644
> --- a/include/linux/psi.h
> +++ b/include/linux/psi.h
> @@ -37,6 +37,11 @@ __poll_t psi_trigger_poll(void **trigger_ptr, struct file *file,
>  			poll_table *wait);
>  #endif
>  
> +#ifdef CONFIG_THRASHING_OOM
> +extern unsigned int sysctl_thrashing_oom_level;
> +extern unsigned int sysctl_thrashing_oom_period;
> +#endif
> +
>  #else /* CONFIG_PSI */
>  
>  static inline void psi_init(void) {}
> diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
> index 07aaf9b82241..7c57d7e5627e 100644
> --- a/include/linux/psi_types.h
> +++ b/include/linux/psi_types.h
> @@ -162,6 +162,12 @@ struct psi_group {
>  	u64 polling_total[NR_PSI_STATES - 1];
>  	u64 polling_next_update;
>  	u64 polling_until;
> +
> +#ifdef CONFIG_THRASHING_OOM
> +	/* Severe thrashing state tracking */
> +	bool oom_pressure;
> +	u64 oom_pressure_start;
> +#endif
>  };
>  
>  #else /* CONFIG_PSI */
> diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> index f28342dc65ec..4b1b620d6359 100644
> --- a/kernel/sched/psi.c
> +++ b/kernel/sched/psi.c
> @@ -139,6 +139,7 @@
>  #include <linux/ctype.h>
>  #include <linux/file.h>
>  #include <linux/poll.h>
> +#include <linux/oom.h>
>  #include <linux/psi.h>
>  #include "sched.h"
>  
> @@ -177,6 +178,14 @@ struct psi_group psi_system = {
>  	.pcpu = &system_group_pcpu,
>  };
>  
> +#ifdef CONFIG_THRASHING_OOM
> +static void psi_oom_tick(struct psi_group *group, u64 now);
> +#else
> +static inline void psi_oom_tick(struct psi_group *group, u64 now)
> +{
> +}
> +#endif
> +
>  static void psi_avgs_work(struct work_struct *work);
>  
>  static void group_init(struct psi_group *group)
> @@ -403,6 +412,8 @@ static u64 update_averages(struct psi_group *group, u64 now)
>  		calc_avgs(group->avg[s], missed_periods, sample, period);
>  	}
>  
> +	psi_oom_tick(group, now);
> +
>  	return avg_next_update;
>  }
>  
> @@ -1280,3 +1291,66 @@ static int __init psi_proc_init(void)
>  	return 0;
>  }
>  module_init(psi_proc_init);
> +
> +#ifdef CONFIG_THRASHING_OOM
> +/*
> + * Trigger the OOM killer when detecting severe thrashing.
> + *
> + * Per default we define severe thrashing as 15 seconds of 80% memory
> + * pressure (i.e. all active tasks are collectively stalled on memory
> + * 80% of the time).
> + */
> +unsigned int sysctl_thrashing_oom_level = 80;
> +unsigned int sysctl_thrashing_oom_period = 15;
> +
> +static void psi_oom_tick(struct psi_group *group, u64 now)
> +{
> +	struct oom_control oc = {
> +		.order = 0,
> +	};
> +	unsigned long pressure;
> +	bool high;
> +
> +	/* Disabled at runtime */
> +	if (!sysctl_thrashing_oom_level)
> +		return;
> +
> +	/*
> +	 * Protect the system from livelocking due to thrashing. Leave
> +	 * per-cgroup policies to oomd, lmkd etc.
> +	 */
> +	if (group != &psi_system)
> +		return;
> +
> +	pressure = LOAD_INT(group->avg[PSI_MEM_FULL][0]);
> +	high = pressure >= sysctl_thrashing_oom_level;
> +
> +	if (!group->oom_pressure && !high)
> +		return;
> +
> +	if (!group->oom_pressure && high) {
> +		group->oom_pressure = true;
> +		group->oom_pressure_start = now;
> +		return;
> +	}
> +
> +	if (group->oom_pressure && !high) {
> +		group->oom_pressure = false;
> +		return;
> +	}
> +
> +	if (now < group->oom_pressure_start +
> +	    (u64)sysctl_thrashing_oom_period * NSEC_PER_SEC)
> +		return;
> +
> +	pr_warn("Severe thrashing detected! (%ds of %d%% memory pressure)\n",
> +		sysctl_thrashing_oom_period, sysctl_thrashing_oom_level);
> +
> +	group->oom_pressure = false;
> +
> +	if (!mutex_trylock(&oom_lock))
> +		return;
> +	out_of_memory(&oc);
> +	mutex_unlock(&oom_lock);
> +}
> +#endif /* CONFIG_THRASHING_OOM */
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index f12888971d66..3b9b3deb1836 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -68,6 +68,7 @@
>  #include <linux/bpf.h>
>  #include <linux/mount.h>
>  #include <linux/userfaultfd_k.h>
> +#include <linux/psi.h>
>  
>  #include "../lib/kstrtox.h"
>  
> @@ -1746,6 +1747,25 @@ static struct ctl_table vm_table[] = {
>  		.extra1		= SYSCTL_ZERO,
>  		.extra2		= SYSCTL_ONE,
>  	},
> +#endif
> +#ifdef CONFIG_THRASHING_OOM
> +	{
> +		.procname	= "thrashing_oom_level",
> +		.data		= &sysctl_thrashing_oom_level,
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= SYSCTL_ZERO,
> +		.extra2		= &one_hundred,
> +	},
> +	{
> +		.procname	= "thrashing_oom_period",
> +		.data		= &sysctl_thrashing_oom_period,
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= SYSCTL_ZERO,
> +	},
>  #endif
>  	{ }
>  };
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 56cec636a1fc..cef13b423beb 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -736,4 +736,24 @@ config ARCH_HAS_PTE_SPECIAL
>  config ARCH_HAS_HUGEPD
>  	bool
>  
> +config THRASHING_OOM
> +	bool "Trigger the OOM killer on severe thrashing"
> +	select PSI
> +	help
> +	  Under memory pressure, the kernel can enter severe thrashing
> +	  or swap storms during which the system is fully IO-bound and
> +	  does not respond to any user input. The OOM killer does not
> +	  always engage because page reclaim manages to make nominal
> +	  forward progress, but the system is effectively livelocked.
> +
> +	  This feature uses pressure stall information (PSI) to detect
> +	  severe thrashing and trigger the OOM killer.
> +
> +	  The OOM killer will be engaged when the system sustains a
> +	  memory pressure level of 80% for 15 seconds. This can be
> +	  adjusted using the vm.thrashing_oom_[level|period] sysctls.
> +
> +	  Say Y if you have observed your system becoming unresponsive
> +	  for extended periods under memory pressure.
> +
>  endmenu
> -- 
> 2.22.0

-- 
Michal Hocko
SUSE Labs

