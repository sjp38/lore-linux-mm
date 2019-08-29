Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D8EAC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18EC1233A1
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18EC1233A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4E086B026F; Thu, 29 Aug 2019 03:00:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD5E26B0270; Thu, 29 Aug 2019 03:00:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B79136B0271; Thu, 29 Aug 2019 03:00:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 8B57C6B026F
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:00:55 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3D0CA824376A
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:55 +0000 (UTC)
X-FDA: 75874568070.05.show37_7fb7f236a14a
X-HE-Tag: show37_7fb7f236a14a
X-Filterd-Recvd-Size: 4329
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:54 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D634C10F23E8;
	Thu, 29 Aug 2019 07:00:53 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-166.ams2.redhat.com [10.36.117.166])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D5F221001B05;
	Thu, 29 Aug 2019 07:00:51 +0000 (UTC)
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
Subject: [PATCH v3 06/11] mm/memory_hotplug: Fix crashes in shrink_zone_span()
Date: Thu, 29 Aug 2019 09:00:14 +0200
Message-Id: <20190829070019.12714-7-david@redhat.com>
In-Reply-To: <20190829070019.12714-1-david@redhat.com>
References: <20190829070019.12714-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.66]); Thu, 29 Aug 2019 07:00:54 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We can currently crash in shrink_zone_span() in case we access an
uninitialized memmap (via page_to_nid()). Root issue is that we cannot
always identify which memmap was actually initialized.

Let's improve the situation by looking only at online PFNs for
!ZONE_DEVICE memory. This is now very reliable - similar to
set_zone_contiguous(). (Side note: set_zone_contiguous() will never
succeed on ZONE_DEVICE memory right now as we have no online PFNs ...).

For ZONE_DEVICE memory, make sure we don't crash by special-casing
poisoned pages and always checking that the NID has a sane value. We
might still read garbage and get false positives, but it certainly
improves the situation.

Note: Especially subsections make it very hard to detect which parts of
a ZONE_DEVICE memmap were actually initialized - otherwise we could just
have reused SECTION_IS_ONLINE. This needs more thought.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Reported-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 663853bf97ed..65b3fdf7f838 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -334,6 +334,17 @@ static unsigned long find_smallest_section_pfn(int n=
id, struct zone *zone,
 		if (unlikely(!pfn_valid(start_pfn)))
 			continue;
=20
+		/*
+		 * TODO: There is no way we can identify whether the memmap
+		 * of ZONE_DEVICE memory was initialized. We might get
+		 * false positives when reading garbage.
+		 */
+		if (zone_idx(zone) =3D=3D ZONE_DEVICE) {
+			if (PagePoisoned(pfn_to_page(start_pfn)))
+				continue;
+		} else if (!pfn_to_online_page(start_pfn))
+			continue;
+
 		if (unlikely(pfn_to_nid(start_pfn) !=3D nid))
 			continue;
=20
@@ -359,6 +370,17 @@ static unsigned long find_biggest_section_pfn(int ni=
d, struct zone *zone,
 		if (unlikely(!pfn_valid(pfn)))
 			continue;
=20
+		/*
+		 * TODO: There is no way we can identify whether the memmap
+		 * of ZONE_DEVICE memory was initialized. We might get
+		 * false positives when reading garbage.
+		 */
+		if (zone_idx(zone) =3D=3D ZONE_DEVICE) {
+			if (PagePoisoned(pfn_to_page(pfn)))
+				continue;
+		} else if (!pfn_to_online_page(pfn))
+			continue;
+
 		if (unlikely(pfn_to_nid(pfn) !=3D nid))
 			continue;
=20
--=20
2.21.0


