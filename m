Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C749C6B002E
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 01:36:38 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p9K5aa8t019260
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 22:36:36 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by wpaz5.hot.corp.google.com with ESMTP id p9K5a3C7014701
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 22:36:34 -0700
Received: by pzk1 with SMTP id 1so8183499pzk.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2011 22:36:32 -0700 (PDT)
Date: Wed, 19 Oct 2011 22:36:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
In-Reply-To: <1318927778.16132.52.camel@zakaz.uk.xensource.com>
Message-ID: <alpine.DEB.2.00.1110192236080.4618@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110131327470.24853@chino.kir.corp.google.com> <20111013.163708.1319779926961023813.davem@davemloft.net> <alpine.DEB.2.00.1110131348310.24853@chino.kir.corp.google.com> <20111013.165148.64222593458932960.davem@davemloft.net>
 <20111013142201.355f9afc.akpm@linux-foundation.org> <1318575363.11016.8.camel@dagon.hellion.org.uk> <1318927778.16132.52.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "jaxboe@fusionio.com" <jaxboe@fusionio.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 18 Oct 2011, Ian Campbell wrote:

> From 806b74572ad63e2ed3ca69bb5640a55dc4475e73 Mon Sep 17 00:00:00 2001
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Mon, 3 Oct 2011 16:46:54 +0100
> Subject: [PATCH] mm: add a "struct page_frag" type containing a page, offset and length
> 
> A few network drivers currently use skb_frag_struct for this purpose but I have
> patches which add additional fields and semantics there which these other uses
> do not want.
> 
> A structure for reference sub-page regions seems like a generally useful thing
> so do so instead of adding a network subsystem specific structure.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Acked-by: Jens Axboe <jaxboe@fusionio.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> [since v1: s/struct subpage/struct page_frag/ on advice from Christoph]
> [since v2: s/page_offset/offset/ on advice from Andrew]

Looks good, is this going to be going through net-next?

> ---
>  include/linux/mm_types.h |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 774b895..29971a5 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -135,6 +135,17 @@ struct page {
>  #endif
>  ;
>  
> +struct page_frag {
> +	struct page *page;
> +#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
> +	__u32 offset;
> +	__u32 size;
> +#else
> +	__u16 offset;
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
