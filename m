Date: Thu, 3 Aug 2000 21:37:05 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: RFC: design for new VM
Message-ID: <20000803213705.C759@nightmaster.csn.tu-chemnitz.de>
References: <Pine.LNX.4.21.0008021212030.16377-100000@duckman.distro.conectiva> <Pine.LNX.4.10.10008031020440.6384-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10008031020440.6384-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Thu, Aug 03, 2000 at 11:05:47AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, Aug 03, 2000 at 11:05:47AM -0700, Linus Torvalds wrote:
> As far as I can tell, the only advantage of multiple lists compared to the
> current one is to avoid overhead in walking extra pages, no?

[...]

> As far as I can tell, the above is _exactly_ equivalent to having one
> single list, and multiple "scan-points" on that list. 

[...]

3 keywords:

   -  reordering of the list breaks _all_ scanpoints
   -  wraparound inside the scanner breaks ordering or it should
      store it's starting point globally
   -  state transistions _require_ reordering, which will affect
      all scanners

conclusions:

   -  scanners can only run exclusive (spinlock()ed) one at a
      point, if they can ever reorder the list, until the reach
      their temporally success or wrap point
      
   -  scanners, that don't reorder the list have to be run under
      the guarantee, that the list will _never_ change until they
      reach their wrap point or succeed for now

Isn't this really bad for performance? It would imply a lot of
waiting, but I haven't measured this ;-)

With the multiple list approach we can skip pages easily and
avoid contention and stuck scanners (waiting for the list_lock to
become free). 

Even your headache with the "purpose" of the lists might get
adressed, if you consider adding a queue in between for the
special state you need (like "dirty_but_not_really_list" ;-)).

The only wish _I_ have is having portal functions for _all_ state
transitions, which can be used as entry point for future
extensions which should continue adding portal functions for
their own transistions.

Practical example: *Nobody* was able to tell me, where we stop
   accessing a swapped out page (so it can be encrypted) and
   where we start accessing a swapped in page (so it has to be
   decrypted). 
   
   Would be no problem (nor a question ;-)) with portal functions
   for this important state transition.

PS: Maybe I didn't get your point with the "scan-points"
   approach.

Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
