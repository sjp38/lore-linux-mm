Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 324722802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 04:18:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 97so6923897wrb.1
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 01:18:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d23si1915769wrb.528.2017.09.06.01.18.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 01:18:19 -0700 (PDT)
Subject: Re: [PATCH] mm, sparse: fix typo in online_mem_sections
References: <20170904112210.3401-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a5386f27-cbdf-dbab-ee9f-cc2a1ee48572@suse.cz>
Date: Wed, 6 Sep 2017 10:18:18 +0200
MIME-Version: 1.0
In-Reply-To: <20170904112210.3401-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/04/2017 01:22 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> online_mem_sections accidentally marks online only the first section in
> the given range. This is a typo which hasn't been noticed because I
> haven't tested large 2GB blocks previously. All users of
> pfn_to_online_page would get confused on the the rest of the pfn range
> in the block.
> 
> All we need to fix this is to use iterator (pfn) rather than start_pfn.
> 
> Fixes: 2d070eab2e82 ("mm: consider zone which is not fully populated to have holes")
> Cc: stable
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/sparse.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index a9783acf2bb9..83b3bf6461af 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -626,7 +626,7 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  	unsigned long pfn;
>  
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> -		unsigned long section_nr = pfn_to_section_nr(start_pfn);
> +		unsigned long section_nr = pfn_to_section_nr(pfn);
>  		struct mem_section *ms;
>  
>  		/* onlining code should never touch invalid ranges */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
