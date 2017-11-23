Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80E6A6B025F
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 13:47:54 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id s28so17579311pfg.6
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:47:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e22si16310289pgv.360.2017.11.23.10.47.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 10:47:51 -0800 (PST)
Date: Thu, 23 Nov 2017 19:45:49 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v2 00/11] Metadata specific accouting and dirty writeout
Message-ID: <20171123184549.GT3553@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org

On Wed, Nov 22, 2017 at 04:15:55PM -0500, Josef Bacik wrote:
> These patches are to support having metadata accounting and dirty handling
> in a generic way.  For dirty metadata ext4 and xfs currently are limited by
> their journal size, which allows them to handle dirty metadata flushing in a
> relatively easy way.  Btrfs does not have this limiting factor, we can have as
> much dirty metadata on the system as we have memory, so we have a dummy inode
> that all of our metadat pages are allocated from so we can call
> balance_dirty_pages() on it and make sure we don't overwhelm the system with
> dirty metadata pages.
> 
> The problem with this is it severely limits our ability to do things like
> support sub-pagesize blocksizes.  Btrfs also supports metadata blocksizes > page
> size, which makes keeping track of our metadata and it's pages particularly
> tricky.  We have the inode mapping with our pages, and we have another radix
> tree for our actual metadata buffers.  This double accounting leads to some fun
> shenanigans around reclaim and evicting pages we know we are done using.
> 
> To solve this we would like to switch to a scheme like xfs has, where we simply
> have our metadata structures tied into the slab shrinking code, and we just use
> alloc_page() for our pages, or kmalloc() when we add sub-pagesize blocksizes.
> In order to do this we need infrastructure in place to make sure we still don't
> overwhelm the system with dirty metadata pages.
> 
> Enter these patches.  Because metadata is tracked on a non-pagesize amount we
> need to convert a bunch of our existing counters to bytes.  From there I've
> added various counters for metadata, to keep track of overall metadata bytes,
> how many are dirty and how many are under writeback.  I've added a super
> operation to handle the dirty writeback, which is going to be handled mostly
> inside the fs since we will need a little more smarts around what we writeback.

The text relevant for btrfs should also go to the btree_inode removal
patch changelog. The cover letter gets lost but we still might need to
refer to the overall logic that's going to be changed in that patch.

And possibly more documentation should go to the code itself, there are
some scattered comments in the tricky parts but the overall logic is not
described and the key functions lack comments.

What's your merge plan? There are other subsystem changes needed, before
the btree_inode removal can happen and can be tested within our for-next
branches. The 4.15 target is out of reach, so I assume 4.16 for the
dependencies and 4.17 for the btree_inode. We can of course test them
earlier, but 4.16 does not seem realistic for the whole patchset.

> The last three patches are just there to show how we use the infrastructure in
> the first 8 patches.  The actuall kill btree_inode patch is pretty big,
> unfortunately ripping out all of the pagecache based handling and replacing it
> with the new infrastructure has to be done whole-hog and can't be broken up
> anymore than it already has been without making it un-bisectable.

I don't completely agree that it cannot be split. I went through it a
few times, the patch is too big for review. It mixes the core part and
cleanups that do not necessarily need to be in the patch. I'd like to
see the core part minimized further, at the cost of leaving some dead
code behind (like the old callbacks).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
