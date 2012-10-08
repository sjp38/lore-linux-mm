Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 438306B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 19:00:50 -0400 (EDT)
Date: Tue, 9 Oct 2012 01:00:29 +0200
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [PATCH v4] KSM: numa awareness sysfs knob
Message-ID: <20121008230028.GA9607@thinkpad-work.redhat.com>
References: <1348448166-1995-1-git-send-email-pholasek@redhat.com>
 <alpine.LSU.2.00.1209301736560.6304@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1209301736560.6304@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

Hi Hugh,

first of all, please let me apologize for the delay in my response and thank
you for your extensive review!

On Sun, 30 Sep 2012, Hugh Dickins wrote:
> Andrea's point about ksm_migrate_page() is an important one, and I've
> answered that against his mail, but here's some other easier points.
> 
> On Mon, 24 Sep 2012, Petr Holasek wrote:
> 
> > Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_across_nodes
> > which control merging pages across different numa nodes.
> > When it is set to zero only pages from the same node are merged,
> > otherwise pages from all nodes can be merged together (default behavior).
> > 

...

> > 
> > v4:	- merge_nodes was renamed to merge_across_nodes
> > 	- share_all debug knob was dropped
> 
> Yes, you were right to drop the share_all knob for now.  I do like the
> idea, but it was quite inappropriate to mix it in with this NUMAnode
> patch.  And although I like the idea, I think it wants a bit more: I
> already have a hacky "allksm" boot option patch to mm/mmap.c for my
> own testing, which adds VM_MERGEABLE everywhere.  If I gave that up
> (I'd like to!) in favour of yours, I think I would still be missing
> all the mms that are created before there's a chance to switch the
> share_all mode on.  Or maybe I misread your v3.  Anyway, that's a
> different topic, happily taken off today's agenda.
> 

Agreed, it hid original purpose of this patch and made it more difficult for
eventual merging. So let's move it lower on the ksm todo list for this time :)

> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index 47c8853..7c82032 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -36,6 +36,7 @@
> >  #include <linux/hash.h>
> >  #include <linux/freezer.h>
> >  #include <linux/oom.h>
> > +#include <linux/numa.h>
> >  
> >  #include <asm/tlbflush.h>
> >  #include "internal.h"
> > @@ -140,7 +141,10 @@ struct rmap_item {
> >  	unsigned long address;		/* + low bits used for flags below */
> >  	unsigned int oldchecksum;	/* when unstable */
> >  	union {
> > -		struct rb_node node;	/* when node of unstable tree */
> > +		struct {
> > +			struct rb_node node;	/* when node of unstable tree */
> > +			struct rb_root *root;
> > +		};
> 
> This worries me a little, enlarging struct rmap_item: there may
> be very many of them in the system, best to minimize their size.
> 
> (This struct rb_root *root is used for one thing only, isn't it?  For the
> unstable rb_erase() in remove_rmap_item_from_tree().  It annoys me that
> we need to record root just for that, but I don't see an alternative.)

Yes, I've played a quite lot with this issue, but wasn't able to find an
alternative solution, too.

> 
> The 64-bit case can be easily improved by locating unsigned int nid
> after oldchecksum instead.  The 32-bit case (which supports smaller
> NODES_SHIFT: 6 was the largest I found) could be "improved" by keeping
> nid in the lower bits of address along with (moved) UNSTABLE_FLAG and
> STABLE_FLAG and reduced SEQNR_MASK - we really need only 1 bit for that,
> but 2 bits would be nice for keeping the BUG_ON(age > 1).
> 
> But you may think I'm going too far there, and prefer just to put
> #ifdef CONFIG_NUMA around the unsigned int nid, so at least it does
> not enlarge the more basic 32-bit configuration.
> 

I like your idea of unsigned int nid, will implement it in next version.

...

> >  
> > -	for (node = rb_first(&root_stable_tree); node; node = rb_next(node)) {
> > -		struct stable_node *stable_node;
> > +	for (i = 0; i < MAX_NUMNODES; i++)
> 
> It's irritating to have to do this outer nid loop, but I think you're
> right, that the memory hotremove notification does not quite tell us
> which node to look at.  Or can we derive that from start_pfn?  Would
> it be safe to assume that end_pfn-1 must be in the same node?
> 

I had assumed that we can't rely on end_pfn-1 in the same node, but now
mm/memory_hotremove.c looks to me that we can rely on it because memory hotremove
callback is triggered for each zone where we are removing memory.
So I think yes, we can optimize it in the way you mentioned above. If I am wrong
correct me, please :)

...

> 
> Looks nice - thank you.
> 

Thanks for your help!

Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
