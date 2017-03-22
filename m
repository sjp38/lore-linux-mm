Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 37BA46B0333
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 02:33:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p189so267751903pfp.5
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 23:33:42 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k91si584347pld.175.2017.03.21.23.33.40
        for <linux-mm@kvack.org>;
        Tue, 21 Mar 2017 23:33:41 -0700 (PDT)
Date: Wed, 22 Mar 2017 15:33:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 3/5] mm: use a dedicated workqueue for the free workers
Message-ID: <20170322063335.GF30149@bbox>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <1489568404-7817-4-git-send-email-aaron.lu@intel.com>
MIME-Version: 1.0
In-Reply-To: <1489568404-7817-4-git-send-email-aaron.lu@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

Hi,

On Wed, Mar 15, 2017 at 05:00:02PM +0800, Aaron Lu wrote:
> Introduce a workqueue for all the free workers so that user can fine
> tune how many workers can be active through sysfs interface: max_active.
> More workers will normally lead to better performance, but too many can
> cause severe lock contention.

Let me ask a question.

How well can workqueue distribute the jobs in multiple CPU?
I don't ask about currency but parallelism.
I guess benefit you are seeing comes from the parallelism and
for your goal, unbound wq should spawn a thread per cpu and
doing the work in every each CPU. does it work?

> 
> Note that since the zone lock is global, the workqueue is also global
> for all processes, i.e. if we set 8 to max_active, we will have at most
> 8 workers active for all processes that are doing munmap()/exit()/etc.
> 
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> ---
>  mm/memory.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 001c7720d773..19b25bb5f45b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -253,6 +253,19 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
>  	__tlb_reset_range(tlb);
>  }
>  
> +static struct workqueue_struct *batch_free_wq;
> +static int __init batch_free_wq_init(void)
> +{
> +	batch_free_wq = alloc_workqueue("batch_free_wq",
> +					WQ_UNBOUND | WQ_SYSFS, 0);
> +	if (!batch_free_wq) {
> +		pr_warn("failed to create workqueue batch_free_wq\n");
> +		return -ENOMEM;
> +	}
> +	return 0;
> +}
> +subsys_initcall(batch_free_wq_init);
> +
>  static void tlb_flush_mmu_free_batches(struct mmu_gather_batch *batch_start,
>  				       bool free_batch_page)
>  {
> @@ -306,7 +319,7 @@ static void tlb_flush_mmu_free(struct mmu_gather *tlb)
>  		batch_free->batch_start = tlb->local.next;
>  		INIT_WORK(&batch_free->work, batch_free_work);
>  		list_add_tail(&batch_free->list, &tlb->worker_list);
> -		queue_work(system_unbound_wq, &batch_free->work);
> +		queue_work(batch_free_wq, &batch_free->work);
>  
>  		tlb->batch_count = 0;
>  		tlb->local.next = NULL;
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
