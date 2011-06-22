Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 666CC6B0158
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:04:27 -0400 (EDT)
Received: by iyl8 with SMTP id 8so324356iyl.14
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 17:04:24 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH 2/2 V2] ksm: take dirty bit as reference to avoid volatile pages scanning
Date: Wed, 22 Jun 2011 08:04:12 +0800
References: <201106212055.25400.nai.xia@gmail.com> <201106212136.17445.nai.xia@gmail.com> <20110621223800.GO25383@sequoia.sous-sol.org>
In-Reply-To: <20110621223800.GO25383@sequoia.sous-sol.org>
MIME-Version: 1.0
Message-Id: <201106220804.12508.nai.xia@gmail.com>
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>

(Sorry for repeated mail, I forgot to Cc the list..)

On Wednesday 22 June 2011 06:38:00 you wrote:
> * Nai Xia (nai.xia@gmail.com) wrote:
> > Introduced ksm_page_changed() to reference the dirty bit of a pte. We clear 
> > the dirty bit for each pte scanned but don't flush the tlb. For a huge page, 
> > if one of the subpage has changed, we try to skip the whole huge page 
> > assuming(this is true by now) that ksmd linearly scans the address space.
> 
> This doesn't build w/ kvm as a module.

I think it's because of the name-error of a related kvm patch, which I only sent
in a same email thread. http://marc.info/?l=linux-mm&m=130866318804277&w=2
The patch split is not clean...I'll redo it.

> 
> > A NEW_FLAG is also introduced as a status of rmap_item to make ksmd scan
> > more aggressively for new VMAs - only skip the pages considered to be volatile
> > by the dirty bits. This can be enabled/disabled through KSM's sysfs interface.
> 
> This seems like it should be separated out.  And while it might be useful
> to enable/disable for testing, I don't think it's worth supporting for
> the long term.  Would also be useful to see the value of this flag.

I think it maybe useful for uses who want to turn on/off this scan policy explicitly
according to their working sets? 

> 
> > @@ -454,7 +468,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
> >  		else
> >  			ksm_pages_shared--;
> >  		put_anon_vma(rmap_item->anon_vma);
> > -		rmap_item->address &= PAGE_MASK;
> > +		rmap_item->address &= ~STABLE_FLAG;
> >  		cond_resched();
> >  	}
> >  
> > @@ -542,7 +556,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
> >  			ksm_pages_shared--;
> >  
> >  		put_anon_vma(rmap_item->anon_vma);
> > -		rmap_item->address &= PAGE_MASK;
> > +		rmap_item->address &= ~STABLE_FLAG;
> >  
> >  	} else if (rmap_item->address & UNSTABLE_FLAG) {
> >  		unsigned char age;
> > @@ -554,12 +568,14 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
> >  		 * than left over from before.
> >  		 */
> >  		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
> > -		BUG_ON(age > 1);
> > +		BUG_ON (age > 1);
> 
> No need to add space after BUG_ON() there
> 
> > +
> >  		if (!age)
> >  			rb_erase(&rmap_item->node, &root_unstable_tree);
> >  
> >  		ksm_pages_unshared--;
> > -		rmap_item->address &= PAGE_MASK;
> > +		rmap_item->address &= ~UNSTABLE_FLAG;
> > +		rmap_item->address &= ~SEQNR_MASK;
> 
> None of these changes are needed AFAICT.  &= PAGE_MASK clears all
> relevant bits.  How could it be in a tree, have NEW_FLAG set, and
> while removing from tree want to preserve NEW_FLAG?

You are right, it's meaningless to preserve NEW_FLAG after it goes 
through the trees. I'll revert the lines.

Thanks!

Nai

> 
> thanks,
> -chris
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
