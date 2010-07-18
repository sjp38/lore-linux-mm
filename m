Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E37BA600365
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 03:53:22 -0400 (EDT)
Message-ID: <4C42B2E4.4040504@cs.helsinki.fi>
Date: Sun, 18 Jul 2010 10:53:08 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] Use xvmalloc to store compressed chunks
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org> <1279283870-18549-8-git-send-email-ngupta@vflare.org>
In-Reply-To: <1279283870-18549-8-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nitin Gupta wrote:
> @@ -528,17 +581,32 @@ static int zcache_store_page(struct zcache_inode_rb *znode,
>  		goto out;
>  	}
>  
> -	dest_data = kmap_atomic(zpage, KM_USER0);
> +	local_irq_save(flags);

Does xv_malloc() required interrupts to be disabled? If so, why doesn't 
the function do it by itself?

> +	ret = xv_malloc(zpool->xv_pool, clen + sizeof(*zheader),
> +			&zpage, &zoffset, GFP_NOWAIT);
> +	local_irq_restore(flags);
> +	if (unlikely(ret)) {
> +		ret = -ENOMEM;
> +		preempt_enable();
> +		goto out;
> +	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
