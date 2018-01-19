Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC3776B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:40:02 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e26so1718245pfi.15
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:40:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e1-v6si807448pli.207.2018.01.19.04.40.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 04:40:01 -0800 (PST)
Date: Fri, 19 Jan 2018 13:39:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Fix explanation of lower bits in the SPARSEMEM mem_map
 pointer
Message-ID: <20180119123956.GZ6584@dhcp22.suse.cz>
References: <20180119080908.3a662e6f@ezekiel.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119080908.3a662e6f@ezekiel.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Tesarik <ptesarik@suse.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>

On Fri 19-01-18 08:09:08, Petr Tesarik wrote:
[...]
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 67f2e3c38939..7522a6987595 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1166,8 +1166,16 @@ extern unsigned long usemap_size(void);
>  
>  /*
>   * We use the lower bits of the mem_map pointer to store
> - * a little bit of information.  There should be at least
> - * 3 bits here due to 32-bit alignment.
> + * a little bit of information.  The pointer is calculated
> + * as mem_map - section_nr_to_pfn(pnum).  The result is
> + * aligned to the minimum alignment of the two values:
> + *   1. All mem_map arrays are page-aligned.
> + *   2. section_nr_to_pfn() always clears PFN_SECTION_SHIFT
> + *      lowest bits.  PFN_SECTION_SHIFT is arch-specific
> + *      (equal SECTION_SIZE_BITS - PAGE_SHIFT), and the
> + *      worst combination is powerpc with 256k pages,
> + *      which results in PFN_SECTION_SHIFT equal 6.
> + * To sum it up, at least 6 bits are available.
>   */

This is _much_ better indeed. Do you think we can go one step further
and add BUG_ON into the sparse code to guarantee that every mmemap
is indeed aligned properly so that SECTION_MAP_LAST_BIT-1 bits are never
used?

Thanks!

>  #define	SECTION_MARKED_PRESENT	(1UL<<0)
>  #define SECTION_HAS_MEM_MAP	(1UL<<1)
> -- 
> 2.13.6

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
