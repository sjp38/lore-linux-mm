Subject: Re: fast path for anonymous memory allocation
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
	 <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
	 <419D581F.2080302@yahoo.com.au>
	 <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com>
	 <419D5E09.20805@yahoo.com.au>
	 <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 19 Nov 2004 18:07:48 +1100
Message-Id: <1100848068.25520.49.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2004-11-18 at 19:28 -0800, Christoph Lameter wrote:
> On Fri, 19 Nov 2004, Nick Piggin wrote:
> 
> > But you're doing it after you've set up a pte for that page you are
> > clearing... I think? What's to stop another thread trying to read or
> > write to it concurrently?
> 
> Nothing. If this had led to anything then we would have needed to address
> this issue. The clearing had to be outside of the lock in order not to
> impact the performance tests negatively.

No, it's clearly a bug. We even had a very hard to track down bug
recently on ppc64 which was caused by the fact that set_pte didn't
contain a barrier, thus the stores done by the _previous_
clear_user_high_page() could be re-ordered with the store to the PTE.
That could cause another process to "see" the PTE before the writes of 0
to the page, and thus start writing to the page before all zero's went
in, thus ending up with corrupted data. We had a real life testcase of
this one. This test case would blow up right away with your code I
think.
 
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
