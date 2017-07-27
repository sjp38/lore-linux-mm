Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 177A16B04AF
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:56:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a186so14460395wmh.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:56:30 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a59si12196458ede.445.2017.07.27.08.56.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jul 2017 08:56:28 -0700 (PDT)
Date: Thu, 27 Jul 2017 11:56:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
Message-ID: <20170727155616.GA23665@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727153010.23347-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727153010.23347-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 27, 2017 at 11:30:10AM -0400, Johannes Weiner wrote:
> +	/*
> +	 * The domain is somewhat delayed when a number of tasks are
> +	 * delayed but there are still others running the workload.
> +	 *
> +	 * The domain is fully delayed when all non-idle tasks on the
> +	 * CPU are delayed, or when a delayed task is actively running
> +	 * and preventing productive tasks from making headway.
> +	 *
> +	 * The state times then add up over all CPUs in the domain: if
> +	 * the domain is fully blocked on one CPU and there is another
> +	 * one running the workload, the domain is considered fully
> +	 * blocked 50% of the time.
> +	 */
> +	if (!mdc->tasks[MTS_DELAYED_ACTIVE] && !mdc->tasks[MTS_DELAYED])
> +		state = MDS_NONE;
> +	else if (mdc->tasks[MTS_WORKING])
> +		state = MDS_SOME;
> +	else
> +		state = MDS_FULL;

Just a headsup, if you're wondering why the distinction between
delayed and delayed_active: I used to track iowait separately from
working, and in a brainfart oversimplified this part right here. It
should really be:

	if (delayed_active && !iowait)
		state = full
	else if (delayed)
		state = (working || iowait) ? some : full
	else
		state = none

I'm going to re-add separate iowait tracking in v2 and fix this, but
since this patch is already big and spans two major subsystems, I
wanted to run the overall design and idea by you first before doing
more polishing on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
