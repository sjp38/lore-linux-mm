Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17rrSh-0006r6-00
	for <linux-mm@kvack.org>; Wed, 18 Sep 2002 19:54:39 -0700
Date: Wed, 18 Sep 2002 19:54:39 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: free_more_memory() calls try_to_free_pages() with a NULL classzone
Message-ID: <20020919025439.GI28202@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm not convinced contig_page_data is supposed to even be defined.
This needs to do something similar to

	for_each_pgdat(pgdat) {
		zone = pgdat->node_zonelists[GFP_NOFS & GFP_ZONEMASK];
		if (!zone || !zone->size)
			continue;
		try_to_free_pages(zone, GFP_NOFS, 0);
	}

Discovered during tiobench 16K on 32x/32G NUMA-Q.


Bill

Program received signal SIGSEGV, Segmentation fault.
shrink_caches (classzone=0x0, priority=12, total_scanned=0xea86fd9c,
    gfp_mask=208, nr_pages=32) at vmscan.c:614
614     vmscan.c: No such file or directory.
        in vmscan.c
(gdb) bt
#0  shrink_caches (classzone=0x0, priority=12, total_scanned=0xea86fd9c,
    gfp_mask=208, nr_pages=32) at vmscan.c:614
#1  0xc0137ea8 in try_to_free_pages (classzone=0x0, gfp_mask=208, order=0)
    at vmscan.c:673
#2  0xc014719f in free_more_memory () at buffer.c:476
#3  0xc0147d68 in __getblk_slow (bdev=0xf68fada0, block=36, size=4096)
    at buffer.c:1157                                  
#4  0xc01480cb in __getblk (bdev=0xf68fada0, block=36, size=4096)
    at buffer.c:1402
#5  0xc01480f7 in __bread (bdev=0xf68fada0, block=36, size=4096)
    at buffer.c:1412
#6  0xc0177361 in ext2_get_inode (sb=0xf68e0e00, ino=993, p=0xea86fe6c)
    at /mnt/b/2.5.36/linux-2.5.36/include/linux/buffer_head.h:227
#7  0xc017767a in ext2_update_inode (inode=0xdbc510b4, do_sync=0)
    at inode.c:1076
#8  0xc0177998 in ext2_write_inode (inode=0xdbc510b4, wait=0) at inode.c:1164
#9  0xc0163062 in write_inode (inode=0xdbc510b4, sync=0) at fs-writeback.c:108
#10 0xc01630f2 in __sync_single_inode (inode=0xdbc510b4, wait=0,
    wbc=0xea86ff98) at fs-writeback.c:152
#11 0xc01632c0 in __writeback_single_inode (inode=0xdbc510b4, sync=0,
    wbc=0xea86ff98) at fs-writeback.c:198
#12 0xc0163452 in sync_sb_inodes (sb=0xf68e0e00, wbc=0xea86ff98)
    at fs-writeback.c:276
#13 0xc01635c1 in writeback_inodes (wbc=0xea86ff98) at fs-writeback.c:322
#14 0xc01413df in background_writeout (_min_pages=3235) at page-writeback.c:190
#15 0xc0140ff8 in __pdflush (my_work=0xea86ffd4) at pdflush.c:119
#16 0xc01410e7 in pdflush (dummy=0x0) at pdflush.c:167

MemTotal:     32107248 kB
MemFree:      14422976 kB
MemShared:           0 kB
Buffers:          1396 kB
Cached:       16772800 kB
SwapCached:          0 kB
Active:          36004 kB
Inactive:     16982084 kB
HighTotal:    31588352 kB
HighFree:     14421456 kB
LowTotal:       518896 kB
LowFree:          1520 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:         2278444 kB
Writeback:       46356 kB
Mapped:         253176 kB
Slab:           332592 kB
Committed_AS: 38937664 kB
PageTables:      78708 kB
ReverseMaps:     94874

       buffer_head:   199327KB   199327KB  100.0 
       names_cache:    47520KB    47520KB  100.0 
       task_struct:    24898KB    25295KB   98.42
   radix_tree_node:    20438KB    20438KB  100.0 
    vm_area_struct:     3363KB     3363KB  100.0 
  ext2_inode_cache:     2197KB     2197KB  100.0 
         size-1024:     1604KB     1604KB  100.0 
         biovec-16:     1044KB     1293KB   80.75
         size-2048:     1008KB     1008KB  100.0 
         pte_chain:      754KB      819KB   92.1 
      dentry_cache:      780KB      780KB  100.0 
        biovec-256:      780KB      780KB  100.0 
              filp:      697KB      701KB   99.46
         size-4096:      608KB      608KB  100.0 
          sigqueue:      530KB      579KB   91.59
           size-32:      512KB      512KB  100.0 
 skbuff_head_cache:      498KB      498KB  100.0 
          size-512:      480KB      480KB  100.0 
               bio:      333KB      464KB   71.77
        biovec-128:      390KB      390KB  100.0 
          size-256:      367KB      367KB  100.0 
   blkdev_requests:      336KB      341KB   98.68
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
