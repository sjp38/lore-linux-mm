Date: Sun, 21 Jul 2002 04:24:55 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: [PATCH 2/2] move slab pages to the lru, for 2.5.27
Message-ID: <Pine.LNX.4.44.0207210245080.6770-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This is an update for the 2.5 port of Ed Tomlinson's patch to move slab
pages onto the lru for page aging, atop 2.5.27 and the full rmap patch.  
It is aimed at being a fairer, self-tuning way to target and evict slab
pages.

Previous description:  
	http://mail.nl.linux.org/linux-mm/2002-07/msg00216.html
Patch URL:
	http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/2.5.27/

What's next:

This patch is intermediate between where we were (freeing slab caches
blindly and not in tune with the rest of the VM), and where we want to be
(cache pruning by page as we scan the active list looking for cold pages
to deactivate).  Uhhh, well, I *think* that's where we want to be.  :)

How do we get there?

Given a slab page, I can find out what cachep and slab I'm dealing with 
(via GET_PAGE_SLAB and friends).  If the cache is prunable one, 
cachep->pruner tells me what kind of callback (dcache/inode/dquot) I 
should invoke to prune the page.  No problem.

The trouble comes when we try to replace shrink_dcache_memory() and
friends with slab-aware pruners.  Namely, how to teach those
inode/dcache/dquot callbacks to free objects belonging to a *specified*
page or slab?  If I have a dentry slab, I'd like to try to liberate
*those* dentries, not some random ones like shrink_dcache_memory does now.
I'm still trying to figure out how to make that work.  Or is that 
totally the wrong approach?  Thoughts?  ;)

[I understand Rik's working on this, but my curiosity made me ask anyway!]

Comments, fixes, & feedback always welcome. :)

Craig Kulesa
Steward Obs.
Univ. of Arizona

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
