Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B9A7C3A5A7
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:15:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3414023427
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:15:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3414023427
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2CB46B000E; Fri, 30 Aug 2019 05:15:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDD786B0010; Fri, 30 Aug 2019 05:15:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF3986B0266; Fri, 30 Aug 2019 05:15:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0013.hostedemail.com [216.40.44.13])
	by kanga.kvack.org (Postfix) with ESMTP id B05A06B000E
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:15:15 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4C0F1824CA2F
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:15:15 +0000 (UTC)
X-FDA: 75878535390.22.cats27_4af0b91732808
X-HE-Tag: cats27_4af0b91732808
X-Filterd-Recvd-Size: 2883
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:15:14 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B60E08AC6FD;
	Fri, 30 Aug 2019 09:15:13 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 21644600F8;
	Fri, 30 Aug 2019 09:15:05 +0000 (UTC)
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
Subject: [PATCH v4 5/8] mm/memory_hotplug: We always have a zone in find_(smallest|biggest)_section_pfn
Date: Fri, 30 Aug 2019 11:14:25 +0200
Message-Id: <20190830091428.18399-6-david@redhat.com>
In-Reply-To: <20190830091428.18399-1-david@redhat.com>
References: <20190830091428.18399-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.69]); Fri, 30 Aug 2019 09:15:13 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With shrink_pgdat_span() out of the way, we now always have a valid
zone.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 5bfca690a922..d6807934bb30 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -337,7 +337,7 @@ static unsigned long find_smallest_section_pfn(int ni=
d, struct zone *zone,
 		if (unlikely(pfn_to_nid(start_pfn) !=3D nid))
 			continue;
=20
-		if (zone && zone !=3D page_zone(pfn_to_page(start_pfn)))
+		if (zone !=3D page_zone(pfn_to_page(start_pfn)))
 			continue;
=20
 		return start_pfn;
@@ -362,7 +362,7 @@ static unsigned long find_biggest_section_pfn(int nid=
, struct zone *zone,
 		if (unlikely(pfn_to_nid(pfn) !=3D nid))
 			continue;
=20
-		if (zone && zone !=3D page_zone(pfn_to_page(pfn)))
+		if (zone !=3D page_zone(pfn_to_page(pfn)))
 			continue;
=20
 		return pfn;
--=20
2.21.0


