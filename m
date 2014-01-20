Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id BA6316B0037
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:55:42 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i8so6008011qcq.4
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 08:55:42 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 6si1068956qgr.10.2014.01.20.08.55.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jan 2014 08:55:41 -0800 (PST)
Date: Mon, 20 Jan 2014 17:55:23 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/7] numa,sched: build per numa_group active node mask
 from faults_from statistics
Message-ID: <20140120165523.GK31570@twins.programming.kicks-ass.net>
References: <1389993129-28180-1-git-send-email-riel@redhat.com>
 <1389993129-28180-4-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389993129-28180-4-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, chegu_vinod@hp.com, mgorman@suse.de, mingo@redhat.com

On Fri, Jan 17, 2014 at 04:12:05PM -0500, riel@redhat.com wrote:
>  /*
> + * Iterate over the nodes from which NUMA hinting faults were triggered, in
> + * other words where the CPUs that incurred NUMA hinting faults are. The
> + * bitmask is used to limit NUMA page migrations, and spread out memory
> + * between the actively used nodes. To prevent flip-flopping, and excessive
> + * page migrations, nodes are added when they cause over 40% of the maximum
> + * number of faults, but only removed when they drop below 20%.
> + */

Maybe break the above into two paragraphs for added readability.

Also, I think this might be a good spot to explain why you need the
second fault metric -- that is, why can't we create the interleave mask
from the existing memory location faults.

> +static void update_numa_active_node_mask(struct task_struct *p)
> +{
> +	unsigned long faults, max_faults = 0;
> +	struct numa_group *numa_group = p->numa_group;
> +	int nid;
> +
> +	for_each_online_node(nid) {
> +		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
> +			 numa_group->faults_from[task_faults_idx(nid, 1)];
> +		if (faults > max_faults)
> +			max_faults = faults;
> +	}
> +
> +	for_each_online_node(nid) {
> +		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
> +			 numa_group->faults_from[task_faults_idx(nid, 1)];
> +		if (!node_isset(nid, numa_group->active_nodes)) {
> +			if (faults > max_faults * 4 / 10)
> +				node_set(nid, numa_group->active_nodes);
> +		} else if (faults < max_faults * 2 / 10)
> +			node_clear(nid, numa_group->active_nodes);
> +	}
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
