Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 1639C6B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 15:37:40 -0500 (EST)
Date: Mon, 5 Nov 2012 12:37:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix NULL checking in dma_pool_create()
Message-Id: <20121105123738.0a0490a7.akpm@linux-foundation.org>
In-Reply-To: <1352097996-25808-1-git-send-email-xi.wang@gmail.com>
References: <1352097996-25808-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xi Wang <xi.wang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon,  5 Nov 2012 01:46:36 -0500
Xi Wang <xi.wang@gmail.com> wrote:

> First, `dev' is dereferenced in dev_to_node(dev), suggesting that it
> must be non-null.  Later `dev' is checked against NULL, suggesting
> the opposite.  This patch adds a NULL check before its use.
> 
> ...
>
> @@ -159,7 +160,9 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>  		return NULL;
>  	}
>  
> -	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
> +	node = dev ? dev_to_node(dev) : -1;
> +
> +	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, node);
>  	if (!retval)
>  		return retval;

Well, the dma_pool_create() kerneldoc does not describe dev==NULL to be
acceptable usage and given the lack of oops reports, we can assume that
no code is calling this function with dev==NULL.

So I think we can just remove the code which handles dev==NULL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
