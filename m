Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 551366B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 05:01:35 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y10so343753wgg.22
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 02:01:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5si7309439wjw.76.2014.01.28.02.01.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 02:01:34 -0800 (PST)
Date: Tue, 28 Jan 2014 10:01:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/9] numa,sched: normalize faults_cpu stats and weigh by
 CPU use
Message-ID: <20140128100131.GS4963@suse.de>
References: <1390860228-21539-1-git-send-email-riel@redhat.com>
 <1390860228-21539-7-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390860228-21539-7-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Mon, Jan 27, 2014 at 05:03:45PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> Tracing the code that decides the active nodes has made it abundantly clear
> that the naive implementation of the faults_from code has issues.
> 
> Specifically, the garbage collector in some workloads will access orders
> of magnitudes more memory than the threads that do all the active work.
> This resulted in the node with the garbage collector being marked the only
> active node in the group.
> 
> This issue is avoided if we weigh the statistics by CPU use of each task in
> the numa group, instead of by how many faults each thread has occurred.
> 
> To achieve this, we normalize the number of faults to the fraction of faults
> that occurred on each node, and then multiply that fraction by the fraction
> of CPU time the task has used since the last time task_numa_placement was
> invoked.
> 
> This way the nodes in the active node mask will be the ones where the tasks
> from the numa group are most actively running, and the influence of eg. the
> garbage collector and other do-little threads is properly minimized.
> 
> On a 4 node system, using CPU use statistics calculated over a longer interval
> results in about 1% fewer page migrations with two 32-warehouse specjbb runs
> on a 4 node system, and about 5% fewer page migrations, as well as 1% better
> throughput, with two 8-warehouse specjbb runs, as compared with the shorter
> term statistics kept by the scheduler.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Chegu Vinod <chegu_vinod@hp.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>

Major changes are related to the weight calculations to avoid overflow
and the avg runtime is calculated based on a longer runtime than the v4
version. Both seem sane so

Acked-by: Mel Gorman <mgorman@suse>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
