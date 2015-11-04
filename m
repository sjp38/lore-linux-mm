Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D34F96B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 03:33:38 -0500 (EST)
Received: by wmff134 with SMTP id f134so35102816wmf.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:33:38 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id la5si372915wjc.27.2015.11.04.00.33.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 00:33:37 -0800 (PST)
Received: by wicfx6 with SMTP id fx6so84588564wic.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:33:37 -0800 (PST)
Date: Wed, 4 Nov 2015 10:33:35 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: change tlb_finish_mmu() to be more simple
Message-ID: <20151104083335.GA7795@node.shutemov.name>
References: <1446622531-316-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446622531-316-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, raindel@mellanox.com, willy@linux.intel.com, boaz@plexistor.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 04, 2015 at 03:35:31PM +0800, yalin wang wrote:
> This patch remove unneeded *next temp variable,
> make this function more simple to read.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> ---
>  mm/memory.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 7f3b9f2..f0040ed 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -270,17 +270,16 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
>   */
>  void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
>  {
> -	struct mmu_gather_batch *batch, *next;
> +	struct mmu_gather_batch *batch;
>  
>  	tlb_flush_mmu(tlb);
>  
>  	/* keep the page table cache within bounds */
>  	check_pgt_cache();
>  
> -	for (batch = tlb->local.next; batch; batch = next) {
> -		next = batch->next;
> +	for (batch = tlb->local.next; batch; batch = batch->next)

Use after free? No, thanks.

>  		free_pages((unsigned long)batch, 0);
> -	}
> +
>  	tlb->local.next = NULL;
>  }
>  
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
