Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C58D6900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 11:21:36 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3IF9LJS016474
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 09:09:21 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3IFLPQi051024
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 09:21:26 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3IFLOY6007061
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 09:21:25 -0600
Subject: Re: [PATCH 2/2] print vmalloc() state after allocation failures
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104161702300.14788@chino.kir.corp.google.com>
References: <20110415170437.17E1AF36@kernel>
	 <20110415170438.D5C317D5@kernel> <op.vtzo4ejf3l0zgt@mnazarewicz-glaptop>
	 <1302889441.16562.3525.camel@nimitz>
	 <alpine.DEB.2.00.1104161702300.14788@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 18 Apr 2011 08:21:22 -0700
Message-ID: <1303140082.9615.2584.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat, 2011-04-16 at 17:03 -0700, David Rientjes wrote:
> >  fail:
> > +     warn_alloc_failed(gfp_mask, order, "vmalloc: allocation failure, "
> > +                       "allocated %ld of %ld bytes\n",
> > +                       (area->nr_pages*PAGE_SIZE), area->size);
> >       vfree(area->addr);
> >       return NULL;
> >  }
> 
> Sorry, I still don't understand why this isn't just a three-liner patch to 
> call warn_alloc_failed().  I don't see the benefit of the "order" or 
> "tmp_mask" variables at all, they'll just be removed next time someone 
> goes down the mm/* directory and looks for variables that are used only 
> once or are unchanged as a cleanup. 

Without the "order" variable, we have:

	warn_alloc_failed(gfp_mask, 0, "vmalloc: allocation failure, "
		"allocated %ld of %ld bytes\n",
		(area->nr_pages*PAGE_SIZE), area->size);

I *HATE* those with a passion.  What is the '0' _doing_?  Is it for "0
pages", "do not print", "_do_ print"?  There's no way to tell without
going and finding warn_alloc_failed()'s definition.

With 'order' in there, the code self-documents, at least from the
caller's side.  It makes it 100% clear that the "0" being passed to the
allocators is that same as the one passed to the warning; it draws a
link between the allocations and the allocation error message:

	warn_alloc_failed(gfp_mask, order, "vmalloc: allocation failure, "
		"allocated %ld of %ld bytes\n",
		(area->nr_pages*PAGE_SIZE), area->size);

As for the 'tmp_mask' business.  Right now we have:

        for (i = 0; i < area->nr_pages; i++) {
                struct page *page;
+               gfp_t tmp_mask = gfp_mask | __GFP_NOWARN;

                if (node < 0)
-                       page = alloc_page(gfp_mask);
+                       page = alloc_page(tmp_mask);
                else
-                       page = alloc_pages_node(node, gfp_mask, 0);
+                       page = alloc_pages_node(node, tmp_mask, order);

The alternative is this:

        for (i = 0; i < area->nr_pages; i++) {
                struct page *page;

                if (node < 0)
-                       page = alloc_page(gfp_mask);
+                       page = alloc_page(gfp_mask | __GFP_NOWARN);
                else
-                       page = alloc_pages_node(node, gfp_mask, 0);
+                       page = alloc_pages_node(node, gfp_mask | __GFP_NOWARN,
+						order);

I can go look, but I bet the compiler compiles down to the same thing.
Plus, they're the same number of lines in the end.  I know which one
appeals to me visually.

I think we're pretty deep in personal preference territory here.  If I
hear a consensus that folks like it one way over another, I'm happy to
change it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
