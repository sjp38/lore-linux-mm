Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 839B6C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:15:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50B9623427
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:15:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50B9623427
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04E616B0010; Fri, 30 Aug 2019 05:15:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3E226B0266; Fri, 30 Aug 2019 05:15:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E31426B0269; Fri, 30 Aug 2019 05:15:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id BDAE56B0010
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:15:17 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 77F42824CA2F
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:15:17 +0000 (UTC)
X-FDA: 75878535474.05.coach53_4b41c3d8dbd02
X-HE-Tag: coach53_4b41c3d8dbd02
X-Filterd-Recvd-Size: 3793
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:15:17 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1709D30917EF;
	Fri, 30 Aug 2019 09:15:16 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 21E12600F8;
	Fri, 30 Aug 2019 09:15:13 +0000 (UTC)
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
Subject: [PATCH v4 6/8] mm/memory_hotplug: Don't check for "all holes" in shrink_zone_span()
Date: Fri, 30 Aug 2019 11:14:26 +0200
Message-Id: <20190830091428.18399-7-david@redhat.com>
In-Reply-To: <20190830091428.18399-1-david@redhat.com>
References: <20190830091428.18399-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Fri, 30 Aug 2019 09:15:16 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If we have holes, the holes will automatically get detected and removed
once we remove the next bigger/smaller section. The extra checks can
go.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 34 +++++++---------------------------
 1 file changed, 7 insertions(+), 27 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d6807934bb30..82f5012cea3c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -393,6 +393,9 @@ static void shrink_zone_span(struct zone *zone, unsig=
ned long start_pfn,
 		if (pfn) {
 			zone->zone_start_pfn =3D pfn;
 			zone->spanned_pages =3D zone_end_pfn - pfn;
+		} else {
+			zone->zone_start_pfn =3D 0;
+			zone->spanned_pages =3D 0;
 		}
 	} else if (zone_end_pfn =3D=3D end_pfn) {
 		/*
@@ -405,34 +408,11 @@ static void shrink_zone_span(struct zone *zone, uns=
igned long start_pfn,
 					       start_pfn);
 		if (pfn)
 			zone->spanned_pages =3D pfn - zone_start_pfn + 1;
+		else {
+			zone->zone_start_pfn =3D 0;
+			zone->spanned_pages =3D 0;
+		}
 	}
-
-	/*
-	 * The section is not biggest or smallest mem_section in the zone, it
-	 * only creates a hole in the zone. So in this case, we need not
-	 * change the zone. But perhaps, the zone has only hole data. Thus
-	 * it check the zone has only hole or not.
-	 */
-	pfn =3D zone_start_pfn;
-	for (; pfn < zone_end_pfn; pfn +=3D PAGES_PER_SUBSECTION) {
-		if (unlikely(!pfn_to_online_page(pfn)))
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
-		zone_span_writeunlock(zone);
-		return;
-	}
-
-	/* The zone has no valid section */
-	zone->zone_start_pfn =3D 0;
-	zone->spanned_pages =3D 0;
 	zone_span_writeunlock(zone);
 }
=20
--=20
2.21.0


