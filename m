Date: Wed, 2 Nov 2005 20:12:43 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: New bug in patch and existing Linux code - race with install_page()
 (was: Re: [PATCH] 2.6.14 patch for supporting madvise(MADV_REMOVE))
In-Reply-To: <200511022054.15119.blaisorblade@yahoo.it>
Message-ID: <Pine.LNX.4.61.0511022003070.17607@goblin.wat.veritas.com>
References: <1130366995.23729.38.camel@localhost.localdomain>
 <20051102014321.GG24051@opteron.random> <1130947957.24503.70.camel@localhost.localdomain>
 <200511022054.15119.blaisorblade@yahoo.it>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, lkml <linux-kernel@vger.kernel.org>, akpm@osdl.org, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Nov 2005, Blaisorblade wrote:
> While looking into this, I probably found another problem, a race with 
> install_page(), which doesn't use the seqlock-style check we use for 
> everything else (aka do_no_page) but simply assumes a page is valid if its 
> index is below the current file size.
> 
> This is clearly "truncate" specific, and is already racy. Suppose I truncate a 
> file and reduce its size, and then re-extend it, the page which I previously 
> fetched from the cache is invalid. The current install_page code generates 
> corruption.

No, it should be fine as is (unless perhaps some barrier is needed).

The check
	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
	if (!page->mapping || page->index >= size)
		goto err_unlock;
handles the case that worries you: page->mapping will be NULL.

do_no_page has to do the more complicated truncate_count business because
it deals with all kinds of ->nopage, some of which leave page->mapping NULL:
so it's unable to distinguish one where the driver left it NULL from one
where truncation has suddenly made it NULL.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
