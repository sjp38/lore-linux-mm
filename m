Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 990C16B00AE
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 20:20:55 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p071KboO003701
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 17:20:37 -0800
Received: from iwn38 (iwn38.prod.google.com [10.241.68.102])
	by kpbe19.cbf.corp.google.com with ESMTP id p071KXYW006342
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 17:20:36 -0800
Received: by iwn38 with SMTP id 38so17159202iwn.8
        for <linux-mm@kvack.org>; Thu, 06 Jan 2011 17:20:33 -0800 (PST)
Date: Thu, 6 Jan 2011 17:20:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: mmotm hangs on compaction lock_page
Message-ID: <alpine.LSU.2.00.1101061632020.9601@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mel,

Here are the traces of two concurrent "cp -a kerneltree elsewhere"s
which have hung on mmotm: in limited RAM, on a PowerPC - I don't have
an explanation for why I can reproduce it in minutes on that box but
never yet on the x86s.

Perhaps we can get it to happen with just one cp: the second cp here
seemed to be deadlocking itself, unmap_and_move()'s force lock_page
waiting on a page which its page cache readahead already holds locked.

cp              D 000000000fea3110     0 18874  18873 0x00008010
Call Trace:
 .__switch_to+0xcc/0x110
 .schedule+0x670/0x7b0
 .io_schedule+0x50/0x8c
 .sync_page+0x84/0xa0
 .sync_page_killable+0x10/0x48
 .__wait_on_bit_lock+0x9c/0x140
 .__lock_page_killable+0x74/0x98
 .do_generic_file_read+0x2b0/0x504
 .generic_file_aio_read+0x214/0x29c
 .do_sync_read+0xac/0x10c
 .vfs_read+0xd0/0x1a0
 .SyS_read+0x58/0xa0
 syscall_exit+0x0/0x40
 syscall_exit+0x0/0x40

cp              D 000000000fea3110     0 18876  18875 0x00008010
Call Trace:
 0xc000000001343b68 (unreliable)
 .__switch_to+0xcc/0x110
 .schedule+0x670/0x7b0
 .io_schedule+0x50/0x8c
 .sync_page+0x84/0xa0
 .__wait_on_bit_lock+0x9c/0x140
 .__lock_page+0x74/0x98
 .unmap_and_move+0xfc/0x380
 .migrate_pages+0xbc/0x18c
 .compact_zone+0xbc/0x400
 .compact_zone_order+0xc8/0xf4
 .try_to_compact_pages+0x104/0x1b8
 .__alloc_pages_direct_compact+0xa8/0x228
 .__alloc_pages_nodemask+0x42c/0x730
 .allocate_slab+0x84/0x168
 .new_slab+0x58/0x198
 .__slab_alloc+0x1ec/0x430
 .kmem_cache_alloc+0x7c/0xe0
 .radix_tree_preload+0x94/0x140
 .add_to_page_cache_locked+0x70/0x1f0
 .add_to_page_cache_lru+0x50/0xac
 .mpage_readpages+0xcc/0x198
 .ext3_readpages+0x28/0x40
 .__do_page_cache_readahead+0x1ac/0x2ac
 .ra_submit+0x28/0x38
 .do_generic_file_read+0xe8/0x504
 .generic_file_aio_read+0x214/0x29c
 .do_sync_read+0xac/0x10c
 .vfs_read+0xd0/0x1a0
 .SyS_read+0x58/0xa0
 syscall_exit+0x0/0x40

I haven't made a patch for it, just hacked unmap_and_move() to say
"if (!0)" instead of "if (!force)" to get on with my testing.  I expect
you'll want to pass another arg down to migrate_pages() to prevent
setting force, or give it some flags, or do something with PF_MEMALLOC.

Over to you - thanks!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
