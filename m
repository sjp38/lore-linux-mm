Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3674EC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F052F2084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F052F2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96FBE6B000D; Wed, 14 Aug 2019 11:41:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D2C26B000E; Wed, 14 Aug 2019 11:41:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 777876B0010; Wed, 14 Aug 2019 11:41:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7F16B000D
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:41:24 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 009B852DA
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:23 +0000 (UTC)
X-FDA: 75821447688.05.dad56_294580d95cb1a
X-HE-Tag: dad56_294580d95cb1a
X-Filterd-Recvd-Size: 3709
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:23 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 506C13CA0D;
	Wed, 14 Aug 2019 15:41:22 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-49.ams2.redhat.com [10.36.116.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A660880A27;
	Wed, 14 Aug 2019 15:41:20 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 3/5] mm/memory_hotplug: Simplify online_pages_range()
Date: Wed, 14 Aug 2019 17:41:07 +0200
Message-Id: <20190814154109.3448-4-david@redhat.com>
In-Reply-To: <20190814154109.3448-1-david@redhat.com>
References: <20190814154109.3448-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 14 Aug 2019 15:41:22 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

online_pages always corresponds to nr_pages. Simplify the code, getting
rid of online_pages_blocks(). Add some comments.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 36 ++++++++++++++++--------------------
 1 file changed, 16 insertions(+), 20 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 10ad970f3f14..63b1775f7cf8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -632,31 +632,27 @@ static void generic_online_page(struct page *page, =
unsigned int order)
 #endif
 }
=20
-static int online_pages_blocks(unsigned long start, unsigned long nr_pag=
es)
-{
-	unsigned long end =3D start + nr_pages;
-	int order, onlined_pages =3D 0;
-
-	while (start < end) {
-		order =3D min(MAX_ORDER - 1,
-			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
-		(*online_page_callback)(pfn_to_page(start), order);
-
-		onlined_pages +=3D (1UL << order);
-		start +=3D (1UL << order);
-	}
-	return onlined_pages;
-}
-
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_=
pages,
 			void *arg)
 {
-	unsigned long onlined_pages =3D *(unsigned long *)arg;
+	const unsigned long end_pfn =3D start_pfn + nr_pages;
+	unsigned long pfn;
+	int order;
+
+	/*
+	 * Online the pages. The callback might decide to keep some pages
+	 * PG_reserved (to add them to the buddy later), but we still account
+	 * them as being online/belonging to this zone ("present").
+	 */
+	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1ul << order) {
+		order =3D min(MAX_ORDER - 1, get_order(PFN_PHYS(end_pfn - pfn)));
+		(*online_page_callback)(pfn_to_page(pfn), order);
+	}
=20
-	onlined_pages +=3D online_pages_blocks(start_pfn, nr_pages);
-	online_mem_sections(start_pfn, start_pfn + nr_pages);
+	/* mark all involved sections as online */
+	online_mem_sections(start_pfn, end_pfn);
=20
-	*(unsigned long *)arg =3D onlined_pages;
+	*(unsigned long *)arg +=3D nr_pages;
 	return 0;
 }
=20
--=20
2.21.0


