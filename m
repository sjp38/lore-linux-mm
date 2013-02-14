Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id ABC596B0002
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 06:58:09 -0500 (EST)
Date: Thu, 14 Feb 2013 11:58:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/11] ksm: remove old stable nodes more thoroughly
Message-ID: <20130214115805.GC7367@suse.de>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
 <alpine.LNX.2.00.1301251800550.29196@eggly.anvils>
 <20130205175551.GL21389@suse.de>
 <alpine.LNX.2.00.1302081057110.4233@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1302081057110.4233@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 08, 2013 at 11:33:40AM -0800, Hugh Dickins wrote:
> > > <SNIP>
> > > 
> > > 2. __ksm_enter() has a nice little optimization, to insert the new mm
> > > just behind ksmd's cursor, so there's a full pass for it to stabilize
> > > (or be removed) before ksmd addresses it.  Nice when ksmd is running,
> > > but not so nice when we're trying to unmerge all mms: we were missing
> > > those mms forked and inserted behind the unmerge cursor.  Easily fixed
> > > by inserting at the end when KSM_RUN_UNMERGE.
> > > 
> > > 3. It is possible for a KSM page to be faulted back from swapcache into
> > > an mm, just after unmerge_and_remove_all_rmap_items() scanned past it.
> > > Fix this by copying on fault when KSM_RUN_UNMERGE: but that is private
> > > to ksm.c, so dissolve the distinction between ksm_might_need_to_copy()
> > > and ksm_does_need_to_copy(), doing it all in the one call into ksm.c.
> 
> What I found is that a 4th cause emerges once KSM migration
> is properly working: that interval during page migration when the old
> page has been fully unmapped but the new not yet mapped in its place.
> 

For anyone else watching -- normal page migration expects to be protected
during that particular window with migration ptes. Any references to the
PTE mapping a page being migrated faults on a swap-like PTE and waits
in migration_entry_wait().

> The KSM COW breaking cannot see a page there then, so it ends up with
> a (newly migrated) KSM page left behind.  Almost certainly has to be
> fixed in follow_page(), but I've not yet settled on its final form -
> the fix I have works well, but a different approach might be better.
> 

follow_page() is one option. My guess is that you're thinking of adding
a FOLL_ flag that will cause follow_page() to check is_migration_entry()
and migration_entry_wait() if the flag is present.

Otherwise you would need to check for migration ptes in a number of places
under page lock and then hold the lock for long periods of time to prevent
migration starting. I did not check this option in depth because it quickly
looked like it would be a mess, with long page lock hold times and might
not even be workable.

> > > +static int remove_all_stable_nodes(void)
> > > +{
> > > +	struct stable_node *stable_node;
> > > +	int nid;
> > > +	int err = 0;
> > > +
> > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > > +		while (root_stable_tree[nid].rb_node) {
> > > +			stable_node = rb_entry(root_stable_tree[nid].rb_node,
> > > +						struct stable_node, node);
> > > +			if (remove_stable_node(stable_node)) {
> > > +				err = -EBUSY;
> > > +				break;	/* proceed to next nid */
> > > +			}
> > 
> > If remove_stable_node() returns an error then it's quite possible that it'll
> > go boom when that page is encountered later but it's not guaranteed. It'd
> > be best effort to continue removing as many of the stable nodes anyway.
> > We're in trouble either way of course.
> 
> If it returns an error, then indeed something we don't yet understand
> has occurred, and we shall want to debug it.  But unless it's due to
> corruption somewhere, we shouldn't be in much trouble, shouldn't go boom:
> remove_all_stable_nodes() error is ignored at the end of unmerging, it
> will be tried again when changing merge_across_nodes, and an error
> then will just prevent changing merge_across_nodes at that time.  So
> the mysteriously unremovable stable nodes remain the same kind of tree.
> 

Ok.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
