Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3AA6B00B9
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 20:13:54 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so223523pab.20
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 17:13:54 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id 5si5382313pbk.61.2014.02.25.17.13.52
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 17:13:53 -0800 (PST)
Date: Wed, 26 Feb 2014 12:13:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 0/10] fs: Introduce new flag(FALLOC_FL_COLLAPSE_RANGE)
 for fallocate
Message-ID: <20140226011347.GL13647@dastard>
References: <1392741436-19995-1-git-send-email-linkinjeon@gmail.com>
 <20140224005710.GH4317@dastard>
 <20140225141601.358f6e3df2660d4af44da876@canb.auug.org.au>
 <20140225041346.GA29907@dastard>
 <alpine.LSU.2.11.1402251217030.2380@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402251217030.2380@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Theodore Ts'o <tytso@mit.edu>, Stephen Rothwell <sfr@canb.auug.org.au>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>

On Tue, Feb 25, 2014 at 03:23:35PM -0800, Hugh Dickins wrote:
> On Tue, 25 Feb 2014, Dave Chinner wrote:
> > On Tue, Feb 25, 2014 at 02:16:01PM +1100, Stephen Rothwell wrote:
> > > On Mon, 24 Feb 2014 11:57:10 +1100 Dave Chinner <david@fromorbit.com> wrote:
> > > >
> > > > > Namjae Jeon (10):
> > > > >   fs: Add new flag(FALLOC_FL_COLLAPSE_RANGE) for fallocate
> > > > >   xfs: Add support FALLOC_FL_COLLAPSE_RANGE for fallocate
> > > > 
> > > > I've pushed these to the following branch:
> > > > 
> > > > 	git://oss.sgi.com/xfs/xfs.git xfs-collapse-range
> > > > 
> > > > And so they'll be in tomorrow's linux-next tree.
> > > > 
> > > > >   ext4: Add support FALLOC_FL_COLLAPSE_RANGE for fallocate
> > > > 
> > > > I've left this one alone for the ext4 guys to sort out.
> > > 
> > > So presumably that xfs tree branch is now completely stable and so Ted
> > > could just merge that branch into the ext4 tree as well and put the ext4
> > > part on top of that in his tree.
> > 
> > Well, for some definition of stable. Right now it's just a topic
> > branch that is merged into the for-next branch, so in theory it is
> > still just a set of pending changes in a branch in a repo that has
> > been pushed to linux-next for testing.
> > 
> > That said, I don't see that branch changing unless we find bugs in
> > the code or a problem with the API needs fixing, at which point I
> > would add more commits to it and rebase the for-next branch that you
> > are pulling into the linux-next tree.
> > 
> > Realistically, I'm waiting for Lukas to repost his other pending
> > fallocate changes (the zero range changes) so I can pull the VFS and
> > XFS bits of that into the XFS tree and I can test them together
> > before I'll call the xfs-collapse-range stable and ready to be
> > merged into some other tree...
> 
> Thank you, Namjae and Dave, for driving this; and thank you, Ted and
> Matthew, for raising appropriate mmap concerns (2013-7-31 and 2014-2-2).
> I was aware of this work in progress, but only now found time to look.
> 
> I've not studied the implementation, knowing too little of ext4 and
> xfs; but it sounds like the approach you've taken, writing out dirties
> and truncating all pagecache from the critical offset onwards, is the
> sensible approach for now - lame, and leaves me wondering whether an
> offline tool wouldn't be more appropriate; but a safe place to start
> if we suppose it will be extended to handle pagecache better in future.

Offline? You mean with the filesystem unmounted, or something else?

> Of course I'm interested in the possibility of extending it to tmpfs;
> which may not be a worthwhile exercise in itself, except that it would
> force us to face and solve any pagecache/radixtree issues, if possible,
> thereby enhancing the support for disk-based filesystems.
> 
> I doubt we should look into that before Jan Kara's range locking mods
> arrive, or are rejected.  As I understand it, you're going ahead with
> this, knowing that there can be awkward races with concurrent faults -
> more likely to cause trinity fuzzer reports, than interfere with daily
> usage (trinity seems to be good at faulting into holes being punched).

Yes, the caveat is that the applications that use it (TVs, DVRs, NLE
applications, etc) typically don't use mmap for accessing the data
stream being modified. Further, it's much less generally useful than
holepunching, so when these two are combined, the likely exposure to
issues resulting from mmap deficiencies are pretty damn low.

> That's probably the right pragmatic decision; but I'm a little worried
> that it's justfied by saying we already have such races in hole-punch.
> Collapse is significantly more challenging than either hole-punch or
> truncation: the shifting of pages from one offset to another is new,
> and might present nastier bugs.

Symptoms might be different, but it's exactly the same problem. i.e.
mmap_sem locking inversions preventing the filesystem from
serialising IO path operations like hole punch, truncate and other
extent manipulation operations against concurrent page faults
that enter the IO path.

> Emphasis on "might": I expect it's impossible, given your current
> approach, but something to be on guard against is unmap_mapping_range()
> failing to find and unmap a pte, because the page is mapped at the
> "wrong" place in the vma, resulting in BUG_ON(page_mapped(page))
> in __delete_from_page_cache().

Unmapping occurs before anything is shifted. And even if a fault
does occur before the file size changes at the end of a collapse
range operation (via the truncate path), the page in the page cache
won't be moved about so I don't see how the above problem could
occur. All that will happen is that you get the wrong data in the
mmap()d page, just like you will with hole_punch issues.

> One thing that is slightly wrong in what you have right now, is your
> use of truncate_pagecache_range(): you'll need to add an "even_cows"
> arg to that (or make it a wrapper to a __truncate_pagecache_range()
> taking additional "even_cows" arg).  That arg governs what is done
> with anonymous COW'ed pages in a MAP_PRIVATE mmap of the file.
> 
> Truncation is required by spec to unmap them; hole punching was up
> to us to spec, did not unmap them originally (because there was no
> preliminary call to unmap_mapping_range(), so it happened to rely
> on the inefficient fallback within truncate_inode_page()), and that
> seemed fine because, why discard a user's data unnecessarily?

I don't see there being a problem here - it's the same case as hole
punch. And when we change the file size after shifting extents we
are doing a truncate so that will behave as expected w.r.t.
anonymous COW'ed pages in a MAP_PRIVATE mmap of the file.

> But your case is different: collapse is much closer to truncation,
> and if you do not unmap the private COW'ed pages, then pages left
> behind beyond the EOF will break the spec that requires SIGBUS when
> touching there, and pages within EOF will be confusingly derived
> from file data now belonging to another offset or none (move these
> pages within the user address space? no, I don't think anon_vmas
> would allow that, and there may be no right place to move them).

See above - we never leave pages beyond the new EOF because setting
the new EOF is a truncate operation that calls
truncate_setsize(inode, newsize).

> It's clear that the right and easy thing to do is just to unmap
> them (all of them, from critical offset to EOF), in the rare case
> of there being any such pages.  Whether this detail needs to be
> mentioned in the man page (I don't like throwing away a user's
> data without warning) I'm not sure, Michael can judge.
> 
> FALLOC_FL_COLLAPSE_RANGE: I'm a little sad at the name COLLAPSE,
> but probably seven months too late to object.  It surprises me that
> you're doing all this work to deflate a part of the file, without
> the obvious complementary work to inflate it - presumably all those
> advertisers whose ads you're cutting out, will come back to us soon
> to ask for inflation, so that they have somewhere to reinsert them ;)

The name makes no difference to me - it's a filesystem offload
function of a very specific nature. If we require the opposite
behaviour - inserting unwritten extents after shifting the data up
out of the way - then we can just add a new FALLOC_FL_INSERT_RANGE
command to do that.

But in the absence of anyone needing such functionality, the
complexity of implementing it is not worth the effort.

> I should mention that when "we" implemented this thirty years ago,
> we had a strong conviction that the system call should be idempotent:
> that is, the len argument should indicate the final i_size, not the
> amount being removed from it.  Now, I don't remember the grounds for
> that conviction: maybe it was just an idealistic preference for how
> to design a good system call.  I can certainly see that defining it
> that way round would surprise many app programmers.  Just mentioning
> this in case anyone on these lists sees a practical advantage to
> doing it that way instead.

I don't see how specifying the end file size as an improvement. What
happens if you are collapse a range in a file that is still being
appended to by the application and so you race with a file size
update? IOWs, with such an API the range to be collapsed is
completely unpredictable, and IMO that's a fundamentally broken API.

> I see you've included xfstests and xfs_io updates, nice.  Did you
> realize that util-linux has a /usr/bin/fallocate?  I hope someone
> will update that too.

I don't care about /usr/bin/fallocate - I've never used it in my
life because xfs_io exists on all my systems and is way more
powerful and useful to me than /usr/bin/fallocate. Regardless, I
think someone posted patches for it yesterday.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
