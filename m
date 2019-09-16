Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EBB5C4CEC7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 05:47:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D297A206C2
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 05:47:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D297A206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FFD06B0005; Mon, 16 Sep 2019 01:47:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 688756B0006; Mon, 16 Sep 2019 01:47:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54FEE6B0007; Mon, 16 Sep 2019 01:47:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0146.hostedemail.com [216.40.44.146])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCDA6B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 01:47:45 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C35341F10
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:47:44 +0000 (UTC)
X-FDA: 75939702048.18.pan28_7d81a262ecc28
X-HE-Tag: pan28_7d81a262ecc28
X-Filterd-Recvd-Size: 3167
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:47:42 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5E2D4337;
	Sun, 15 Sep 2019 22:47:41 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.43.143])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 6DF843F67D;
	Sun, 15 Sep 2019 22:50:08 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	David Hildenbrand <david@redhat.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH] mm/hotplug: Reorder memblock_[free|remove]() calls in try_remove_memory()
Date: Mon, 16 Sep 2019 11:17:37 +0530
Message-Id: <1568612857-10395-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In add_memory_resource() the memory range to be hot added first gets into
the memblock via memblock_add() before arch_add_memory() is called on it.
Reverse sequence should be followed during memory hot removal which already
is being followed in add_memory_resource() error path. This now ensures
required re-order between memblock_[free|remove]() and arch_remove_memory()
during memory hot-remove.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
Original patch https://lkml.org/lkml/2019/9/3/327

Memory hot remove now works on arm64 without this because a recent commit
60bb462fc7ad ("drivers/base/node.c: simplify unregister_memory_block_under_nodes()").

David mentioned that re-ordering should still make sense for consistency
purpose (removing stuff in the reverse order they were added). This patch
is now detached from arm64 hot-remove series.

https://lkml.org/lkml/2019/9/3/326

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


