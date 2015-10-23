Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4256B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 03:41:19 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so111288207pad.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 00:41:19 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id xg5si27589701pab.13.2015.10.23.00.41.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 00:41:18 -0700 (PDT)
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 3D426205F8
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 03:41:15 -0400 (EDT)
Message-ID: <1445586069.2996.16.camel@themaw.net>
Subject: Re: [RFC] A couple of questions about the paged I/O sub system
From: Ian Kent <raven@themaw.net>
Date: Fri, 23 Oct 2015 15:41:09 +0800
In-Reply-To: <alpine.LSU.2.11.1510221754350.3081@eggly.anvils>
References: <1445409598.5025.17.camel@themaw.net>
	 <alpine.LSU.2.11.1510211212440.2711@eggly.anvils>
	 <1445477797.3063.28.camel@themaw.net>
	 <alpine.LSU.2.11.1510221754350.3081@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2015-10-22 at 18:54 -0700, Hugh Dickins wrote:
> On Thu, 22 Oct 2015, Ian Kent wrote:
> > On Wed, 2015-10-21 at 12:56 -0700, Hugh Dickins wrote:
> > > On Wed, 21 Oct 2015, Ian Kent wrote:
> > 
> > Thanks for taking the time to reply Hugh.
> > 
> > > 
> > > > Hi all,
> > > > 
> > > > I've been looking through some of the page reclaim code and at
> > > > truncate_inode_pages().
> > > > 
> > > > I'm not familiar with the code and I'm struggling to understand
> it.
> > > > 
> > > > One thing that is puzzling me right now is, if a file has pages
> > > that
> > > > have been modified and are swapped out when
> > > pagevec_lookup_entries() is
> > > > called will they be found?
> > > 
> > > truncate_inode_pages() is a library function which a filesystem
> calls
> > > at some stage in its inode truncation processing, to take all the
> > > incore
> > > pages out of pagecache (out of its radix_tree), and free them up
> > > (usually: some might be otherwise pinned in memory at the time).
> > > 
> > > A filesystem will have other work to do, very particular to that
> > > filesystem, to free up the actual disk blocks: that's definitely
> > > not part of truncate_inode_pages()'s job.
> > > 
> > > It's also called when evicting an inode no longer needed in
> memory,
> > > to free the associated pagecache, when not deleting the blocks on
> > > disk.
> > > 
> > > I think I don't understand your "swapped out": modifications
> occur to
> > > a page while it is in pagecache, and those modifications need to
> be
> > > written back to disk before that page can be reclaimed for other
> use.
> > 
> > Indeed, now I think about it, "swapped out" is a bad choice of
> words
> > when talking about a paged IO system.
> > 
> > What I'm trying to say is if pages allocated to a mapping are
> modified,
> > then under memory pressure, are they ever reclaimed by writing them
> to
> > swap storage or are they always reclaimed by writing them back to
> disk?
> > 
> > Now I think about what you've said here and looking at the code I
> > suspect the answer is they are always reclaimed by writing them to
> > disk.
> 
> Yes.
> 
> > 
> > > 
> > > > 
> > > > If not then how does truncate_inode_pages(_range)() handle
> waiting
> > > for
> > > > these pages to be swapped back in to perform the writeback and
> > > > truncation?
> > > 
> > > Pages are never "swapped back in to perform the writeback":
> > > if writeback is needed, it's done before the page can be freed
> from
> > > pagecache; and if that data is needed again after the page was
> freed,
> > > it's read back in from disk to fresh page.
> > 
> > That makes sense, using swap would be unnecessary double handling.
> > 
> > > 
> > > You may be worrying about what happens when a page is modified or
> > > under writeback when it is truncated: I think that's something
> each
> > > filesystem has to be careful of, and may deal with in different
> ways.
> > 
> > I'm wondering how a mapping nrpages can be non-zero (read greater
> than
> > one) after calling truncate_inode_pages().
> > 
> > But I'm looking at a much older kernel so it's quite different to
> > current upstream and this seemed like a question relevant to both
> > kernels to get some idea of how page reclaim works.
> > 
> > I guess what I'm really looking to work out is if it's possible,
> with
> > the current upstream kernel, for a mapping to have nrpages greater
> than
> > 1 after calling truncate_inode_pages() and hopefully get some
> > explanation of why if that's not so.
> 
> I assume you're worrying about a truncate_inode_pages(mapping, 0). 
> If
> it's truncate_inode_pages(mapping, 1), or lstart anything greater
> than 0,
> then it will leave behind the incompletely truncated pages at the
> start:
> no mystery in that.

I am, sorry I didn't make that clear to start with.

> 
> > 
> > It's certainly possible with the older kernel I'm looking at but I
> need
> > some info. before I consider looking for possible changes to back
> port.
> 
> Probably what you're looking for is Jan Kara's v3.0 commit
> 08142579b6ca
> "mm: fix assertion mapping->nrpages == 0 in end_writeback()".

I looked at that commit and the back port that went into the older
kernel I'm looking at (around 2011/2012) and I couldn't work out why
taking the tree_lock lock in end_writeback() would always result in
nrpages == 0 due to the quite granular lock/decrement/unlock in the
reclaim code.

In fact, when looking at this, I think I saw a report for that same
problem on a later kernel but I didn't look further (yet) because, in
at least one crash analysis I looked at, nrpages was described as "much
larger than 1" so this is probably a different problem.

Don't think any crash dumps remain so I can't give details, I probably
need to request they be collected, but that's going to be a hard sell
as well, ;)

> > 
> > > 
> > > I'm not sure how much to read in to your use of the word "swap".
> > > It's true that shmem/tmpfs uses swap (of the swapon/swapoff
> variety)
> > > as backing for its pages when under pressure (and uses its own
> > > variant
> > > shmem_undo_range() to manage that, instead of
> > > truncate_inode_pages()),
> > > but most filesystems don't use "swap" at all.
> > > 
> > > I just noticed your subject "paged I/O sub system": I hope you
> > > realize
> > > that mm/page_io.c is solely concerned with swap (of the
> > > swapon/swapoff
> > > variety), and has next to nothing to do with filesystems.  (Just
> as,
> > > conversely, mm/swap.c has next to nothing to do with swap.)
> > 
> > LOL, right, I'm looking at the page reclaim code which, so far,
> hasn't
> > lead me to either of those source files.
> > 
> > > 
> > > > 
> > > > Anyone, please?
> > > 
> > > I hope something I've said there has helped, but warn you that
> > > I'm a terrible person to engage in an extended conversation with!
> > > Expect long silences, pray for someone else to jump in.
> > 
> > As well as pointing out that swap storage shouldn't be used in this
> > case you've reminded me of the difference between swapping and
> demand
> > paging, so that's a good start.
> 
> So long as you leave it as a distant memory: you're right that
> "swapping"
> used to mean copying out a whole process to disk and reading in
> another,
> but Linux never implemented it that way: it's always been paging out
> to
> and in from the swap medium, much like demand paging from file.
> 
> (I say "never" and "always": I think that's so,
> but I don't really know beyond v2.4.0.)

LOL, I think I've actually read that somewhere too, which probably
means around the 2.6 time frame. In one eye and out the other if your
not immediately concerned with it.

> 
> Hugh
> 
> > 
> > Perhaps folks at linux-mm will have more to say.
> > 
> > 
> > > > Ian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
