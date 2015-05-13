Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 178886B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 04:17:57 -0400 (EDT)
Received: by lbbzk7 with SMTP id zk7so23893406lbb.0
        for <linux-mm@kvack.org>; Wed, 13 May 2015 01:17:56 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com. [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id dg6si11888882lac.105.2015.05.13.01.17.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 01:17:55 -0700 (PDT)
Received: by lbbzk7 with SMTP id zk7so23892753lbb.0
        for <linux-mm@kvack.org>; Wed, 13 May 2015 01:17:54 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 13 May 2015 01:17:54 -0700
Message-ID: <CACgMoiK61mKYFpfhhK51uvkvFHK3k+Dz4peMnbeW7-npDu4XBQ@mail.gmail.com>
Subject: mm: BUG_ON with NUMA_BALANCING (kernel BUG at include/linux/swapops.h:131!)
From: Haren Myneni <hmyneni@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: Haren Myneni <hbabu@us.ibm.com>, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com

Hi,

 I am getting BUG_ON in migration_entry_to_page() with 4.1.0-rc2
kernel on powerpc system which has 512 CPUs (64 cores - 16 nodes) and
1.6 TB memory. We can easily recreate this issue with kernel compile
(make -j500). But I could not reproduce with numa_balancing=disable.

------------[ cut here ]------------
kernel BUG at include/linux/swapops.h:134!
cpu 0x154: Vector: 700 (Program Check) at [c00009cf365c7610]
    pc: c00000000021e48c: remove_migration_pte+0x29c/0x450
    lr: c00000000021e47c: remove_migration_pte+0x28c/0x450
    sp: c00009cf365c7890
   msr: 8000000002029033
  current = 0xc00009cf36525fc0
  paca    = 0xc00000000e80fa00   softe: 0        irq_happened: 0x01
    pid   = 244969, comm = cc1
kernel BUG at include/linux/swapops.h:134!
enter ? for help
[c00009cf365c7960] c0000000001f3228 rmap_walk+0x348/0x460
[c00009cf365c7a10] c0000000008d8804 remove_migration_ptes+0x6c/0x84
[c00009cf365c7ab0] c000000000220d2c migrate_pages+0xaac/0xd20
[c00009cf365c7c00] c0000000002218cc migrate_misplaced_page+0x12c/0x210
[c00009cf365c7ca0] c0000000001e613c handle_mm_fault+0xa4c/0x17d0
[c00009cf365c7d70] c0000000008d1098 do_page_fault+0x3a8/0x800
[c00009cf365c7e30] c000000000008664 handle_page_fault+0x10/0x30

I think we are hitting this race issue when the migrate entry page is
not locked.

dump_page() for *old page:

page:f00000035f36a5a0 count:1 mapcount:0 mapping:c00009cf3d351311
index:0x3ffffffe
flags: 0x93ffff800080009(locked|uptodate|swapbacked)

dump_page() for migrate entry page:

page:f00000009f36a5a0 count:0 mapcount:0 mapping:          (null) index:0x0
flags: 0x13ffff800000000()

Any suggestions on how to debug this issue?

Thanks
Haren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
