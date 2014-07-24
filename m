Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 732526B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:27:05 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id w8so2858196qac.2
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 06:27:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o39si11113121qga.10.2014.07.24.06.27.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 06:27:04 -0700 (PDT)
Date: Thu, 24 Jul 2014 08:45:11 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH]mm: fix potential infinite loop in
 dissolve_free_huge_pages()
Message-ID: <20140724124511.GA14379@nhori>
References: <1406194585.2586.15.camel@TP-T420>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406194585.2586.15.camel@TP-T420>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Zhong,

On Thu, Jul 24, 2014 at 05:36:25PM +0800, Li Zhong wrote:
> It is possible for some platforms, such as powerpc to set HPAGE_SHIFT to
> 0 to indicate huge pages not supported. 
> 
> When this is the case, hugetlbfs could be disabled during boot time:
> hugetlbfs: disabling because there are no supported hugepage sizes
> 
> Then in dissolve_free_huge_pages(), order is kept maximum (64 for
> 64bits), and the for loop below won't end:
> for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)

At first I wonder that why could dissolve_free_huge_pages() is called
if the platform doesn't support hugetlbfs. But I found that the function
is called by memory hotplug code without checking hugepage support.

So it looks to me straightforward and self-descriptive to check
hugepage_supported() just before calling dissolve_free_huge_pages().

Thanks,
Naoya Horiguchi

> The fix below returns directly if the order isn't set to a correct
> value.
> 
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> ---
>  mm/hugetlb.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 2024bbd..a950817 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1093,6 +1093,10 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	for_each_hstate(h)
>  		if (order > huge_page_order(h))
>  			order = huge_page_order(h);
> +
> +	if (order == 8 * sizeof(void *))
> +		return;
> +
>  	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
>  		dissolve_free_huge_page(pfn_to_page(pfn));
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
