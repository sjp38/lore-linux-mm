Date: Mon, 12 Jun 2000 20:04:34 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <20000612232932.I15054@redhat.com>
Message-ID: <Pine.LNX.4.21.0006121959450.25868-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Jun 2000, Stephen C. Tweedie wrote:
> On Mon, Jun 12, 2000 at 11:46:09PM +0200, Zlatko Calusic wrote:
> > 
> > This simple one-liner solves a long standing problem in Linux VM.
> > While searching for a discardable page in shrink_mmap() Linux was too
> > easily failing and subsequently falling back to swapping. The problem
> > was that shrink_mmap() counted pages from the wrong zone, and in case
> > of balancing a relatively smaller zone (e.g. DMA zone on a 128MB
> > computer) "count" would be mistakenly spent dealing with pages from
> > the wrong zone. The net effect of all this was spurious swapping that
> > hurt performance greatly.
> 
> Nice --- it might also explain some of the excessive kswap CPU 
> utilisation we've seen reported now and again.

Indeed. And to be honest, the patch can be made even simpler.

We can simply move the test up to above the count--, so we won't
start IO for the "wrong" zones either.

There's only one serious bug left with the current shrink_mmap,
a bug which appears to be easy to trigger with this patch, but
still there without it.

Consider the case where only one zone has free_pages < pages_high,
but all the pages in the LRU queue are from the other zone or not
freeable (ie. with pagetable mapping)...

In those cases shrink_mmap() can loop forever. We probably want to
add a "maxscan" variable, initialised to nr_lru_pages, which is
decremented on every iteration through the loop to prevent us from
triggering this bug.

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
