Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3381AC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01C852084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01C852084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0CA26B0006; Wed, 14 Aug 2019 11:41:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BB386B0007; Wed, 14 Aug 2019 11:41:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F8696B000D; Wed, 14 Aug 2019 11:41:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6B61A6B0006
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:41:20 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2067040C3
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:20 +0000 (UTC)
X-FDA: 75821447520.28.sleet45_28a27d0fe721c
X-HE-Tag: sleet45_28a27d0fe721c
X-Filterd-Recvd-Size: 3057
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:19 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5221351F00;
	Wed, 14 Aug 2019 15:41:18 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-49.ams2.redhat.com [10.36.116.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D540F8069C;
	Wed, 14 Aug 2019 15:41:15 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Borislav Petkov <bp@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Ingo Molnar <mingo@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Nadav Amit <namit@vmware.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH v2 1/5] resource: Use PFN_UP / PFN_DOWN in walk_system_ram_range()
Date: Wed, 14 Aug 2019 17:41:05 +0200
Message-Id: <20190814154109.3448-2-david@redhat.com>
In-Reply-To: <20190814154109.3448-1-david@redhat.com>
References: <20190814154109.3448-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 14 Aug 2019 15:41:18 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This makes it clearer that we will never call func() with duplicate PFNs
in case we have multiple sub-page memory resources. All unaligned parts
of PFNs are completely discarded.

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Cc: Oscar Salvador <osalvador@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 kernel/resource.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 7ea4306503c5..88ee39fa9103 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -487,8 +487,8 @@ int walk_system_ram_range(unsigned long start_pfn, un=
signed long nr_pages,
 	while (start < end &&
 	       !find_next_iomem_res(start, end, flags, IORES_DESC_NONE,
 				    false, &res)) {
-		pfn =3D (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
-		end_pfn =3D (res.end + 1) >> PAGE_SHIFT;
+		pfn =3D PFN_UP(res.start);
+		end_pfn =3D PFN_DOWN(res.end + 1);
 		if (end_pfn > pfn)
 			ret =3D (*func)(pfn, end_pfn - pfn, arg);
 		if (ret)
--=20
2.21.0


