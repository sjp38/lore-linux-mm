Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0750FC3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 09:46:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD899230F2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 09:46:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD899230F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C1BE6B0005; Tue,  3 Sep 2019 05:46:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54CA86B0006; Tue,  3 Sep 2019 05:46:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4392D6B0008; Tue,  3 Sep 2019 05:46:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0141.hostedemail.com [216.40.44.141])
	by kanga.kvack.org (Postfix) with ESMTP id 23B386B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 05:46:11 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A35C8824CA3A
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 09:46:10 +0000 (UTC)
X-FDA: 75893128500.28.head34_8d233525ccd62
X-HE-Tag: head34_8d233525ccd62
X-Filterd-Recvd-Size: 6289
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 09:46:09 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 931B91570;
	Tue,  3 Sep 2019 02:46:08 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.42.170])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id B19A73F59C;
	Tue,  3 Sep 2019 02:46:01 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	catalin.marinas@arm.com,
	will@kernel.org
Cc: mark.rutland@arm.com,
	mhocko@suse.com,
	ira.weiny@intel.com,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	mgorman@techsingularity.net,
	osalvador@suse.de,
	ard.biesheuvel@arm.com,
	steve.capper@arm.com,
	broonie@kernel.org,
	valentin.schneider@arm.com,
	Robin.Murphy@arm.com,
	steven.price@arm.com,
	suzuki.poulose@arm.com
Subject: [PATCH V7 1/3] mm/hotplug: Reorder memblock_[free|remove]() calls in try_remove_memory()
Date: Tue,  3 Sep 2019 15:15:56 +0530
Message-Id: <1567503958-25831-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
entries between memory block and node. It first checks pfn validity with
pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
(arm64 has this enabled) pfn_valid_within() calls pfn_valid().

pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
which scans all mapped memblock regions with memblock_is_map_memory(). This
creates a problem in memory hot remove path which has already removed given
memory range from memory block with memblock_[remove|free] before arriving
at unregister_mem_sect_under_nodes(). Hence get_nid_for_pfn() returns -1
skipping subsequent sysfs_remove_link() calls leaving node <-> memory block
sysfs entries as is. Subsequent memory add operation hits BUG_ON() because
of existing sysfs entries.

[   62.007176] NUMA: Unknown node for memory at 0x680000000, assuming node 0
[   62.052517] ------------[ cut here ]------------
[   62.053211] kernel BUG at mm/memory_hotplug.c:1143!
[   62.053868] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[   62.054589] Modules linked in:
[   62.054999] CPU: 19 PID: 3275 Comm: bash Not tainted 5.1.0-rc2-00004-g28cea40b2683 #41
[   62.056274] Hardware name: linux,dummy-virt (DT)
[   62.057166] pstate: 40400005 (nZcv daif +PAN -UAO)
[   62.058083] pc : add_memory_resource+0x1cc/0x1d8
[   62.058961] lr : add_memory_resource+0x10c/0x1d8
[   62.059842] sp : ffff0000168b3ce0
[   62.060477] x29: ffff0000168b3ce0 x28: ffff8005db546c00
[   62.061501] x27: 0000000000000000 x26: 0000000000000000
[   62.062509] x25: ffff0000111ef000 x24: ffff0000111ef5d0
[   62.063520] x23: 0000000000000000 x22: 00000006bfffffff
[   62.064540] x21: 00000000ffffffef x20: 00000000006c0000
[   62.065558] x19: 0000000000680000 x18: 0000000000000024
[   62.066566] x17: 0000000000000000 x16: 0000000000000000
[   62.067579] x15: ffffffffffffffff x14: ffff8005e412e890
[   62.068588] x13: ffff8005d6b105d8 x12: 0000000000000000
[   62.069610] x11: ffff8005d6b10490 x10: 0000000000000040
[   62.070615] x9 : ffff8005e412e898 x8 : ffff8005e412e890
[   62.071631] x7 : ffff8005d6b105d8 x6 : ffff8005db546c00
[   62.072640] x5 : 0000000000000001 x4 : 0000000000000002
[   62.073654] x3 : ffff8005d7049480 x2 : 0000000000000002
[   62.074666] x1 : 0000000000000003 x0 : 00000000ffffffef
[   62.075685] Process bash (pid: 3275, stack limit = 0x00000000d754280f)
[   62.076930] Call trace:
[   62.077411]  add_memory_resource+0x1cc/0x1d8
[   62.078227]  __add_memory+0x70/0xa8
[   62.078901]  probe_store+0xa4/0xc8
[   62.079561]  dev_attr_store+0x18/0x28
[   62.080270]  sysfs_kf_write+0x40/0x58
[   62.080992]  kernfs_fop_write+0xcc/0x1d8
[   62.081744]  __vfs_write+0x18/0x40
[   62.082400]  vfs_write+0xa4/0x1b0
[   62.083037]  ksys_write+0x5c/0xc0
[   62.083681]  __arm64_sys_write+0x18/0x20
[   62.084432]  el0_svc_handler+0x88/0x100
[   62.085177]  el0_svc+0x8/0xc

Re-ordering memblock_[free|remove]() with arch_remove_memory() solves the
problem on arm64 as pfn_valid() behaves correctly and returns positive
as memblock for the address range still exists. arch_remove_memory()
removes applicable memory sections from zone with __remove_pages() and
tears down kernel linear mapping. Removing memblock regions afterwards
is safe because there is no other memblock (bootmem) allocator user that
late. So nobody is going to allocate from the removed range just to blow
up later. Also nobody should be using the bootmem allocated range else
we wouldn't allow to remove it. So reordering is indeed safe.

Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Mark Rutland <mark.rutland@arm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 mm/memory_hotplug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c73f09913165..355c466e0621 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1770,13 +1770,13 @@ static int __ref try_remove_memory(int nid, u64 start, u64 size)
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
-	memblock_free(start, size);
-	memblock_remove(start, size);
 
 	/* remove memory block devices before removing memory */
 	remove_memory_block_devices(start, size);
 
 	arch_remove_memory(nid, start, size, NULL);
+	memblock_free(start, size);
+	memblock_remove(start, size);
 	__release_memory_resource(start, size);
 
 	try_offline_node(nid);
-- 
2.20.1


