Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 895976B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 07:34:42 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so21089367wic.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 04:34:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bh4si699524wjb.66.2015.09.10.04.34.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 04:34:41 -0700 (PDT)
Subject: Re: [PATCHv5 7/7] mm: use 'unsigned int' for
 compound_dtor/compound_order on 64BIT
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1441283758-92774-8-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F16ACD.2010104@suse.cz>
Date: Thu, 10 Sep 2015 13:34:37 +0200
MIME-Version: 1.0
In-Reply-To: <1441283758-92774-8-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/03/2015 02:35 PM, Kirill A. Shutemov wrote:
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
> 
> On other architectures without native support of 16-bit data types the
> difference can be bigger.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
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

I'm indifferent to this change. But some comment here to explain would avoid git
blame to figure out why it's done?

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
