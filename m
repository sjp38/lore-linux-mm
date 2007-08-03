Date: Fri, 3 Aug 2007 02:20:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] balance-on-fork NUMA placement
Message-ID: <20070803002010.GB14775@wotan.suse.de>
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de> <20070801002313.GC31006@wotan.suse.de> <46B0C8A3.8090506@mbligh.org> <1185993169.5059.79.camel@localhost> <46B10E9B.2030907@mbligh.org> <20070802013631.GA15595@wotan.suse.de> <46B22383.5020109@mbligh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46B22383.5020109@mbligh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 02, 2007 at 11:33:39AM -0700, Martin Bligh wrote:
> Nick Piggin wrote:
> >On Wed, Aug 01, 2007 at 03:52:11PM -0700, Martin Bligh wrote:
> >>>And so forth.  Initial forks will balance.  If the children refuse to
> >>>die, forks will continue to balance.  If the parent starts seeing short
> >>>lived children, fork()s will eventually start to stay local.  
> >>Fork without exec is much more rare than without. Optimising for
> >>the uncommon case is the Wrong Thing to Do (tm). What we decided
> >
> >It's only the wrong thing to do if it hurts the common case too
> >much. Considering we _already_ balance on exec, then adding another
> >balance on fork is not going to introduce some order of magnitude
> >problem -- at worst it would be 2x but it really isn't too slow
> >anyway (at least nobody complained when we added it).
> >
> >One place where we found it helps is clone for threads.
> >
> >If we didn't do such a bad job at keeping tasks together with their
> >local memory, then we might indeed reduce some of the balance-on-crap
> >and increase the aggressiveness of periodic balancing.
> >
> >Considering we _already_ balance on fork/clone, I don't know what
> >your argument is against this patch is? Doing the balance earlier
> >and allocating more stuff on the local node is surely not a bad
> >idea.
> 
> I don't know who turned that on ;-( I suspect nobody bothered
> actually measuring it at the time though, or used some crap
> benchmark like stream to do so. It should get reverted.

So you have numbers to show it hurts? I tested some things where it
is not supposed to help, and it didn't make any difference. Nobody
else noticed either.

If the cost of doing the double balance is _really_ that painful,
then we ccould skip balance-on-exec for domains with balance-on-fork
set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
