Date: Wed, 11 Oct 2000 17:09:29 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] atomic pte updates for x86 smp
In-Reply-To: <Pine.LNX.4.21.0010111937380.892-100000@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.10.10010111702001.2444-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: tytso@mit.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 11 Oct 2000, Ben LaHaise wrote:
> 
> Here's an updated version of the patch that doesn't do the funky RISC like
> dirty bit updates.  It doesn't incur the additional overhead of page
> faults on dirty, which actually happens a lot on SHM attaches
> (during Oracle runs this is quite noticeable due to their use of
> hundreds of MB of SHM).

I much prefered the dirty fault version.

What does "quite noticeable" mean? Does it mean that you can see page
faults (no big deal), or does it mean that you can actually measure the
performance degradation objectively?

Also, this version doesn't seem to fix the bug.

> diff -ur v2.4.0-test10-pre1/mm/vmscan.c work-v2.4.0-test10-pre1/mm/vmscan.c
> --- v2.4.0-test10-pre1/mm/vmscan.c	Tue Oct 10 16:57:31 2000
> +++ work-v2.4.0-test10-pre1/mm/vmscan.c	Wed Oct 11 18:17:17 2000
> @@ -134,7 +143,7 @@
>  	 * locks etc.
>  	 */
>  	if (!(gfp_mask & __GFP_IO))
> -		goto out_unlock;
> +		goto out_unlock_restore;
>  
>  	/*
>  	 * Don't do any of the expensive stuff if
> @@ -143,7 +152,7 @@
>  	if (page->zone->free_pages + page->zone->inactive_clean_pages
>  					+ page->zone->inactive_dirty_pages
>  		      	> page->zone->pages_high + inactive_target)
> -		goto out_unlock;
> +		goto out_unlock_restore;
>  
>  	/*
>  	 * Ok, it's really dirty. That means that

Both of the above paths can cause the dirty bit to be dropped again, as
far as I can see.

In fact, you seem to have _added_ those drops in this patch. What's up?

I'm not going to apply a patch that I don't see will even fix the problem
at this point.

I _will_ apply the "exception on dirty" version, if you remove the SMP
special case (ie you do it unconditionally). At least that one I believe
really fixes the problem.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
