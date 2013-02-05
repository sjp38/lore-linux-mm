Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 30E736B00FF
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 03:38:34 -0500 (EST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MHQ008TKO01O320@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Feb 2013 08:38:32 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MHQ00AS9O067G00@eusync4.samsung.com> for linux-mm@kvack.org;
 Tue, 05 Feb 2013 08:38:31 +0000 (GMT)
Message-id: <5110C506.2060209@samsung.com>
Date: Tue, 05 Feb 2013 09:38:30 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high memory
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
 <20130204150657.6d05f76a.akpm@linux-foundation.org>
 <CAH9JG2Usd4HJKrBXwX3aEc3i6068zU=F=RjcoQ8E8uxYGrwXgg@mail.gmail.com>
 <20130204234358.GB2610@blaptop>
 <CAH9JG2VDOVv4-QrDs1FeyQNPzEDq+bf+qiSZ0snEqLGSed3PqA@mail.gmail.com>
 <20130205004032.GD2610@blaptop>
In-reply-to: <20130205004032.GD2610@blaptop>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de

Hello,

On 2/5/2013 1:40 AM, Minchan Kim wrote:

...

> > Previous time, it's not fully tested and now we checked it with
> > highmem support patches.
>
> I get it. Sigh. then [1] inline attached below wan't good.
> We have to code like this?
>
> [1] 6a6dccba, mm: cma: don't replace lowmem pages with highmem
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b97cf12..0707e0a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5671,11 +5671,10 @@ static struct page *
>   __alloc_contig_migrate_alloc(struct page *page, unsigned long private,
>                               int **resultp)
>   {
> -       gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
> -
> -       if (PageHighMem(page))
> -               gfp_mask |= __GFP_HIGHMEM;
> -
> +       gfp_t gfp_mask = GFP_HIGHUSER_MOVABLE;
> +       struct address_space *mapping = page_mapping(page);
> +       if (mapping)
> +               gfp_mask = mapping_gfp_mask(mapping);
>          return alloc_page(gfp_mask);
>   }

Am I right that this code will allocate more pages from himem? Old approach
never migrate lowmem page to himem, what is now possible as gfp mask is 
always
taken from mapping_gfp flags. I only wonder if forcing GFP_HIGHUSER_MOVABLE
for pages without the mapping is a correct. Shouldn't we use avoid himem in
such case?

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
