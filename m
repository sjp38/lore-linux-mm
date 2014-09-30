Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id E17AE6B0039
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 05:26:44 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so2488103pdi.19
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 02:26:44 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id c7si26445513pat.121.2014.09.30.02.26.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 02:26:44 -0700 (PDT)
Received: from kw-mxq.gw.nic.fujitsu.com (unknown [10.0.237.131])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 776FB3EE0AE
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 18:26:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 7C88FAC067C
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 18:26:41 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 25AB8E38001
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 18:26:41 +0900 (JST)
Message-ID: <542A771C.9040605@jp.fujitsu.com>
Date: Tue, 30 Sep 2014 18:25:48 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] driver/firmware/memmap: don't create memmap sysfs of same
 firmware_map_entry
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

By the following commits, we prevented from allocating firmware_map_entry
of same memory range:
  f0093ede: drivers/firmware/memmap.c: don't allocate firmware_map_entry
            of same memory range
  49c8b24d: drivers/firmware/memmap.c: pass the correct argument to
            firmware_map_find_entry_bootmem()

But it's not enough. When PNP0C80 device is added by acpi_scan_init(),
memmap sysfses of same firmware_map_entry are created twice as follows:

  # cat /sys/firmware/memmap/*/start
  0x40000000000
  0x60000000000
  0x4a837000
  0x4a83a000
  0x4a8b5000
  ...
  0x40000000000
  0x60000000000
  ...

The flows of the issues are as follows:

  1. e820_reserve_resources() allocates firmware_map_entrys of all
     memory ranges defined in e820. And, these firmware_map_entrys
     are linked with map_entries list.

     map_entries -> entry 1 -> ... -> entry N

  2. When PNP0C80 device is limited by mem= boot option, acpi_scan_init()
     added the memory device. In this case, firmware_map_add_hotplug()
     allocates firmware_map_entry and creates memmap sysfs.

     map_entries -> entry 1 -> ... -> entry N -> entry N+1
                                                 |
                                                 memmap 1

  3. firmware_memmap_init() creates memmap sysfses of firmware_map_entrys
     linked with map_entries.

     map_entries -> entry 1 -> ... -> entry N -> entry N+1
                     |                 |             |
                     memmap 2          memmap N+1    memmap 1
                                                     memmap N+2

So while hot removing the PNP0C80 device, kernel panic occurs as follows:

     BUG: unable to handle kernel paging request at 00000001003e000b
      IP: sysfs_open_file+0x46/0x2b0
      PGD 203a89fe067 PUD 0
      Oops: 0000 [#1] SMP
      ...
      Call Trace:
        do_dentry_open+0x1ef/0x2a0
        finish_open+0x31/0x40
        do_last+0x57c/0x1220
        path_openat+0xc2/0x4c0
        do_filp_open+0x4b/0xb0
        do_sys_open+0xf3/0x1f0
        SyS_open+0x1e/0x20
        system_call_fastpath+0x16/0x1b

The patch adds a check of confirming whether memmap sysfs of
firmware_map_entry has been created, and does not create memmap
sysfs of same firmware_map_entry.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 drivers/firmware/memmap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 79f18e6..cc016c6 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -184,6 +184,9 @@ static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry)
 	static int map_entries_nr;
 	static struct kset *mmap_kset;

+	if (entry->kobj.state_in_sysfs)
+		return -EEXIST;
+
 	if (!mmap_kset) {
 		mmap_kset = kset_create_and_add("memmap", NULL, firmware_kobj);
 		if (!mmap_kset)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
