Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 89A0D6B0037
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:33:56 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p9DKXrZ6020150
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:33:53 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz29.hot.corp.google.com with ESMTP id p9DKQDUn002890
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:33:51 -0700
Received: by pzk33 with SMTP id 33so5311196pzk.4
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:33:47 -0700 (PDT)
Date: Thu, 13 Oct 2011 13:33:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
In-Reply-To: <1318500176-10728-1-git-send-email-ian.campbell@citrix.com>
Message-ID: <alpine.DEB.2.00.1110131327470.24853@chino.kir.corp.google.com>
References: <1318500176-10728-1-git-send-email-ian.campbell@citrix.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <ian.campbell@citrix.com>
Cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm@kvack.org

On Thu, 13 Oct 2011, Ian Campbell wrote:

> A few network drivers currently use skb_frag_struct for this purpose but I have
> patches which add additional fields and semantics there which these other uses
> do not want.
> 

Is this patch a part of a larger series that actually uses 
struct page_frag?  Probably a good idea to post them so we know it doesn't 
just lie there dormant.

> A structure for reference sub-page regions seems like a generally useful thing
> so do so instead of adding a network subsystem specific structure.
> 

Agreed.

> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Jens Axboe <jaxboe@fusionio.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> [since v1: s/struct subpage/struct page_frag/ on advice from Christoph]

Acked-by: David Rientjes <rientjes@google.com>

> ---
>  include/linux/mm_types.h |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 774b895..575faaf 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -135,6 +135,17 @@ struct page {
>  #endif
>  ;
>  
> +struct page_frag {
> +	struct page *page;
> +#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
> +	__u32 page_offset;
> +	__u32 size;
> +#else
> +	__u16 page_offset;
> +	__u16 size;
> +#endif
> +};
> +
>  typedef unsigned long __nocast vm_flags_t;
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
