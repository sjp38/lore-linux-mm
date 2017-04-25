Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE93F6B0317
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:27:59 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p80so240183350iop.16
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 07:27:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c131si24862808ioe.115.2017.04.25.07.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 07:27:58 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PEOVti053601
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:27:57 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a22ce9gt5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:27:57 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 15:27:55 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2 0/2] BUG raised when onlining HWPoisoned page
Date: Tue, 25 Apr 2017 16:27:50 +0200
Message-Id: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

When a page is HWPoisoned and later offlined and onlined back, a BUG
warning is raised in the kernel:

BUG: Bad page state in process mem-on-off-test  pfn:7ae3b
page:f000000001eb8ec0 count:0 mapcount:0 mapping:          (null)
index:0x1
flags: 0x3ffff800200000(hwpoison)
raw: 003ffff800200000 0000000000000000 0000000000000001
00000000ffffffff
raw: 5deadbeef0000100 5deadbeef0000200 0000000000000000
c0000007fe055800
page dumped because: page still charged to cgroup
page->mem_cgroup:c0000007fe055800
Modules linked in: pseries_rng rng_core vmx_crypto virtio_balloon
ip_tables x_tables autofs4 virtio_blk virtio_net virtio_pci
virtio_ring virtio
CPU: 34 PID: 5946 Comm: mem-on-off-test Tainted: G    B 4.11.0-rc7-hwp
#1
Call Trace:
[c0000007e4a737f0] [c000000000958e8c] dump_stack+0xb0/0xf0
(unreliable)
[c0000007e4a73830] [c00000000021588c] bad_page+0x11c/0x190
[c0000007e4a738c0] [c00000000021757c] free_pcppages_bulk+0x46c/0x600
[c0000007e4a73990] [c00000000021924c] free_hot_cold_page+0x2ec/0x320
[c0000007e4a739e0] [c0000000002a6440] generic_online_page+0x50/0x70
[c0000007e4a73a10] [c0000000002a6184] online_pages_range+0x94/0xe0
[c0000007e4a73a70] [c00000000005a2b0] walk_system_ram_range+0xe0/0x120
[c0000007e4a73ac0] [c0000000002cce44] online_pages+0x2b4/0x6b0
[c0000007e4a73b60] [c000000000600558] memory_subsys_online+0x218/0x270
[c0000007e4a73bf0] [c0000000005dec84] device_online+0xb4/0x110
[c0000007e4a73c30] [c000000000600f00] store_mem_state+0xc0/0x190
[c0000007e4a73c70] [c0000000005da1d4] dev_attr_store+0x34/0x60
[c0000007e4a73c90] [c000000000377c70] sysfs_kf_write+0x60/0xa0
[c0000007e4a73cb0] [c0000000003769fc] kernfs_fop_write+0x16c/0x240
[c0000007e4a73d00] [c0000000002d1b0c] __vfs_write+0x3c/0x1b0
[c0000007e4a73d90] [c0000000002d34dc] vfs_write+0xcc/0x230
[c0000007e4a73de0] [c0000000002d50e0] SyS_write+0x60/0x110
[c0000007e4a73e30] [c00000000000b760] system_call+0x38/0xfc

This has been seen on x86 kvm guest, PowerPC bare metal system and KVM
guest.

The issue is that the onlined page has already the mem_cgroup field
set.

It seems that the mem_cgroup field should be cleared when the page is
poisoned, which is done in the first patch of this series.

Then when the page is onlined back, the BUG warning is no more
triggered, but the page is now available for use, and once a process
is using it, it got killed because of the memory error.
It seems that the page should be ignored when onlined, as it is when
it is offlined (introduced by commit b023f46813cd "memory-hotplug:
skip HWPoisoned page when offlining pages"). The second patch of this
series is skipping HWPoisoned page when the memory block is onlined
back.

Changes against V1:
 - The first patch commit's description mentioned the BUG explicitly
 - In the patch as requested by Naoya Horiguchi, clear the page's
   reserved flag when the skipping the poisoned page.

Laurent Dufour (2):
  mm: Uncharge poisoned pages
  mm: skip HWPoisoned pages when onlining pages

 mm/memory-failure.c | 3 +++
 mm/memory_hotplug.c | 4 ++++
 2 files changed, 7 insertions(+)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
