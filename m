Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 08F486B0070
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:03:28 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bh2so2419791pad.5
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:03:28 -0800 (PST)
Date: Thu, 20 Dec 2012 16:03:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] cma: use unsigned type for count argument
In-Reply-To: <20121220153525.97841100.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1212201557270.13223@chino.kir.corp.google.com>
References: <52fd3c7b677ff01f1cd6d54e38a567b463ec1294.1355938871.git.mina86@mina86.com> <20121220153525.97841100.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mpn@google.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 20 Dec 2012, Andrew Morton wrote:

> > Specifying negative size of buffer makes no sense and thus this commit
> > changes the type of the count argument to unsigned.
> > 
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -1038,9 +1038,9 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
> >  					  gfp_t gfp, struct dma_attrs *attrs)
> >  {
> >  	struct page **pages;
> > -	int count = size >> PAGE_SHIFT;
> > -	int array_size = count * sizeof(struct page *);
> > -	int i = 0;
> > +	unsigned int count = size >> PAGE_SHIFT;
> > +	unsigned int array_size = count * sizeof(struct page *);
> > +	unsigned int i = 0;
> 
> C programmers expect a variable called `i' to have type `int'.  It
> would be clearer to find a new name for this.  `idx', perhaps.
> 

I didn't ack this because there's no bounds checking on 
dma_alloc_from_contiguous() and bitmap_set() has a dangerous side-effect 
when called with an overflowed nr since it takes a signed argument.  
Marek, is there some sane upper bound we can put on count?

Additionally, I think at least this is needed for callers of bitmap_set() 
for some sanity (unless someone wants to audit the almost 100 callers and 
change it to unsigned as well).  There's probably additional nastiness in 
this library as well, I didn't check.
---
diff --git a/lib/bitmap.c b/lib/bitmap.c
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -287,7 +287,7 @@ void bitmap_set(unsigned long *map, int start, int nr)
 		mask_to_set = ~0UL;
 		p++;
 	}
-	if (nr) {
+	if (nr > 0) {
 		mask_to_set &= BITMAP_LAST_WORD_MASK(size);
 		*p |= mask_to_set;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
