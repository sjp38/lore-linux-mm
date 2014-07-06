Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5986B0038
	for <linux-mm@kvack.org>; Sun,  6 Jul 2014 15:31:33 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so4201123pdj.33
        for <linux-mm@kvack.org>; Sun, 06 Jul 2014 12:31:33 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id df8si4049345pdb.455.2014.07.06.12.31.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 06 Jul 2014 12:31:32 -0700 (PDT)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B87D83EE0BB
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 04:31:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.nic.fujitsu.com [10.0.50.94])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id C37BEAC0583
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 04:31:29 +0900 (JST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 676B41DB8037
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 04:31:29 +0900 (JST)
Message-ID: <53B9A3FE.6040105@jp.fujitsu.com>
Date: Mon, 7 Jul 2014 04:31:10 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] don't allocate firmware_map_entry of same memory range
References: <53B9A38F.9000609@jp.fujitsu.com>
In-Reply-To: <53B9A38F.9000609@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, santosh.shilimkar@ti.com, toshi.kani@hp.com

When limiting memory by mem= and ACPI DSDT table has PNP0C80,
firmware_map_entrys of same memory range are allocated and
memmap X sysfses which have same memory range are created as
follows:

 # cat /sys/firmware/memmap/0/*
 0x407ffffffff
 0x40000000000
 System RAM
 # cat /sys/firmware/memmap/33/*
 0x407ffffffff
 0x40000000000
 System RAM
 # cat /sys/firmware/memmap/35/*
 0x407ffffffff
 0x40000000000
 System RAM

In this case, when hot-removing memory, kernel panic occurs, showing
following call trace:

 BUG: unable to handle kernel paging request at 00000001003e000b
 IP: [<ffffffff81225c26>] sysfs_open_file+0x46/0x2b0
 PGD 203a89fe067 PUD 0
 Oops: 0000 [#1] SMP
 ...
 Call Trace:
  [<ffffffff811ad95f>] do_dentry_open+0x1ef/0x2a0
  [<ffffffff811bba32>] ? __inode_permission+0x52/0xc0
  [<ffffffff81225be0>] ? sysfs_schedule_callback+0x1c0/0x1c0
  [<ffffffff811ada41>] finish_open+0x31/0x40
  [<ffffffff811bf6ac>] do_last+0x57c/0x1220
  [<ffffffff8119529e>] ? kmem_cache_alloc_trace+0x1ce/0x1f0
  [<ffffffff811c0412>] path_openat+0xc2/0x4c0
  [<ffffffff81167e2c>] ? tlb_flush_mmu.part.53+0x4c/0x90
  [<ffffffff811c102b>] do_filp_open+0x4b/0xb0
  [<ffffffff811cd827>] ? __alloc_fd+0xa7/0x130
  [<ffffffff811aeed3>] do_sys_open+0xf3/0x1f0
  [<ffffffff811aefee>] SyS_open+0x1e/0x20
  [<ffffffff815f2199>] system_call_fastpath+0x16/0x1b

The problem occurs as follows:

When calling e820_reserve_resources(), firmware_map_entrys of all
e820 memory map are allocated. And all firmware_map_entrys is added
map_entries list as follows:

map_entries
 -> +--- entry A --------+ -> ...
    | start 0x407ffffffff|
    | end   0x40000000000|
    | type  System RAM   |
    +--------------------+

After that, if ACPI DSDT table has PNP0C80 and the memory range is
limited by mem=, the PNP0C80 is hot-added. Then firmware_map_entry of
PNP0C80 is allocated and added map_entries list as follows:

map_entries
 -> +--- entry A --------+ -> ... -> +--- entry B --------+
    | start 0x407ffffffff|           | start 0x407ffffffff|
    | end   0x40000000000|           | end   0x40000000000|
    | type  System RAM   |           | type  System RAM   |
    +--------------------+           +--------------------+

Then memmap 0 sysfs for entry B is created.

After that, firmware_memmap_init() creates memmap sysfses of all
firmware_map_entrys in map_entries list. As a result, memmap 33
sysfs for entry A and memmap 35 sysfs for entry B are created.
But kobject of entry B has been used by memmap 0 sysfs. So
when creating memmap 35 sysfs, the kobject is broken.

If hot-removing memory, memmap 0 sysfs is destroyed and kobject of
memmap 0 sysfs is freed. But the kobject can be accessed via
memmap 35 sysfs. So when open memmap 35 sysfs, kernel panic occurs.

This patch checks whether there is firmware_map_entry of same memory
range in map_entries list and don't allocate firmware_map_entry of
same memroy range.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 drivers/firmware/memmap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 1815849..79f18e6 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -286,6 +286,10 @@ int __meminit firmware_map_add_hotplug(u64 start, u64 end, const char *type)
 {
 	struct firmware_map_entry *entry;

+	entry = firmware_map_find_entry(start, end - 1, type);
+	if (entry)
+		return 0;
+
 	entry = firmware_map_find_entry_bootmem(start, end - 1, type);
 	if (!entry) {
 		entry = kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
