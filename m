Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 762AC6B005D
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:28:19 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id h10so1740770pgf.3
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:28:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f9-v6si237835plk.94.2018.02.09.11.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Feb 2018 11:28:18 -0800 (PST)
Date: Fri, 9 Feb 2018 11:28:16 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: Split page_type out from _map_count
Message-ID: <20180209192816.GG16666@bombadil.infradead.org>
References: <20180207213047.6148-1-willy@infradead.org>
 <20180209105132.hhkjoijini3f74fz@node.shutemov.name>
 <20180209134942.GB16666@bombadil.infradead.org>
 <20180209152848.GF16666@bombadil.infradead.org>
 <7c5414ce-fece-b908-bebc-22fa15fc783c@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c5414ce-fece-b908-bebc-22fa15fc783c@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Fri, Feb 09, 2018 at 10:43:19AM -0800, Dave Hansen wrote:
> On 02/09/2018 07:28 AM, Matthew Wilcox wrote:
> >  	union {
> > +		/*
> > +		 * If the page is neither PageSlab nor PageAnon, the value
> > +		 * stored here may help distinguish it from page cache pages.
> > +		 * See page-flags.h for a list of page types which are
> > +		 * currently stored here.
> > +		 */
> > +		unsigned int page_type;
> > +
> >  		_slub_counter_t counters;
> >  		unsigned int active;		/* SLAB */
> >  		struct {			/* SLUB */
> 
> Are there any straightforward rules that we can enforce here?  For
> instance, if you are using "page_type", you can never have PG_lru set.
> 
> Not that we have done this at all for 'struct page' historically, it
> would be really convenient to have a clear definition for when
> "page_type" is valid vs. "_mapcount".

I agree, it'd be nice.  I think the only invariant we can claim to be
true is that if PageSlab is set then page_type is not valid.  There are
probably any number of bits in the page->flags that aren't currently in
use by any of the consumers who actually set page_type, but I don't feel
like there's a straightforward rule that we can enforce.  Maybe they'll
want to start using them in the future for their own purposes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
