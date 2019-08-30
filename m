Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 382AEC3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:14:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 039CF23427
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:14:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 039CF23427
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EE126B000A; Fri, 30 Aug 2019 05:14:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 701F06B000C; Fri, 30 Aug 2019 05:14:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CBD76B000D; Fri, 30 Aug 2019 05:14:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id 31ED46B000A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:14:50 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B98BA2CBBB
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:14:49 +0000 (UTC)
X-FDA: 75878534298.10.rings06_4734660d3b734
X-HE-Tag: rings06_4734660d3b734
X-Filterd-Recvd-Size: 4674
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:14:49 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 606968CEC67;
	Fri, 30 Aug 2019 09:14:48 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 53563600F8;
	Fri, 30 Aug 2019 09:14:46 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v4 2/8] mm/memory_hotplug: Don't access uninitialized memmaps in shrink_zone_span()
Date: Fri, 30 Aug 2019 11:14:22 +0200
Message-Id: <20190830091428.18399-3-david@redhat.com>
In-Reply-To: <20190830091428.18399-1-david@redhat.com>
References: <20190830091428.18399-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.69]); Fri, 30 Aug 2019 09:14:48 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's limit shrinking to !ZONE_DEVICE so we can fix the current code. We
should never try to touch the memmap of offline sections where we could
have uninitialized memmaps and could trigger BUGs when calling
page_to_nid() on poisoned pages.

Stopping to shrink the ZONE_DEVICE is fine as set_zone_contiguous() canno=
t
deal with ZONE_DEVICE either way. The zones will always be !contiguous
already and zone shrinking is therefore of limited use.

Before commit d0dc12e86b31 ("mm/memory_hotplug: optimize memory
hotplug"), the memmap was initialized with 0 and the node with the
right value. So the zone might be wrong but not garbage. After that
commit, both the zone and the node will be garbage when touching
uninitialized memmaps.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
Reported-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ddba8d786e4a..e0d1f6a9dfeb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -331,7 +331,7 @@ static unsigned long find_smallest_section_pfn(int ni=
d, struct zone *zone,
 				     unsigned long end_pfn)
 {
 	for (; start_pfn < end_pfn; start_pfn +=3D PAGES_PER_SUBSECTION) {
-		if (unlikely(!pfn_valid(start_pfn)))
+		if (unlikely(!pfn_to_online_page(start_pfn)))
 			continue;
=20
 		if (unlikely(pfn_to_nid(start_pfn) !=3D nid))
@@ -356,7 +356,7 @@ static unsigned long find_biggest_section_pfn(int nid=
, struct zone *zone,
 	/* pfn is the end pfn of a memory section. */
 	pfn =3D end_pfn - 1;
 	for (; pfn >=3D start_pfn; pfn -=3D PAGES_PER_SUBSECTION) {
-		if (unlikely(!pfn_valid(pfn)))
+		if (unlikely(!pfn_to_online_page(pfn)))
 			continue;
=20
 		if (unlikely(pfn_to_nid(pfn) !=3D nid))
@@ -415,7 +415,7 @@ static void shrink_zone_span(struct zone *zone, unsig=
ned long start_pfn,
 	 */
 	pfn =3D zone_start_pfn;
 	for (; pfn < zone_end_pfn; pfn +=3D PAGES_PER_SUBSECTION) {
-		if (unlikely(!pfn_valid(pfn)))
+		if (unlikely(!pfn_to_online_page(pfn)))
 			continue;
=20
 		if (page_zone(pfn_to_page(pfn)) !=3D zone)
@@ -463,6 +463,14 @@ static void __remove_zone(struct zone *zone, unsigne=
d long start_pfn,
 	struct pglist_data *pgdat =3D zone->zone_pgdat;
 	unsigned long flags;
=20
+	/*
+	 * Zone shrinking code cannot properly deal with ZONE_DEVICE. So
+	 * we will not try to shrink the zones - which is okay as
+	 * set_zone_contiguous() cannot deal with ZONE_DEVICE either way.
+	 */
+	if (zone_idx(zone) =3D=3D ZONE_DEVICE)
+		return;
+
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
 	update_pgdat_span(pgdat);
--=20
2.21.0


