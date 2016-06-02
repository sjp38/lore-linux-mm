Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE6DA6B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 21:19:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so19583558wme.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 18:19:34 -0700 (PDT)
Received: from smtpbgbr2.qq.com (smtpbgbr2.qq.com. [54.207.22.56])
        by mx.google.com with ESMTPS id id4si60461173wjb.67.2016.06.01.18.19.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Jun 2016 18:19:33 -0700 (PDT)
Subject: Re: Why __alloc_contig_migrate_range calls migrate_prep() at first?
References: <tencent_29E1A2CA78CE0C9046C1494E@qq.com>
 <20160601074010.GO19976@bbox>
From: Wang Sheng-Hui <shhuiw@foxmail.com>
Message-ID: <231748d4-6d9b-85d9-6796-e4625582e148@foxmail.com>
Date: Thu, 2 Jun 2016 09:19:19 +0800
MIME-Version: 1.0
In-Reply-To: <20160601074010.GO19976@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm <akpm@linux-foundation.org>, mgorman <mgorman@techsingularity.net>, "iamjoonsoo.kim" <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>



On 6/1/2016 3:40 PM, Minchan Kim wrote:
> On Wed, Jun 01, 2016 at 11:42:29AM +0800, Wang Sheng-Hui wrote:
>> Dear,
>>
>> Sorry to trouble you.
>>
>> I noticed cma_alloc would turn to  __alloc_contig_migrate_range for allocating pages.
>> But  __alloc_contig_migrate_range calls  migrate_prep() at first, even if the requested page
>> is single and free, lru_add_drain_all still run (called by  migrate_prep())?
>>
>> Image a large chunk of free contig pages for CMA, various drivers may request a single page from
>> the CMA area, we'll get  lru_add_drain_all run for each page.
>>
>> Should we detect if the required pages are free before migrate_prep(), or detect at least for single 
>> page allocation?
> That makes sense to me.
>
> How about calling migrate_prep once migrate_pages fails in the first trial?

Minchan,

I tried your patch in my env, and the number of calling migrate_prep() dropped a lot.

In my case, CMA reserved 512MB, and the linux will call migrate_prep() 40~ times during bootup,
most are single page allocation request to CMA.
With your patch, migrate_prep() is not called for the single pages allocation requests as the free
pages in CMA area is enough.

Will you please push the patch to upstream?

Thanks,
Sheng-Hui

>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9d666df5ef95..c504c1a623d2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6623,8 +6623,6 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>  	unsigned int tries = 0;
>  	int ret = 0;
>  
> -	migrate_prep();
> -
>  	while (pfn < end || !list_empty(&cc->migratepages)) {
>  		if (fatal_signal_pending(current)) {
>  			ret = -EINTR;
> @@ -6650,6 +6648,8 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>  
>  		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
>  				    NULL, 0, cc->mode, MR_CMA);
> +		if (ret)
> +			migrate_prep();
>  	}
>  	if (ret < 0) {
>  		putback_movable_pages(&cc->migratepages);
>
>
>> ------------------
>> Regards,
>> Wang Sheng-HuiN??2aeir,?zC?u(C)?2AE {-?ei1>>(R)&TH?)iAEic?O^n?r?????Ycj$ 1/2 ?$c,c1?-e?~?'.)iAA,yem??yA%?{+-?j+?de?x|j)Z?.?thfc?Uc{d 1/2 ?$c,??JPY?o???a



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
