Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DJYjYg030832
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 15:34:45 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DJYjqi563994
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 15:34:45 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DJYi36001047
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 15:34:45 -0400
Subject: 2.6.23-rc4-mm1 memory controller BUG_ON()
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 12:34:43 -0700
Message-Id: <1189712083.17236.1626.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@in.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Looks like somebody is holding a lock while trying to do a
mem_container_charge(), and the mem_container_charge() call is doing an
allocation.  Naughty.

I'm digging into it a bit more, but thought I'd report it, first.

.config: http://sr71.net/~dave/linux/memory-controller-bug.config

BUG: sleeping function called from invalid context at /home/dave/work/linux/2.6/23/rc4/mm1/lxc/mm/slab.c:3052
in_atomic():1, irqs_disabled():0
 [<c01029c1>] show_trace_log_lvl+0x19/0x2e
 [<c01029e8>] show_trace+0x12/0x14
 [<c0102ad3>] dump_stack+0x13/0x15
 [<c010f223>] __might_sleep+0xe4/0xea
 [<c014cdc0>] kmem_cache_alloc+0x25/0xae
 [<c014e1dd>] mem_container_charge+0xc9/0x2cd
 [<c014e403>] mem_container_cache_charge+0x22/0x28
 [<c0131839>] add_to_page_cache+0x35/0xd7
 [<c01318f0>] add_to_page_cache_lru+0x15/0x29
 [<c0131c43>] find_or_create_page+0x75/0x93
 [<c016cc71>] grow_dev_page+0x32/0x125
 [<c016ce15>] grow_buffers+0xb1/0xd4
 [<c016ceef>] __getblk_slow+0xb7/0xcf
 [<c016d2b9>] __getblk+0x44/0x4f
 [<c018c721>] ext3_getblk+0xca/0x19c
 [<c018fc48>] ext3_find_entry+0x127/0x325
 [<c0190063>] ext3_lookup+0x2c/0xe1
 [<c015635a>] real_lookup+0x54/0xc5
 [<c01565bd>] do_lookup+0x59/0xa0
 [<c0156824>] __link_path_walk+0x220/0xa4f
 [<c0157094>] link_path_walk+0x41/0xa5
 [<c0157110>] path_walk+0x18/0x1a
 [<c01573de>] do_path_lookup+0x165/0x182
 [<c01574a0>] __path_lookup_intent_open+0x44/0x75
 [<c01574f2>] path_lookup_open+0x21/0x27
 [<c0157c5a>] open_namei+0x7f/0x4c4
 [<c014f6c0>] do_filp_open+0x26/0x3b
 [<c014f975>] do_sys_open+0x43/0xc7
 [<c014fa13>] sys_open+0x1a/0x1c
 [<c010010e>] init_post+0x45/0xe7
 [<c03f6ab6>] kernel_init+0x8a/0x8e
 [<c010287b>] kernel_thread_helper+0x7/0x10
 =======================


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
