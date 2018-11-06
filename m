Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A22C66B032F
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 09:08:03 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x98-v6so7753804ede.0
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 06:08:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u8-v6si12257257eju.138.2018.11.06.06.08.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 06:08:02 -0800 (PST)
Date: Tue, 6 Nov 2018 15:08:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 2/2] mm/page_alloc: remove software prefetching in
 __free_pages_core
Message-ID: <20181106140801.GO27423@dhcp22.suse.cz>
References: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
 <1541484194-1493-2-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541484194-1493-2-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Tue 06-11-18 11:33:14, Arun KS wrote:
> They not only increase the code footprint, they actually make things
> slower rather than faster. Remove them as contemporary hardware doesn't
> need any hint.

I guess I have already asked for that. When you argue about performance
then always add some numbers.

I do agree we want to get rid of the prefetching because it is just too
of an micro-optimization without any reasonable story behind.

> Suggested-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> ---
>  mm/page_alloc.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7cf503f..a1b9a6a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1270,14 +1270,10 @@ void __free_pages_core(struct page *page, unsigned int order)
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
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs
