Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA32452
	for <linux-mm@kvack.org>; Wed, 2 Dec 1998 12:41:25 -0500
Date: Wed, 2 Dec 1998 17:41:09 GMT
Message-Id: <199812021741.RAA04526@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: swapin readahead and locking
In-Reply-To: <Pine.LNX.3.96.981201170845.437E-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.981201170845.437E-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 1 Dec 1998 17:12:45 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> struct page *page_map = lookup_swap_cache(entry);

> if (!page_map) {
> 	page_map = read_swap_cache(entry);

> ... do readahead stuff
> }

read_swap_cache() is not asynchronous!  include/linux/swap.h:

	#define read_swap_cache(entry) read_swap_cache_async(entry, 1);

I think you were on the right lines before (except for the missing
free_page()). 

> I have a funny feeling I missed a wait_on_page() this way,
> but things are runnig happily right now. 

No, read_swap_cache automatically waits, and if you do the async
version, then any later call to read the same page will in turn wait for
the IO to complete.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
