Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA12383
	for <linux-mm@kvack.org>; Sat, 16 Jan 1999 11:52:47 -0500
Date: Sat, 16 Jan 1999 17:49:33 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] NEW: arca-vm-21, swapout via shrink_mmap using PG_dirty
In-Reply-To: <Pine.LNX.3.96.990116002913.853C-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990116160536.328A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Max <max@Linuz.sns.it>
List-ID: <linux-mm.kvack.org>

In my new PG_dirty implementation I did a grave bug that was causing
sometimes under eavily swapping a corrupted swap entry (note, the kernel
memory was always safe, so no risk to bad fs corruption). Sometimes
happened that a swapin was swapping in a random swap data, instead of the
(not) swapped out page of the process. This because when GFP_IO was not
set (and so I was not going to sync the page to disk) I didn't re-set the
Dirty bit to tell to the MM that the page is still dirty.

I noticed the bug one hour ago and I fixed it now.

> +		if (PageSwapCache(page)) {
> +			unsigned long entry = page->offset;
> +			if (PageTestandClearDirty(page) &&
			    ^^^^^^^^^^^^^^^^^^^^^^^^^^^
> +			    swap_count(entry) > 1)
> +			{
> +				if (!(gfp_mask & __GFP_IO))
> +					continue;
					^^^^^^^^^
> +				entry = page->offset;
> +				set_bit(PG_locked, &page->flags);
> +				atomic_inc(&page->count);
> +				rw_swap_page(WRITE, entry, page, 0);
> +				atomic_dec(&page->count);
> +			}
> +			delete_from_swap_cache(page);
> +			return 1;
> +		}
> +

With the bug fixed it seems really rock solid. It would be interesting
making performance comparison with kernels that are swapping out in
swap_out() (e.g. clean pre7). I am not sure it's a win (but I'm sure it's
more fun ;). The swapout performances are a bit decreased even if
sometimes (in the second pass) my benchmark give me super results with
this my new code (43 sec, that's been the record of every other kernel
tried). 

The only thing I don't like is that the kernel seems to stall a bit every
some seconds in the grow_freeabe() path (the old swap_out()), also the
profiling report try_to_swap_out() as the function where the kernel is
passing most of the time (20 timer interrupt against 10 of shrink_mmap). 
Maybe because now I'm recalling grow_freeable() many more times than I was
used to do... Maybe I should reinsert something like the smart swapout
weight code to allow grow_freeable() to scale greatly... It's just quite
good though.

The fixed patch (arca-vm-22) can be downloaded from here:

ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre7-arca-VM-22.gz

(if it's too slow drop me a line and I'll post privately it via email, I
am not posting it here again to not spam too much ;)

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
