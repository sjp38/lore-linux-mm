Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id F0EBD6B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 17:57:51 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so2279374ied.14
        for <linux-mm@kvack.org>; Wed, 10 Oct 2012 14:57:50 -0700 (PDT)
Date: Wed, 10 Oct 2012 14:57:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
In-Reply-To: <alpine.LSU.2.00.1210091600450.30446@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1210101428470.1939@eggly.anvils>
References: <1349108796-32161-1-git-send-email-jack@suse.cz> <alpine.LSU.2.00.1210082029190.2237@eggly.anvils> <20121009101822.79bdcb65@mschwide> <alpine.LSU.2.00.1210091600450.30446@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org

On Tue, 9 Oct 2012, Hugh Dickins wrote:
> On Tue, 9 Oct 2012, Martin Schwidefsky wrote:
> > On Mon, 8 Oct 2012 21:24:40 -0700 (PDT)
> > Hugh Dickins <hughd@google.com> wrote:
> > 
> > > A separate worry came to mind as I thought about your patch: where
> > > in page migration is s390's dirty storage key migrated from old page
> > > to new?  And if there is a problem there, that too should be fixed
> > > by what I propose in the previous paragraph.
> > 
> > That is covered by the SetPageUptodate() in migrate_page_copy().
> 
> I don't think so: that makes sure that the newpage is not marked
> dirty in storage key just because of the copy_highpage to it; but
> I see nothing to mark the newpage dirty in storage key when the
> old page was dirty there.

I went to prepare a patch to fix this, and ended up finding no such
problem to fix - which fits with how no such problem has been reported.

Most of it is handled by page migration's unmap_and_move() having to
unmap the old page first: so the old page will pass through the final
page_remove_rmap(), which will transfer storage key to page_dirty in
those cases which it deals with (with the old code, any file or swap
page; with the new code, any unaccounted file or swap page, now that
we realize the accounted files don't even need this); and page_dirty
is already properly migrated to the new page.

But that does leave one case behind: an anonymous page not yet in
swapcache, migrated via a swap-like migration entry.  But this case
is not a problem because PageDirty doesn't actually affect anything
for an anonymous page not in swapcache.  There are various places
where we set it, and its life-history is hard to make sense of, but
in fact it's meaningless in 2.6, where page reclaim adds anon to swap
(and sets PageDirty) whether the page was marked dirty before or not
(which makes sense when we use the ZERO_PAGE for anon read faults).

2.4 did behave differently: it was liable to free anon pages not
marked dirty, and I think most of our anon SetPageDirtys are just a
relic of those days - I do have a patch from 18 months ago to remove
them (adding PG_dirty to the flags which should not be set when a
page is freed), but there are usually more urgent things to attend
to than rebase and retest that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
