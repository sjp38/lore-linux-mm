Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA386B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 06:08:40 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d140so25779154wmd.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 03:08:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k206si17914873wma.17.2017.01.24.03.08.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 03:08:38 -0800 (PST)
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f4b504e1-30a2-5c53-bd15-c9b22a56da83@suse.cz>
Date: Tue, 24 Jan 2017 12:08:35 +0100
MIME-Version: 1.0
In-Reply-To: <20170117092954.15413-4-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Tejun Heo <tj@kernel.org>

On 01/17/2017 10:29 AM, Mel Gorman wrote:
> The per-cpu page allocator can be drained immediately via drain_all_pages()
> which sends IPIs to every CPU. In the next patch, the per-cpu allocator
> will only be used for interrupt-safe allocations which prevents draining
> it from IPI context. This patch uses workqueues to drain the per-cpu
> lists instead.
> 
> This is slower but no slowdown during intensive reclaim was measured and
> the paths that use drain_all_pages() are not that sensitive to performance.
> This is particularly true as the path would only be triggered when reclaim
> is failing. It also makes a some sense to avoid storming a machine with IPIs
> when it's under memory pressure. Arguably, it should be further adjusted
> so that only one caller at a time is draining pages but it's beyond the
> scope of the current patch.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/page_alloc.c | 42 +++++++++++++++++++++++++++++++++++-------
>  1 file changed, 35 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d15527a20dce..9c3a0fcf8c13 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2341,19 +2341,21 @@ void drain_local_pages(struct zone *zone)
>  		drain_pages(cpu);
>  }
>  
> +static void drain_local_pages_wq(struct work_struct *work)
> +{
> +	drain_local_pages(NULL);
> +}
> +
>  /*
>   * Spill all the per-cpu pages from all CPUs back into the buddy allocator.
>   *
>   * When zone parameter is non-NULL, spill just the single zone's pages.
>   *
> - * Note that this code is protected against sending an IPI to an offline
> - * CPU but does not guarantee sending an IPI to newly hotplugged CPUs:
> - * on_each_cpu_mask() blocks hotplug and won't talk to offlined CPUs but
> - * nothing keeps CPUs from showing up after we populated the cpumask and
> - * before the call to on_each_cpu_mask().
> + * Note that this can be extremely slow as the draining happens in a workqueue.
>   */
>  void drain_all_pages(struct zone *zone)
>  {
> +	struct work_struct __percpu *works;
>  	int cpu;
>  
>  	/*
> @@ -2362,6 +2364,16 @@ void drain_all_pages(struct zone *zone)
>  	 */
>  	static cpumask_t cpus_with_pcps;
>  
> +	/* Workqueues cannot recurse */
> +	if (current->flags & PF_WQ_WORKER)
> +		return;
> +
> +	/*
> +	 * As this can be called from reclaim context, do not reenter reclaim.
> +	 * An allocation failure can be handled, it's simply slower
> +	 */
> +	works = alloc_percpu_gfp(struct work_struct, GFP_ATOMIC);

BTW I wonder, even with GFP_ATOMIC, is this a good idea to do for a
temporary allocation like this one? pcpu_alloc() seems rather involved
to me and I've glanced at the other usages and they seem much more
long-lived. Maybe it would be really better to have single static
"works" and serialize the callers as you suggest in the changelog?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
