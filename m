Date: Thu, 7 Jun 2001 21:42:22 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] VM tuning patch, take 2
In-Reply-To: <l03130326b745e267d7e8@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0106072138030.1156-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 8 Jun 2001, Jonathan Morton wrote:

> At 1:19 am +0100 8/6/2001, Marcelo Tosatti wrote:
> >+               if ((gfp_mask & (__GFP_WAIT | __GFP_IO)) == (__GFP_WAIT |
> >__GFP_IO)) {
> >+                       int progress = try_to_free_pages(gfp_mask);
> >+                       if(!progress) {
> >+                               wakeup_kswapd(1);
> >+                               goto try_again;
> >+                       }
> >
> >You're going to allow GFP_BUFFER allocations to eat from the reserved
> >queues. Eek.
> 
> Hang on, I did optimise that part - let me check it against your
> original...  but hey, it's the same behaviour!
> 
>                 if (gfp_mask & __GFP_WAIT) {
>                        int progress;
>                        if (gfp_mask & __GFP_IO) {
>                                 progress = try_to_free_pages(gfp_mask);
>                                 if (!progress) {
>                                         /*
>                                          * Not able to make progress freeing
>                                          * pages: wait for kswapd to free
>                                          * pages if possible.
>                                          */
>                                         if (gfp_mask & __GFP_IO) {
>                                                 wakeup_kswapd(1);
>                                                 goto try_again;
>                                         }
>                                 }
>                         }
>                 }
> 
> Can you point out why the behaviour of your code is *any* different from
> mine?  

It is not.

> Or have you just found a bug in your own code?  :)

Yes, my code is also broken. 

It should be: 

	progress = try_to_free_pages(gfp_mask);

	if (!progress) { 
		if (gfp_mask & __GFP_IO) { 
			wakeup_kswapd(1);
			goto try_again;
		} else 
			return NULL;
	} else
		goto try_again;


Also note that my code makes non-zero order allocations loop like mad
here. You may want to fix that, too. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
