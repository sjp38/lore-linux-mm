Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A50D2C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:14:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F1F023429
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:14:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F1F023429
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04DEF6B0008; Fri, 30 Aug 2019 05:14:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEF076B000A; Fri, 30 Aug 2019 05:14:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDF8B6B000C; Fri, 30 Aug 2019 05:14:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by kanga.kvack.org (Postfix) with ESMTP id BE62A6B0008
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:14:47 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6D5372CBBB
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:14:47 +0000 (UTC)
X-FDA: 75878534214.29.gun25_46df586cf7e02
X-HE-Tag: gun25_46df586cf7e02
X-Filterd-Recvd-Size: 6199
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:14:46 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 01F20190C02E;
	Fri, 30 Aug 2019 09:14:46 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9F5A76012E;
	Fri, 30 Aug 2019 09:14:43 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v4 1/8] mm/memory_hotplug: Don't access uninitialized memmaps in shrink_pgdat_span()
Date: Fri, 30 Aug 2019 11:14:21 +0200
Message-Id: <20190830091428.18399-2-david@redhat.com>
In-Reply-To: <20190830091428.18399-1-david@redhat.com>
References: <20190830091428.18399-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.70]); Fri, 30 Aug 2019 09:14:46 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We might use the nid of memmaps that were never initialized. For
example, if the memmap was poisoned, we will crash the kernel in
pfn_to_nid() right now. Let's use the calculated boundaries of the separa=
te
zones instead. This now also avoids having to iterate over a whole bunch =
of
subsections again, after shrinking one zone.

Before commit d0dc12e86b31 ("mm/memory_hotplug: optimize memory
hotplug"), the memmap was initialized to 0 and the node was set to the
right value. After that commit, the node might be garbage.

We'll have to fix shrink_zone_span() next.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
Reported-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 72 ++++++++++-----------------------------------
 1 file changed, 15 insertions(+), 57 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 49f7bf91c25a..ddba8d786e4a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -436,67 +436,25 @@ static void shrink_zone_span(struct zone *zone, uns=
igned long start_pfn,
 	zone_span_writeunlock(zone);
 }
=20
-static void shrink_pgdat_span(struct pglist_data *pgdat,
-			      unsigned long start_pfn, unsigned long end_pfn)
+static void update_pgdat_span(struct pglist_data *pgdat)
 {
-	unsigned long pgdat_start_pfn =3D pgdat->node_start_pfn;
-	unsigned long p =3D pgdat_end_pfn(pgdat); /* pgdat_end_pfn namespace cl=
ash */
-	unsigned long pgdat_end_pfn =3D p;
-	unsigned long pfn;
-	int nid =3D pgdat->node_id;
-
-	if (pgdat_start_pfn =3D=3D start_pfn) {
-		/*
-		 * If the section is smallest section in the pgdat, it need
-		 * shrink pgdat->node_start_pfn and pgdat->node_spanned_pages.
-		 * In this case, we find second smallest valid mem_section
-		 * for shrinking zone.
-		 */
-		pfn =3D find_smallest_section_pfn(nid, NULL, end_pfn,
-						pgdat_end_pfn);
-		if (pfn) {
-			pgdat->node_start_pfn =3D pfn;
-			pgdat->node_spanned_pages =3D pgdat_end_pfn - pfn;
-		}
-	} else if (pgdat_end_pfn =3D=3D end_pfn) {
-		/*
-		 * If the section is biggest section in the pgdat, it need
-		 * shrink pgdat->node_spanned_pages.
-		 * In this case, we find second biggest valid mem_section for
-		 * shrinking zone.
-		 */
-		pfn =3D find_biggest_section_pfn(nid, NULL, pgdat_start_pfn,
-					       start_pfn);
-		if (pfn)
-			pgdat->node_spanned_pages =3D pfn - pgdat_start_pfn + 1;
-	}
-
-	/*
-	 * If the section is not biggest or smallest mem_section in the pgdat,
-	 * it only creates a hole in the pgdat. So in this case, we need not
-	 * change the pgdat.
-	 * But perhaps, the pgdat has only hole data. Thus it check the pgdat
-	 * has only hole or not.
-	 */
-	pfn =3D pgdat_start_pfn;
-	for (; pfn < pgdat_end_pfn; pfn +=3D PAGES_PER_SUBSECTION) {
-		if (unlikely(!pfn_valid(pfn)))
-			continue;
-
-		if (pfn_to_nid(pfn) !=3D nid)
-			continue;
+	unsigned long node_start_pfn =3D 0, node_end_pfn =3D 0;
+	struct zone *zone;
=20
-		/* Skip range to be removed */
-		if (pfn >=3D start_pfn && pfn < end_pfn)
-			continue;
+	for (zone =3D pgdat->node_zones;
+	     zone < pgdat->node_zones + MAX_NR_ZONES; zone++) {
+		unsigned long zone_end_pfn =3D zone->zone_start_pfn +
+					     zone->spanned_pages;
=20
-		/* If we find valid section, we have nothing to do */
-		return;
+		/* No need to lock the zones, they can't change. */
+		if (zone_end_pfn > node_end_pfn)
+			node_end_pfn =3D zone_end_pfn;
+		if (zone->zone_start_pfn < node_start_pfn)
+			node_start_pfn =3D zone->zone_start_pfn;
 	}
=20
-	/* The pgdat has no valid section */
-	pgdat->node_start_pfn =3D 0;
-	pgdat->node_spanned_pages =3D 0;
+	pgdat->node_start_pfn =3D node_start_pfn;
+	pgdat->node_spanned_pages =3D node_end_pfn - node_start_pfn;
 }
=20
 static void __remove_zone(struct zone *zone, unsigned long start_pfn,
@@ -507,7 +465,7 @@ static void __remove_zone(struct zone *zone, unsigned=
 long start_pfn,
=20
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
-	shrink_pgdat_span(pgdat, start_pfn, start_pfn + nr_pages);
+	update_pgdat_span(pgdat);
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 }
=20
--=20
2.21.0


