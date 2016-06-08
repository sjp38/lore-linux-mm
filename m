Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB1E6B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 11:31:25 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id jt9so6690209obc.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 08:31:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id d63si1859123pfd.93.2016.06.08.08.31.24
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 08:31:24 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57583A49.30809@intel.com>
Date: Wed, 8 Jun 2016 08:31:21 -0700
MIME-Version: 1.0
In-Reply-To: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Odzioba <lukasz.odzioba@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, aarcange@redhat.com, vdavydov@parallels.com, mingli199x@qq.com, minchan@kernel.org
Cc: lukasz.anaczkowski@intel.com

On 06/08/2016 07:35 AM, Lukasz Odzioba wrote:
> diff --git a/mm/swap.c b/mm/swap.c
> index 9591614..3fe4f18 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -391,9 +391,8 @@ static void __lru_cache_add(struct page *page)
>  	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
>  
>  	get_page(page);
> -	if (!pagevec_space(pvec))
> +	if (!pagevec_add(pvec, page) || PageCompound(page))
>  		__pagevec_lru_add(pvec);
> -	pagevec_add(pvec, page);
>  	put_cpu_var(lru_add_pvec);
>  }

Lukasz,

Do we have any statistics that tell us how many pages are sitting the
lru pvecs?  Although this helps the problem overall, don't we still have
a problem with memory being held in such an opaque place?

I think if we're going to be hacking around this area, we should also
add something to vmstat or zoneinfo to spell out how many of these
things there are.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
