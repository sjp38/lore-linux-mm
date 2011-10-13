Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 241746B017D
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 17:22:08 -0400 (EDT)
Received: by pzk4 with SMTP id 4so3964845pzk.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:22:04 -0700 (PDT)
Date: Thu, 13 Oct 2011 14:22:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
Message-Id: <20111013142201.355f9afc.akpm@linux-foundation.org>
In-Reply-To: <20111013.165148.64222593458932960.davem@davemloft.net>
References: <alpine.DEB.2.00.1110131327470.24853@chino.kir.corp.google.com>
	<20111013.163708.1319779926961023813.davem@davemloft.net>
	<alpine.DEB.2.00.1110131348310.24853@chino.kir.corp.google.com>
	<20111013.165148.64222593458932960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: rientjes@google.com, ian.campbell@citrix.com, linux-kernel@vger.kernel.org, hch@infradead.org, jaxboe@fusionio.com, linux-mm@kvack.org

On Thu, 13 Oct 2011 16:51:48 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> >> 
> >> http://patchwork.ozlabs.org/patch/118693/
> >> http://patchwork.ozlabs.org/patch/118694/
> >> http://patchwork.ozlabs.org/patch/118695/
> >> http://patchwork.ozlabs.org/patch/118700/
> >> http://patchwork.ozlabs.org/patch/118696/
> >> http://patchwork.ozlabs.org/patch/118699/
> >> 
> >> This is a replacement for patch #1 in that series.
> >> 
> > 
> > Ok, let's add Andrew to the thread so this can go through -mm in 
> > preparation for that series.
> 
> It doesn't usually work like that, net-next is usually one of the first
> trees that Stephen pulls into -next, so this kind of simple dependency should
> go into my tree

yup.

> if the -mm developers give it an ACK and are OK with it.

Looks OK to me.  I'm surprised we don't already have such a thing.

Review comments:


> +struct page_frag {
> +	struct page *page;
> +#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)

It does add risk that people will add compile warnings and bugs by
failing to consider or test the other case.

We could reduce that risk by doing

   #if (PAGE_SIZE >= 65536)

but then the 32-bit version would hardly ever be tested at all.

> +	__u32 page_offset;

I suggest this be called simply "offset".

> +	__u32 size;
> +#else
> +	__u16 page_offset;
> +	__u16 size;
> +#endif
> +};
> 	
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
