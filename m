Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65AA0C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35B932054F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35B932054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F276B0010; Wed, 14 Aug 2019 11:41:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 417F86B0266; Wed, 14 Aug 2019 11:41:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 305B86B0269; Wed, 14 Aug 2019 11:41:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0142.hostedemail.com [216.40.44.142])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1BD6B0010
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:41:28 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C216A40C3
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:27 +0000 (UTC)
X-FDA: 75821447814.15.hour23_29d4536cd4352
X-HE-Tag: hour23_29d4536cd4352
X-Filterd-Recvd-Size: 3546
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:27 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 777C7309BDA0;
	Wed, 14 Aug 2019 15:41:26 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-49.ams2.redhat.com [10.36.116.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC13D80693;
	Wed, 14 Aug 2019 15:41:24 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 5/5] mm/memory_hotplug: online_pages cannot be 0 in online_pages()
Date: Wed, 14 Aug 2019 17:41:09 +0200
Message-Id: <20190814154109.3448-6-david@redhat.com>
In-Reply-To: <20190814154109.3448-1-david@redhat.com>
References: <20190814154109.3448-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 14 Aug 2019 15:41:26 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_system_ram_range() will fail with -EINVAL in case
online_pages_range() was never called (=3D=3D no resource applicable in t=
he
range). Otherwise, we will always call online_pages_range() with
nr_pages > 0 and, therefore, have online_pages > 0.

Remove that special handling.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f245fb50ba7f..01456fc66564 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -853,6 +853,7 @@ int __ref online_pages(unsigned long pfn, unsigned lo=
ng nr_pages, int online_typ
 	ret =3D walk_system_ram_range(pfn, nr_pages, &onlined_pages,
 		online_pages_range);
 	if (ret) {
+		/* not a single memory resource was applicable */
 		if (need_zonelists_rebuild)
 			zone_pcp_reset(zone);
 		goto failed_addition;
@@ -866,27 +867,22 @@ int __ref online_pages(unsigned long pfn, unsigned =
long nr_pages, int online_typ
=20
 	shuffle_zone(zone);
=20
-	if (onlined_pages) {
-		node_states_set_node(nid, &arg);
-		if (need_zonelists_rebuild)
-			build_all_zonelists(NULL);
-		else
-			zone_pcp_update(zone);
-	}
+	node_states_set_node(nid, &arg);
+	if (need_zonelists_rebuild)
+		build_all_zonelists(NULL);
+	else
+		zone_pcp_update(zone);
=20
 	init_per_zone_wmark_min();
=20
-	if (onlined_pages) {
-		kswapd_run(nid);
-		kcompactd_run(nid);
-	}
+	kswapd_run(nid);
+	kcompactd_run(nid);
=20
 	vm_total_pages =3D nr_free_pagecache_pages();
=20
 	writeback_set_ratelimit();
=20
-	if (onlined_pages)
-		memory_notify(MEM_ONLINE, &arg);
+	memory_notify(MEM_ONLINE, &arg);
 	mem_hotplug_done();
 	return 0;
=20
--=20
2.21.0


