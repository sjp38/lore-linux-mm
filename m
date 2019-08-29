Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3426C3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:01:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A42852342E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:01:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A42852342E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55FA56B0276; Thu, 29 Aug 2019 03:01:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E9E26B0277; Thu, 29 Aug 2019 03:01:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 386FF6B0278; Thu, 29 Aug 2019 03:01:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3E06B0276
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:01:06 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A87776D91
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:01:05 +0000 (UTC)
X-FDA: 75874568490.11.wool70_97e5d4810530
X-HE-Tag: wool70_97e5d4810530
X-Filterd-Recvd-Size: 9816
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:01:05 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2B784308FB82;
	Thu, 29 Aug 2019 07:01:04 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-166.ams2.redhat.com [10.36.117.166])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 089C61001B05;
	Thu, 29 Aug 2019 07:00:58 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.com>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Logan Gunthorpe <logang@deltatee.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH v3 09/11] mm/memory_hotplug: Remove pages from a zone before removing memory
Date: Thu, 29 Aug 2019 09:00:17 +0200
Message-Id: <20190829070019.12714-10-david@redhat.com>
In-Reply-To: <20190829070019.12714-1-david@redhat.com>
References: <20190829070019.12714-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 29 Aug 2019 07:01:04 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Remove memory from the zone when offlining and when onlining
failed (we only have a single zone) in case of !ZONE_DEVICE memory. Do
the same with ZONE_DEVICE memory before removing memory. Introduce
remove_pfn_range_from_zone().

This fixes a whole bunch of BUGs we have in our code right now when
removing memory whereby
- Single memory blocks that fall into no zone (never onlined)
- Single memory blocks that fall into multiple zones (offlined+re-onlined=
)
- Multiple memory blocks that fall into different zones
Right now, the zones don't get updated properly in these cases. And we
can trigger kernel bugs when removing memory that was never onlined:

:/# [   23.912993] BUG: unable to handle page fault for address: 00000000=
0000353d
[   23.914219] #PF: supervisor write access in kernel mode
[   23.915199] #PF: error_code(0x0002) - not-present page
[   23.916160] PGD 0 P4D 0
[   23.916627] Oops: 0002 [#1] SMP PTI
[   23.917256] CPU: 1 PID: 7 Comm: kworker/u8:0 Not tainted 5.3.0-rc5-nex=
t-20190820+ #317
[   23.918900] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S rel-1.12.1-0-ga5cab58e9a3f-prebuilt.qemu.4
[   23.921194] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
[   23.922249] RIP: 0010:clear_zone_contiguous+0x5/0x10
[   23.923173] Code: 48 89 c6 48 89 c3 e8 2a fe ff ff 48 85 c0 75 cf 5b 5=
d c3 c6 85 fd 05 00 00 01 5b 5d c3 0f 1f 840
[   23.926876] RSP: 0018:ffffad2400043c98 EFLAGS: 00010246
[   23.927928] RAX: 0000000000000000 RBX: 0000000200000000 RCX: 000000000=
0000000
[   23.929458] RDX: 0000000000200000 RSI: 0000000000140000 RDI: 000000000=
0002f40
[   23.930899] RBP: 0000000140000000 R08: 0000000000000000 R09: 000000000=
0000001
[   23.932362] R10: 0000000000000000 R11: 0000000000000000 R12: 000000000=
0140000
[   23.933603] R13: 0000000000140000 R14: 0000000000002f40 R15: ffff9e3e7=
aff3680
[   23.934913] FS:  0000000000000000(0000) GS:ffff9e3e7bb00000(0000) knlG=
S:0000000000000000
[   23.936294] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   23.937481] CR2: 000000000000353d CR3: 0000000058610000 CR4: 000000000=
00006e0
[   23.938687] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
[   23.939889] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 000000000=
0000400
[   23.941168] Call Trace:
[   23.941580]  __remove_pages+0x4b/0x640
[   23.942303]  ? mark_held_locks+0x49/0x70
[   23.943149]  arch_remove_memory+0x63/0x8d
[   23.943921]  try_remove_memory+0xdb/0x130
[   23.944766]  ? walk_memory_blocks+0x7f/0x9e
[   23.945616]  __remove_memory+0xa/0x11
[   23.946274]  acpi_memory_device_remove+0x70/0x100
[   23.947308]  acpi_bus_trim+0x55/0x90
[   23.947914]  acpi_device_hotplug+0x227/0x3a0
[   23.948714]  acpi_hotplug_work_fn+0x1a/0x30
[   23.949433]  process_one_work+0x221/0x550
[   23.950190]  worker_thread+0x50/0x3b0
[   23.950993]  kthread+0x105/0x140
[   23.951644]  ? process_one_work+0x550/0x550
[   23.952508]  ? kthread_park+0x80/0x80
[   23.953367]  ret_from_fork+0x3a/0x50
[   23.954025] Modules linked in:
[   23.954613] CR2: 000000000000353d
[   23.955248] ---[ end trace 93d982b1fb3e1a69 ]---

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h |  3 +++
 mm/memory_hotplug.c            | 16 +++++++++-------
 mm/memremap.c                  |  7 ++++---
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
index 235530cdface..f27559f11b64 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -345,6 +345,9 @@ extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long star=
t_pfn,
 		unsigned long nr_pages, struct dev_pagemap *pgmap);
+extern void remove_pfn_range_from_zone(struct zone *zone,
+				       unsigned long start_pfn,
+				       unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int sparse_add_section(int nid, unsigned long pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 56eabd22cbae..75859a57ecda 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -484,16 +484,21 @@ static void update_pgdat_span(struct pglist_data *p=
gdat)
 	pgdat->node_spanned_pages =3D node_end_pfn - node_start_pfn;
 }
=20
-static void __remove_zone(struct zone *zone, unsigned long start_pfn,
-		unsigned long nr_pages)
+void __ref remove_pfn_range_from_zone(struct zone *zone,
+				      unsigned long start_pfn,
+				      unsigned long nr_pages)
 {
 	struct pglist_data *pgdat =3D zone->zone_pgdat;
 	unsigned long flags;
=20
+	clear_zone_contiguous(zone);
+
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
 	update_pgdat_span(pgdat);
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+
+	set_zone_contiguous(zone);
 }
=20
 static void __remove_section(struct zone *zone, unsigned long pfn,
@@ -505,7 +510,6 @@ static void __remove_section(struct zone *zone, unsig=
ned long pfn,
 	if (WARN_ON_ONCE(!valid_section(ms)))
 		return;
=20
-	__remove_zone(zone, pfn, nr_pages);
 	sparse_remove_section(ms, pfn, nr_pages, map_offset, altmap);
 }
=20
@@ -532,8 +536,6 @@ void __remove_pages(struct zone *zone, unsigned long =
pfn,
=20
 	map_offset =3D vmem_altmap_offset(altmap);
=20
-	clear_zone_contiguous(zone);
-
 	start_sec =3D pfn_to_section_nr(pfn);
 	end_sec =3D pfn_to_section_nr(pfn + nr_pages - 1);
 	for (nr =3D start_sec; nr <=3D end_sec; nr++) {
@@ -547,8 +549,6 @@ void __remove_pages(struct zone *zone, unsigned long =
pfn,
 		nr_pages -=3D pfns;
 		map_offset =3D 0;
 	}
-
-	set_zone_contiguous(zone);
 }
=20
 int set_online_page_callback(online_page_callback_t callback)
@@ -875,6 +875,7 @@ int __ref online_pages(unsigned long pfn, unsigned lo=
ng nr_pages, int online_typ
 	pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
 		 (unsigned long long) pfn << PAGE_SHIFT,
 		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
+	remove_pfn_range_from_zone(zone, pfn, nr_pages);
 	memory_notify(MEM_CANCEL_ONLINE, &arg);
 	mem_hotplug_done();
 	return ret;
@@ -1586,6 +1587,7 @@ static int __ref __offline_pages(unsigned long star=
t_pfn,
 	spin_unlock_irqrestore(&zone->lock, flags);
=20
 	/* removal success */
+	remove_pfn_range_from_zone(zone, start_pfn, nr_pages);
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -=3D offlined_pages;
=20
diff --git a/mm/memremap.c b/mm/memremap.c
index 9ee23374e6da..7c662643a0aa 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -125,7 +125,7 @@ static void dev_pagemap_cleanup(struct dev_pagemap *p=
gmap)
 void memunmap_pages(struct dev_pagemap *pgmap)
 {
 	struct resource *res =3D &pgmap->res;
-	unsigned long pfn;
+	unsigned long pfn =3D PHYS_PFN(res->start);
 	int nid;
=20
 	dev_pagemap_kill(pgmap);
@@ -134,11 +134,12 @@ void memunmap_pages(struct dev_pagemap *pgmap)
 	dev_pagemap_cleanup(pgmap);
=20
 	/* pages are dead and unused, undo the arch mapping */
-	nid =3D page_to_nid(pfn_to_page(PHYS_PFN(res->start)));
+	nid =3D page_to_nid(pfn_to_page(pfn));
=20
 	mem_hotplug_begin();
+	remove_pfn_range_from_zone(page_zone(pfn_to_page(pfn)), pfn,
+				   PHYS_PFN(resource_size(res)));
 	if (pgmap->type =3D=3D MEMORY_DEVICE_PRIVATE) {
-		pfn =3D PHYS_PFN(res->start);
 		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
 				 PHYS_PFN(resource_size(res)), NULL);
 	} else {
--=20
2.21.0


