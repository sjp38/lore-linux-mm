Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E368C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49BB52341B
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:20:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OkB8WmnO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49BB52341B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95C426B0010; Wed, 28 Aug 2019 10:20:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90D746B0266; Wed, 28 Aug 2019 10:20:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84D106B0269; Wed, 28 Aug 2019 10:20:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0126.hostedemail.com [216.40.44.126])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1EA6B0010
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:20:12 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1637F8138
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:20:12 +0000 (UTC)
X-FDA: 75872046264.05.books24_1b3e40a3d618
X-HE-Tag: books24_1b3e40a3d618
X-Filterd-Recvd-Size: 3193
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:20:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=zl4G8WtuziQvLKFqDgMdC9UCvqeacC6em8tdHCZigf0=; b=OkB8WmnON97oS6Y/JoC0YQ4U0E
	IslxnmG7+sUaZwQg4Yi1yE68jOJc8TkEnEfgn7GdDAYmzNN+0GVCubBhKmjjcDXg/H32Nz8ZDKaTb
	19DGkJh2XSDQ48/p5CJFqPFr7krGLZvjpZ460jfdJ+r61yH2Ng3CZyvliJ4Bawc4gKd/RwGomc08I
	nHnqQ6SuMzevS/QTCFkiztqG2QNar+ZUvWNRYmSNrFc+gKZbX0qQ2TUR0qQ3pnnXA4CJ2OTC0S4Ql
	nns156DI7AWQKjg5dAKWdppB4FbZNora49ZcfbYVr4aq4Uc1PccDeBxlA7zrI3veBTAk5a0neMhrV
	h2OQOU2A==;
Received: from [2001:4bb8:180:3f4c:863:2ead:e9d4:da9f] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i2ynu-0004SO-I3; Wed, 28 Aug 2019 14:20:06 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?Thomas=20Hellstr=C3=B6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Thomas Hellstrom <thellstrom@vmware.com>
Subject: [PATCH 3/3] pagewalk: use lockdep_assert_held for locking validation
Date: Wed, 28 Aug 2019 16:19:55 +0200
Message-Id: <20190828141955.22210-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190828141955.22210-1-hch@lst.de>
References: <20190828141955.22210-1-hch@lst.de>
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use lockdep to check for held locks instead of using home grown
asserts.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Steven Price <steven.price@arm.com>
---
 mm/pagewalk.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index b8762b673a3d..d48c2a986ea3 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -317,7 +317,7 @@ int walk_page_range(struct mm_struct *mm, unsigned lo=
ng start,
 	if (!walk.mm)
 		return -EINVAL;
=20
-	VM_BUG_ON_MM(!rwsem_is_locked(&walk.mm->mmap_sem), walk.mm);
+	lockdep_assert_held(&walk.mm->mmap_sem);
=20
 	vma =3D find_vma(walk.mm, start);
 	do {
@@ -367,7 +367,7 @@ int walk_page_vma(struct vm_area_struct *vma, const s=
truct mm_walk_ops *ops,
 	if (!walk.mm)
 		return -EINVAL;
=20
-	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+	lockdep_assert_held(&walk.mm->mmap_sem);
=20
 	err =3D walk_page_test(vma->vm_start, vma->vm_end, &walk);
 	if (err > 0)
--=20
2.20.1


