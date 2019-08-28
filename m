Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE700C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:42:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A155C2077B
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:42:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C5yshFhd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A155C2077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 505736B0006; Wed, 28 Aug 2019 10:42:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B6766B000E; Wed, 28 Aug 2019 10:42:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CC626B0010; Wed, 28 Aug 2019 10:42:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0019.hostedemail.com [216.40.44.19])
	by kanga.kvack.org (Postfix) with ESMTP id 216146B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:42:51 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C70E69067
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:42:50 +0000 (UTC)
X-FDA: 75872103300.02.cloth16_35e3a69c8af40
X-HE-Tag: cloth16_35e3a69c8af40
X-Filterd-Recvd-Size: 3209
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:42:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=5miFGnPe5RpYDj/Z2zM+wDYPkBcELi5PHsN67JsLU40=; b=C5yshFhd1Yq+LUhUehHTilZS9
	fohwe25pSav/nTwz0sWetQQmwfprwB6OJiI3jJBHDWa24moS92VxURWQTl/IXHhW6stQLhuYQEVll
	MGZQ/OzubmdslO+P9OPuKM80uT8E5vybX0h8FYEr/ZKyWiiSA1oKZVm5Z3iUjdl2nVQQIPJHnaXtw
	A/OWQMr4tCIN68mb5fGaoJXabRa2Dbnx5DXilcVXgRDQJ61va5rtytMG08fBKRL5jQG9rwxF549LZ
	NftVRvTAyJUNWn31zbMcBAFvW59/hEqEmowPpeDS0U8cWpCxV7iZ9p7au8X9D0BzJ+dxLZTBVdVTW
	pqjEHc3ew==;
Received: from [2001:4bb8:180:3f4c:863:2ead:e9d4:da9f] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i2yox-0005Z0-Bu; Wed, 28 Aug 2019 14:21:11 +0000
From: Christoph Hellwig <hch@lst.de>
To: jgg@mellanox.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	daniel@ffwll.ch
Subject: [PATCH] mm: remove the __mmu_notifier_invalidate_range_start/end exports
Date: Wed, 28 Aug 2019 16:21:09 +0200
Message-Id: <20190828142109.29012-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Bo modular code uses these, which makes a lot of sense given the
wrappers around them are only called by core mm code.

Also remove the recently added __mmu_notifier_invalidate_range_start_map
export for which the same applies.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/mmu_notifier.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 690f1ea639d5..240f4e14d42e 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -25,7 +25,6 @@ DEFINE_STATIC_SRCU(srcu);
 struct lockdep_map __mmu_notifier_invalidate_range_start_map =3D {
 	.name =3D "mmu_notifier_invalidate_range_start"
 };
-EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start_map);
 #endif
=20
 /*
@@ -184,7 +183,6 @@ int __mmu_notifier_invalidate_range_start(struct mmu_=
notifier_range *range)
=20
 	return ret;
 }
-EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
=20
 void __mmu_notifier_invalidate_range_end(struct mmu_notifier_range *rang=
e,
 					 bool only_end)
@@ -218,7 +216,6 @@ void __mmu_notifier_invalidate_range_end(struct mmu_n=
otifier_range *range,
 	srcu_read_unlock(&srcu, id);
 	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
 }
-EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
=20
 void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
--=20
2.20.1


