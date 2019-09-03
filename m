Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D63FBC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:32:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AA7E238D1
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:32:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="slfWfLXH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AA7E238D1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37F256B0003; Tue,  3 Sep 2019 12:32:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 356D96B0005; Tue,  3 Sep 2019 12:32:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26D986B0006; Tue,  3 Sep 2019 12:32:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0161.hostedemail.com [216.40.44.161])
	by kanga.kvack.org (Postfix) with ESMTP id 0783A6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:32:03 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8FD67824CA24
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:32:03 +0000 (UTC)
X-FDA: 75894151326.16.flag72_2f04839e28a01
X-HE-Tag: flag72_2f04839e28a01
X-Filterd-Recvd-Size: 3736
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:32:02 +0000 (UTC)
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E833E2343A;
	Tue,  3 Sep 2019 16:32:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567528321;
	bh=RnF9yfW2THGGX/asy4zb05YAO7hpaGDMbNjZA2wFmEo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=slfWfLXHZZVAmSNcnTPW8w/eTMbUaneu1iVM1F1tTR02J4ghbItk4vuuyIffcsi2Y
	 bup8wZR8FY3tnOpFNVAc9KnlGLt63ZEL1gM7j8gz+ZeVT8jdKm0Uoh6zjRGCLccwNO
	 dEaISpfIPpFMMtlDnFj8D8n5g6650UQE0qIJj6+U=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 154/167] mm/migrate.c: initialize pud_entry in migrate_vma()
Date: Tue,  3 Sep 2019 12:25:06 -0400
Message-Id: <20190903162519.7136-154-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190903162519.7136-1-sashal@kernel.org>
References: <20190903162519.7136-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

[ Upstream commit 7b358c6f12dc82364f6d317f8c8f1d794adbc3f5 ]

When CONFIG_MIGRATE_VMA_HELPER is enabled, migrate_vma() calls
migrate_vma_collect() which initializes a struct mm_walk but didn't
initialize mm_walk.pud_entry.  (Found by code inspection) Use a C
structure initialization to make sure it is set to NULL.

Link: http://lkml.kernel.org/r/20190719233225.12243-1-rcampbell@nvidia.co=
m
Fixes: 8763cb45ab967 ("mm/migrate: new memory migration helper for use wi=
th device memory")
Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/migrate.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index b2ea7d1e6f248..0c48191a90368 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2328,16 +2328,13 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
  */
 static void migrate_vma_collect(struct migrate_vma *migrate)
 {
-	struct mm_walk mm_walk;
-
-	mm_walk.pmd_entry =3D migrate_vma_collect_pmd;
-	mm_walk.pte_entry =3D NULL;
-	mm_walk.pte_hole =3D migrate_vma_collect_hole;
-	mm_walk.hugetlb_entry =3D NULL;
-	mm_walk.test_walk =3D NULL;
-	mm_walk.vma =3D migrate->vma;
-	mm_walk.mm =3D migrate->vma->vm_mm;
-	mm_walk.private =3D migrate;
+	struct mm_walk mm_walk =3D {
+		.pmd_entry =3D migrate_vma_collect_pmd,
+		.pte_hole =3D migrate_vma_collect_hole,
+		.vma =3D migrate->vma,
+		.mm =3D migrate->vma->vm_mm,
+		.private =3D migrate,
+	};
=20
 	mmu_notifier_invalidate_range_start(mm_walk.mm,
 					    migrate->start,
--=20
2.20.1


