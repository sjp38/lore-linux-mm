Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D88786B0253
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 08:04:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so18634797wme.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:04:32 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id t197si3837216wmd.52.2016.04.29.05.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 05:04:20 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n129so4516064wmn.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:04:20 -0700 (PDT)
Date: Fri, 29 Apr 2016 14:04:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] scop GFP_NOFS api
Message-ID: <20160429120418.GK21977@dhcp22.suse.cz>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <8737q5ugcx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8737q5ugcx.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <mr@neil.brown.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Fri 29-04-16 15:35:42, NeilBrown wrote:
> On Tue, Apr 26 2016, Michal Hocko wrote:
> 
> > Hi,
> > we have discussed this topic at LSF/MM this year. There was a general
> > interest in the scope GFP_NOFS allocation context among some FS
> > developers. For those who are not aware of the discussion or the issue
> > I am trying to sort out (or at least start in that direction) please
> > have a look at patch 1 which adds memalloc_nofs_{save,restore} api
> > which basically copies what we have for the scope GFP_NOIO allocation
> > context. I haven't converted any of the FS myself because that is way
> > beyond my area of expertise but I would be happy to help with further
> > changes on the MM front as well as in some more generic code paths.
> >
> > Dave had an idea on how to further improve the reclaim context to be
> > less all-or-nothing wrt. GFP_NOFS. In short he was suggesting an opaque
> > and FS specific cookie set in the FS allocation context and consumed
> > by the FS reclaim context to allow doing some provably save actions
> > that would be skipped due to GFP_NOFS normally.  I like this idea and
> > I believe we can go that direction regardless of the approach taken here.
> > Many filesystems simply need to cleanup their NOFS usage first before
> > diving into a more complex changes.>
> 
> This strikes me as over-engineering to work around an unnecessarily
> burdensome interface.... but without details it is hard to be certain.
>
> Exactly what things happen in "FS reclaim context" which may, or may
> not, be safe depending on the specific FS allocation context?  Do they
> need to happen at all?

Let me quote Dave Chinner from one of the emails discussed at LSFMM
mailing list:
: IMO, making GFP_NOFS "better" cannot be done with context-less flags
: being passed through reclaim. If we want to prevent the recursive
: self-deadlock case in an optimal manner, then we need to be able to
: pass state down to reclaim so that page writeback and the shrinkers
: can determine if they are likely to deadlock.
: 
: IOWs, I think we should stop thinking of GFP_NOFS as a *global*
: directive to avoid recursion under any circumstance and instead
: start thinking about it as a mechanism to avoid recursion in
: specific reclaim contexts.
: 
: Something as simple as adding an opaque cookie (e.g. can hold a
: superblock or inode pointer) to check against in writeback and
: subsystem shrinkers would result in the vast majority of GFP_NOFS
: contexts being able to reclaim from everything but the one context
: that we *might* deadlock against.
: 
: e.g, if we then also check the PF_FSTRANS flag in XFS, we'll
: still be able to reclaim clean inodes, buffers and write back
: dirty pages that don't require transactions to complete under "don't
: recurse" situations because we know it's transactions that we could
: deadlock on in the direct reclaim context.
: 
: Note that this information could be added to the writeback_control
: for page writeback, and it could be passed directly to shrinkers
: in the shrink_control structures. The allocation paths might be a
: little harder, but I suspect using the task struct for passing this
: information into direct reclaim might be the easiest approach...

> My research suggests that for most filesystems the only thing that
> happens in reclaim context that is at all troublesome is the final
> 'evict()' on an inode.  This needs to flush out dirty pages and sync the
> inode to storage.  Some time ago we moved most dirty-page writeout out
> of the reclaim context and into kswapd.  I think this was an excellent
> advance in simplicity.
> If we could similarly move evict() into kswapd (and I believe we can)
> then most file systems would do nothing in reclaim context that
> interferes with allocation context.
> 
> The exceptions include:
>  - nfs and any filesystem using fscache can block for up to 1 second
>    in ->releasepage().  They used to block waiting for some IO, but that
>    caused deadlocks and wasn't really needed.  I left the timeout because
>    it seemed likely that some throttling would help.  I suspect that a
>    careful analysis will show that there is sufficient throttling
>    elsewhere.
> 
>  - xfs_qm_shrink_scan is nearly unique among shrinkers in that it waits
>    for IO so it can free some quotainfo things.  If it could be changed
>    to just schedule the IO without waiting for it then I think this
>    would be safe to be called in any FS allocation context.  It already
>    uses a 'trylock' in xfs_dqlock_nowait() to avoid deadlocking
>    if the lock is held.
> 
> I think you/we would end up with a much simpler system if instead of
> focussing on the places where GFP_NOFS is used, we focus on places where
> __GFP_FS is tested, and try to remove them.

One think I have learned is that shrinkers can be really complex and
getting rid of GFP_NOFS will be really hard so I would really like to
start the easiest way possible and remove the direct usage and replace
it by scope one which would at least _explain_ why it is needed. I think
this is a reasonable _first_ step and a large step ahead because we have
a good chance to get rid of a large number of those which were used
"just because I wasn't sure and this should be safe, right?". I wouldn't
be surprised if we end up with a very small number of both scope and
direct usage in the end.

I would also like to revisit generic inode/dentry shrinker and see
whether it could be more __GFP_FS friendly. As you say many FS might
even not depend on some FS internal locks so pushing GFP_FS check down
the layers might make a lot of sense and allow to clean some [id]cache
even for __GFP_FS context.

> If we get rid of enough of them the remainder could just use __GFP_IO.
> 
> > The patch 2 is a debugging aid which warns about explicit allocation
> > requests from the scope context. This is should help to reduce the
> > direct usage of the NOFS flags to bare minimum in favor of the scope
> > API. It is not aimed to be merged upstream. I would hope Andrew took it
> > into mmotm tree to give it linux-next exposure and allow developers to
> > do further cleanups.  There is a new kernel command line parameter which
> > has to be used for the debugging to be enabled.
> >
> > I think the GFP_NOIO should be seeing the same clean up.
> 
> I think you are suggesting that use of GFP_NOIO should (largely) be
> deprecated in favour of memalloc_noio_save().  I think I agree.

Yes that was the idea.

> Could we go a step further and deprecate GFP_ATOMIC in favour of some
> in_atomic() test?  Maybe that is going too far.

I am not really sure we need that and some GFP_NOWAIT usage is deliberate
to perform an optimistic allocation with another fallback (e.g. higher order
for performance reasons with single page fallback). So I think that nowait
is a slightly different thing.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
