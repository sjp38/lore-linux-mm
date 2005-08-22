Date: Sun, 21 Aug 2005 21:06:25 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Use deltas to replace atomic inc
In-Reply-To: <Pine.LNX.4.58.0508212040380.3317@g5.osdl.org>
Message-ID: <Pine.LNX.4.62.0508212102240.2290@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
 <20050818212939.7dca44c3.akpm@osdl.org> <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
 <Pine.LNX.4.62.0508200033420.20471@schroedinger.engr.sgi.com>
 <20050820005843.21ba4d9b.akpm@osdl.org> <Pine.LNX.4.62.0508212030020.2093@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508212040380.3317@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 Aug 2005, Linus Torvalds wrote:

> On Sun, 21 Aug 2005, Christoph Lameter wrote:
> > 
> > The thing that bothers me more is that schedule() can be called both by 
> > handle_mm_fault as well as during unuse_mm. We may need some flag 
> > PF_NO_COUNTER_UPDATES or so there to insure that schedule() does not add 
> > deltas to the current->mm.
> 
> Why? I don't think it's ever wrong to do the thing. We should be holding 
> no locks at the point (and we haven't grabbed he RQ lock yet), so it 
> should always be safe to get the page table lock. 

get_user_pages and unuse_mm may be working on an mm that is not 
current->mm. If schedule is called then the deltas are added to the wrong 
mm (current->mm). If we had PF_NO_COUNTER_UPDATES then we could force no 
counters updates to occur until get_user_pages or unuse_mm assigns the 
deltas to a specific mm using mm_counter_catchup(current, target_mm).

> I think the delta approach looks quite reasonable, although I think 
> somebody should check that the cache behaviour is ok (ie the deltas should 
> hopefully be in a cacheline that we need to look at anyway).

I put the deltas near to exit_state which is also checked in schedule().
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
