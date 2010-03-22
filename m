Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7843F6B01AC
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 07:08:01 -0400 (EDT)
Date: Mon, 22 Mar 2010 07:07:58 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch] mm, fs: warn on missing address space operations
Message-ID: <20100322110758.GA13690@infradead.org>
References: <20100322053937.GA17637@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100322053937.GA17637@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> @@ -2472,7 +2472,14 @@ int try_to_release_page(struct page *pag
>  
>  	if (mapping && mapping->a_ops->releasepage)
>  		return mapping->a_ops->releasepage(page, gfp_mask);
> -	return try_to_free_buffers(page);
> +	else {
> +		static bool warned = false;
> +		if (!warned) {
> +			warned = true;
> +			print_symbol("address_space_operations %s missing releasepage method. Use try_to_free_buffers.\n", (unsigned long)page->mapping->a_ops);
> +		}
> +		return try_to_free_buffers(page);
> +	}

I don't think this is correct.  We currently also call
try_to_free_buffers if the page does not have a mapping, and from
conversations with Andrew long time ago that case actually does seem to
be nessecary due to behaviour in ext3/jbd.  So you really should
only warn if there is a mapping to start with.  In fact your code will
dereference a potential NULL pointer in that case.

And as others said, this patch only makes sense after the existing
filesystems are updated to fill out all methods, and for the case
of try_to_free_buffers and set_page_dirty until we have suitable
and well-named default operations available.

Btw, any reason this doesn't use the %pf specifier to printk
instead of dragging in print_symbol?  Even better would
be to just print the fs type from mapping->host->i_sb->s_type->name.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
