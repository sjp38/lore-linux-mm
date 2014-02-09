Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5896B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 13:29:48 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b57so2520552eek.38
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 10:29:48 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id q43si21459167eeo.117.2014.02.09.10.29.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 09 Feb 2014 10:29:47 -0800 (PST)
Date: Sun, 9 Feb 2014 13:29:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2014-02-05 list_lru_add lockdep splat
Message-ID: <20140209182942.GJ6963@cmpxchg.org>
References: <alpine.LSU.2.11.1402051944210.27326@eggly.anvils>
 <20140206164136.GC6963@cmpxchg.org>
 <20140207125233.4b84482453da6a656ff427dd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140207125233.4b84482453da6a656ff427dd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 07, 2014 at 12:52:33PM -0800, Andrew Morton wrote:
> On Thu, 6 Feb 2014 11:41:36 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > 
> > Make the shadow lru->node[i].lock IRQ-safe to remove the order
> > dictated by interruption.  This slightly increases the IRQ-disabled
> > section in the shadow shrinker, but it still drops all locks and
> > enables IRQ after every reclaimed shadow radix tree node.
> > 
> > ...
> >
> > --- a/mm/workingset.c
> > +++ b/mm/workingset.c
> > @@ -273,7 +273,10 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
> >  	unsigned long max_nodes;
> >  	unsigned long pages;
> >  
> > +	local_irq_disable();
> >  	shadow_nodes = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
> > +	local_irq_enable();
> 
> This is a bit ugly-looking.
> 
> A reader will look at that and wonder why the heck we're disabling
> interrupts here.  Against what?  Is there some way in which we can
> clarify this?

We need the list_lru's internal locking to be IRQ-safe because of the
mapping->tree_lock nesting.

This particular instance should go away once Dave's scalability fixes
from last summer get merged, the lock and thus the IRQ-disabling is
not necessary to read that counter: https://lkml.org/lkml/2013/7/31/7

This leaves the IRQ-disabling in the scan and isolate function.

[ I also noticed the patch that does an optimistic list_empty() check
  before acquiring the locks, which is something my callers also do,
  so it might be worth revisiting the missing pieces of this patch
  set: https://lkml.org/lkml/2013/7/31/9 -- Dave? ]

> Perhaps adding list_lru_count_node_irq[save] and
> list_lru_walk_node_irq[save] would be better - is it reasonable to
> assume this is the only caller of the list_lru code which will ever
> want irq-safe treatment?

It's a combination of our objects being locked from IRQ context and
using the object lock for lifetime management, which means list_lru
locking has to nest inside the IRQ-safe object lock.  I suspect this
will not be too common and mapping->tree_lock will remain the oddball.

> This is all somewhat a side-effect of list_lru implementing its own
> locking rather than requiring caller-provided locking.  It's always a
> mistake.

The locks are embedded in the internal per-node structure that first
has to be looked up.  All the users could live with the internal
locking, so I can see why Dave didn't want to push 4 manual steps
(lookup, lock, list op, unlock) into all callsites unnecessarily.

Are the two manual IRQ-disabling sections in one user enough to change
all that?  I'm perfectly neutral on this, so... path of least
resistance ;)

---
Subject: [patch] mm: keep page cache radix tree nodes in check fix fix fix

document IRQ-disabling around list_lru API calls

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/workingset.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/workingset.c b/mm/workingset.c
index 20aa16754305..f7216fa7da27 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -273,6 +273,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	unsigned long max_nodes;
 	unsigned long pages;
 
+	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
 	local_irq_disable();
 	shadow_nodes = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
 	local_irq_enable();
@@ -373,6 +374,7 @@ static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 {
 	unsigned long ret;
 
+	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
 	local_irq_disable();
 	ret =  list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
 				  shadow_lru_isolate, NULL, &sc->nr_to_scan);
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
