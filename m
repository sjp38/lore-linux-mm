Date: Sat, 17 Jun 2000 00:05:27 -0300
Subject: Re: kswapd eating too much CPU on ac16/ac18
Message-ID: <20000617000527.A5485@cesarb.personal>
References: <Pine.Linu.4.10.10006160724100.793-100000@mikeg.weiden.de> <Pine.LNX.4.21.0006161203110.24794-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0006161203110.24794-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Fri, Jun 16, 2000 at 12:08:06PM -0300
From: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Mike Galbraith <mikeg@weiden.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Cesar Eduardo Barros <cesarb@nitnet.com.br>, linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 16, 2000 at 12:08:06PM -0300, Rik van Riel wrote:
> On Fri, 16 Jun 2000, Mike Galbraith wrote:
> > On Wed, 14 Jun 2000, Alan Cox wrote:
> > 
> > > Im interested to know if ac9/ac10 is the slow->fast change point
> > 
> > ac5 is definately the breaking point.  ac5 doesn't survive make
> > -j30.. starts swinging it's VM machette at everything in sight.  
> > Reversing the VM changes to ac4 restores throughput to test1
> > levels (11 minute build vs 21-26 minutes for everything
> > forward).
> > 
> > Exact tested reversals below.  FWIW, page aging doesn't seem to
> > be the problem.  I disabled that in ac17 and saw zero
> > difference.  (What may or not be a hint is that the /* Let
> > shrink_mmap handle this swapout. */ bit in vmscan.c does make a
> > consistent difference.  Reverting that bit alone takes a minimum
> > of 4 minutes off build time)
> 
> Interesting. Not delaying the swapout IO completely broke
> performance under the tests I did here...
> 
> Delayed swapout vs. non-delayed swapouts was the difference
> between 300 swapouts/s vs. 700 swapouts/s  (under a load
> with 400 swapins/s).

I can understand it... When you wake up kswapd you need more memory, and if you
don't free it you will be called again. And again. And again. (leaf is a slow
box; both top and vmstat eat 20% CPU each with 1 second updates all the time).
So it does waste more time.

Worst case (dpkg --install) in ac4 gets kswapd at about 5%. Which considering
that top or vmstat use 20% is low enough. Also it gets more throughput because
it has no need to waste time thinking.

With ac4 I get the HDD light full on during the worse moments; with ac16/18 it
just sits there in kswapd and the light blinks at about 1Hz.

> OTOH, I can imagine it being better if you have a very small
> LRU cache, something like less than 1/2 MB.

You can imagine it being better in some random rare condition I don't care
about. People have been noticing speed problems related to kswapd. This is not
microkernel research.

-- 
Cesar Eduardo Barros
cesarb@nitnet.com.br
cesarb@dcc.ufrj.br
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
