Received: from localhost (riel@localhost)
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id UAA17973
	for <linux-mm@kvack.org>; Thu, 17 Aug 2000 20:18:39 -0300
Date: Thu, 17 Aug 2000 20:18:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: filemap.c SMP bug in 2.4.0-test* (fwd)
Message-ID: <Pine.LNX.4.21.0008172017450.16454-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

it seems that Roger has done some deep puzzling today...
I'm not sure if he found something or not, could somebody
else with a more intimate knowledge of the source take a
look at Roger's idea?

thanks,

Rik
---------- Forwarded message ----------
Date: Fri, 18 Aug 2000 00:25:03 +0200
From: Roger Larsson <roger.larsson@norran.net>
To: Rik van Riel <riel@conectiva.com.br>
Subject: Re: filemap.c SMP bug in 2.4.0-test*

Rik van Riel wrote:
> 
> On Fri, 18 Aug 2000, Roger Larsson wrote:
> 
> > One question to ask is what will happen if
> > there are two threads both requesting the
> > same swap page at almost the same time?
> > (a process forking, both threads continue to run
> >  on both processors, both ends up in page fault...)
> >
> > there might then be a possibility for a race with
> > the indicated code and the lookup_swap_cache call
> > chain (first fails, second lookup_swap_cache runs
> > before page is fully added...)
> 
> The adding happens completely under the pagecache_lock,
> so either it is added or it is not, intermediate states
> are not visible to the other cpus...
> 

But I am considering the possibility that __find_page_nolock
is run before the page is actually added. Page gets added
slightly after.

Proc A                                Proc B
page faults
...
read_swap_cache_async
  lookup_swap_cache fails twice       page faults (same page)
                                      ...
                                      read_swap_cache_async
  init of page info (insert in
  hash tables...)

                                      lookup_swap_cache
	                                 __find_page_nolock
                                         (succeeds, page not active
                                          activate)

  lru_cache_add (OUCH)


Is this scenario possible?
I will check tomorrow...


/RogerL


> add_to_page_cache_unique should handle this situation
> just fine ... should and probably does, but I'm still
> not 100% sure ;)
> 
> regards,
> 
> Rik
> --
> "What you're running that piece of shit Gnome?!?!"
>        -- Miguel de Icaza, UKUUG 2000
> 
> http://www.conectiva.com/               http://www.surriel.com/

--
Home page:
  http://www.norran.net/nra02596/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
