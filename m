Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A5FEE6B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 20:42:01 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id e13so721523iej.4
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 17:42:01 -0800 (PST)
Message-ID: <1359337321.6763.18.camel@kernel>
Subject: Re: [PATCH 6/11] ksm: remove old stable nodes more thoroughly
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sun, 27 Jan 2013 19:42:01 -0600
In-Reply-To: <alpine.LNX.2.00.1301271451130.17495@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	 <alpine.LNX.2.00.1301251800550.29196@eggly.anvils>
	 <1359262556.4159.23.camel@kernel>
	 <alpine.LNX.2.00.1301271451130.17495@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 2013-01-27 at 15:05 -0800, Hugh Dickins wrote:
> On Sat, 26 Jan 2013, Simon Jeons wrote:
> > On Fri, 2013-01-25 at 18:01 -0800, Hugh Dickins wrote:
> > > Switching merge_across_nodes after running KSM is liable to oops on stale
> > > nodes still left over from the previous stable tree.  It's not something
> > > that people will often want to do, but it would be lame to demand a reboot
> > > when they're trying to determine which merge_across_nodes setting is best.
> > > 
> > > How can this happen?  We only permit switching merge_across_nodes when
> > > pages_shared is 0, and usually set run 2 to force that beforehand, which
> > > ought to unmerge everything: yet oopses still occur when you then run 1.
> > > 
> > > Three causes:
> > > 
> > > 1. The old stable tree (built according to the inverse merge_across_nodes)
                                                   ^^^^^^^^^^^^^^^^^^^^^
How to understand inverse merge_across_nodes here?

> > > has not been fully torn down.  A stable node lingers until get_ksm_page()
> > > notices that the page it references no longer references it: but the page

Do you mean page->mapping is NULL when call get_ksm_page()? Who clear it
NULL?

> > > is not necessarily freed as soon as expected, particularly when swapcache.

Why is not necessarily freed as soon as expected?

> > > 
> > 
> > When can this happen?  
> 
> Whenever there's an additional reference to the page, beyond those for
> its ptes in userspace - swapcache for example, or pinned by get_user_pages.
> That delays its being freed (arriving at the "page->mapping = NULL;"
> in free_pages_prepare()).  Or it might simply be sitting in a pagevec,
> waiting for that to be filled up, to be freed as part of a batch.
> 
> > 
> > > Fix this with a pass through the old stable tree, applying get_ksm_page()
> > > to each of the remaining nodes (most found stale and removed immediately),
> > > with forced removal of any left over.  Unless the page is still mapped:
> > > I've not seen that case, it shouldn't occur, but better to WARN_ON_ONCE
> > > and EBUSY than BUG.
> > > 
> > > 2. __ksm_enter() has a nice little optimization, to insert the new mm
> > > just behind ksmd's cursor, so there's a full pass for it to stabilize
> > > (or be removed) before ksmd addresses it.  Nice when ksmd is running,
> > > but not so nice when we're trying to unmerge all mms: we were missing
> > > those mms forked and inserted behind the unmerge cursor.  Easily fixed
> > > by inserting at the end when KSM_RUN_UNMERGE.
> > 
> > mms forked will be unmerged just after ksmd's cursor since they're
> > inserted behind it, why will be missing?
> 
> unmerge_and_remove_all_rmap_items() makes one pass through the list
> from start to finish: insert behind the cursor and it will be missed.

Since mms forked will be insert just after ksmd's cursor, so it is the
next which will be scan and unmerge, where I miss?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
