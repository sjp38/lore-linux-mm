Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B75D6B0006
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 05:30:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x10-v6so905181edx.9
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 02:30:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7-v6si689272edf.24.2018.10.09.02.30.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 02:30:38 -0700 (PDT)
Date: Tue, 9 Oct 2018 11:30:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm/page_alloc: remove software prefetching in
 __free_pages_core
Message-ID: <20181009093037.GI8528@dhcp22.suse.cz>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
 <1538727006-5727-2-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538727006-5727-2-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Fri 05-10-18 13:40:06, Arun KS wrote:
> They not only increase the code footprint, they actually make things
> slower rather than faster. Remove them as contemporary hardware doesn't
> need any hint.

I agree with the change but it is much better to add some numbers
whenever arguing about performance impact.

> 
> Suggested-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Arun KS <arunks@codeaurora.org>
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
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs
