Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 09E926B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 09:25:24 -0500 (EST)
Received: by padhz1 with SMTP id hz1so27837945pad.9
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 06:25:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ow1si1731864pbb.118.2015.02.23.06.25.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 06:25:23 -0800 (PST)
Date: Mon, 23 Feb 2015 15:25:14 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 4/6] mm, thp: move collapsing from khugepaged to task_work
 context
Message-ID: <20150223142514.GX5029@twins.programming.kicks-ass.net>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
 <1424696322-21952-5-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424696322-21952-5-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>

On Mon, Feb 23, 2015 at 01:58:40PM +0100, Vlastimil Babka wrote:
> @@ -7713,8 +7820,15 @@ static void task_tick_fair(struct rq *rq, struct task_struct *curr, int queued)
>  		entity_tick(cfs_rq, se, queued);
>  	}
>  
> -	if (numabalancing_enabled)
> -		task_tick_numa(rq, curr);
> +	/*
> +	 * For latency considerations, don't schedule the THP work together
> +	 * with NUMA work. NUMA has higher priority, assuming remote accesses
> +	 * have worse penalty than TLB misses.
> +	 */
> +	if (!(numabalancing_enabled && task_tick_numa(rq, curr))
> +						&& khugepaged_enabled())
> +		task_tick_thp(rq, curr);
> +
>  
>  	update_rq_runnable_avg(rq, 1);
>  }

That's a bit yucky; and I think there's no problem moving that
update_rq_runnable_avg() thing up a bit; which would get you:

static void task_tick_fair(..)
{

	...

	update_rq_runnable_avg();

	if (numabalancing_enabled && task_tick_numa(rq, curr))
		return;

	if (khugepaged_enabled() && task_tick_thp(rq, curr))
		return;
}

Clearly the return on that second conditional is a tad pointless, but
OCD :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
