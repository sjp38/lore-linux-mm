Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5MHeN43020721
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 13:40:23 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5MHeNWn289354
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 13:40:23 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5MHeNxF029364
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 13:40:23 -0400
Date: Thu, 22 Jun 2006 10:40:57 -0700
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [patch 3/3] radix-tree: RCU lockless readside
Message-ID: <20060622174057.GF1295@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20060408134635.22479.79269.sendpatchset@linux.site> <20060408134707.22479.33814.sendpatchset@linux.site> <20060622014949.GA2202@us.ibm.com> <20060622154518.GA23109@wotan.suse.de> <20060622163032.GC1295@us.ibm.com> <20060622165551.GB23109@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060622165551.GB23109@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul McKenney <Paul.McKenney@us.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 22, 2006 at 06:55:51PM +0200, Nick Piggin wrote:
> On Thu, Jun 22, 2006 at 09:30:32AM -0700, Paul E. McKenney wrote:
> > On Thu, Jun 22, 2006 at 05:45:18PM +0200, Nick Piggin wrote:
> > > 
> > > I'll probably put a little table in radix-tree.h to summarise the
> > > API synchronisation requirements, OK?
> > 
> > Makes sense to me -- except will that feed into the docbook stuff?
> > It seems to me to be really important to get these sorts of requirements
> > included in the docbook stuff.  I have had too many people show me
> > code that assumed that RCU somehow synchronizes updates, so it is
> > good to call out these requirements early and often.
> 
> I'm not a docbook expert, but that's a good point. Will RFComments
> on the comments when I'm done ;)

Nor am I, but the trick seems to be to put the right verbiage and
format into the function comment header.

> > > Does the single rcu_dereference in radix_tree_gang_lookup look OK?
> > 
> > Well, it does put a memory barrier in the right place on Alpha, but the
> > intent would be more clear to me if the rcu_dereference() were on the
> > assignments to each element of the results array.  And there would be
> > no additional overhead on most architectures.
> > 
> > So I would much prefer the rcu_dereference() be on the assignment to
> > the results array.
> 
> No problem, will change.

Thank you!

> > > Ah indeed, that's confusing. Yes, the lookup_tag must exclude updates.
> > > I guess I got too mechanical in my conversion... however, tag lookups
> > > can be RCUified without a great deal of trouble, so I might take this
> > > opportunity.
> > 
> > The tag lookups would then find anything that (1) had been tagged in a
> > prior operation and (2) had not been deleted in the meantime, right?
> 
> Yes. Where "prior" is only really prior as guaranteed by some
> synchronising (or otherwise dependent) operation. But I don't
> need to tell you that ;)

We can all use reminding from time to time...  ;-)

> > And the caller could hold a lock across both the tagging and tag
> > lookup if greater certainty was desired.  I could imagine this sort
> > of semantic being useful for deferred operations on ranges of memory,
> > where new additions would have the operation implicit in creation and any
> > deletions would no longer need the operation to be performed (or might
> > be performed as part of deletion operation), but have not actually used
> > this sort of thing myself.
> > 
> > So I must defer to people who have used tagging and tagged lookups
> > in anger.
> 
> We use tagged lookups for writeout and synching -- slow IO related
> which is why I had not converted it over to lockless. But it could
> use lockless tagged lookups: eg. so long as sync catches all the
> pages that we *know* to be dirty at the time of the sync, that's
> fine.

Fair enough!

> > > I've tried to get that message across in the radix_tree_lookup_slot
> > > comment, if they're using RCU lookups. Enough? I guess I'll add it
> > > to the locking summary too.
> > 
> > This is what I saw in the radix_tree_lookup_slot() comment:
> > 
> > + *   radix_tree_lookup_slot    -    lookup a slot in a radix tree
> > + *   @root:          radix tree root
> > + *   @index:         index key
> > + *
> > + *   Lookup the slot corresponding to the position @index in the radix tree
> > + *   @root. This is useful for update-if-exists operations.
> > + *
> > + *   This function cannot be called under rcu_read_lock, it must be
> > + *   excluded from writers, as must the returned slot.
> > 
> > This comment does not make the RCU-protection point clear to me.
> > The constraint is that if you use RCU radix-tree lookups, then you must
> > use synchronize_rcu() or call_rcu() when freeing any elements removed
> > from the radix tree via radix_tree_delete().
> > 
> > Or am I missing something here?
> 
> Well the pagecache uses pointers to struct page. struct page is never
> freed, so we can forget the whole thing ;)
> (mem unplug may want to free them, so in that case they would have to
> synchronize_rcu).

OK, but they still need to be careful -- otherwise, they can end up
re-using a page quickly, and then someone can search with the old
identity, but end up with a reference to the page, but with its new
identity.  Sort of a reverse form of identity theft, I guess.

The usual approach to handle this is to either:

1.	wait a grace period before reusing a page after it has been
	deleted.

2.	recheck the page's identity after each lookup.

>From your comments below, looks like you do #2.

> But I guess for less specialised users, RCU would be the usual way to
> go... ah I see, I must have got out of synch somewhere. I have comments
> along these lines for radix_tree_lookup_slot:
> 
> + *     This function can be called under rcu_read_lock, however it is the
> + *     duty of the caller to manage the lifetimes of the leaf nodes (ie.
> + *     they would usually be RCU protected as well). Also, dereferencing
> + *     the slot pointer would require rcu_dereference, and modifying it
> + *     would require rcu_assign_pointer.
> 
> > > > Rough notes, FYA:
> > 
> > You went through all these as well?  Hope you have recovered from the
> > bout of insomnia!  ;-)
> 
> Pretty well gone through them.

;-)

> > > > o	Don't the items placed into the radix tree need to be protected
> > > > 	by RCU?  If not, how does the radix tree avoid handing a pointer
> > > > 	to something that has recently been removed, that the caller to
> > > > 	radix_tree_delete() might have already freed?
> > > 
> > > Yes, they'll need to be protected by something. In the lockless pagecache,
> > > they are never freed, so that isn't an issue. But other users (Ben's
> > > irq patch perhaps, unless it uses the slot pointers directly) will have to
> > > be careful.
> > 
> > Ah!  If they are never freed, there is still a need to take care when
> > reusing them.  One approach is to prevent them from being reused until
> > after a grace period has elapsed, another is to use revalidation checks
> > after lookup.  Either way, one needs to allow for the fact that a
> > lookup might hand you something that has just been deleted.
> 
> Yep, validation checks are done after lookup. The core of it, the
> ``page_cache_get_speculative'' function isn't that big.

Good enough!

							Thanx, Paul

> > > I'll send out an incremental diff with changes.
> > 
> > Looking forward to it!  Maybe not as anxiously as Ben Herrenschmidt, but
> > so it goes.  ;-)
> 
> Well I couldn't ask you to spend any more time on it, but if you
> get interested and take a peek, that'll be a bonus for me ;)
> 
> Thanks again
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
