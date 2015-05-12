Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 095246B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 19:15:14 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so29565674pac.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 16:15:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id da1si24493439pad.9.2015.05.12.16.15.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 16:15:13 -0700 (PDT)
Date: Tue, 12 May 2015 16:15:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: initialize order with UINT_MAX in
 dissolve_free_huge_pages()
Message-Id: <20150512161511.7967c400cae6c1d693b61d57@linux-foundation.org>
In-Reply-To: <20150512092034.GF3068@hori1.linux.bs1.fc.nec.co.jp>
References: <20150511111748.GA20660@mwanda>
	<20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
	<20150512084339.GN16501@mwanda>
	<20150512090454.GD3068@hori1.linux.bs1.fc.nec.co.jp>
	<20150512091349.GO16501@mwanda>
	<20150512091640.GE3068@hori1.linux.bs1.fc.nec.co.jp>
	<20150512092034.GF3068@hori1.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 12 May 2015 09:20:35 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently the initial value of order in dissolve_free_huge_page is 64 or 32,
> which leads to the following warning in static checker:
> 
>   mm/hugetlb.c:1203 dissolve_free_huge_pages()
>   warn: potential right shift more than type allows '9,18,64'
> 
> This is a potential risk of infinite loop, because 1 << order (== 0) is used
> in for-loop like this:
> 
>   for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
>       ...
> 
> So this patch simply avoids the risk by initializing with UINT_MAX.
> 
> ..
>
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1188,7 +1188,7 @@ static void dissolve_free_huge_page(struct page *page)
>   */
>  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  {
> -	unsigned int order = 8 * sizeof(void *);
> +	unsigned int order = UINT_MAX;
>  	unsigned long pfn;
>  	struct hstate *h;
>  
> @@ -1200,6 +1200,7 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  		if (order > huge_page_order(h))
>  			order = huge_page_order(h);
>  	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
> +	VM_BUG_ON(order == UINT_MAX);
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
>  		dissolve_free_huge_page(pfn_to_page(pfn));

Do we need to calculate this each time?  Can it be done in
hugetlb_init_hstates(), save the result in a global?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
