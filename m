Message-ID: <394BEEFF.C194F59E@norran.net>
Date: Sat, 17 Jun 2000 23:34:55 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: kswapd eating too much CPU on ac16/ac18
References: <20000617164317.A9421@cesarb.personal>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

The reason for me to ask you to remove it is since there are two
problems
related to this code snippet. (Reported earlier on linux-mm)

* If no zone has pressure - we will loop "forever" since no pages will
pass
this test. (On a 16 MB machine this is the likely scenario)

* If there are no pages of a zone with pressure are on LRU - we will
loop...

And since there is no guarantee that shrink_mmap is not called in these
circumstances...

I have released patches (on linux-mm) that tries to handle these
situations.
* do_try_to_free_pages avoids to call shrink_mmap with no pressure.
* shrink_mmap tries to determine the bad situation (not in my latest)

/RogerL


Cesar Eduardo Barros wrote:
> 
> > Please try to remove only this test to get a comparable result.
> 
> I nuked the whole block:
> 
>                 /*
>                  * Page is from a zone we don't care about.
>                  * Don't drop page cache entries in vain.
>                  */
>                 if (page->zone->free_pages > page->zone->pages_high) {
>                         /* the page from the wrong zone doesn't count */
>                         count++;
>                         goto unlock_continue;
>                 }
> 
> Commenting it out made ac19 perform almost as good as ac4 (it looked a bit
> faster).
> 
> I don't know how it would affect boxes with more than one zone, but my gut
> feeling is that it won't hurt and might make them even a bit faster.
> 
> --
> Cesar Eduardo Barros
> cesarb@nitnet.com.br
> cesarb@dcc.ufrj.br
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
