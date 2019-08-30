Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54248C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:15:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1723423429
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:15:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1723423429
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C30A76B000D; Fri, 30 Aug 2019 05:15:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE0B46B000E; Fri, 30 Aug 2019 05:15:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAC596B0010; Fri, 30 Aug 2019 05:15:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0097.hostedemail.com [216.40.44.97])
	by kanga.kvack.org (Postfix) with ESMTP id 86B056B000D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:15:08 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0BBAC27056
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:15:08 +0000 (UTC)
X-FDA: 75878535096.05.rod89_49c87c1b76363
X-HE-Tag: rod89_49c87c1b76363
X-Filterd-Recvd-Size: 3849
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:15:06 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C17D32A09C9;
	Fri, 30 Aug 2019 09:15:05 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1334B60166;
	Fri, 30 Aug 2019 09:15:02 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v4 4/8] mm/memory_hotplug: Poison memmap in remove_pfn_range_from_zone()
Date: Fri, 30 Aug 2019 11:14:24 +0200
Message-Id: <20190830091428.18399-5-david@redhat.com>
In-Reply-To: <20190830091428.18399-1-david@redhat.com>
References: <20190830091428.18399-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 30 Aug 2019 09:15:05 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's poison the pages similar to when adding new memory in
sparse_add_section(). Also call remove_pfn_range_from_zone() from
memunmap_pages(), so we can poison the memmap from there as well.

While at it, calculate the pfn in memunmap_pages() only once.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 3 +++
 mm/memremap.c       | 7 ++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4da59ec14dbb..5bfca690a922 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -464,6 +464,9 @@ void __ref remove_pfn_range_from_zone(struct zone *zo=
ne,
 	struct pglist_data *pgdat =3D zone->zone_pgdat;
 	unsigned long flags;
=20
+	/* Poison struct pages because they are now uninitialized again. */
+	page_init_poison(pfn_to_page(start_pfn), sizeof(struct page) * nr_pages=
);
+
 	/*
 	 * Zone shrinking code cannot properly deal with ZONE_DEVICE. So
 	 * we will not try to shrink the zones - which is okay as
diff --git a/mm/memremap.c b/mm/memremap.c
index cb90c3e8804a..48f573502f88 100644
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
 		__remove_pages(pfn, PHYS_PFN(resource_size(res)), NULL);
 	} else {
 		arch_remove_memory(nid, res->start, resource_size(res),
--=20
2.21.0


