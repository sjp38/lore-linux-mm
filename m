Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA24871
	for <linux-mm@kvack.org>; Fri, 11 Dec 1998 13:10:18 -0500
Date: Fri, 11 Dec 1998 19:08:31 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.1.130 mem usage.
In-Reply-To: <199812111405.OAA02292@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981211181928.765F-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Dec 1998, Stephen C. Tweedie wrote:

>the large fraction of cached but referenced pages will cause the new
>code to become more aggressive in its scanning (because the pages
>which contribute to the loop exit condition become more dilute).  This
>is exactly what you want for self-balancing behaviour.

Yes is that what I want. With the past email I only wanted to pointed out
that if I remeber well you published the patch as fix to the excessive
swapout (look the report of people that was pointing out the swpd field of
`vmstat 1`). Your patch instead will cause still more swapout, note I am
not talking about I/O. This is the reason I didn' t agreed with your patch
at first because I thought you would get the opposite effect (and I
couldn' t understand why it could improve things).  The reason is that
your patch will cause less IO (cool)  since the cache working set will be
preserved fine. I agree with the patch as far I agree with decreasing the
pressure on shrink_mmap().  Also your comment is not exaustive since you
say that the new check will cause the cache to be aged faster while
instead it reduces _radically_ the pressure of shrink_mmap() and so the
cache will be aged slower than with the previous code. The improvement is
not because we age faster but because we age slower and we don' t throw
away the cache of our working set (and so reducing very a not needed sloww
IO).

As always correct me if I am wrong or I am misunderstanding something. 

>> For the s/free_page_and_swap_cache/free_page/ I agree with it completly. I
>> only want to be sure that other mm parts are well balanced with the
>> change.
>
>Please try 2.1.131-ac8, then, as it not only includes the patches

I am just running with the ac6 mm (except for kswapd but that will make no
difference for what we are discussing here since do_try_to_free_pages() is
the same). ac6 seems good to me (for the reason above) and now it make
sense to me (too ;).

>we're talking about here, but it also adds Rik's swap readahead stuff
>extended to do aligned block readahead for both swap and normal mmap
>paging. 

Downloading ac8 from here is a pain (I was used to get patches from
linux-kernel-patches). A guy sent me by email ac7 but since I want sync
with ac8 I' ll wait a bit for ac8... 

>> It would also be nice to not have two separate mm cycles (one that
>> grow the cache until borrow percentage and the other one that shrink
>> and that reach very near the limit of the working set). We should
>> have always the same level of cache in the system if the mm stress
>> is constant. This could be easily done by a state++ inside
>> do_try_to_free_pages() after some (how many??) susccesfully returns.
>
>I'm seeing a pretty stable cache behaviour here, on everything from
>4MB to 64MB systems.

It works fine but it' s not stable at all. The cache here goes from
40Mbyte to 10Mbyte in cycle (the only local changes I have here are on
kswapd implementation; do_try_to_free_pages() and all other function that
do_try_to_free_pages() uses are untouched). The good thing is that now
when the cache reaches the low bound the working set is preserved (this is
achieved by decreasing (not increasing as it seem to me reading the
comment some days ago) the pressure of shrink_mmap()). 

Now I' ll try to remove my state = 0 to see what will happens...  My state
= 0 is the reason of the mm cycle I am seeing here, but is also the reason
for which the mm subsystem doesn' t swapout too much. I' ll experiment
now...

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
