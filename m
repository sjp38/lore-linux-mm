Date: Thu, 21 Sep 2000 13:26:50 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.0-test9-pre4: __alloc_pages(...) try_again:
In-Reply-To: <39C91CC8.F8D27899@norran.net>
Message-ID: <Pine.LNX.4.21.0009211322270.15315-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Juan J. Quintela" <quintela@fi.udc.es>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2000, Roger Larsson wrote:

> I added a counter for try_again loops.
> 
> ... __alloc_pages(...)
> 
>         int direct_reclaim = 0;
>         unsigned int gfp_mask = zonelist->gfp_mask;
>         struct page * page = NULL;
> +       int try_again_loops = 0;
> 
> - - -
> 
> +         printk("VM: sync kswapd (direct_reclaim: %d) try_again #
> %d\n",
> +                direct_reclaim, ++try_again_loops);
>                         wakeup_kswapd(1);
>                         goto try_again;
> 
> 
> Result was surprising:
>   direct_reclaim was 1.
>   try_again_loops did never stop increasing (note: it is not static,
>   and should restart from zero after each success)
> 
> Why does this happen?
> a) kswapd did not succeed in freeing a suitable page?
> b) __alloc_pages did not succeed in grabbing the page?

No.

It's a locking issue. In __alloc_pages we may be
holding some IO locks (gfp_mask & __GFP_IO == 0),
then we wait on kswapd and schedule out. The result is that
kswapd will be spinning on a lock it can never get.

The fix for this was included in the patch I sent to Linus
for 2.4.0-tes9-pre2, but unfortunately not included.
Ia'll send it agani soon.

There is anathor, more subtle, case like this in
buffer.c, which I have also fixed in my local tree here.

The patch for this will be online on my home paeg
soon. (connectivity isn't that great as you can see from mytyping)

cheers,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
