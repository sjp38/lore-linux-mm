Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id AEC026B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 10:33:45 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id f51so8651377qge.18
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 07:33:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v6si32479704qge.21.2014.07.28.07.33.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 07:33:44 -0700 (PDT)
Date: Mon, 28 Jul 2014 10:33:36 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2]mm: fix potential infinite loop in
 dissolve_free_huge_pages()
Message-ID: <20140728143336.GB27391@nhori.redhat.com>
References: <1406194585.2586.15.camel@TP-T420>
 <20140724124511.GA14379@nhori>
 <1406514043.2941.6.camel@TP-T420>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406514043.2941.6.camel@TP-T420>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nadia.yvette.chambers@gmail.com>

On Mon, Jul 28, 2014 at 10:20:43AM +0800, Li Zhong wrote:
> It is possible for some platforms, such as powerpc to set HPAGE_SHIFT to
> 0 to indicate huge pages not supported. 
> 
> When this is the case, hugetlbfs could be disabled during boot time:
> hugetlbfs: disabling because there are no supported hugepage sizes
> 
> Then in dissolve_free_huge_pages(), order is kept maximum (64 for
> 64bits), and the for loop below won't end:
> for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
> 
> As suggested by Naoya, below fix checks hugepages_supported() before
> calling dissolve_free_huge_pages().
> 
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>

Thanks!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

And I think that this patch can go into stable (3.12+) trees.

> ---
>  mm/memory_hotplug.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 469bbf5..f642701 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1695,7 +1695,8 @@ repeat:
>  	 * dissolve free hugepages in the memory block before doing offlining
>  	 * actually in order to make hugetlbfs's object counting consistent.
>  	 */
> -	dissolve_free_huge_pages(start_pfn, end_pfn);
> +	if (hugepages_supported())
> +		dissolve_free_huge_pages(start_pfn, end_pfn);
>  	/* check again */
>  	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
>  	if (offlined_pages < 0) {
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
