Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFE96B0031
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 09:31:37 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bg4so707018pad.32
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 06:31:37 -0700 (PDT)
Date: Fri, 20 Sep 2013 14:31:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 46/50] sched: numa: Prevent parallel updates to group
 stats during placement
Message-ID: <20130920133130.GY22421@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-47-git-send-email-mgorman@suse.de>
 <20130920095526.GT9326@twins.programming.kicks-ass.net>
 <20130920123151.GX22421@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130920123151.GX22421@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 20, 2013 at 01:31:51PM +0100, Mel Gorman wrote:
> @@ -1402,14 +1394,15 @@ unlock:
>  	if (!join)
>  		return;
>  
> +	double_lock(&my_grp->lock, &grp->lock);
> +
>  	for (i = 0; i < 2*nr_node_ids; i++) {
> -		atomic_long_sub(p->numa_faults[i], &my_grp->faults[i]);
> -		atomic_long_add(p->numa_faults[i], &grp->faults[i]);
> +		my_grp->faults[i] -= p->numa_faults[i];
> +		grp->faults[i] -= p->numa_faults[i];
> +		WARN_ON_ONCE(grp->faults[i] < 0);
>  	}

That stupidity got fixed

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
