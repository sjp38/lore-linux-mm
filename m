Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 179626B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 04:58:32 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id n12so5660079wgh.0
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 01:58:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yx1si4368540wjc.16.2014.01.28.01.58.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 01:58:31 -0800 (PST)
Date: Tue, 28 Jan 2014 09:58:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/9] numa,sched,mm: use active_nodes nodemask to limit
 numa migrations
Message-ID: <20140128095828.GR4963@suse.de>
References: <1390860228-21539-1-git-send-email-riel@redhat.com>
 <1390860228-21539-6-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390860228-21539-6-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Mon, Jan 27, 2014 at 05:03:44PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> Use the active_nodes nodemask to make smarter decisions on NUMA migrations.
> 
> In order to maximize performance of workloads that do not fit in one NUMA
> node, we want to satisfy the following criteria:
> 1) keep private memory local to each thread
> 2) avoid excessive NUMA migration of pages
> 3) distribute shared memory across the active nodes, to
>    maximize memory bandwidth available to the workload
> 
> This patch accomplishes that by implementing the following policy for
> NUMA migrations:
> 1) always migrate on a private fault
> 2) never migrate to a node that is not in the set of active nodes
>    for the numa_group
> 3) always migrate from a node outside of the set of active nodes,
>    to a node that is in that set
> 4) within the set of active nodes in the numa_group, only migrate
>    from a node with more NUMA page faults, to a node with fewer
>    NUMA page faults, with a 25% margin to avoid ping-ponging
> 
> This results in most pages of a workload ending up on the actively
> used nodes, with reduced ping-ponging of pages between those nodes.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Chegu Vinod <chegu_vinod@hp.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
