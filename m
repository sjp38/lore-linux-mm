Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB2B06B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 10:17:31 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f3-v6so1522518plf.1
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 07:17:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si526220pgf.82.2018.03.14.07.17.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Mar 2018 07:17:30 -0700 (PDT)
Date: Wed, 14 Mar 2018 15:17:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: fix boot hang in memmap_init_zone
Message-ID: <20180314141727.GE23100@dhcp22.suse.cz>
References: <20180313224240.25295-1-neelx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313224240.25295-1-neelx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sudeep Holla <sudeep.holla@arm.com>, Naresh Kamboju <naresh.kamboju@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Paul Burton <paul.burton@imgtec.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

On Tue 13-03-18 23:42:40, Daniel Vacek wrote:
> On some architectures (reported on arm64) commit 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
> causes a boot hang. This patch fixes the hang making sure the alignment
> never steps back.

I am sorry to be complaining again, but the code is so obscure that I
would _really_ appreciate some more information about what is going
on here. memblock_next_valid_pfn will most likely return a pfn within
the same memblock and the alignment will move it before the old pfn
which is not valid - so the block has some holes. Is that correct?
If yes then please put it into the changelog. Maybe reuse data provided
by Arnd http://lkml.kernel.org/r/20180314134431.13241-1-ard.biesheuvel@linaro.org
 
> Link: http://lkml.kernel.org/r/0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com
> Fixes: 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
> Signed-off-by: Daniel Vacek <neelx@redhat.com>
> Tested-by: Sudeep Holla <sudeep.holla@arm.com>
> Tested-by: Naresh Kamboju <naresh.kamboju@linaro.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Paul Burton <paul.burton@imgtec.com>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: <stable@vger.kernel.org>
> ---
>  mm/page_alloc.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3d974cb2a1a1..e033a6895c6f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5364,9 +5364,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  			 * is not. move_freepages_block() can shift ahead of
>  			 * the valid region but still depends on correct page
>  			 * metadata.
> +			 * Also make sure we never step back.
>  			 */
> -			pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
> +			unsigned long next_pfn;
> +
> +			next_pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>  					~(pageblock_nr_pages-1)) - 1;
> +			if (next_pfn > pfn)
> +				pfn = next_pfn;
>  #endif
>  			continue;
>  		}
> -- 
> 2.16.2
> 

-- 
Michal Hocko
SUSE Labs
