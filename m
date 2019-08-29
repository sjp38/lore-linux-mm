Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CCC4C3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:01:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E58CF233A1
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E58CF233A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B77BA6B0270; Thu, 29 Aug 2019 03:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B020D6B0271; Thu, 29 Aug 2019 03:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97E736B0272; Thu, 29 Aug 2019 03:00:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0233.hostedemail.com [216.40.44.233])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7CE6B0270
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:00:57 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 20CC9180AD7C3
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:57 +0000 (UTC)
X-FDA: 75874568154.12.son30_845a6e442c15
X-HE-Tag: son30_845a6e442c15
X-Filterd-Recvd-Size: 2910
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:56 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0B0298AC6FF;
	Thu, 29 Aug 2019 07:00:56 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-166.ams2.redhat.com [10.36.117.166])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 358F81001B05;
	Thu, 29 Aug 2019 07:00:54 +0000 (UTC)
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
Subject: [PATCH v3 07/11] mm/memory_hotplug: Exit early in __remove_pages() on BUGs
Date: Thu, 29 Aug 2019 09:00:15 +0200
Message-Id: <20190829070019.12714-8-david@redhat.com>
In-Reply-To: <20190829070019.12714-1-david@redhat.com>
References: <20190829070019.12714-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.69]); Thu, 29 Aug 2019 07:00:56 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The error path should never happen in practice (unless bringing up a new
device driver, or on BUGs). However, it's clearer to not touch anything
in case we are going to return right away. Move the check/return.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 65b3fdf7f838..56eabd22cbae 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -527,13 +527,13 @@ void __remove_pages(struct zone *zone, unsigned lon=
g pfn,
 	unsigned long map_offset =3D 0;
 	unsigned long nr, start_sec, end_sec;
=20
+	if (check_pfn_span(pfn, nr_pages, "remove"))
+		return;
+
 	map_offset =3D vmem_altmap_offset(altmap);
=20
 	clear_zone_contiguous(zone);
=20
-	if (check_pfn_span(pfn, nr_pages, "remove"))
-		return;
-
 	start_sec =3D pfn_to_section_nr(pfn);
 	end_sec =3D pfn_to_section_nr(pfn + nr_pages - 1);
 	for (nr =3D start_sec; nr <=3D end_sec; nr++) {
--=20
2.21.0


