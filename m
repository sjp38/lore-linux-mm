Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBEE6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:59:48 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id l2so4501556wml.5
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:59:48 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k7si1159141wrc.18.2017.01.06.08.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 08:59:47 -0800 (PST)
Date: Fri, 6 Jan 2017 11:59:41 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: 4.10-rc2 list_lru_isolate list corruption
Message-ID: <20170106165941.GA19083@cmpxchg.org>
References: <20170106052056.jihy5denyxsnfuo5@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106052056.jihy5denyxsnfuo5@codemonkey.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org

Dave, can you reproduce this by any chance with this patch applied?

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 6f382e07de77..0783af1c0ebb 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -640,6 +640,8 @@ static inline void radix_tree_shrink(struct radix_tree_root *root,
 				update_node(node, private);
 		}
 
+		WARN_ON_ONCE(!list_empty(&node->private_list));
+
 		radix_tree_node_free(node);
 	}
 }
@@ -666,6 +668,8 @@ static void delete_node(struct radix_tree_root *root,
 			root->rnode = NULL;
 		}
 
+		WARN_ON_ONCE(!list_empty(&node->private_list));
+
 		radix_tree_node_free(node);
 
 		node = parent;
@@ -767,6 +771,7 @@ static void radix_tree_free_nodes(struct radix_tree_node *node)
 			struct radix_tree_node *old = child;
 			offset = child->offset + 1;
 			child = child->parent;
+			WARN_ON_ONCE(!list_empty(&node->private_list));
 			radix_tree_node_free(old);
 			if (old == entry_to_node(node))
 				return;

On Fri, Jan 06, 2017 at 12:20:56AM -0500, Dave Jones wrote:
> While fuzzing today, I triggered list corruption in the mm code twice.
> 
> Exhibit a:
> 
> WARNING: CPU: 1 PID: 53 at lib/list_debug.c:55 __list_del_entry_valid+0x5c/0xc0
> list_del corruption. next->prev should be ffff8804c31b8e60, but was ffffffff813d2dc0
> CPU: 1 PID: 53 Comm: kswapd0 Not tainted 4.10.0-rc2-think+ #2 
> Call Trace:
>  dump_stack+0x4f/0x73
>  __warn+0xcb/0xf0
>  warn_slowpath_fmt+0x5f/0x80
>  ? warn_slowpath_fmt+0x5/0x80
>  ? radix_tree_free_nodes+0xa0/0xa0
>  __list_del_entry_valid+0x5c/0xc0
>  list_lru_isolate+0x1a/0x40
>  shadow_lru_isolate+0x3e/0x220
>  __list_lru_walk_one.isra.4+0x9b/0x190
>  ? memcg_drain_all_list_lrus+0x1d0/0x1d0
>  list_lru_walk_one+0x23/0x30
>  scan_shadow_nodes+0x2e/0x40
>  shrink_slab.part.44+0x23d/0x5d0
>  ? 0xffffffffa0285077
>  shrink_node+0x22c/0x330
>  kswapd+0x392/0x8f0
>  kthread+0x10f/0x150
>  ? mem_cgroup_shrink_node+0x2e0/0x2e0
>  ? kthread_create_on_node+0x60/0x60
>  ret_from_fork+0x22/0x30
> 
> 
> Exhibit b:
> 
> 
> WARNING: CPU: 0 PID: 17728 at lib/list_debug.c:55 __list_del_entry_valid+0x5c/0xc0
> list_del corruption. next->prev should be ffff8804f8972030, but was ffffffff813d2dc0
> CPU: 0 PID: 17728 Comm: trinity-c28 Not tainted 4.10.0-rc2-think+ #2 
> Call Trace:
>  dump_stack+0x4f/0x73
>  __warn+0xcb/0xf0
>  warn_slowpath_fmt+0x5f/0x80
>  ? warn_slowpath_fmt+0x5/0x80
>  ? radix_tree_free_nodes+0xa0/0xa0
>  __list_del_entry_valid+0x5c/0xc0
>  list_lru_isolate+0x1a/0x40
>  shadow_lru_isolate+0x3e/0x220
>  __list_lru_walk_one.isra.4+0x9b/0x190
>  ? memcg_drain_all_list_lrus+0x1d0/0x1d0
>  list_lru_walk_one+0x23/0x30
>  scan_shadow_nodes+0x2e/0x40
>  shrink_slab.part.44+0x23d/0x5d0
>  ? 0xffffffffa0333077
>  shrink_node+0x22c/0x330
>  do_try_to_free_pages+0xf5/0x330
>  try_to_free_pages+0x132/0x310
>  __alloc_pages_slowpath+0x357/0xaa0
>  __alloc_pages_nodemask+0x3cc/0x460
>  __do_page_cache_readahead+0x165/0x370
>  ? __do_page_cache_readahead+0xed/0x370
>  ? __do_page_cache_readahead+0x5/0x370
>  ondemand_readahead+0x112/0x350
>  ? page_cache_sync_readahead+0x5/0x50
>  page_cache_sync_readahead+0x31/0x50
>  generic_file_read_iter+0x724/0x960
>  ? rw_copy_check_uvector+0x8e/0x190
>  ? generic_file_read_iter+0x5/0x960
>  do_iter_readv_writev+0xb8/0x120
>  do_readv_writev+0x1a4/0x250
>  ? do_readv_writev+0x5/0x250
>  ? vfs_readv+0x5/0x50
>  vfs_readv+0x3c/0x50
>  do_preadv+0xb5/0xd0
>  SyS_preadv+0x11/0x20
>  do_syscall_64+0x61/0x170
>  entry_SYSCALL64_slow_path+0x25/0x25
> RIP: 0033:0x7f5cb7c1e119
> RSP: 002b:00007ffc7e7d2758 EFLAGS: 00000246
> [CONT START]  ORIG_RAX: 0000000000000127
> RAX: ffffffffffffffda RBX: 0000000000000127 RCX: 00007f5cb7c1e119
> RDX: 0000000000000037 RSI: 00005561d7798a70 RDI: 000000000000000c
> RBP: 00007f5cb8228000 R08: 00000000a0000033 R09: 0000000000000030
> R10: 0000000000400000 R11: 0000000000000246 R12: 0000000000000002
> R13: 00007f5cb8228048 R14: 00007f5cb82f3ad8 R15: 00007f5cb8228000
> 
> 
> Interesting that the 'but was' value is the same on two seperate boots.
> 
> 
> It looks like mm/list_lru.c didn't change recently, but mm/workingset.c did,
> which calls into this..  Johannes ?
> 
> 	Dave
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
