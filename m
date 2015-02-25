Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DAAEF6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 21:34:23 -0500 (EST)
Received: by padet14 with SMTP id et14so1400284pad.11
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 18:34:23 -0800 (PST)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-251.mail.alibaba.com. [205.204.113.251])
        by mx.google.com with ESMTP id qn15si366443pab.114.2015.02.24.18.34.21
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 18:34:23 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [patch] mm, hugetlb: close race when setting PageTail for gigantic pages
Date: Wed, 25 Feb 2015 10:32:45 +0800
Message-ID: <068c01d050a3$57c90eb0$075b2c10$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'David Rientjes' <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 'Davidlohr Bueso' <dave@stgolabs.net>, 'Luiz Capitulino' <lcapitulino@redhat.com>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hillf Danton <hillf.zj@alibaba-inc.com>

> Now that gigantic pages are dynamically allocatable, care must be taken
> to ensure that p->first_page is valid before setting PageTail.
> 
> If this isn't done, then it is possible to race and have compound_head()
> return NULL.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/hugetlb.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -917,7 +917,6 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
>  	__SetPageHead(page);
>  	__ClearPageReserved(page);
>  	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
> -		__SetPageTail(p);
>  		/*
>  		 * For gigantic hugepages allocated through bootmem at
>  		 * boot, it's safer to be consistent with the not-gigantic
> @@ -933,6 +932,9 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
>  		__ClearPageReserved(p);
>  		set_page_count(p, 0);
>  		p->first_page = page;
> +		/* Make sure p->first_page is always valid for PageTail() */
> +		smp_wmb();
> +		__SetPageTail(p);
>  	}
>  }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
