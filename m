Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA29752
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 18:08:14 -0500
Date: Wed, 25 Nov 1998 23:08:01 GMT
Message-Id: <199811252308.XAA05815@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: rw_swap_page() and swapin readahead
In-Reply-To: <Pine.LNX.3.96.981125235645.17460B-100000@mirkwood.dummy.home>
References: <199811252219.WAA05712@dax.scot.redhat.com>
	<Pine.LNX.3.96.981125235645.17460B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 25 Nov 1998 23:59:17 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Wed, 25 Nov 1998, Stephen C. Tweedie wrote:
>> 
>> The PG_free_after bit is there only to mark that increment, so that
>> the page count is decremented again (asynchronously) once the IO is
>> complete and no sooner. 

> Then what does the PG_decr_after do? It seems like there
> are two flags to do the same thing... I'm curious :)

It's in fs/buffer.c, after_unlock_page:

	if (test_and_clear_bit(PG_decr_after, &page->flags))
		atomic_dec(&nr_async_pages);
	if (test_and_clear_bit(PG_swap_unlock_after, &page->flags))
		swap_after_unlock_page(page->offset);
	if (test_and_clear_bit(PG_free_after, &page->flags))
		__free_page(page);

So PG_free_after causes us to decrement the page count after IO;
PG_decr_after decrements the global async page IO count (the one which
stops us doing runaway async swapout), andd PG_swap_unlock_after unlocks
the swap map after the IO.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
