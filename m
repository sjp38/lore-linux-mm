Subject: Re: fast path for anonymous memory allocation
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <419D581F.2080302@yahoo.com.au>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
	 <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
	 <419D581F.2080302@yahoo.com.au>
Content-Type: text/plain
Date: Fri, 19 Nov 2004 18:05:20 +1100
Message-Id: <1100847920.25497.46.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2004-11-19 at 13:19 +1100, Nick Piggin wrote:
> Christoph Lameter wrote:
> > This patch conflicts with the page fault scalability patch but I could not
> > leave this stone unturned. No significant performance increases so
> > this is just for the record in case someone else gets the same wild idea.
> > 
> 
> I had a similar wild idea. Mine was to just make sure we have a spare
> per-CPU page ready before taking any locks.
> 
> Ahh, you're doing clear_user_highpage after the pte is already set up?
> Won't that be racy? I guess that would be an advantage of my approach,
> the clear_user_highpage can be done first (although that is more likely
> to be wasteful of cache).

Yah, doing clear_user_highpage() after setting the PTE is unfortunately
unacceptable. It show interesting bugs... As soon as the PTE is setup,
another thread on another CPU can hit the page, you'll then clear what
it's writing... 

Take for example 2 threads writing to different structures in the same
page of anonymous memory. The first one triggers the allocation, the
second writes right away, "sees" the new PTE, and writes just before the
first one does clear_user_highpage...

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
