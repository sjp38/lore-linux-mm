Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 201B66B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 19:47:56 -0500 (EST)
Date: Tue, 13 Nov 2012 16:47:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: fix null dev in dma_pool_create()
Message-Id: <20121113164754.cd1426de.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1211131458440.17623@chino.kir.corp.google.com>
References: <1352097996-25808-1-git-send-email-xi.wang@gmail.com>
	<50A2BE19.7000604@gmail.com>
	<alpine.DEB.2.00.1211131458440.17623@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Xi Wang <xi.wang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 13 Nov 2012 15:01:34 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 13 Nov 2012, Xi Wang wrote:
> 
> > diff --git a/mm/dmapool.c b/mm/dmapool.c
> > index c5ab33b..bf7f8f0 100644
> > --- a/mm/dmapool.c
> > +++ b/mm/dmapool.c
> > @@ -135,6 +135,7 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
> >  {
> >  	struct dma_pool *retval;
> >  	size_t allocation;
> > +	int node;
> >  
> >  	if (align == 0) {
> >  		align = 1;
> > @@ -159,7 +160,9 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
> >  		return NULL;
> >  	}
> >  
> > -	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
> > +	node = WARN_ON(!dev) ? -1 : dev_to_node(dev);
> > +
> > +	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, node);
> >  	if (!retval)
> >  		return retval;
> >  
> 
> Begs the question why we don't just do something like this generically?
> ---
> diff --git a/include/linux/device.h b/include/linux/device.h
> --- a/include/linux/device.h
> +++ b/include/linux/device.h
> @@ -718,7 +718,7 @@ int dev_set_name(struct device *dev, const char *name, ...);
>  #ifdef CONFIG_NUMA
>  static inline int dev_to_node(struct device *dev)
>  {
> -	return dev->numa_node;
> +	return WARN_ON(!dev) ? NUMA_NO_NODE : dev->numa_node;
>  }

WARN and friends can cause quite a lot of code to be generated, so they're
a rather bloat-risky thing to include in a little inlined helper
function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
