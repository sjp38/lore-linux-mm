Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id C75CD6B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 10:16:46 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so1441608pbc.37
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 07:16:46 -0700 (PDT)
Received: from psmtp.com ([74.125.245.105])
        by mx.google.com with SMTP id sg3si18050502pbb.343.2013.10.30.07.16.42
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 07:16:43 -0700 (PDT)
Date: Wed, 30 Oct 2013 14:16:16 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH] mm: list_lru: fix almost infinite loop causing effective
	livelock
Message-ID: <20131030141616.GB16735@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <dchinner@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>

I've seen a fair number of issues with kswapd and other processes
appearing to get stuck in v3.12-rc.  Using sysrq-p many times seems
to indicate that it gets stuck somewhere in list_lru_walk_node(),
called from prune_icache_sb() and super_cache_scan().

I never seem to be able to trigger a calltrace for functions above
that point.

So I decided to add the following to super_cache_scan():

@@ -81,10 +81,14 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
        inodes = list_lru_count_node(&sb->s_inode_lru, sc->nid);
        dentries = list_lru_count_node(&sb->s_dentry_lru, sc->nid);
        total_objects = dentries + inodes + fs_objects + 1;
+printk("%s:%u: %s: dentries %lu inodes %lu total %lu\n", current->comm, current->pid, __func__, dentries, inodes, total_objects);
 
        /* proportion the scan between the caches */
        dentries = mult_frac(sc->nr_to_scan, dentries, total_objects);
        inodes = mult_frac(sc->nr_to_scan, inodes, total_objects);
+printk("%s:%u: %s: dentries %lu inodes %lu\n", current->comm, current->pid, __func__, dentries, inodes);
+BUG_ON(dentries == 0);
+BUG_ON(inodes == 0);
 
        /*
         * prune the dcache first as the icache is pinned by it, then
@@ -99,7 +103,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
                freed += sb->s_op->free_cached_objects(sb, fs_objects,
                                                       sc->nid);
        }
-
+printk("%s:%u: %s: dentries %lu inodes %lu freed %lu\n", current->comm, current->pid, __func__, dentries, inodes, freed);
        drop_super(sb);
        return freed;
 }

and shortly thereafter, having applied some pressure, I got this:

update-apt-xapi:1616: super_cache_scan: dentries 25632 inodes 2 total 25635    
update-apt-xapi:1616: super_cache_scan: dentries 1023 inodes 0                 
------------[ cut here ]------------                                           
Kernel BUG at c0101994 [verbose debug info unavailable]                        
Internal error: Oops - BUG: 0 [#3] SMP ARM                                     
Modules linked in: fuse rfcomm bnep bluetooth hid_cypress                      
CPU: 0 PID: 1616 Comm: update-apt-xapi Tainted: G      D      3.12.0-rc7+ #154 
task: daea1200 ti: c3bf8000 task.ti: c3bf8000                                  
PC is at super_cache_scan+0x1c0/0x278                                          
LR is at trace_hardirqs_on+0x14/0x18                                           
pc : [<c0101994>]    lr : [<c007e418>]    psr: 600f0013                        
sp : c3bf9ba8  ip : c3bf9af8  fp : c3bf9bf4                                    
r10: 00000000  r9 : 00000400  r8 : 00000000                                    
r7 : 000003ff  r6 : 00006423  r5 : db3f0800  r4 : c3bf9cc8                     
r3 : 00000000  r2 : 000003ff  r1 : 00000001  r0 : 0000003e                     
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user              
Control: 10c53c7d  Table: 13b60059  DAC: 00000015                              
Process update-apt-xapi (pid: 1616, stack limit = 0xc3bf8240)                  
...
Backtrace:                                                                     
[<c01017d4>] (super_cache_scan) from [<c00cd69c>] (shrink_slab+0x254/0x4c8)    
 r10:00000000 r9:00000023 r8:c0930f9c r7:c3bf9cc8 r6:db3f0bd0 r5:00000400      
 r4:00000423                                                                   
[<c00cd448>] (shrink_slab) from [<c00d09a0>] (try_to_free_pages+0x3a0/0x5e0)   
 r10:c0990dcc r9:c0ef5a0c r8:c3bf9cdc r7:c3bf9cd8 r6:00200010 r5:c3bf9cd0      
 r4:0000f5cb                                                                   
[<c00d0600>] (try_to_free_pages) from [<c00c59cc>] (__alloc_pages_nodemask+0x5)
 r10:00000035 r9:c0990dc0 r8:00000000 r7:00000000 r6:c093c7d0 r5:c3bf8000      
 r4:002084d2                                                                   
[<c00c5454>] (__alloc_pages_nodemask) from [<c00e07c0>] (__pte_alloc+0x2c/0x13)
 r10:c3b60000 r9:daea1200 r8:0000002a r7:dbacbf20 r6:c3bf8000 r5:dba99600      
 r4:c3b60150                                                                   
[<c00e0794>] (__pte_alloc) from [<c00e3a70>] (handle_mm_fault+0x84c/0x914)     
 r8:0000002a r7:dbacbf20 r6:c3bf8000 r5:0540e000 r4:000af855 r3:0540e000       
[<c00e3224>] (handle_mm_fault) from [<c001a4cc>] (do_page_fault+0x1f0/0x3bc)   
 r10:00000805 r9:daea1200 r8:dbacbf20 r7:0540ea84 r6:c3bf8000 r5:c3bf9fb0      
 r4:dba99600                                                                   
[<c001a2dc>] (do_page_fault) from [<c001a7b0>] (do_translation_fault+0xac/0xb8)
 r10:00021000 r9:00030588 r8:c3bf9fb0 r7:00000005 r6:c0941bf4 r5:0540ea84      
 r4:00000805                                                                   
[<c001a704>] (do_translation_fault) from [<c000840c>] (do_DataAbort+0x38/0xa0) 
 r7:00000005 r6:c0941bf4 r5:0540ea84 r4:00000805                               
[<c00083d4>] (do_DataAbort) from [<c00133f8>] (__dabt_usr+0x38/0x40)           

Notice that we had a very low number of inodes, which were reduced to
zero my mult_frac().

Now, prune_icache_sb() calls list_lru_walk_node() passing that number
of inodes (0) into that as the number of objects to scan:

long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
                     int nid)
{
        LIST_HEAD(freeable);
        long freed;

        freed = list_lru_walk_node(&sb->s_inode_lru, nid, inode_lru_isolate,
                                       &freeable, &nr_to_scan);

which does:

unsigned long
list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
                   void *cb_arg, unsigned long *nr_to_walk)
{

        struct list_lru_node    *nlru = &lru->node[nid];
        struct list_head *item, *n;
        unsigned long isolated = 0;

        spin_lock(&nlru->lock);
restart:
        list_for_each_safe(item, n, &nlru->list) {
                enum lru_status ret;

                /*
                 * decrement nr_to_walk first so that we don't livelock if we
                 * get stuck on large numbesr of LRU_RETRY items
                 */
                if (--(*nr_to_walk) == 0)
                        break;

So, if *nr_to_walk was zero when this function was entered, that means
we're wanting to operate on (~0UL)+1 objects - which might as well be
infinite.

Clearly this is not correct behaviour.  If we think about the behaviour
of this function when *nr_to_walk is 1, then clearly it's wrong - we
decrement first and then test for zero - which results in us doing
nothing at all.  A post-decrement would give the desired behaviour -
we'd try to walk one object and one object only if *nr_to_walk were
one.

It also gives the correct behaviour for zero - we exit at this point.

Fixes: 5cedf721a7cdb5 (list_lru: fix broken LRU_RETRY behaviour)
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 mm/list_lru.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 72467914b856..917b1e0ea82f 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -81,7 +81,7 @@ list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
 		 * decrement nr_to_walk first so that we don't livelock if we
 		 * get stuck on large numbesr of LRU_RETRY items
 		 */
-		if (--(*nr_to_walk) == 0)
+		if ((*nr_to_walk)-- == 0)
 			break;
 
 		ret = isolate(item, &nlru->lock, cb_arg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
