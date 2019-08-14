Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 317F4C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F40752084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F40752084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D6EB6B0007; Wed, 14 Aug 2019 11:41:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68C896B000D; Wed, 14 Aug 2019 11:41:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 577856B000E; Wed, 14 Aug 2019 11:41:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id 30AFC6B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:41:22 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CB6ED180AD801
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:21 +0000 (UTC)
X-FDA: 75821447562.12.cup15_28f414dfd9d07
X-HE-Tag: cup15_28f414dfd9d07
X-Filterd-Recvd-Size: 3069
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:21 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 540D2C069B52;
	Wed, 14 Aug 2019 15:41:20 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-49.ams2.redhat.com [10.36.116.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A720080693;
	Wed, 14 Aug 2019 15:41:18 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 2/5] mm/memory_hotplug: Drop PageReserved() check in online_pages_range()
Date: Wed, 14 Aug 2019 17:41:06 +0200
Message-Id: <20190814154109.3448-3-david@redhat.com>
In-Reply-To: <20190814154109.3448-1-david@redhat.com>
References: <20190814154109.3448-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 14 Aug 2019 15:41:20 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

move_pfn_range_to_zone() will set all pages to PG_reserved via
memmap_init_zone(). The only way a page could no longer be reserved
would be if a MEM_GOING_ONLINE notifier would clear PG_reserved - which
is not done (the online_page callback is used for that purpose by
e.g., Hyper-V instead). walk_system_ram_range() will never call
online_pages_range() with duplicate PFNs, so drop the PageReserved() chec=
k.

This seems to be a leftover from ancient times where the memmap was
initialized when adding memory and we wanted to check for already
onlined memory.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3706a137d880..10ad970f3f14 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -653,9 +653,7 @@ static int online_pages_range(unsigned long start_pfn=
, unsigned long nr_pages,
 {
 	unsigned long onlined_pages =3D *(unsigned long *)arg;
=20
-	if (PageReserved(pfn_to_page(start_pfn)))
-		onlined_pages +=3D online_pages_blocks(start_pfn, nr_pages);
-
+	onlined_pages +=3D online_pages_blocks(start_pfn, nr_pages);
 	online_mem_sections(start_pfn, start_pfn + nr_pages);
=20
 	*(unsigned long *)arg =3D onlined_pages;
--=20
2.21.0


