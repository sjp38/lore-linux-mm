Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41C9CC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E9C52084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E9C52084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F5836B000E; Wed, 14 Aug 2019 11:41:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 305A36B0010; Wed, 14 Aug 2019 11:41:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F4A06B0266; Wed, 14 Aug 2019 11:41:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0157.hostedemail.com [216.40.44.157])
	by kanga.kvack.org (Postfix) with ESMTP id EE9236B000E
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:41:25 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9C1C78248AA7
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:25 +0000 (UTC)
X-FDA: 75821447730.04.teeth36_2985ed1e73744
X-HE-Tag: teeth36_2985ed1e73744
X-Filterd-Recvd-Size: 2831
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:25 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 788F88E592;
	Wed, 14 Aug 2019 15:41:24 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-49.ams2.redhat.com [10.36.116.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A234E80693;
	Wed, 14 Aug 2019 15:41:22 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Arun KS <arunks@codeaurora.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 4/5] mm/memory_hotplug: Make sure the pfn is aligned to the order when onlining
Date: Wed, 14 Aug 2019 17:41:08 +0200
Message-Id: <20190814154109.3448-5-david@redhat.com>
In-Reply-To: <20190814154109.3448-1-david@redhat.com>
References: <20190814154109.3448-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 14 Aug 2019 15:41:24 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit a9cd410a3d29 ("mm/page_alloc.c: memory hotplug: free pages as high=
er
order") assumed that any PFN we get via memory resources is aligned to
to MAX_ORDER - 1, I am not convinced that is always true. Let's play safe=
,
check the alignment and fallback to single pages.

Cc: Arun KS <arunks@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 63b1775f7cf8..f245fb50ba7f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -646,6 +646,9 @@ static int online_pages_range(unsigned long start_pfn=
, unsigned long nr_pages,
 	 */
 	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1ul << order) {
 		order =3D min(MAX_ORDER - 1, get_order(PFN_PHYS(end_pfn - pfn)));
+		/* __free_pages_core() wants pfns to be aligned to the order */
+		if (unlikely(!IS_ALIGNED(pfn, 1ul << order)))
+			order =3D 0;
 		(*online_page_callback)(pfn_to_page(pfn), order);
 	}
=20
--=20
2.21.0


