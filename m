Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 645FDC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F97A22DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F97A22DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D06DE6B02F6; Wed, 21 Aug 2019 11:40:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB72A6B02F7; Wed, 21 Aug 2019 11:40:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCE636B02F8; Wed, 21 Aug 2019 11:40:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0010.hostedemail.com [216.40.44.10])
	by kanga.kvack.org (Postfix) with ESMTP id 952506B02F6
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:40:33 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1A5A7181AC9CC
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:33 +0000 (UTC)
X-FDA: 75846847146.30.fog95_4c51fa46564c
X-HE-Tag: fog95_4c51fa46564c
X-Filterd-Recvd-Size: 3511
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:32 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CB2FA1801175;
	Wed, 21 Aug 2019 15:40:31 +0000 (UTC)
Received: from t460s.redhat.com (unknown [10.36.118.29])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 74B5A2B9E3;
	Wed, 21 Aug 2019 15:40:27 +0000 (UTC)
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
Subject: [PATCH v1 4/5] mm/memory_hotplug: Cleanup __remove_pages()
Date: Wed, 21 Aug 2019 17:40:05 +0200
Message-Id: <20190821154006.1338-5-david@redhat.com>
In-Reply-To: <20190821154006.1338-1-david@redhat.com>
References: <20190821154006.1338-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.62]); Wed, 21 Aug 2019 15:40:31 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's drop the basically unused section stuff and simplify.

Also, let's use a shorter variant to calculate the number of pages to
the next section boundary.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 27f0457b7512..e88c96cf9d77 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -545,8 +545,9 @@ static void __remove_section(unsigned long pfn, unsig=
ned long nr_pages,
 void __remove_pages(struct zone *zone, unsigned long pfn,
 		    unsigned long nr_pages, struct vmem_altmap *altmap)
 {
+	const unsigned long end_pfn =3D pfn + nr_pages;
+	unsigned long cur_nr_pages;
 	unsigned long map_offset =3D 0;
-	unsigned long nr, start_sec, end_sec;
=20
 	if (check_pfn_span(pfn, nr_pages, "remove"))
 		return;
@@ -558,17 +559,11 @@ void __remove_pages(struct zone *zone, unsigned lon=
g pfn,
 		if (zone_intersects(zone, pfn, nr_pages))
 			clear_zone_contiguous(zone);
=20
-	start_sec =3D pfn_to_section_nr(pfn);
-	end_sec =3D pfn_to_section_nr(pfn + nr_pages - 1);
-	for (nr =3D start_sec; nr <=3D end_sec; nr++) {
-		unsigned long pfns;
-
+	for (; pfn < end_pfn; pfn +=3D cur_nr_pages) {
 		cond_resched();
-		pfns =3D min(nr_pages, PAGES_PER_SECTION
-				- (pfn & ~PAGE_SECTION_MASK));
-		__remove_section(pfn, pfns, map_offset, altmap);
-		pfn +=3D pfns;
-		nr_pages -=3D pfns;
+		/* Select all remaining pages up to the next section boundary */
+		cur_nr_pages =3D min(end_pfn - pfn, -(pfn | PAGE_SECTION_MASK));
+		__remove_section(pfn, cur_nr_pages, map_offset, altmap);
 		map_offset =3D 0;
 	}
=20
--=20
2.21.0


