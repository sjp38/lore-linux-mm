Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4204D6B009F
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 01:42:32 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so536349pdj.12
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 22:42:31 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id qy5si2752373pab.79.2014.02.25.22.42.29
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 22:42:31 -0800 (PST)
Date: Wed, 26 Feb 2014 17:42:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 0/10] fs: Introduce new flag(FALLOC_FL_COLLAPSE_RANGE)
 for fallocate
Message-ID: <20140226064224.GU13647@dastard>
References: <1392741436-19995-1-git-send-email-linkinjeon@gmail.com>
 <20140224005710.GH4317@dastard>
 <20140225141601.358f6e3df2660d4af44da876@canb.auug.org.au>
 <20140225041346.GA29907@dastard>
 <alpine.LSU.2.11.1402251217030.2380@eggly.anvils>
 <20140226011347.GL13647@dastard>
 <alpine.LSU.2.11.1402251856060.1114@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402251856060.1114@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Theodore Ts'o <tytso@mit.edu>, Stephen Rothwell <sfr@canb.auug.org.au>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>

On Tue, Feb 25, 2014 at 08:45:15PM -0800, Hugh Dickins wrote:
> On Wed, 26 Feb 2014, Dave Chinner wrote:
> > On Tue, Feb 25, 2014 at 03:23:35PM -0800, Hugh Dickins wrote:
> > > Of course I'm interested in the possibility of extending it to tmpfs;
> > > which may not be a worthwhile exercise in itself, except that it would
> > > force us to face and solve any pagecache/radixtree issues, if possible,
> > > thereby enhancing the support for disk-based filesystems.
> > > 
> > > I doubt we should look into that before Jan Kara's range locking mods
> > > arrive, or are rejected.  As I understand it, you're going ahead with
> > > this, knowing that there can be awkward races with concurrent faults -
> > > more likely to cause trinity fuzzer reports, than interfere with daily
> > > usage (trinity seems to be good at faulting into holes being punched).
> > 
> > Yes, the caveat is that the applications that use it (TVs, DVRs, NLE
> > applications, etc) typically don't use mmap for accessing the data
> > stream being modified. Further, it's much less generally useful than
> > holepunching, so when these two are combined, the likely exposure to
> > issues resulting from mmap deficiencies are pretty damn low.
> 
> Agreed, but we do want to define how the interaction behaves, we want
> it to be the same across all filesystems supporting COLLAPSE_RANGE,
> and we don't want it to lead to system crashes or corruptions.

We have defined it. It's just a data manipulation operation that
moves file data from one offset to another. How  a filesystem
implements that is a filesystem's problem, not a problem with the
API.

ext4 and XFS implement it by removing all cached data and mappings
over the range from memory and then mainpulating extent status.
Other fileystems might be able to do similar things, or we might
just do an internal kernel read/write loop. And there's nothing
ruling out a hardware ior nework protocol copy offload being used to
implement an optimised data copy, either.

tmpfs is different in that it's only data store is the page cache,
so it needs to operate within the constraints of the page cache.
moving pages inside the page cache might be a new operation for
tmpfs, but it's not an operation that is needed by filesystems
to implement this file data manipulation.

> > > That's probably the right pragmatic decision; but I'm a little worried
> > > that it's justfied by saying we already have such races in hole-punch.
> > > Collapse is significantly more challenging than either hole-punch or
> > > truncation: the shifting of pages from one offset to another is new,
> > > and might present nastier bugs.
> > 
> > Symptoms might be different, but it's exactly the same problem. i.e.
> > mmap_sem locking inversions preventing the filesystem from
> > serialising IO path operations like hole punch, truncate and other
> > extent manipulation operations against concurrent page faults
> > that enter the IO path.
> 
> That may (may) be true of the current kick-everything-out-of-pagecache
> approach.  But in general I stand by "Collapse is significantly more
> challenging".  Forgive me if that amounts to saying "Hey, here's a
> more complicated way to do it.  Ooh, this way is more complicated."
> The concept of moving a page from one file offset to another is new,
> and can be expected to pose new difficulties.

Collapse might be challenging for tmpfs, but it's relatively trivial
for block based filesystems because we have an independent backing
store and so we don't need to move cached data around.

> > > Emphasis on "might": I expect it's impossible, given your current
> > > approach, but something to be on guard against is unmap_mapping_range()
> > > failing to find and unmap a pte, because the page is mapped at the
> > > "wrong" place in the vma, resulting in BUG_ON(page_mapped(page))
> > > in __delete_from_page_cache().
> > 
> > Unmapping occurs before anything is shifted. And even if a fault
> > does occur before the file size changes at the end of a collapse
> > range operation (via the truncate path), the page in the page cache
> > won't be moved about so I don't see how the above problem could
> > occur. All that will happen is that you get the wrong data in the
> > mmap()d page, just like you will with hole_punch issues.
> 
> I think you're probably right.  I expect that attempting to fault
> a page back from disk while collapse is shifting down, will hit a
> mutex and wait.  But that's liable to differ from filesystem to
> filesystem, so I'm not certain.

Well, no, we can't do that entirely atomically because of mmap_sem
inversions. Individual extent shifts, yes, but not against the
operation as a whole. i.e. fallocate needs to serialise against IO
operations, but we can't serialise Io operations against page faults
because of mmap_sem inversions....

> > > But your case is different: collapse is much closer to truncation,
> > > and if you do not unmap the private COW'ed pages, then pages left
> > > behind beyond the EOF will break the spec that requires SIGBUS when
> > > touching there, and pages within EOF will be confusingly derived
> > > from file data now belonging to another offset or none (move these
> > > pages within the user address space? no, I don't think anon_vmas
> > > would allow that, and there may be no right place to move them).
> > 
> > See above - we never leave pages beyond the new EOF because setting
> > the new EOF is a truncate operation that calls
> > truncate_setsize(inode, newsize).
> 
> Right, thanks, I now see the truncate_setsize() in the xfs case -
> though not in the ext4 case, which looks as if it's just doing an
> i_size_write() afterwards.

So that's a bug in the ext4 code ;)

> Yes, truncate_setsize() at the end should answer my SIGBUS objection.
> And with that out of the way, although I don't particularly care for
> the weirdness of private COW'ed pages becoming associated with file
> offsets they never originated from, I don't think I could argue with
> you when you tell me "well, that's the weirdness you get from mixing
> COLLAPSE_RANGE with MAP_PRIVATE mmaps".
> 
> Looks like there's no need for the __truncate_pagecache_range() with
> even_cows arg that I was advocating: we just need ext4 to truncate
> properly at the end, and document the disassociated private pages.

*nod*

> > > It's clear that the right and easy thing to do is just to unmap
> > > them (all of them, from critical offset to EOF), in the rare case
> > > of there being any such pages.  Whether this detail needs to be
> > > mentioned in the man page (I don't like throwing away a user's
> > > data without warning) I'm not sure, Michael can judge.
> > > 
> > > FALLOC_FL_COLLAPSE_RANGE: I'm a little sad at the name COLLAPSE,
> > > but probably seven months too late to object.  It surprises me that
> > > you're doing all this work to deflate a part of the file, without
> > > the obvious complementary work to inflate it - presumably all those
> > > advertisers whose ads you're cutting out, will come back to us soon
> > > to ask for inflation, so that they have somewhere to reinsert them ;)
> > 
> > The name makes no difference to me - it's a filesystem offload
> > function of a very specific nature. If we require the opposite
> > behaviour - inserting unwritten extents after shifting the data up
> > out of the way - then we can just add a new FALLOC_FL_INSERT_RANGE
> > command to do that.
> > 
> > But in the absence of anyone needing such functionality, the
> > complexity of implementing it is not worth the effort.
> 
> Yes, it's not a requirement that it be implemented immediately.
> 
> > 
> > > I should mention that when "we" implemented this thirty years ago,
> > > we had a strong conviction that the system call should be idempotent:
> > > that is, the len argument should indicate the final i_size, not the
> > > amount being removed from it.  Now, I don't remember the grounds for
> > > that conviction: maybe it was just an idealistic preference for how
> > > to design a good system call.  I can certainly see that defining it
> > > that way round would surprise many app programmers.  Just mentioning
> > > this in case anyone on these lists sees a practical advantage to
> > > doing it that way instead.
> > 
> > I don't see how specifying the end file size as an improvement. What
> > happens if you are collapse a range in a file that is still being
> > appended to by the application and so you race with a file size
> > update? IOWs, with such an API the range to be collapsed is
> > completely unpredictable, and IMO that's a fundamentally broken API.
> 
> That's fine if you don't see the idempotent API as an improvement,
> I just wanted to put it on the table in case someone does see an
> advantage to it.  But I think I'm missing something in your race
> example: I don't see a difference between the two APIs there.


Userspace can't sample the inode size via stat(2) and then use the value for a
syscall atomically. i.e. if you specify the offset you want to
collapse at, and the file size you want to have to define the region
to collapse, then the length you need to collapse is (current inode
size - end file size). If "current inode size" can change between
the stat(2) and fallocate() call (and it can), then the length being
collapsed is indeterminate....

> > > I see you've included xfstests and xfs_io updates, nice.  Did you
> > > realize that util-linux has a /usr/bin/fallocate?  I hope someone
> > > will update that too.
> > 
> > I don't care about /usr/bin/fallocate - I've never used it in my
> > life because xfs_io exists on all my systems and is way more
> > powerful and useful to me than /usr/bin/fallocate. Regardless,
> > I think someone posted patches for it yesterday.
> 
> Your scorn is noted: yes, it is pretty simple,
> but I'm glad to hear Dongsu is attending to it.

Not scorn - "don't care" was careless phrasing. What I was trying to
say is that fallocate is not really relevant for testing filesystem
implementations as you need a bunch more functionality to be able to
test the syscall and filesystems adequately.....

Cheers,

Dave.


> 
> Hugh
> 

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
