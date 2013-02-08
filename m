Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 0896E6B0007
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 14:33:36 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id bj3so2256647pad.34
        for <linux-mm@kvack.org>; Fri, 08 Feb 2013 11:33:36 -0800 (PST)
Date: Fri, 8 Feb 2013 11:33:40 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/11] ksm: remove old stable nodes more thoroughly
In-Reply-To: <20130205175551.GL21389@suse.de>
Message-ID: <alpine.LNX.2.00.1302081057110.4233@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251800550.29196@eggly.anvils> <20130205175551.GL21389@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 5 Feb 2013, Mel Gorman wrote:
> On Fri, Jan 25, 2013 at 06:01:59PM -0800, Hugh Dickins wrote:
> > Switching merge_across_nodes after running KSM is liable to oops on stale
> > nodes still left over from the previous stable tree.  It's not something
> > that people will often want to do, but it would be lame to demand a reboot
> > when they're trying to determine which merge_across_nodes setting is best.
> > 
> > How can this happen?  We only permit switching merge_across_nodes when
> > pages_shared is 0, and usually set run 2 to force that beforehand, which
> > ought to unmerge everything: yet oopses still occur when you then run 1.
> > 
> 
> When reviewing patch 1, I missed that the pages_shared check would prevent
> most of the problems I was envisioning with leftover entries in the
> stable tree. Sorry about that.

No apology necessary!

> 
> > Three causes:
> > 
> > 1. The old stable tree (built according to the inverse merge_across_nodes)
> > has not been fully torn down.  A stable node lingers until get_ksm_page()
> > notices that the page it references no longer references it: but the page
> > is not necessarily freed as soon as expected, particularly when swapcache.
> > 
> > Fix this with a pass through the old stable tree, applying get_ksm_page()
> > to each of the remaining nodes (most found stale and removed immediately),
> > with forced removal of any left over.  Unless the page is still mapped:
> > I've not seen that case, it shouldn't occur, but better to WARN_ON_ONCE
> > and EBUSY than BUG.

But once I applied the testing for this to the completed patch series,
I did start seeing that WARN_ON_ONCE: it's made safe by the EBUSY,
but not working as intended.  Cause outlined below.

> > 
> > 2. __ksm_enter() has a nice little optimization, to insert the new mm
> > just behind ksmd's cursor, so there's a full pass for it to stabilize
> > (or be removed) before ksmd addresses it.  Nice when ksmd is running,
> > but not so nice when we're trying to unmerge all mms: we were missing
> > those mms forked and inserted behind the unmerge cursor.  Easily fixed
> > by inserting at the end when KSM_RUN_UNMERGE.
> > 
> > 3. It is possible for a KSM page to be faulted back from swapcache into
> > an mm, just after unmerge_and_remove_all_rmap_items() scanned past it.
> > Fix this by copying on fault when KSM_RUN_UNMERGE: but that is private
> > to ksm.c, so dissolve the distinction between ksm_might_need_to_copy()
> > and ksm_does_need_to_copy(), doing it all in the one call into ksm.c.

What I found is that a 4th cause emerges once KSM migration
is properly working: that interval during page migration when the old
page has been fully unmapped but the new not yet mapped in its place.

The KSM COW breaking cannot see a page there then, so it ends up with
a (newly migrated) KSM page left behind.  Almost certainly has to be
fixed in follow_page(), but I've not yet settled on its final form -
the fix I have works well, but a different approach might be better.

I'm also puzzled that I've never in practice been hit by a 5th cause:
swapoff's try_to_unuse() is much like faulting, and ought to have the
same ksm_might_need_to_copy() safeguards as faulting (or at least,
I cannot see why not).

> > --- mmotm.orig/mm/ksm.c	2013-01-25 14:36:58.856206099 -0800
> > +++ mmotm/mm/ksm.c	2013-01-25 14:37:00.768206145 -0800
> > @@ -644,6 +644,57 @@ static int unmerge_ksm_pages(struct vm_a
> >  /*
> >   * Only called through the sysfs control interface:
> >   */
> > +static int remove_stable_node(struct stable_node *stable_node)
> > +{
> > +	struct page *page;
> > +	int err;
> > +
> > +	page = get_ksm_page(stable_node, true);
> > +	if (!page) {
> > +		/*
> > +		 * get_ksm_page did remove_node_from_stable_tree itself.
> > +		 */
> > +		return 0;
> > +	}
> > +
> > +	if (WARN_ON_ONCE(page_mapped(page)))
> > +		err = -EBUSY;
> > +	else {
> > +		/*
> 
> It will probably be very obvious to people familiar with ksm.c but even
> so maybe remind the reader that the pages must already have been unmerged
> 
> * This page must already have been unmerged and should be stale.
> * It might be in a pagevec waiting to be freed or it might be

Okay, I'll add a little more comment there;
but I need to think longer for exactly how to express it.

> ......
> 
> 
> 
> > +		 * This page might be in a pagevec waiting to be freed,
> > +		 * or it might be PageSwapCache (perhaps under writeback),
> > +		 * or it might have been removed from swapcache a moment ago.
> > +		 */
> > +		set_page_stable_node(page, NULL);
> > +		remove_node_from_stable_tree(stable_node);
> > +		err = 0;
> > +	}
> > +
> > +	unlock_page(page);
> > +	put_page(page);
> > +	return err;
> > +}
> > +
> > +static int remove_all_stable_nodes(void)
> > +{
> > +	struct stable_node *stable_node;
> > +	int nid;
> > +	int err = 0;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > +		while (root_stable_tree[nid].rb_node) {
> > +			stable_node = rb_entry(root_stable_tree[nid].rb_node,
> > +						struct stable_node, node);
> > +			if (remove_stable_node(stable_node)) {
> > +				err = -EBUSY;
> > +				break;	/* proceed to next nid */
> > +			}
> 
> If remove_stable_node() returns an error then it's quite possible that it'll
> go boom when that page is encountered later but it's not guaranteed. It'd
> be best effort to continue removing as many of the stable nodes anyway.
> We're in trouble either way of course.

If it returns an error, then indeed something we don't yet understand
has occurred, and we shall want to debug it.  But unless it's due to
corruption somewhere, we shouldn't be in much trouble, shouldn't go boom:
remove_all_stable_nodes() error is ignored at the end of unmerging, it
will be tried again when changing merge_across_nodes, and an error
then will just prevent changing merge_across_nodes at that time.  So
the mysteriously unremovable stable nodes remain the same kind of tree.

> 
> Otherwise I didn't spot a problem so as weak as it is due my familiarity
> with KSM;
> 
> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
