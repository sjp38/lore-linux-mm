Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58A45C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 298C721924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:49:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 298C721924
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5D456B0007; Mon,  9 Sep 2019 07:48:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0D916B0008; Mon,  9 Sep 2019 07:48:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4A926B000A; Mon,  9 Sep 2019 07:48:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0006.hostedemail.com [216.40.44.6])
	by kanga.kvack.org (Postfix) with ESMTP id 816EC6B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:48:59 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id CCB87824CA3F
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:48:58 +0000 (UTC)
X-FDA: 75915210756.10.crime27_6b6091ab5c84e
X-HE-Tag: crime27_6b6091ab5c84e
X-Filterd-Recvd-Size: 2512
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:48:57 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AC81019B114E;
	Mon,  9 Sep 2019 11:48:56 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-173.ams2.redhat.com [10.36.116.173])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0F9C71001B09;
	Mon,  9 Sep 2019 11:48:50 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	Souptick Joarder <jrdr.linux@gmail.com>,
	linux-hyperv@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Stephen Hemminger <sthemmin@microsoft.com>,
	Sasha Levin <sashal@kernel.org>
Subject: [PATCH v1 2/3] hv_balloon: Use generic_online_page()
Date: Mon,  9 Sep 2019 13:48:29 +0200
Message-Id: <20190909114830.662-3-david@redhat.com>
In-Reply-To: <20190909114830.662-1-david@redhat.com>
References: <20190909114830.662-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.63]); Mon, 09 Sep 2019 11:48:56 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's use the generic onlining function - which will now also take care
of calling kernel_map_pages().

Cc: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
Cc: Sasha Levin <sashal@kernel.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/hv/hv_balloon.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index a91c90d4402c..35f123b459c8 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -680,8 +680,7 @@ static void hv_page_online_one(struct hv_hotadd_state=
 *has, struct page *pg)
 		__ClearPageOffline(pg);
=20
 	/* This frame is currently backed; online the page. */
-	__online_page_increment_counters(pg);
-	__online_page_free(pg);
+	generic_online_page(pg, 0);
=20
 	lockdep_assert_held(&dm_device.ha_lock);
 	dm_device.num_pages_onlined++;
--=20
2.21.0


