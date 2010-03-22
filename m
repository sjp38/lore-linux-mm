Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 62F5B6B01AC
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 07:33:23 -0400 (EDT)
Date: Mon, 22 Mar 2010 22:33:17 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm, fs: warn on missing address space operations
Message-ID: <20100322113317.GK17637@laptop>
References: <20100322053937.GA17637@laptop>
 <20100322110758.GA13690@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100322110758.GA13690@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 07:07:58AM -0400, Christoph Hellwig wrote:
> > @@ -2472,7 +2472,14 @@ int try_to_release_page(struct page *pag
> >  
> >  	if (mapping && mapping->a_ops->releasepage)
> >  		return mapping->a_ops->releasepage(page, gfp_mask);
> > -	return try_to_free_buffers(page);
> > +	else {
> > +		static bool warned = false;
> > +		if (!warned) {
> > +			warned = true;
> > +			print_symbol("address_space_operations %s missing releasepage method. Use try_to_free_buffers.\n", (unsigned long)page->mapping->a_ops);
> > +		}
> > +		return try_to_free_buffers(page);
> > +	}
> 
> I don't think this is correct.  We currently also call
> try_to_free_buffers if the page does not have a mapping, and from
> conversations with Andrew long time ago that case actually does seem to
> be nessecary due to behaviour in ext3/jbd.  So you really should
> only warn if there is a mapping to start with.  In fact your code will
> dereference a potential NULL pointer in that case.

Good point.

I think some of that code is actually dead.

is_page_cache_freeable will check for the page reclaim reference,
the pagecache reference, and the PagePrivate reference.

If the page is removed from pagecache, that reference will be
dropped but is_page_cache_freeable() will not consider that and
fail.

NULL page can still come in there from buffer_heads_over_limit AFAIKS,
but if we are relying on that for freeing pages then it can break if a
lot of memory is tied up in other things.

That's all really ugly too. It means no other filesystem may take an 
action to take in case of NULL page->mapping, which means it is really
the wrong thing to do. Fortunately fsblock has proper refcounting so it
would never need to handle this case.

> 
> And as others said, this patch only makes sense after the existing
> filesystems are updated to fill out all methods, and for the case
> of try_to_free_buffers and set_page_dirty until we have suitable
> and well-named default operations available.

__set_page_dirty_nobuffers seems OK. Everyone has had to use that
until now anyway. Agreed about try_to_free_buffers.

> 
> Btw, any reason this doesn't use the %pf specifier to printk
> instead of dragging in print_symbol?  Even better would
> be to just print the fs type from mapping->host->i_sb->s_type->name.

Ah, because I didn't know about it. Thanks. Name I guess can be
ambiguous if there is more than one aop. I'll make it a macro and
print both maybe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
