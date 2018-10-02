Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id D35CD6B026C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 08:41:59 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id e38-v6so1199412otj.15
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 05:41:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l1-v6si4000234otb.47.2018.10.02.05.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 05:41:58 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w92CYnLu033993
	for <linux-mm@kvack.org>; Tue, 2 Oct 2018 08:41:57 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mv6f9nsq0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:41:57 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 2 Oct 2018 13:41:55 +0100
Date: Tue, 2 Oct 2018 18:11:49 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm, numa: Migrate pages to local nodes quicker early
 in the lifetime of a task
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
 <20181001100525.29789-3-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20181001100525.29789-3-mgorman@techsingularity.net>
Message-Id: <20181002124149.GB4593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Jirka Hladky <jhladky@redhat.com>, Rik van Riel <riel@surriel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

>
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 25c7c7e09cbd..7fc4a371bdd2 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1392,6 +1392,17 @@ bool should_numa_migrate_memory(struct task_struct *p, struct page * page,
>  	int last_cpupid, this_cpupid;
>
>  	this_cpupid = cpu_pid_to_cpupid(dst_cpu, current->pid);
> +	last_cpupid = page_cpupid_xchg_last(page, this_cpupid);
> +
> +	/*
> +	 * Allow first faults or private faults to migrate immediately early in
> +	 * the lifetime of a task. The magic number 4 is based on waiting for
> +	 * two full passes of the "multi-stage node selection" test that is
> +	 * executed below.
> +	 */
> +	if ((p->numa_preferred_nid == -1 || p->numa_scan_seq <= 4) &&
> +	    (cpupid_pid_unset(last_cpupid) || cpupid_match_pid(p, last_cpupid)))
> +		return true;
>

This does have issues when using with workloads that access more shared faults
than private faults.

In such workloads, this change would spread the memory causing regression in
behaviour.

5 runs of on 2 socket/ 4 node power 8 box


Without this patch
./numa01.sh      Real:  382.82    454.29    422.31    29.72
./numa01.sh      Sys:   40.12     74.53     58.50     13.37
./numa01.sh      User:  34230.22  46398.84  40292.62  4915.93

With this patch
./numa01.sh      Real:  415.56    555.04    473.45    51.17    -10.8016%
./numa01.sh      Sys:   43.42     94.22     73.59     17.31    -20.5055%
./numa01.sh      User:  35271.95  56644.19  45615.72  7165.01  -11.6694%

Since we are looking at time, smaller numbers are better.

----------------------------------------
# cat numa01.sh
#! /bin/bash
# numa01.sh corresponds to 2 perf bench processes each having ncpus/2 threads
# 50 loops of 3G process memory.

THREADS=${THREADS:-$(($(getconf _NPROCESSORS_ONLN)/2))}
perf bench numa mem --no-data_rand_walk -p 2 -t $THREADS -G 0 -P 3072 -T 0 -l 50 -c -s 2000 $@
----------------------------------------

I know this is a synthetic benchmark, but wonder if benchmarks run on vm
guest show similar behaviour when noticed from host.

SPECJbb did show some small loss and gains.

Our numa grouping is not fast enough. It can take sometimes several
iterations before all the tasks belonging to the same group end up being
part of the group. With the current check we end up spreading memory faster
than we should hence hurting the chance of early consolidation.

Can we restrict to something like this?

if (p->numa_scan_seq >=MIN && p->numa_scan_seq <= MIN+4 &&
    (cpupid_match_pid(p, last_cpupid)))
	return true;

meaning, we ran atleast MIN number of scans, and we find the task to be most likely
task using this page.

-- 
Thanks and Regards
Srikar Dronamraju
