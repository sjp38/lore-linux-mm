Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA04883
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 07:36:13 -0500
Date: Thu, 3 Dec 1998 12:35:14 GMT
Message-Id: <199812031235.MAA03337@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead v4
In-Reply-To: <Pine.LNX.3.96.981203111953.4894B-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.981203111953.4894B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

In article
<Pine.LNX.3.96.981203111953.4894B-100000@mirkwood.dummy.home>, Rik van
Riel <H.H.vanRiel@phys.uu.nl> writes:

> Stephen's messages gave away the clue to something I was just
> about to track down myself. Anyway, here is the 4th version of
> my swapin readahead patch.

> @@ -329,6 +329,8 @@
 
>  	set_bit(PG_locked, &new_page->flags);
>  	rw_swap_page(READ, entry, (char *) new_page_addr, wait);
> +	if (!wait)
> +		__free_page(new_page);
>  #ifdef DEBUG_SWAP
>  	printk("DebugVM: read_swap_cache_async created "
>  	       "entry %08lx at %p\n",

Much better to do this after calling read_swap_cache_async(): it's bad
policy to make the reference count of the page after calling this
function dependent on the arguments: that is a maintenance nightmare.  

Oh, and you _still_ need to check the swap_lockmap before calling
read_swap_cache_async(), and you still have the extra break() in the
readahead loop...

Finally, the code before the start of the readahead loop loops really
broken.  You do both a lookup_swap_cache AND a read_swap_cache on the
entry, which is going to double-increment the page count: bad news.
It's probably best to leave the original swapin code intact, and just
add the readahead bits.  You also seem to have a construct

    if (!page_map) {
	page_map = read_swap_cache(entry);
	do something else
    } else {
	page_map = read_swap_cache(entry);
    }

and I can't for the life of me work out why you are doing things this
way!

--Stephen
 
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
