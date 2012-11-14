Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 2EB136B005D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 19:58:49 -0500 (EST)
Date: Tue, 13 Nov 2012 16:58:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: fix null dev in dma_pool_create()
Message-Id: <20121113165847.4dcf968c.akpm@linux-foundation.org>
In-Reply-To: <50A2BE19.7000604@gmail.com>
References: <1352097996-25808-1-git-send-email-xi.wang@gmail.com>
	<50A2BE19.7000604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xi Wang <xi.wang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 13 Nov 2012 16:39:37 -0500
Xi Wang <xi.wang@gmail.com> wrote:

> A few drivers invoke dma_pool_create() with a null dev.  Note that dev
> is dereferenced in dev_to_node(dev), causing a null pointer dereference.
> 
> A long term solution is to disallow null dev.  Once the drivers are
> fixed, we can simplify the core code here.  For now we add WARN_ON(!dev)
> to notify the driver maintainers and avoid the null pointer dereference.
> 
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>

I'm not sure that I really suggested doing this :(

> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -135,6 +135,7 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>  {
>  	struct dma_pool *retval;
>  	size_t allocation;
> +	int node;
>  
>  	if (align == 0) {
>  		align = 1;
> @@ -159,7 +160,9 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>  		return NULL;
>  	}
>  
> -	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
> +	node = WARN_ON(!dev) ? -1 : dev_to_node(dev);
> +
> +	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, node);
>  	if (!retval)
>  		return retval;

We know there are a few scruffy drivers which are passing in dev==0. 

Those drivers don't oops because nobody is testing them on NUMA
systems.

With this patch, the kernel will now cause runtime warnings to be
emitted from those drivers.  Even on non-NUMA systems.


This is a problem!  What will happen is that this code will get
released by Linus and will propagate to users mainly via distros and
eventually end-user bug reports will trickle back saying "hey, I got
this warning".  Slowly people will fix the scruffy drivers and those
fixes will propagate out from Linus's tree into -stable and then into
distros and then into the end-users hands.

This is *terribly* inefficient!  It's a lot of work for a lot of people
and it involves long delays.

So let's not do any of that!  Let us try to get those scruffy drivers
fixed up *before* we add this warning.

As a nice side-effect of that work, we can then clean up the dmapool
code so it doesn't need to worry about handling the dev==0 special
case.

So.  To start this off, can you please generate a list of the offending
drivers?  Then we can hunt down the maintainers and we'll see what can be
done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
