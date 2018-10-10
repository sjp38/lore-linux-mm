Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7451F6B0270
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 12:39:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x44-v6so3488826edd.17
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 09:39:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r22-v6si6311036edm.167.2018.10.10.09.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 09:39:36 -0700 (PDT)
Subject: Re: [PATCH v5 2/2] mm/page_alloc: remove software prefetching in
 __free_pages_core
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
 <1538727006-5727-2-git-send-email-arunks@codeaurora.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e8afbe5e-06b1-f179-6292-1a5967432849@suse.cz>
Date: Wed, 10 Oct 2018 18:36:52 +0200
MIME-Version: 1.0
In-Reply-To: <1538727006-5727-2-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org
Cc: vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 10/5/18 10:10 AM, Arun KS wrote:
> They not only increase the code footprint, they actually make things
> slower rather than faster. Remove them as contemporary hardware doesn't
> need any hint.
> 
> Suggested-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Arun KS <arunks@codeaurora.org>

Yeah, a tight loop with fixed stride is a trivial case for hw prefetcher.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7ab5274..90db431 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1258,14 +1258,10 @@ void __free_pages_core(struct page *page, unsigned int order)
>  	struct page *p = page;
>  	unsigned int loop;
>  
> -	prefetchw(p);
> -	for (loop = 0; loop < (nr_pages - 1); loop++, p++) {
> -		prefetchw(p + 1);
> +	for (loop = 0; loop < nr_pages ; loop++, p++) {
>  		__ClearPageReserved(p);
>  		set_page_count(p, 0);
>  	}
> -	__ClearPageReserved(p);
> -	set_page_count(p, 0);
>  
>  	page_zone(page)->managed_pages += nr_pages;
>  	set_page_refcounted(page);
> 
