Date: Fri, 19 Nov 2004 20:23:40 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page fault scalability patch V11 [0/7]: overview
Message-ID: <20041120042340.GJ2714@holomorphy.com>
References: <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com> <419D5E09.20805@yahoo.com.au> <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com> <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411191155180.2222@ppc970.osdl.org> <20041120020306.GA2714@holomorphy.com> <419EBBE0.4010303@yahoo.com.au> <20041120035510.GH2714@holomorphy.com> <419EC205.5030604@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <419EC205.5030604@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@osdl.org>, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> /proc/ triggering NMI oopses was a persistent problem even before that
>> code was merged. I've not bothered testing it as it at best aggravates it.

On Sat, Nov 20, 2004 at 03:03:17PM +1100, Nick Piggin wrote:
> It isn't a problem. If it ever became a problem then we can just
> touch the nmi oopser in the loop.

Very, very wrong. The tasklist scans hold the read side of the lock
and aren't even what's running with interrupts off. The contenders
on the write side are what the NMI oopser oopses.

And supposing the arch reenables interrupts in the write side's
spinloop, you just get a box that silently goes out of service for
extended periods of time, breaking cluster membership and more. The
NMI oopser is just the report of the problem, not the problem itself.
It's not a false report. The box is dead for > 5s at a time.


William Lee Irwin III wrote:
>> And thread groups can share mm's. do_for_each_thread() won't suffice.

On Sat, Nov 20, 2004 at 03:03:17PM +1100, Nick Piggin wrote:
> I think it will be just fine.

And that makes it wrong on both counts. The above fails any time
LD_ASSUME_KERNEL=2.4 is used, we well as when actual Linux features
are used directly.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
