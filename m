Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D33FB6B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:19:07 -0400 (EDT)
Received: by wicge2 with SMTP id ge2so5322953wic.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:19:07 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id iz2si5489876wic.52.2015.08.27.08.19.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 08:19:06 -0700 (PDT)
Received: by wicgk12 with SMTP id gk12so12037034wic.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:19:06 -0700 (PDT)
Date: Thu, 27 Aug 2015 17:19:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv4 7/7] mm: use 'unsigned int' for
 compound_dtor/compound_order on 64BIT
Message-ID: <20150827151904.GG27052@dhcp22.suse.cz>
References: <1440683961-32839-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1440683961-32839-8-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440683961-32839-8-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 27-08-15 16:59:21, Kirill A. Shutemov wrote:
> On 64 bit system we have enough space in struct page to encode
> compound_dtor and compound_order with unsigned int.
> 
> On x86-64 it leads to slightly smaller code size due usesage of plain
> MOV instead of MOVZX (zero-extended move) or similar effect.
> 
> allyesconfig:
> 
>    text	   data	    bss	    dec	    hex	filename
> 159520446	48146736	72196096	279863278	10ae5fee	vmlinux.pre
> 159520382	48146736	72196096	279863214	10ae5fae	vmlinux.post

64B is not much, really, but if that works as a microptimization then I
have no objections.

> On other architectures without native support of 16-bit data types the
> difference can be bigger.

Thank you for pulling this out of the original patch.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm_types.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index ecaf3b1d0216..39b0db74ba5e 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -150,8 +150,13 @@ struct page {
>  		/* First tail page of compound page */
>  		struct {
>  			unsigned long compound_head; /* If bit zero is set */
> +#ifdef CONFIG_64BIT
> +			unsigned int compound_dtor;
> +			unsigned int compound_order;
> +#else
>  			unsigned short int compound_dtor;
>  			unsigned short int compound_order;
> +#endif
>  		};
>  
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
> -- 
> 2.5.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
