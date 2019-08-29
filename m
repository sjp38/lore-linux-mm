Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA803C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA113233A1
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA113233A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 629716B0269; Thu, 29 Aug 2019 03:00:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 539176B026A; Thu, 29 Aug 2019 03:00:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FBED6B026B; Thu, 29 Aug 2019 03:00:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8AD6B0269
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:00:49 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B8CC9180AD802
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:48 +0000 (UTC)
X-FDA: 75874567776.18.kitty96_70a73672c940
X-HE-Tag: kitty96_70a73672c940
X-Filterd-Recvd-Size: 2888
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:48 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 31A0C10C696E;
	Thu, 29 Aug 2019 07:00:47 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-166.ams2.redhat.com [10.36.117.166])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 55CBE1001B05;
	Thu, 29 Aug 2019 07:00:45 +0000 (UTC)
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
Subject: [PATCH v3 03/11] mm/memory_hotplug: We always have a zone in find_(smallest|biggest)_section_pfn
Date: Thu, 29 Aug 2019 09:00:11 +0200
Message-Id: <20190829070019.12714-4-david@redhat.com>
In-Reply-To: <20190829070019.12714-1-david@redhat.com>
References: <20190829070019.12714-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.65]); Thu, 29 Aug 2019 07:00:47 +0000 (UTC)
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
index 70cd6c59c168..0a21f6f99753 100644
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


