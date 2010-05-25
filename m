Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D3E306004B2
	for <linux-mm@kvack.org>; Tue, 25 May 2010 04:53:35 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 0/5] Per superblock shrinkers V2
Date: Tue, 25 May 2010 18:53:03 +1000
Message-Id: <1274777588-21494-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>


This series reworks the filesystem shrinkers. We currently have a
set of issues with the current filesystem shrinkers:

        1. There is an dependency between dentry and inode cache
           shrinking that is only implicitly defined by the order of
           shrinker registration.
        2. The shrinkers need to walk the superblock list and pin
           the superblock to avoid unmount races with the sb going
           away.
        3. The dentry cache uses per-superblock LRUs and proportions
           reclaim between all the superblocks which means we are
           doing breadth based reclaim. This means we touch every
           superblock for every shrinker call, and may only reclaim
           a single dentry at a time from a given superblock.
        4. The inode cache has a global LRU, so it has different
           reclaim patterns to the dentry cache, despite the fact
           that the dentry cache is generally the only thing that
           pins inodes in memory.
        5. Filesystems need to register their own shrinkers for
           caches and can't co-ordinate them with the dentry and
           inode cache shrinkers.

The series starts by converting the inode cache to per-superblock
LRUs and changes the shrinker to match the dentry cache (#4).

It then adds a context to the shrinker callouts by passing the
shrinker structure with the callout. With this, a shrinker structure
is added to the superblock structure and a per-superblock shrinker
is registered.  Both the inode and dentry caches are modified to
shrunk via the superblock shrinker, and this directly encodes the
dcache/icache dependency inside the shrinker (#1).

This shrinker structure also avoids the need to pin the superblock
inside the shrinker because the shrinker is unregistered before the
superblock is freed (#2). Further, it pushes the proportioning of
reclaim between superblocks back up into the shrinker and batches
all the reclaim from a superblock into a tight call loop until the
shrink cycle for that superblock is complete. This effectively
converts reclaim to a depth-based reclaim mechanism which has a
smaller CPU cache footprint than the current mechanism (#3).

Then a pair of superblock operations that can be used to implement
filesystem specific cache reclaim is added. This is split into two
operations we don't need to overload the number of objects to scan
to indicate that a count should be returned.

Finally, the XFS inode cache shrinker is converted to use these
superblock operations, removing the need to register a shrinker,
keep a global list of XFS filesystems and locking to access the
per-filesystem caches. This fixes several new lockdep warnings the
XFS shrinker introduces because of the different contexts the
shrinker is called in, and allows for correct proportioning of
reclaim between the dentry, inode and XFS inode caches on the
filesystem to be executed (#5).

Version 2:
- rebase on new superblock iterator code in 2.6.35
- move sb shrinker registration to sget() and unregister to
  deactivate_super() to avoid unregister_shrinker() being called
  inside a spinlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
