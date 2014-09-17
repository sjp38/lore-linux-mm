Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A91036B0035
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 20:09:08 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so833744pde.19
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 17:09:08 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id ur9si32110011pbc.125.2014.09.16.17.09.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 17:09:07 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id w10so844400pde.13
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 17:09:07 -0700 (PDT)
Date: Tue, 16 Sep 2014 17:07:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Best way to pin a page in ext4?
In-Reply-To: <20140916180759.GI6205@thunk.org>
Message-ID: <alpine.LSU.2.11.1409161555120.5144@eggly.anvils>
References: <20140915185102.0944158037A@closure.thunk.org> <36321733-F488-49E3-8733-C6758F83DFA1@dilger.ca> <20140916180759.GI6205@thunk.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Andreas Dilger <adilger@dilger.ca>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, linux-ext4@vger.kernel.org

On Tue, 16 Sep 2014, Theodore Ts'o wrote:
> On Mon, Sep 15, 2014 at 02:57:23PM -0600, Andreas Dilger wrote:
> > 
> > As discussed in http://lists.openwall.net/linux-ext4/2013/03/25/15
> > the bitmap pages were being evicted under memory pressure even when
> > they are active use.  That turned out to be an MM problem and not an
> > ext4 problem in the end, and was fixed in commit c53954a092d in 3.11,
> > in case you are running an older kernel.
> 
> Yes, I remember.  And that could potentially be a contributing factor,
> since the user in question is using 3.2.  However, the user in
> question has a use case where bitmap pinning is probably going to be
> needed given the likely allocation patterns of a DVR; if the pages
> aren't pinned, it's likely that by the time the DVR needs to fallocate
> space for a new show, the bitmap pages would have been aged out due to
> not being frequently accessed enough, even if the usage tracking was
> backported to a 3.2 kernel.
> 
> > > The other approach would be to keep an elevated refcount on the pages in
> > > question, but it seemed it would be more efficient use the mlock
> > > facility since that keeps the pages on an unevictable list.
> > 
> > It doesn't seem unreasonable to just grab an extra refcount on the pages
> > when they are first loaded.  
> 
> Well yes, but using mlock_vma_page() would be a bit more efficient,
> and technically, more correct than simply elevating the refcount.
> 
> > However, the memory usage may be fairly
> > high (32MB per 1TB of disk) so this definitely can't be generally used,
> > and it would be nice to make sure that ext4 is already doing the right
> > thing to keep these important pages in cache.
> 
> Well, as I mentioned above, the use case in question is a DVR, where
> having the disk need to suddenly seek a large number block groups, and
> thus pull in a largish number of allocation bitmaps, might be harmful
> for a video replay that might be happening at the same time that the
> DVR needs to fallocate space for a new TV show to be recorded.
> 
> And for a 2TB disk, the developer in question felt that he could
> afford pinning 64MB.  So no, it's not a general solution, but it's
> probably good enough for now.
> 
> Long run, I think we really need to consider trying to cache free
> space information in some kind in-memory of rbtree, with a bail-out in
> the worst case of the free space is horrendously fragmented in a
> particular block group.  But as a quick hack, using mlock_vma_page()
> was the simplest short term solution.
> 
> The main question then for the mm developers is would there be
> objections in making mlock/munlock_vma_page() be EXPORT_SYMBOL_GPL and
> moving the function declaration from mm/internal.h to
> include/linux/mm.h?

Yes, I'm afraid there is a pitfall, and there would be objections.

It's not accidental that the function is called mlock_vma_page(): it
and PageMlocked are about support for mlock'ed areas of user memory;
and if you look hard, you'll find that PageMlocked needs to be
"supported" by at least one VM_LOCKED vma.

You might (I'm not certain) be able to get away with extending the
use of mlock_vma_page() and munlock_vma_page() in this (admittedly
attractive) way, up until someone mmap's that range (and mlocks
then munlocks it? again, I'm not certain if that's necessary).
Then the PageMlocked flag is liable to be cleared, because the
page will not be found in any mlock'ed vma; and the page can
then be reclaimed behind your back (statistics gone wrong too?
again I'm not sure).

Now, I expect it's unlikely (impossible?) for anyone to mmap your
bitmap pages while they're being used as filesystem metadata (rather
than mere blockdev pages).  But you can see why we would prefer not
to export those functions.

I suspect that to handle your special case, we would need to declare
another page flag: but it would need a lot more uses to justify that.
For now I agree with Andreas, just grab an extra refcount; but you're
right that leaving these pages on evictable LRUs is regrettable,
and can be inefficient under reclaim.

On the page migration issue: it's not quite as straightforward as
Christoph suggests.  He and I agree completely that mlocked pages
should be migratable, but some real-time-minded people disagree:
so normal compaction is still forbidden to migrate mlocked pages in
the vanilla kernel (though we in Google patch that prohibition out).
So pinning by refcount is no worse for compaction than mlocking,
in the vanilla kernel.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
