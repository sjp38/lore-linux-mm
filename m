Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0736E6B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 09:35:12 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k104so2224599wrc.19
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 06:35:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g6si1877630ede.381.2017.12.06.06.35.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 06:35:10 -0800 (PST)
Date: Wed, 6 Dec 2017 15:35:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v3 1/7] ktask: add documentation
Message-ID: <20171206143509.GG7515@dhcp22.suse.cz>
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
 <20171205195220.28208-2-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205195220.28208-2-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

Please note that I haven't checked any code in this patch series. I've
just started here to see how the thing is supposed to work and what is
the overall design

On Tue 05-12-17 14:52:14, Daniel Jordan wrote:
[...]
> +Resource Limits and Auto-Tuning
> +===============================
> +
> +ktask has resource limits on the number of workqueue items it queues.  In
> +ktask, a workqueue item is a thread that runs chunks of the task until the task
> +is finished.
> +
> +These limits support the different ways ktask uses workqueues:
> + - ktask_run to run threads on the calling thread's node.
> + - ktask_run_numa to run threads on the node(s) specified.
> + - ktask_run_numa with nid=NUMA_NO_NODE to run threads on any node in the
> +   system.
> +
> +To support these different ways of queueing work while maintaining an efficient
> +concurrency level, we need both system-wide and per-node limits on the number
> +of threads.  Without per-node limits, a node might become oversubscribed
> +despite ktask staying within the system-wide limit, and without a system-wide
> +limit, we can't properly account for work that can run on any node.
> +
> +The system-wide limit is based on the total number of CPUs, and the per-node
> +limit on the CPU count for each node.  A per-node work item counts against the
> +system-wide limit.  Workqueue's max_active can't accommodate both types of
> +limit, no matter how many workqueues are used, so ktask implements its own.
> +
> +If a per-node limit is reached, the work item is allowed to run anywhere on the
> +machine to avoid overwhelming the node.  If the global limit is also reached,
> +ktask won't queue additional work items until we fall below the limit again.
> +
> +These limits apply only to workqueue items--that is, additional threads beyond
> +the one starting the task.  That way, one thread per task is always allowed to
> +run.
> +
> +Within the resource limits, ktask uses a default maximum number of threads per
> +task to avoid disturbing other processes on the system.  Callers can change the
> +limit with ktask_ctl_set_max_threads.  For example, this might be used to raise
> +the maximum number of threads for a boot-time initialization task when more
> +CPUs than usual are idle.

The last time something like this (maybe even this specific approach -
I do not remember) the main objection was the auto-tuning. Unless I've
missed anything here all the tuning is based on counters rather than
the _current_ system utilization. There is also no mention about other
characteristics (e.g. power management), resource isolation etc. So
let me ask again. How do you control that the parallelized operation
doesn't run outside of the limit imposed to the calling context? How
do you control whether a larger number of workers should be fired when
the system is idle but we want to keep many cpus idle due to power
constrains. How do you control how many workers are fired based on
cpu utilization? Do you talk to the scheduler to see overall/per node
utilization.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
