Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A7AE76B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 07:16:43 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 5so1398995672pgi.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 04:16:43 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v1si57912338pgo.267.2017.01.04.04.16.42
        for <linux-mm@kvack.org>;
        Wed, 04 Jan 2017 04:16:42 -0800 (PST)
Date: Wed, 4 Jan 2017 12:16:41 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] mm: don't dereference struct page fields of invalid
 pages
Message-ID: <20170104121641.GC18193@arm.com>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-2-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481706707-6211-2-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, catalin.marinas@arm.com, akpm@linux-foundation.org, hanjun.guo@linaro.org, xieyisheng1@huawei.com, rrichter@cavium.com, james.morse@arm.com

On Wed, Dec 14, 2016 at 09:11:46AM +0000, Ard Biesheuvel wrote:
> The VM_BUG_ON() check in move_freepages() checks whether the node
> id of a page matches the node id of its zone. However, it does this
> before having checked whether the struct page pointer refers to a
> valid struct page to begin with. This is guaranteed in most cases,
> but may not be the case if CONFIG_HOLES_IN_ZONE=y.
> 
> So reorder the VM_BUG_ON() with the pfn_valid_within() check.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  mm/page_alloc.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f64e7bcb43b7..4e298e31fa86 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1864,14 +1864,14 @@ int move_freepages(struct zone *zone,
>  #endif
>  
>  	for (page = start_page; page <= end_page;) {
> -		/* Make sure we are not inadvertently changing nodes */
> -		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
> -
>  		if (!pfn_valid_within(page_to_pfn(page))) {
>  			page++;
>  			continue;
>  		}
>  
> +		/* Make sure we are not inadvertently changing nodes */
> +		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
> +
>  		if (!PageBuddy(page)) {
>  			page++;
>  			continue;

Acked-by: Will Deacon <will.deacon@arm.com>

I'm guessing akpm can pick this up as a non-urgent fix.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
