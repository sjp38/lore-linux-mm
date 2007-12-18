Date: Tue, 18 Dec 2007 12:20:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 01/19] Define functions for page cache handling
In-Reply-To: <20071203141020.c8119197.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0712181216390.22286@schroedinger.engr.sgi.com>
References: <20071130173448.951783014@sgi.com> <20071130173506.366983341@sgi.com>
 <20071203141020.c8119197.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, mel@skynet.ie, wli@holomorphy.com, dgc@sgi.com, jens.axboe@oracle.com, pbadari@gmail.com, maximlevitsky@gmail.com, fengguang.wu@gmail.com, wangswin@gmail.com, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Dec 2007, Andrew Morton wrote:

> These will of course all work OK as they are presently implemented.
> 
> But you have callsites doing things like
> 
> 	page_cache_size(page_mapping(page));
> 
> which is a whole different thing.  Once page_cache_size() is changed to
> look inside the address_space we need to handle races against truncation
> and we need to handle the address_space getting reclaimed, etc.

Right. The page must be locked for that to work right. I tried to avoid
the above construct as much as possible by relying on the inode mapping. I 
can go over this again to make sure that there is nothing amiss after the 
recent changes.

> So I think it would be misleading to merge these changes at present - they
> make it _look_ like we can have variable PAGE_CACHE_SIZE just by tweaking a
> bit of core code, but we in fact cannot do that without a careful review of
> all callsites and perhaps the addition of new locking and null-checking.

The mapping is generally available in some form if you cannot get it from 
the page. In some cases I added a new parameter to functions to pass the 
mapping so that we do not have to use page->mapping. I can recheck that 
all is fine on that level.

> And a coding nit: when you implement the out-of-line versions of these
> functions you're going to stick with VFS conventions and use the identifier
> `mapping' to identify the address_space*.  So I think it would be better to
> also call in `mapping' in these inlined stubbed functions, rather than `a'.
> No?

Ok. A trivial change. But a is shorter and made the 
functions more concise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
