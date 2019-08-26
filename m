Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68848C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:10:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3003F21872
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:10:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3003F21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7FAC6B0557; Mon, 26 Aug 2019 06:10:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0D0C6B0558; Mon, 26 Aug 2019 06:10:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C45C06B0559; Mon, 26 Aug 2019 06:10:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0094.hostedemail.com [216.40.44.94])
	by kanga.kvack.org (Postfix) with ESMTP id 9AED06B0557
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 06:10:44 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 53212824CA3D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:10:44 +0000 (UTC)
X-FDA: 75864160008.15.toys94_236dd243d0f4b
X-HE-Tag: toys94_236dd243d0f4b
X-Filterd-Recvd-Size: 2688
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:10:43 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 72397300BEB0;
	Mon, 26 Aug 2019 10:10:42 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-227.ams2.redhat.com [10.36.116.227])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4E1C560920;
	Mon, 26 Aug 2019 10:10:40 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michal Hocko <mhocko@suse.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Arun KS <arunks@codeaurora.org>
Subject: [PATCH v2 5/6] mm: Introduce for_each_zone_nid()
Date: Mon, 26 Aug 2019 12:10:11 +0200
Message-Id: <20190826101012.10575-6-david@redhat.com>
In-Reply-To: <20190826101012.10575-1-david@redhat.com>
References: <20190826101012.10575-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 26 Aug 2019 10:10:42 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Allow to iterate all zones belonging to a nid.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Arun KS <arunks@codeaurora.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/mmzone.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8b5f758942a2..71f2b9b55069 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1004,6 +1004,11 @@ extern struct zone *next_zone(struct zone *zone);
 			; /* do nothing */		\
 		else
=20
+#define for_each_zone_nid(zone, nid)			\
+	for (zone =3D (NODE_DATA(nid))->node_zones;	\
+	     zone && zone_to_nid(zone) =3D=3D nid;		\
+	     zone =3D next_zone(zone))
+
 static inline struct zone *zonelist_zone(struct zoneref *zoneref)
 {
 	return zoneref->zone;
--=20
2.21.0


