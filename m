Date: Thu, 29 Mar 2007 14:10:55 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc][patch 1/2] mm: dont account ZERO_PAGE
In-Reply-To: <20070329075805.GA6852@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
References: <20070329075805.GA6852@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 29 Mar 2007, Nick Piggin wrote:
> 
> Special-case the ZERO_PAGE to prevent it from being accounted like a normal
> mapped page. This is not illogical or unclean, because the ZERO_PAGE is
> heavily special cased through the page fault path.

Thou dost protest too much!  By "heavily special cased through the page
fault path" you mean do_wp_page() uses a pre-zeroed page when it spots
it, instead of copying its data.  That's rather a different case.

Look, I don't have any vehement objection to exempting the ZERO_PAGE
from accounting: if you remember before, I just suggested it was of
questionable value to exempt it, and the exemption should be made a
separate patch.

But this patch is not complete, is it?  For example, fremap.c's
zap_pte?  I haven't checked further.  I was going to suggest you
should make ZERO_PAGEs fail vm_normal_page, but I guess do_wp_page
wouldn't behave very well then ;)  Tucking the tests away in some
vm_normal_page-like function might make them more acceptable.

> A test-case which took over 2 hours to complete on a 1024 core Altix
> takes around 2 seconds afterward.

Oh, it's easy to devise a test-case of that kind, but does it matter
in real life?  I admit that what most people run on their 1024-core
Altices will be significantly different from what I checked on my
laptop back then, but in my case use of the ZERO_PAGE didn't look
common enough to make special cases for.

You put forward a pagecache replication patch a few weeks ago.
That's what I expected to happen to the ZERO_PAGE, once NUMA folks
complained of the accounting.  Isn't that a better way to go?

Or is there some important app on the Altix which uses the
ZERO_PAGE so very much, that its interesting data remains shared
between nodes forever, and it's only its struct page cacheline
bouncing dirtily from one to another that slows things down?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
