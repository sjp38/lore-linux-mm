Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Accelerate dbench
Date: Sun, 5 Aug 2001 04:33:41 +0200
References: <Pine.LNX.4.33L.0108042101341.2526-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0108042101341.2526-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <01080504334100.00294@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Sunday 05 August 2001 02:02, Rik van Riel wrote:
> On Sun, 5 Aug 2001, Daniel Phillips wrote:
> > --- ../2.4.7.clean/mm/filemap.c	Sat Aug  4 14:27:16 2001
> > +++ ./mm/filemap.c	Sat Aug  4 14:32:51 2001
> >
> > -	/* Mark the page referenced, kswapd will find it later. */
> >  	SetPageReferenced(page);
> > -
> > +	if (!PageActive(page))
> > +		activate_page(page);
>
> I think this is wrong.
>
> By doing this the page will end up at the far end
> of the active list with the referenced bit already
> set.
>
> This doesn't allow us to distinguish between pages
> which get accessed again after we put them on the
> active list and pages which aren't.
>
> Also, it effectively gives a double boost for this
> one access...

How wrong could it be when it's turning in results like this:

  dbench 12, 2.4.8-pre4 vanilla
  12.76user 76.49system 6:20.56elapsed 23%CPU (0avgtext+0avgdata 0maxresident)k
  0inputs+0outputs (426major+405minor)pagefaults 0swaps

  dbench 12, 2.4.8-pre4 with immediate activate in find_page
  16.81user 58.05system 3:13.92elapsed 38%CPU (0avgtext+0avgdata 0maxresident)k
  0inputs+0outputs (1112major+632minor)pagefaults 0swaps

Almost twice as fast with the patch.  Mind you, it doesn't
turn in this spectacular result all the time, sometimes it's
more like:

  dbench 12, 2.4.8-pre4 with immediate activate in find_page
  15.81user 69.09system 4:40.60elapsed 30%CPU (0avgtext+0avgdata 0maxresident)k
  0inputs+0outputs (991major+766minor)pagefaults 0swaps

which is still very good compared to the stock kernel and
its predecessors.  (Note the huge difference between timings
take under identical conditions, from clean reboots.)

But you're right, this fits our aging model better:

-  	SetPageReferenced(page);
+	if (PageActive(page))
+	  	SetPageReferenced(page);
+	else
+		activate_page(page);

So I'll try it...<time passes>...OK, it doesn't make a lot of
difference, results still range from "pretty good" to "really
great".  Not really suprising, I have this growing gut feeling
that we're not doing that well on the active page aging anyway,
and that random selection of candidates for trial on the
inactive queue would perform almost as well - which might be
worth testing.  Anyway, I'm putting this on the back burner for
now.  Interesting as it is, it's hardly a burning issue.

--
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
