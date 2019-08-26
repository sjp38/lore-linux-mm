Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BE3BC3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:10:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0851321872
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:10:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0851321872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F06136B0550; Mon, 26 Aug 2019 06:10:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE2DF6B0551; Mon, 26 Aug 2019 06:10:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE3996B0552; Mon, 26 Aug 2019 06:10:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id A35766B0550
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 06:10:34 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4F050181AC9AE
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:10:34 +0000 (UTC)
X-FDA: 75864159588.27.food83_220c2211f334d
X-HE-Tag: food83_220c2211f334d
X-Filterd-Recvd-Size: 2957
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:10:33 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0892010C696F;
	Mon, 26 Aug 2019 10:10:33 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-227.ams2.redhat.com [10.36.116.227])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AF6D86060D;
	Mon, 26 Aug 2019 10:10:30 +0000 (UTC)
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
Subject: [PATCH v2 2/6] mm: Exit early in set_zone_contiguous() if already contiguous
Date: Mon, 26 Aug 2019 12:10:08 +0200
Message-Id: <20190826101012.10575-3-david@redhat.com>
In-Reply-To: <20190826101012.10575-1-david@redhat.com>
References: <20190826101012.10575-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.65]); Mon, 26 Aug 2019 10:10:33 +0000 (UTC)
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


