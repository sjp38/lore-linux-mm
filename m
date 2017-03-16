Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D63366B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 05:17:21 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y90so7360052wrb.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:17:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h19si5855114wrc.138.2017.03.16.02.17.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 02:17:20 -0700 (PDT)
Date: Thu, 16 Mar 2017 10:17:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-sparse-refine-usemap_size-a-little.patch added to -mm tree
Message-ID: <20170316091718.GA30508@dhcp22.suse.cz>
References: <58c32b92.qgOCFj/bIjx+ym6m%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58c32b92.qgOCFj/bIjx+ym6m%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: richard.weiyang@gmail.com, tj@kernel.org, mm-commits@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

[CC Mel]

On Fri 10-03-17 14:41:22, Andrew Morton wrote:
> From: Wei Yang <richard.weiyang@gmail.com>
> Subject: mm/sparse: refine usemap_size() a little
> 
> Current implementation calculates usemap_size in two steps:
>     * calculate number of bytes to cover these bits
>     * calculate number of "unsigned long" to cover these bytes
> 
> It would be more clear by:
>     * calculate number of "unsigned long" to cover these bits
>     * multiple it with sizeof(unsigned long)
> 
> This patch refine usemap_size() a little to make it more easy to
> understand.

I haven't checked deeply yet but reading through 5c0e3066474b ("Fix
corruption of memmap on IA64 SPARSEMEM when mem_section is not a power
of 2") made me ask whether the case described in the commit message
still applies after this change or whether it has been considered at
all.

> Link: http://lkml.kernel.org/r/20170310043713.96871-1-richard.weiyang@gmail.com
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/sparse.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff -puN mm/sparse.c~mm-sparse-refine-usemap_size-a-little mm/sparse.c
> --- a/mm/sparse.c~mm-sparse-refine-usemap_size-a-little
> +++ a/mm/sparse.c
> @@ -248,10 +248,7 @@ static int __meminit sparse_init_one_sec
>  
>  unsigned long usemap_size(void)
>  {
> -	unsigned long size_bytes;
> -	size_bytes = roundup(SECTION_BLOCKFLAGS_BITS, 8) / 8;
> -	size_bytes = roundup(size_bytes, sizeof(unsigned long));
> -	return size_bytes;
> +	return BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS) * sizeof(unsigned long);
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> _
> 
> Patches currently in -mm which might be from richard.weiyang@gmail.com are
> 
> mm-sparse-refine-usemap_size-a-little.patch
> mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
> 
> --
> To unsubscribe from this list: send the line "unsubscribe mm-commits" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
