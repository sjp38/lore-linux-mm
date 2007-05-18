From: clameter@sgi.com
Subject: [patch 00/10] Slab defragmentation V2
Date: Fri, 18 May 2007 11:10:40 -0700
Message-ID: <20070518181040.465335396@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763536AbXERSMV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

Hugh: Could you have a look at this? There is lots of critical locking
here....

Support for Slab defragmentation and targeted reclaim. The current
state of affairs is that a large portion of inode and dcache slab caches
can be effectively reclaimed. The remaining problems are:

1. We cannot reclaim dentries / inodes that are in active use.
   Probably inadvisable anyways and maybe impossible if we cannot track
   down all the references to dentries. The active dentries / inodes are
   usually only a small subset of the inode / dentries in the system.

2. Directory reclaim is an issue both for dentries and inodes. A solution
   here may be complex. However, the majority of dentries and inodes are
   *not* directories. So I think that we are fine even without being
   able to reclaim slabs with directory entries in them. These slabs
   will move to the head of the partial list and soon be filled up with
   other entries. This means that the directory entries will tend to
   aggregate over time in certain slabs.

Slab defragmentation is performed during kmem_cache_shrink. This is usually
triggered through the slab shrinkers but can also be manually triggered
through the slabinfo command by running "slabinfo -s".

Support is also provided for antifrag/defrag to evict a specific slab page
through the kmem_cache_vacate function call.  Since we can now target the
freeing of slab pages we may now be able to remove a page that hinders
the freeing of a higher order page in the antifrag/defrag code.

V1->V2
- Clean up control flow using a state variable. Simplify API. Back to 2
  functions that now take arrays of objects.
- Inode defrag support for a set of filesystems
- Fix up dentry defrag support to work on negative dentries by adding
  a new dentry flag that indicates that a dentry is not in the process
  of being freed or allocated.

-- 
