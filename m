Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id C00086B0069
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 16:55:43 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id a2so1979245ybn.20
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 13:55:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p68sor4962946ywd.139.2017.12.11.13.55.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 13:55:38 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH v3 00/11] Metadata specific accouting and dirty writeout
Date: Mon, 11 Dec 2017 16:55:25 -0500
Message-Id: <1513029335-5112-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org

FYI patches 8-10 are purely there so people can see how I intend to use this.
These are large changes that need to go through the btrfs tree and will
undoubtedly change a lot.  My goal is for patches 1-7 to go through Andrew via
the mm tree and then once they have landed to go ahead and work out the details
of the btrfs patches with the other btrfs developers and merge via that tree.
I'm not asking for reviews on those, Jan just mentioned that it would be easier
to tell what I was trying to do if he could see how I intended to use it.

v2->v3:
- addressed issues brought up by Jan in the actual node metadata bytes
  accounting patch.
- collapsed the fprop patch that converted everything to bytes into the patch
  that converted the wb usage of fprop stuff to bytes.

-- Original message --
These patches are to support having metadata accounting and dirty handling
in a generic way.  For dirty metadata ext4 and xfs currently are limited by
their journal size, which allows them to handle dirty metadata flushing in a
relatively easy way.  Btrfs does not have this limiting factor, we can have as
much dirty metadata on the system as we have memory, so we have a dummy inode
that all of our metadat pages are allocated from so we can call
balance_dirty_pages() on it and make sure we don't overwhelm the system with
dirty metadata pages.

The problem with this is it severely limits our ability to do things like
support sub-pagesize blocksizes.  Btrfs also supports metadata blocksizes > page
size, which makes keeping track of our metadata and it's pages particularly
tricky.  We have the inode mapping with our pages, and we have another radix
tree for our actual metadata buffers.  This double accounting leads to some fun
shenanigans around reclaim and evicting pages we know we are done using.

To solve this we would like to switch to a scheme like xfs has, where we simply
have our metadata structures tied into the slab shrinking code, and we just use
alloc_page() for our pages, or kmalloc() when we add sub-pagesize blocksizes.
In order to do this we need infrastructure in place to make sure we still don't
overwhelm the system with dirty metadata pages.

Enter these patches.  Because metadata is tracked on a non-pagesize amount we
need to convert a bunch of our existing counters to bytes.  From there I've
added various counters for metadata, to keep track of overall metadata bytes,
how many are dirty and how many are under writeback.  I've added a super
operation to handle the dirty writeback, which is going to be handled mostly
inside the fs since we will need a little more smarts around what we writeback.

The last three patches are just there to show how we use the infrastructure in
the first 8 patches.  The actuall kill btree_inode patch is pretty big,
unfortunately ripping out all of the pagecache based handling and replacing it
with the new infrastructure has to be done whole-hog and can't be broken up
anymore than it already has been without making it un-bisectable.

Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
