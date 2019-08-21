Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18BD8C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB53222DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB53222DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27F236B02F1; Wed, 21 Aug 2019 11:40:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 230E66B02F2; Wed, 21 Aug 2019 11:40:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D7AE6B02F3; Wed, 21 Aug 2019 11:40:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id D4F0D6B02F1
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:40:26 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 67C8F8248AAE
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:26 +0000 (UTC)
X-FDA: 75846846852.25.tree89_3ca3e73eb509
X-HE-Tag: tree89_3ca3e73eb509
X-Filterd-Recvd-Size: 2933
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:25 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F15E43082B40;
	Wed, 21 Aug 2019 15:40:24 +0000 (UTC)
Received: from t460s.redhat.com (unknown [10.36.118.29])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A600C50DD6;
	Wed, 21 Aug 2019 15:40:22 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: [PATCH v1 2/5] mm: Exit early in set_zone_contiguous() if already contiguous
Date: Wed, 21 Aug 2019 17:40:03 +0200
Message-Id: <20190821154006.1338-3-david@redhat.com>
In-Reply-To: <20190821154006.1338-1-david@redhat.com>
References: <20190821154006.1338-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 21 Aug 2019 15:40:25 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No need to recompute in case the zone is already marked contiguous.
We will soon exploit this on the memory removal path, where we will only
clear zone->contiguous on zones that intersect with the memory to be
removed.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b799e11fba3..995708e05cde 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1546,6 +1546,9 @@ void set_zone_contiguous(struct zone *zone)
 	unsigned long block_start_pfn =3D zone->zone_start_pfn;
 	unsigned long block_end_pfn;
=20
+	if (zone->contiguous)
+		return;
+
 	block_end_pfn =3D ALIGN(block_start_pfn + 1, pageblock_nr_pages);
 	for (; block_start_pfn < zone_end_pfn(zone);
 			block_start_pfn =3D block_end_pfn,
--=20
2.21.0


