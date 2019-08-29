Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 806FFC3A5A7
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4643E23403
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4643E23403
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A69926B026D; Thu, 29 Aug 2019 03:00:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 905666B026E; Thu, 29 Aug 2019 03:00:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7576E6B026F; Thu, 29 Aug 2019 03:00:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id 48BF76B026D
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:00:53 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id EC7EBBEF3
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:52 +0000 (UTC)
X-FDA: 75874567944.04.roll90_7a90e2004104
X-HE-Tag: roll90_7a90e2004104
X-Filterd-Recvd-Size: 4337
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:52 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 871E43B738;
	Thu, 29 Aug 2019 07:00:51 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-166.ams2.redhat.com [10.36.117.166])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B0D861001B07;
	Thu, 29 Aug 2019 07:00:49 +0000 (UTC)
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
Subject: [PATCH v3 05/11] mm/memory_hotplug: Optimize zone shrinking code when checking for holes
Date: Thu, 29 Aug 2019 09:00:13 +0200
Message-Id: <20190829070019.12714-6-david@redhat.com>
In-Reply-To: <20190829070019.12714-1-david@redhat.com>
References: <20190829070019.12714-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 29 Aug 2019 07:00:51 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

... and clarify why this is needed at all right now. It all boils down
to false positives. We will try to remove the false positives for
!ZONE_DEVICE memory, soon, however, for ZONE_DEVICE memory we won't be
able to easily get rid of false positives.

Don't only detect "all holes" but try to shrink using the existing
functions we have.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 45 +++++++++++++++++++++++----------------------
 1 file changed, 23 insertions(+), 22 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d3c34bbeb36d..663853bf97ed 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -411,32 +411,33 @@ static void shrink_zone_span(struct zone *zone, uns=
igned long start_pfn,
 		}
 	}
=20
-	/*
-	 * The section is not biggest or smallest mem_section in the zone, it
-	 * only creates a hole in the zone. So in this case, we need not
-	 * change the zone. But perhaps, the zone has only hole data. Thus
-	 * it check the zone has only hole or not.
-	 */
-	for (pfn =3D zone->zone_start_pfn;
-	     pfn < zone_end_pfn(zone); pfn +=3D PAGES_PER_SUBSECTION) {
-		if (unlikely(!pfn_valid(pfn)))
-			continue;
-
-		if (page_zone(pfn_to_page(pfn)) !=3D zone)
-			continue;
-
-		/* Skip range to be removed */
-		if (pfn >=3D start_pfn && pfn < end_pfn)
-			continue;
-
-		/* If we find valid section, we have nothing to do */
+	if (!zone->spanned_pages) {
 		zone_span_writeunlock(zone);
 		return;
 	}
=20
-	/* The zone has no valid section */
-	zone->zone_start_pfn =3D 0;
-	zone->spanned_pages =3D 0;
+	/*
+	 * Due to false positives in previous skrink attempts, it can happen
+	 * that we can shrink the zones further (possibly to zero). Once we
+	 * can reliably detect which PFNs actually belong to a zone
+	 * (especially for ZONE_DEVICE memory where we don't have online
+	 * sections), this can go.
+	 */
+	pfn =3D find_smallest_section_pfn(nid, zone, zone->zone_start_pfn,
+					zone_end_pfn(zone));
+	if (pfn) {
+		zone->spanned_pages =3D zone_end_pfn(zone) - pfn;
+		zone->zone_start_pfn =3D pfn;
+
+		pfn =3D find_biggest_section_pfn(nid, zone, zone->zone_start_pfn,
+					       zone_end_pfn(zone));
+		if (pfn)
+			zone->spanned_pages =3D pfn - zone->zone_start_pfn + 1;
+	}
+	if (!pfn) {
+		zone->zone_start_pfn =3D 0;
+		zone->spanned_pages =3D 0;
+	}
 	zone_span_writeunlock(zone);
 }
=20
--=20
2.21.0


