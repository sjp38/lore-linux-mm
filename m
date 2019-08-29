Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DC49C3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:01:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C80422CF5
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:01:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C80422CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5DF66B027A; Thu, 29 Aug 2019 03:01:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE66F6B027B; Thu, 29 Aug 2019 03:01:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAE5F6B027C; Thu, 29 Aug 2019 03:01:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id A290E6B027A
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:01:25 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 54A03180AD801
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:01:25 +0000 (UTC)
X-FDA: 75874569330.03.able55_c5f6706c414b
X-HE-Tag: able55_c5f6706c414b
X-Filterd-Recvd-Size: 3412
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:01:24 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 013C3C05AA6B;
	Thu, 29 Aug 2019 07:01:24 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-166.ams2.redhat.com [10.36.117.166])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1323D1001B14;
	Thu, 29 Aug 2019 07:01:18 +0000 (UTC)
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
Subject: [PATCH v3 11/11] mm/memory_hotplug: Cleanup __remove_pages()
Date: Thu, 29 Aug 2019 09:00:19 +0200
Message-Id: <20190829070019.12714-12-david@redhat.com>
In-Reply-To: <20190829070019.12714-1-david@redhat.com>
References: <20190829070019.12714-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 29 Aug 2019 07:01:24 +0000 (UTC)
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
index fe29c637c0a8..da56cb57a8aa 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -527,25 +527,20 @@ static void __remove_section(unsigned long pfn, uns=
igned long nr_pages,
 void __remove_pages(unsigned long pfn, unsigned long nr_pages,
 		    struct vmem_altmap *altmap)
 {
+	const unsigned long end_pfn =3D pfn + nr_pages;
+	unsigned long cur_nr_pages;
 	unsigned long map_offset =3D 0;
-	unsigned long nr, start_sec, end_sec;
=20
 	if (check_pfn_span(pfn, nr_pages, "remove"))
 		return;
=20
 	map_offset =3D vmem_altmap_offset(altmap);
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
 }
--=20
2.21.0


