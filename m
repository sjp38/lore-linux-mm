Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA32256
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 16:51:11 -0500
Date: Tue, 22 Dec 1998 21:25:02 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.95.981222082256.8438C-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.03.9812222119540.397-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Dec 1998, Linus Torvalds wrote:
> On Tue, 22 Dec 1998, Andrea Arcangeli wrote:
> > On 22 Dec 1998, Eric W. Biederman wrote:
> > 
> > >My suggestion (again) would be to not call shrink_mmap in the swapper
> > >(unless we are endangering atomic allocations).  And to never call
> > >swap_out in the memory allocator (just wake up kswapd).
> > 
> > Ah, I just had your _same_ _exactly_ idea yesterday but there' s a good
> > reason I nor proposed/tried it. The point are Real time tasks. kswapd is
> > not realtime and a realtime task must be able to swapout a little by
> > itself in try_to_free_pages() when there's nothing to free on the cache
> > anymore. 
> 
> There's another one: if you never call shrink_mmap() in the swapper, the
> swapper at least currently won't ever really know when it should finish.

Remember 2.1.89, when you solemnly swore off any kswapd solution
that had anything to do with nr_freepages?

I guess it's time to just let kswapd finish when there are enough
pages that can be 'reapt' by shrink_mmap(). This is a somewhat less
arbitrary way than what we have now, since those clean pages can be
mapped back in any time.

And when we have not enough memory for DMA buffers or something
like that, we can just set a flag that:
- orders kswapd to unmap XX pages a second
- modifies shrink_mmap() to look for contiguous areas that it
  can free -- and free them

regards,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
