Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9A7896B005A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 08:23:09 -0500 (EST)
Date: Fri, 4 Jan 2013 08:23:05 -0500
From: Chris Mason <chris.mason@fusionio.com>
Subject: compaction vs data=ordered on ext34
Message-ID: <20130104132305.GG14537@shiny>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Steven Rostedt <srostedt@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, Jan Kara <jack@suse.cz>

Hi everyone,

Steve recently hit very long stalls in firefox, and was able to snag
this sysrq-w

[223349.032831] firefox-bin     D 0000000000000000     0  5798   5797 0x00000004
[223349.033208]  ffff8801abb69798 0000000000000086 ffff8801abb696d8 ffff8801abb69fd8
[223349.033622]  0000000000004000 ffff8801abb69fd8 ffffffff81813420 ffff880209d7e180
[223349.034053]  000000000000003c ffff88023f02cb00 ffff88023f01d080 ffff88023f02cac0
[223349.034472] Call Trace:
[223349.034609]  [<ffffffff8145abbc>] ? cache_flusharray+0x8f/0xb9
[223349.034909]  [<ffffffff81110b56>] ? free_pcppages_bulk+0x406/0x450
[223349.035228]  [<ffffffff81191aa0>] ? __wait_on_buffer+0x30/0x30
[223349.035530]  [<ffffffff8145f41f>] ? io_schedule+0x8f/0xd0
[223349.035812]  [<ffffffff81191aae>] ? sleep_on_buffer+0xe/0x20
[223349.036103]  [<ffffffff8145d72a>] ? __wait_on_bit_lock+0x5a/0xc0
[223349.036432]  [<ffffffff8111201e>] ?  free_hot_cold_page_list+0x5e/0x100
[223349.036769]  [<ffffffff81191aa0>] ? __wait_on_buffer+0x30/0x30
[223349.037073]  [<ffffffff8145d80c>] ?  out_of_line_wait_on_bit_lock+0x7c/0x90
[223349.037427]  [<ffffffff81067300>] ?  autoremove_wake_function+0x40/0x40
[223349.037767]  [<ffffffff81155c5e>] ?  buffer_migrate_lock_buffers+0x7e/0xb0
[223349.038116]  [<ffffffff81156761>] ? buffer_migrate_page+0x61/0x160
[223349.038437]  [<ffffffff81156536>] ? move_to_new_page+0x96/0x260
[223349.038749]  [<ffffffff81156c11>] ? migrate_pages+0x3b1/0x4b0
[223349.039047]  [<ffffffff8112b7b0>] ?  compact_checklock_irqsave.isra.14+0x100/0x100
[223349.039433]  [<ffffffff8112c48f>] ? compact_zone+0x17f/0x430
[223349.039729]  [<ffffffff8135c3eb>] ? __kmalloc_reserve+0x3b/0xa0
[223349.040036]  [<ffffffff8112c9f7>] ? compact_zone_order+0x87/0xd0
[223349.040349]  [<ffffffff8112cb11>] ? try_to_compact_pages+0xd1/0x100
[223349.040674]  [<ffffffff8145a6e3>] ?  __alloc_pages_direct_compact+0xc3/0x1fa
[223349.041034]  [<ffffffff81111468>] ?  __alloc_pages_nodemask+0x7b8/0xa00
[223349.041368]  [<ffffffff8114d003>] ? alloc_pages_vma+0xb3/0x1d0
[223349.041673]  [<ffffffff8115ab28>] ?  do_huge_pmd_anonymous_page+0x138/0x300
[223349.042030]  [<ffffffff814634e8>] ? do_page_fault+0x198/0x510
[223349.042331]  [<ffffffff81125b36>] ? vm_mmap_pgoff+0x96/0xb0
[223349.042640]  [<ffffffff8146095f>] ? page_fault+0x1f/0x30

This shows THP -> compaction -> buffer_migrate_page then waiting for a
buffer to unlock.  He was doing backups on a USB drive at the time,
formatted w/ext3.

Reading the compaction code, it'll jump over pages marked as writeback,
but happily sit on locked buffer heads.  If I'm reading the ext3 code
correctly, it still uses submit_bh directly on data=ordered writes,
without the working on the page bits.

The end result is that compaction stalls on all the data=ordered
writeback.  We shouldn't see this with ext4 because it is using page
based writeback for the data=ordered.  But, should we have a
buffer_migrate_page variant that returns busy for locked buffer heads?

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
