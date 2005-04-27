Date: Wed, 27 Apr 2005 11:08:48 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
Message-ID: <20050427150848.GR8018@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linux-MM <linux-mm@kvack.org>
Cc: Ray Bryant <raybry@sgi.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

Hi,

The following set of patches is response to the first round of comments
that were sent out in February

http://marc.theaimsgroup.com/?l=linux-kernel&m=110839604924587&w=2

The consensus of this thread was that manual reclaim should happen
through a syscall and be per-node, and that automatic reclaim should
probably happen through mempolicy hints.

This set is against 2.6.12-rc2-mm2  (sorry for not being against -mm3.
It doesn't boot correctly on Altix)

The patches introduce two different ways to free up page cache from a
node: manually through a syscall and automatically through flag
modifiers to a mempolicy.

Currently if a job is started and there is page cache lying around on a
particular node then allocations will spill onto remote nodes and page
cache won't be reclaimed until the whole system is short on memory.
This can result in a signficiant performance hit for HPC applications
that planned on that memory being allocated locally.

Here's a little summary of the pages in the set:

1/4:  Merge LRU pages

This is the opposite of isolate_lru_pages().  It merges pages from
a list back onto the appropriate LRU lists.

2/4:  Local reclaim core

The reclaim code.  It extends shrink_list() so it can be used to scan
the active list as well.  The core of all of this is
reclaim_clean_pages().  It tries to remove a specified number of pages
from a zone's cache.  It does this without swapping or doing writebacks.
The goal here is to free easily freeable pages.

3/4:  toss_page_cache_node() syscall

This adds the manual reclaim method via a syscall.

4/4:  localreclaim flags for mempolicies

Adds a flags argument to set_mempolicy() and add a new mempolicy.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
