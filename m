Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 95EC66B005D
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 07:53:15 -0400 (EDT)
Date: Mon, 1 Oct 2012 13:53:09 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4] KSM: numa awareness sysfs knob
Message-ID: <20121001115309.GE20924@redhat.com>
References: <1348448166-1995-1-git-send-email-pholasek@redhat.com>
 <20120928112645.GX19474@redhat.com>
 <alpine.LSU.2.00.1209301639240.6304@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1209301639240.6304@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

Hi Hugh,

On Sun, Sep 30, 2012 at 05:36:33PM -0700, Hugh Dickins wrote:
> I'm all for the simplest solution, but here in ksm_migrate_page()
> is not a good place for COW breaking - we don't want to get into
> an indefinite number of page allocations, and the risk of failure.

Agreed, not a good place to break_cow.

> I was toying with the idea of leaving the new page in the old NUMAnode's
> stable tree temporarily, until ksmd comes around again, and let that
> clean it up.  Which would imply less reliance on get_kpfn_nid(),
> and not skipping PageKsm in ksm_do_scan(), and...

There a break_cow could more easily run to cleanup the errors in the
stable tree. It'd be one way to avoid altering migrate.

> But it's not all that simple, and I think we can do better.

Agreed.

> It's only just fully dawned on me that ksm_migrate_page() is actually
> a very convenient place: no pagetable mangling required, because we
> know that neither old nor new page is at this instant mapped into
> userspace at all - don't we?  Instead there are swap-like migration
> entries plugging all ptes until we're ready to put in the new page.

Yes.

> So I think what we really want to do is change the ksm_migrate_page()
> interface a little, and probably the precise position it's called from,
> to allow it to update mm/migrate.c's newpage - in the collision case

I agree your proposed modification to the ->migratepage protocol
should be able to deal with that. We should notify the caller the
"newpage" has been freed and we transferred all ownership to an
"alternate_newpage". So then migrate will restore the ptes pointing to
the alternate_newpage (not the allocated newpage). It should be also
possible to get an hold on the alternate_newpage, before having to
allocate newpage.

> when the new NUMAnode already has a stable copy of this page.  But when
> it doesn't, just move KSMnode from old NUMAnode's stable tree to new.

Agreed, that is the easy case and doesn't require interface changes.

> How well the existing ksm.c primitives are suited to this, I've not
> checked.  Probably not too well, but shouldn't be hard to add what's
> needed.
> 
> What do you think?  Does that sound reasonable, Petr?

Sounds like a plan, I agree the modification to migrate is the best
way to go here. Only cons: it's not the simplest solution.

> By the way, this is probably a good occasion to remind ourselves,
> that page migration is still usually disabled on PageKsm pages:
> ksm_migrate_page() is only being called for memory hotremove.  I had
> been about to complain that calling remove_node_from_stable_tree()
> from ksm_migrate_page() is also unsafe from a locking point of view;
> until I remembered that MEM_GOING_OFFLINE has previously acquired
> ksm_thread_mutex.
> 
> But page migration is much more important now than three years ago,
> with compaction relying upon it, CMA and THP relying upon compaction,
> and lumpy reclaim gone.

Agreed. AutoNUMA needs it too: AutoNUMA migrates all types of memory,
not just anonymous memory, as long as the mapcount == 1.

If all users break_cow except one, then the KSM page can move around
if it has left just one user, we don't need to wait this last user to
break_cow (which may never happen) before can move it.

> Whilst it should not be mixed up in the NUMA patch itself, I think we
> need now to relax that restriction.  I found re-reading my 62b61f611e
> "ksm: memory hotremove migration only" was helpful.  Petr, is that
> something you could take on also?  I _think_ it's just a matter of
> protecting the stable tree(s) with an additional mutex (which ought
> not to be contended, since ksm_thread_mutex is normally held above
> it, except in migration); then removing a number of PageKsm refusals
> (and the offlining arg to unmap_and_move() etc).  But perhaps there's
> more to it, I haven't gone over it properly.

Removing the restriction sounds good. In addition to
compaction/AutoNUMA etc.. KSM pages are marked MOVABLE so it's likely
not good for the anti frag pageblock types.

So if I understand this correctly, there would be no way to trigger
the stable tree corruption in current v4, without memory hotremove.

> Yes, I agree; but a few more comments I'll make against the v4 post.

Cool.

Thanks for the help!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
