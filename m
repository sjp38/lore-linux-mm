Date: Sat, 17 Jun 2000 12:33:52 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: kswapd eating too much CPU on ac16/ac18
In-Reply-To: <20000617000527.A5485@cesarb.personal>
Message-ID: <Pine.LNX.4.21.0006171227230.31955-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Cc: Mike Galbraith <mikeg@weiden.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Jun 2000, Cesar Eduardo Barros wrote:
> On Fri, Jun 16, 2000 at 12:08:06PM -0300, Rik van Riel wrote:
> > On Fri, 16 Jun 2000, Mike Galbraith wrote:
> > > On Wed, 14 Jun 2000, Alan Cox wrote:
> > > 
> > > > Im interested to know if ac9/ac10 is the slow->fast change point
> > > 
> > > ac5 is definately the breaking point.  ac5 doesn't survive make
> > > -j30.. starts swinging it's VM machette at everything in sight.  
> > > Reversing the VM changes to ac4 restores throughput to test1
> > > levels (11 minute build vs 21-26 minutes for everything
> > > forward).
> > > 
> > > Exact tested reversals below.  FWIW, page aging doesn't seem to
> > > be the problem.  I disabled that in ac17 and saw zero
> > > difference.  (What may or not be a hint is that the /* Let
> > > shrink_mmap handle this swapout. */ bit in vmscan.c does make a
> > > consistent difference.  Reverting that bit alone takes a minimum
> > > of 4 minutes off build time)
> > 
> > Interesting. Not delaying the swapout IO completely broke
> > performance under the tests I did here...
> > 
> > Delayed swapout vs. non-delayed swapouts was the difference
> > between 300 swapouts/s vs. 700 swapouts/s  (under a load
> > with 400 swapins/s).
> 
> I can understand it... When you wake up kswapd you need more
> memory, and if you don't free it you will be called again. And
> again. And again. (leaf is a slow box; both top and vmstat eat
> 20% CPU each with 1 second updates all the time). So it does
> waste more time.
> 
> With ac4 I get the HDD light full on during the worse moments;
> with ac16/18 it just sits there in kswapd and the light blinks
> at about 1Hz.

I think the phenomenon you're seeing is not at all related
to deferred/non-deferred swapout. That doesn't have anything
to do with kswapd CPU usage.

The changed feedback loop in do_try_to_free_pages, however
may have something to do with this. It works well on machines
with more than 1 memory zone, but I can envision it breaking
on machines with just one zone...

I'm thinking of a way to fix this cleanly, I'll keep you posted.

> > OTOH, I can imagine it being better if you have a very small
> > LRU cache, something like less than 1/2 MB.
> 
> You can imagine it being better in some random rare condition I
> don't care about. People have been noticing speed problems
> related to kswapd. This is not microkernel research.

Please read my email before flaming. I am telling you I can
imagine non-deferred swapout (like what we had before) being
better when you have very little LRU cache, like on 8MB machines.

But now that you've told me you're not interested in 8MB machines
and value a flamewar more than a nicely running Linux box.  ;))

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
