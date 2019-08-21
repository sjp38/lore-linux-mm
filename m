Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15E2DC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D869B22DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D869B22DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47DAD6B02F4; Wed, 21 Aug 2019 11:40:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 391086B02F5; Wed, 21 Aug 2019 11:40:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25AC06B02F6; Wed, 21 Aug 2019 11:40:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0068.hostedemail.com [216.40.44.68])
	by kanga.kvack.org (Postfix) with ESMTP id E73716B02F4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:40:28 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8FF43180AD801
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:28 +0000 (UTC)
X-FDA: 75846846936.25.loss84_41304a21b601
X-HE-Tag: loss84_41304a21b601
X-Filterd-Recvd-Size: 8830
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:27 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2210F18C8919;
	Wed, 21 Aug 2019 15:40:27 +0000 (UTC)
Received: from t460s.redhat.com (unknown [10.36.118.29])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 498FF5B807;
	Wed, 21 Aug 2019 15:40:25 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH v1 3/5] mm/memory_hotplug: Process all zones when removing memory
Date: Wed, 21 Aug 2019 17:40:04 +0200
Message-Id: <20190821154006.1338-4-david@redhat.com>
In-Reply-To: <20190821154006.1338-1-david@redhat.com>
References: <20190821154006.1338-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.70]); Wed, 21 Aug 2019 15:40:27 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is easier than I though to trigger a kernel bug by removing memory tha=
t
was never onlined. With CONFIG_DEBUG_VM the memmap is initialized with
garbage, resulting in the detection of a broken zone when removing memory=
.
Without CONFIG_DEBUG_VM it is less likely - but we could still have
garbage in the memmap.

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

But the problem is more extreme: When removing memory we could have
- Single memory blocks that fall into no zone (never onlined)
- Single memory blocks that fall into multiple zones (offlined+re-onlined=
)
- Multiple memory blocks that fall into different zones
Right now, the zones don't get updated properly in these cases.

So let's simply process all zones for now until we can properly handle
this via the reverse of move_pfn_range_to_zone() (which would then be
called something like remove_pfn_range_from_zone()), for example, when
offlining memory or before removing ZONE_DEVICE memory.

To speed things up, only mark applicable zones non-contiguous (and
therefore reduce the zones to recompute) and skip non-intersecting zones
when trying to resize. shrink_zone_span() and shrink_pgdat_span() seem
to be able to cope just fine with pfn ranges they don't actually
contain (but still intersect with).

Don't check for zone_intersects() when triggering set_zone_contiguous()
- we might have resized the zone and the check might no longer hold. For
now, we have to try to recompute any zone (which will be skipped in case
the zone is already contiguous).

Note1: Detecting which memory is still part of a zone is not easy before
removing memory as the detection relies almost completely on pfn_valid()
right now. pfn_online() cannot be used as ZONE_DEVICE memory is never
online. pfn_present() cannot be used as all memory is present once it was
added (but not onlined). We need to rethink/refactor this properly.

Note2: We are safe to call zone_intersects() without locking (as already
done by onlining code in default_zone_for_pfn()), as we are protected by
the memory hotplug lock - just like zone->contiguous.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 71779b7b14df..27f0457b7512 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -505,22 +505,28 @@ static void __remove_zone(struct zone *zone, unsign=
ed long start_pfn,
 	struct pglist_data *pgdat =3D zone->zone_pgdat;
 	unsigned long flags;
=20
+	if (!zone_intersects(zone, start_pfn, nr_pages))
+		return;
+
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
 	shrink_pgdat_span(pgdat, start_pfn, start_pfn + nr_pages);
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 }
=20
-static void __remove_section(struct zone *zone, unsigned long pfn,
-		unsigned long nr_pages, unsigned long map_offset,
-		struct vmem_altmap *altmap)
+static void __remove_section(unsigned long pfn, unsigned long nr_pages,
+			     unsigned long map_offset,
+			     struct vmem_altmap *altmap)
 {
 	struct mem_section *ms =3D __nr_to_section(pfn_to_section_nr(pfn));
+	struct zone *zone;
=20
 	if (WARN_ON_ONCE(!valid_section(ms)))
 		return;
=20
-	__remove_zone(zone, pfn, nr_pages);
+	/* TODO: move zone handling out of memory removal path */
+	for_each_zone(zone)
+		__remove_zone(zone, pfn, nr_pages);
 	sparse_remove_section(ms, pfn, nr_pages, map_offset, altmap);
 }
=20
@@ -547,7 +553,10 @@ void __remove_pages(struct zone *zone, unsigned long=
 pfn,
=20
 	map_offset =3D vmem_altmap_offset(altmap);
=20
-	clear_zone_contiguous(zone);
+	/* TODO: move zone handling out of memory removal path */
+	for_each_zone(zone)
+		if (zone_intersects(zone, pfn, nr_pages))
+			clear_zone_contiguous(zone);
=20
 	start_sec =3D pfn_to_section_nr(pfn);
 	end_sec =3D pfn_to_section_nr(pfn + nr_pages - 1);
@@ -557,13 +566,15 @@ void __remove_pages(struct zone *zone, unsigned lon=
g pfn,
 		cond_resched();
 		pfns =3D min(nr_pages, PAGES_PER_SECTION
 				- (pfn & ~PAGE_SECTION_MASK));
-		__remove_section(zone, pfn, pfns, map_offset, altmap);
+		__remove_section(pfn, pfns, map_offset, altmap);
 		pfn +=3D pfns;
 		nr_pages -=3D pfns;
 		map_offset =3D 0;
 	}
=20
-	set_zone_contiguous(zone);
+	/* TODO: move zone handling out of memory removal path */
+	for_each_zone(zone)
+		set_zone_contiguous(zone);
 }
=20
 int set_online_page_callback(online_page_callback_t callback)
--=20
2.21.0


