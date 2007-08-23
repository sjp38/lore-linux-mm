Date: Thu, 23 Aug 2007 13:23:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
In-Reply-To: <20070823120506.GN13915@v2.random>
Message-ID: <Pine.LNX.4.64.0708231318100.14720@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <1187692586.6114.211.camel@twins>
 <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
 <1187730812.5463.12.camel@lappy> <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
 <46CB5C89.2070807@redhat.com> <Pine.LNX.4.64.0708211521260.5728@schroedinger.engr.sgi.com>
 <20070823120506.GN13915@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, dkegel@google.com, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, ak@suse.de, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2007, Andrea Arcangeli wrote:

> On Tue, Aug 21, 2007 at 03:32:25PM -0700, Christoph Lameter wrote:
> > 1. Like in the earlier patchset allow reentry to reclaim under 
> >    PF_MEMALLOC if we are out of all memory.
> 
> Can you simply tweak on the may_writepage flag only to achieve the
> second pass? We're talking here about a totally non-performance case,
> almost impossible to hit in practice unless you do real weird things,
> and certainly very unlikely to happen. So I'm unsure what's all that
> complexity just to make a regular pass on the lru looking for clean
> pages, something may_writepage=0 already does.
> 

Yes that is what the PF_MEMALLOC patch that I posted before does. This 
discussion gets me more and more to thinking that the recursive reclaim on 
PF_MEMALLOC is all that is needed for emergency situations (to get out of 
the "tight spot").

See
http://marc.info/?l=linux-kernel&m=118710219116624&w=2

> If the PF_MEMALLOC is found empty, I agree entering reclaim a second
> time with may_writepage=0 sounds theoretically a good idea (in
> practice it should never be necessary). printk must also be printed to
> warn the user he was risking to deadlock for real and he has to
> increase the min_free_kbytes.

Ok. I can add a printk to that one.

> That sounds a bit risky, there are latency considerations here to
> make, GFP_ATOMIC will run with irq locally disabled and it may hang
> for indefinite amount of time (O(N)). So irq latency may break and it
> may be better to lose a packet once in a while than to hang
> interrupts. If you want to do this you'd probably need to add a new
> GFP_ATOMIC_RECLAIM or similar.

Well we could do the same as for PF_MEMALLOC: print a warning and then 
reclaim nevertheless if we cannot fail (We already have a GFP_NOFAIL 
flag). It is better to generate a latency than the system failing 
altogether. However the GFP_ATOMIC reclaim patchset is a 
bit more invasive (http://marc.info/?l=linux-mm&m=118710584014150&w=2). 
Maybe this is too much churn for the rare need of such a reclaim.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
