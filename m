Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 1AAAF6B002B
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 13:38:56 -0500 (EST)
Message-ID: <50D0AF65.90701@redhat.com>
Date: Tue, 18 Dec 2012 13:01:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cond_resched in tlb_flush_mmu to fix soft lockups
 on !CONFIG_PREEMPT
References: <1355847088-1207-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <1355847088-1207-1-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 12/18/2012 11:11 AM, Michal Hocko wrote:
> Since e303297 (mm: extended batches for generic mmu_gather) we are batching
> pages to be freed until either tlb_next_batch cannot allocate a new batch or we
> are done.
>
> This works just fine most of the time but we can get in troubles with
> non-preemptible kernel (CONFIG_PREEMPT_NONE or CONFIG_PREEMPT_VOLUNTARY) on
> large machines where too aggressive batching might lead to soft lockups during
> process exit path (exit_mmap) because there are no scheduling points down the
> free_pages_and_swap_cache path and so the freeing can take long enough to
> trigger the soft lockup.
>
> The lockup is harmless except when the system is setup to panic on
> softlockup which is not that unusual.
>
> The simplest way to work around this issue is to explicitly cond_resched per
> batch in tlb_flush_mmu (1020 pages on x86_64).

> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Cc: stable@vger.kernel.org # 3.0 and higher

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
