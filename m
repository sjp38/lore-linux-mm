Date: Tue, 25 Nov 2008 21:35:02 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 0/9] swapfile: cleanups and solidstate mods
Message-ID: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a batch of 9 mm patches, intended for 2.6.29: a minor bugfix
and some cleanups in swapfile.c, before improving the behaviour of
swap on solidstate, by implementing discard and better nonrotational
allocation.  Hopefully.  I don't have a device which reports either
capability, so have merely hacked it for testing.

I'll send all the patches to linux-mm,
but add linux-kernel and a panel of experts in for the last four.

Though most of the testing has been against 2.6.28-rc6 and its
precursors, these patches are diffed to slot in to the mmotm series
after my previous patches, just before "mmend".

 include/linux/swap.h |   14 -
 mm/swapfile.c        |  449 +++++++++++++++++++++++++++++------------
 2 files changed, 330 insertions(+), 133 deletions(-)

The reindentation of sys_swapon() in 4/9 does clash with
memcg-swap-cgroup-for-remembering-usage.patch
Please replace its final hunk by these two hunks
(the second hunk fixes freeing of resources on error):

@@ -1821,6 +1825,11 @@ asmlinkage long sys_swapon(const char __
 		}
 		swap_map[page_nr] = SWAP_MAP_BAD;
 	}
+
+	error = swap_cgroup_swapon(type, maxpages);
+	if (error)
+		goto bad_swap;
+
 	nr_good_pages = swap_header->info.last_page -
 			swap_header->info.nr_badpages -
 			1 /* header page */;
@@ -1893,6 +1902,7 @@ bad_swap:
 		bd_release(bdev);
 	}
 	destroy_swap_extents(p);
+	swap_cgroup_swapoff(type);
 bad_swap_2:
 	spin_lock(&swap_lock);
 	p->swap_file = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
