Date: Mon, 22 Aug 2005 06:23:33 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Use deltas to replace atomic inc
In-Reply-To: <Pine.LNX.4.58.0508212112260.3317@g5.osdl.org>
Message-ID: <Pine.LNX.4.62.0508220617030.4675@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
 <20050818212939.7dca44c3.akpm@osdl.org> <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
 <Pine.LNX.4.62.0508200033420.20471@schroedinger.engr.sgi.com>
 <20050820005843.21ba4d9b.akpm@osdl.org> <Pine.LNX.4.62.0508212030020.2093@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508212040380.3317@g5.osdl.org>
 <Pine.LNX.4.62.0508212102240.2290@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508212112260.3317@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 Aug 2005, Linus Torvalds wrote:

> On Sun, 21 Aug 2005, Christoph Lameter wrote:
> > > 
> > > Why? I don't think it's ever wrong to do the thing. We should be holding 
> > > no locks at the point (and we haven't grabbed he RQ lock yet), so it 
> > > should always be safe to get the page table lock. 
> > 
> > get_user_pages and unuse_mm may be working on an mm that is not 
> > current->mm. If schedule is called then the deltas are added to the wrong 
> > mm (current->mm).
> 
> Hmm. But we already hold (and _have_ to hold) the mm lock there, don't we?

We drop the lock for allocations. At that point schedule() may be called.

> Why not make the rule be that we only use the delta stuff when we don't 
> hold the mm lock. Which is pretty seldom, but the big one is obviously 
> anon page faults.

Yes I have tried to follow that. But there are some functions that are 
called from both contexts. Most importantly this is page_add_anon_rmap.
If we would remove incrementing anon_rss from the function then we can at 
avoid the problem for the unuse_mm path. But we would still have the issue 
with handle_mm_fault. So we would still need some flag.

> Whenever we already -do- hold the page table lock for other reasons, 
> there's no actual upside to using the delta representation. In fact, 
> there's only downsides, since it just makes the things like scheduling 
> slower.

There is a slight benefit in avoiding additional writes to mm_struct which 
limits cacheline bouncing during heavy contention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
