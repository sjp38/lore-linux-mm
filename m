Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA23719
	for <linux-mm@kvack.org>; Fri, 11 Dec 1998 09:07:16 -0500
Date: Fri, 11 Dec 1998 14:05:30 GMT
Message-Id: <199812111405.OAA02292@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: 2.1.130 mem usage.
In-Reply-To: <Pine.LNX.3.96.981210235427.309E-100000@laser.bogus>
References: <199812021749.RAA04575@dax.scot.redhat.com>
	<Pine.LNX.3.96.981210235427.309E-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 11 Dec 1998 01:38:47 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

>>>> +		if (atomic_read(&page->count) != 1 ||
>>>> +		    (!page->inode && !page->buffers))
>>>> count_min--;

> My idea is that your patch works well due subtle reason. The effect of the
> patch is that we try on a few freeable pages so we remove only a few
> refernce bits and so we don' t throw away aging (just the opposite you
> wrote in the comment :). The reason it works is that there are many more
> not freeable pages than orphaned not-used ones. 

> So basically it' s the same of setting count_min to 100 200 (instead of
> 10000/20000) pages and decrease count_min when we don' t decrease it with
> your patch.

No, no, not at all.  The whole point is that this patch does indeed
behave as you describe if the cache is small or moderately sized, but
if you have something like a "cat /usr/bin/* > /dev/null" going on,
the large fraction of cached but referenced pages will cause the new
code to become more aggressive in its scanning (because the pages
which contribute to the loop exit condition become more dilute).  This
is exactly what you want for self-balancing behaviour.

> For the s/free_page_and_swap_cache/free_page/ I agree with it completly. I
> only want to be sure that other mm parts are well balanced with the
> change.

Please try 2.1.131-ac8, then, as it not only includes the patches
we're talking about here, but it also adds Rik's swap readahead stuff
extended to do aligned block readahead for both swap and normal mmap
paging. 

> It would also be nice to not have two separate mm cycles (one that
> grow the cache until borrow percentage and the other one that shrink
> and that reach very near the limit of the working set). We should
> have always the same level of cache in the system if the mm stress
> is constant. This could be easily done by a state++ inside
> do_try_to_free_pages() after some (how many??) susccesfully returns.

I'm seeing a pretty stable cache behaviour here, on everything from
4MB to 64MB systems.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
