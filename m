Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C8FFC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:07:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B485206A2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:07:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B485206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAB6D6B0006; Mon, 12 Aug 2019 12:07:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4DE26B0008; Mon, 12 Aug 2019 12:07:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46CF6B000A; Mon, 12 Aug 2019 12:07:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8726B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:07:18 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 320FB45D8
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:07:18 +0000 (UTC)
X-FDA: 75814255356.07.coast70_56ce341ef341
X-HE-Tag: coast70_56ce341ef341
X-Filterd-Recvd-Size: 3577
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:07:17 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2D24F1715;
	Mon, 12 Aug 2019 09:06:48 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 29A6B3F718;
	Mon, 12 Aug 2019 09:06:47 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v3 1/3] mm: kmemleak: Make the tool tolerant to struct scan_area allocation failures
Date: Mon, 12 Aug 2019 17:06:40 +0100
Message-Id: <20190812160642.52134-2-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
In-Reply-To: <20190812160642.52134-1-catalin.marinas@arm.com>
References: <20190812160642.52134-1-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Object scan areas are an optimisation aimed to decrease the false
positives and slightly improve the scanning time of large objects known
to only have a few specific pointers. If a struct scan_area fails to
allocate, kmemleak can still function normally by scanning the full
object.

Introduce an OBJECT_FULL_SCAN flag and mark objects as such when
scan_area allocation fails.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/kmemleak.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f6e602918dac..5ba7fad00fda 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -168,6 +168,8 @@ struct kmemleak_object {
 #define OBJECT_REPORTED		(1 << 1)
 /* flag set to not scan the object */
 #define OBJECT_NO_SCAN		(1 << 2)
+/* flag set to fully scan the object when scan_area allocation failed */
+#define OBJECT_FULL_SCAN	(1 << 3)
=20
 #define HEX_PREFIX		"    "
 /* number of bytes to print per line; must be 16 or 32 */
@@ -773,12 +775,14 @@ static void add_scan_area(unsigned long ptr, size_t=
 size, gfp_t gfp)
 	}
=20
 	area =3D kmem_cache_alloc(scan_area_cache, gfp_kmemleak_mask(gfp));
-	if (!area) {
-		pr_warn("Cannot allocate a scan area\n");
-		goto out;
-	}
=20
 	spin_lock_irqsave(&object->lock, flags);
+	if (!area) {
+		pr_warn_once("Cannot allocate a scan area, scanning the full object\n"=
);
+		/* mark the object for full scan to avoid false positives */
+		object->flags |=3D OBJECT_FULL_SCAN;
+		goto out_unlock;
+	}
 	if (size =3D=3D SIZE_MAX) {
 		size =3D object->pointer + object->size - ptr;
 	} else if (ptr + size > object->pointer + object->size) {
@@ -795,7 +799,6 @@ static void add_scan_area(unsigned long ptr, size_t s=
ize, gfp_t gfp)
 	hlist_add_head(&area->node, &object->area_list);
 out_unlock:
 	spin_unlock_irqrestore(&object->lock, flags);
-out:
 	put_object(object);
 }
=20
@@ -1408,7 +1411,8 @@ static void scan_object(struct kmemleak_object *obj=
ect)
 	if (!(object->flags & OBJECT_ALLOCATED))
 		/* already freed object */
 		goto out;
-	if (hlist_empty(&object->area_list)) {
+	if (hlist_empty(&object->area_list) ||
+	    object->flags & OBJECT_FULL_SCAN) {
 		void *start =3D (void *)object->pointer;
 		void *end =3D (void *)(object->pointer + object->size);
 		void *next;

