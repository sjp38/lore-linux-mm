Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2354C6B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 08:50:23 -0400 (EDT)
Date: Mon, 6 Jun 2011 14:49:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110606124954.GC12887@random.random>
References: <20110531143830.GC13418@barrios-laptop>
 <20110602182302.GA2802@random.random>
 <20110602202156.GA23486@barrios-laptop>
 <20110602214041.GF2802@random.random>
 <BANLkTim1WjdHWOQp7bMg5pFFKp1SSFoLKw@mail.gmail.com>
 <20110602223201.GH2802@random.random>
 <BANLkTikA+ugFNS95Zs_o6QqG2u4r2g93=Q@mail.gmail.com>
 <20110603173707.GL2802@random.random>
 <20110603180730.GM2802@random.random>
 <20110606103216.GC5247@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110606103216.GC5247@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 06, 2011 at 11:32:16AM +0100, Mel Gorman wrote:
> This patch is pulling in stuff from Minchan. Minimally his patch should
> be kept separate to preserve history or his Signed-off should be
> included on this patch.

Well I didn't apply Minchan's patch, just improved it as he suggested
from pseudocode, but I can add his signed-off-by no prob.

> I still think this optimisation is rare and only applies if we are
> encountering huge pages during the linear scan. How often are we doing
> that really?

Well it's so fast to do it, that it looks worthwhile. You probably
noticed initially I suggested only the fix for page_count
(theoretical) oops, and I argued we could improve some more bits, but
then it was kind of obvious to improve the upper side of the loop too
according to pseudocode.

> 
> > +				VM_BUG_ON(!isolated_pages);
> 
> This BUG_ON is overkill. hpage_nr_pages would have to return 0.
> 
> > +				VM_BUG_ON(isolated_pages > MAX_ORDER_NR_PAGES);
> 
> This would require order > MAX_ORDER_NR_PAGES to be passed into
> isolate_lru_pages or for a huge page to be unaligned to a power of
> two. The former is very unlikely and the latter is not supported by
> any CPU.

Minchan also disliked the VM_BUG_ON, it's clearly way overkill, but
frankly the pfn physical scans are tricky enough things and if there's
a race and the order is wrong for whatever reason (no compound page or
overwritten by driver messing with subpages) we'll just trip into some
weird pointer next iteration (or maybe not and it'll go ahead
unnoticed if it's not beyond the range) and in that case I'd like to
notice immediately.

But probably it's too paranoid even of a VM_BUG_ON so I surely can
remove it...

> 
> >  			} else {
> > -				/* the page is freed already. */
> > -				if (!page_count(cursor_page))
> > +				/*
> > +				 * Check if the page is freed already.
> > +				 *
> > +				 * We can't use page_count() as that
> > +				 * requires compound_head and we don't
> > +				 * have a pin on the page here. If a
> > +				 * page is tail, we may or may not
> > +				 * have isolated the head, so assume
> > +				 * it's not free, it'd be tricky to
> > +				 * track the head status without a
> > +				 * page pin.
> > +				 */
> > +				if (!PageTail(cursor_page) &&
> > +				    !__page_count(cursor_page))
> >  					continue;
> >  				break;
> 
> Ack to this part.

This is also the only important part that fixes the potential oops.

> I'm not keen on __page_count() as __ normally means the "unlocked"
> version of a function although I realise that rule isn't universal
> either. I can't think of a better name though.

If better suggestions comes to mind I can change it... Or I can also
use atomic_read like in the first patch... it's up to you. I figured
it wasn't so nice to call atomic_read and there are other places in
huge_memory.c that used that for bugchecks and it can be cleaned up
with __page_count. The _count having _ prefix is the thing that makes
it look like a more private field not to use in generic VM code so the
raw value can be altered without changing all callers of __page_count
similar to _mapcount.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
