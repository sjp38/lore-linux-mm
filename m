Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADE60C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 23:32:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F7A421849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 23:32:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="kSM15fI5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F7A421849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A05136B0005; Fri, 19 Jul 2019 19:32:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B6896B0006; Fri, 19 Jul 2019 19:32:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A4CD8E0001; Fri, 19 Jul 2019 19:32:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6976B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 19:32:37 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id e66so18527570ybe.19
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 16:32:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=cBV6E3QUPkSFHVwkOFQ0NgttBSDLgksbh5PnUNNrN0w=;
        b=bLwKvPfGkHbemj5Hr7LHu0F2o6EVZ8fsKNSDNwQ64EZR8IqXtDFYL0OwEaF2cuACD+
         4nMpZZ2ULmDMAfuDcgjoQv4qWphGOFAHwcJL6RQ2FFIOomYMExLvZWB1J01UtHsq5iiJ
         DnkmjD35uSqat2dM8ICdQvHtCCVBsOmdFDs9+1L6BEprzlk0Ytzh2NNYIPpoV1RfN0Cj
         Nj0+gkMv7LKzG6oypFYhvuKKX3ph+rW2aJ6Ts4z3flGUOwp/vjnvj+dRvckUgZ0nl17g
         E/0aQH6zdb3u/iMtABM3fwiH46V9bh9fzD5AEWkPFYBv3mY39yP3f5eZm/sV0obwg7wW
         PANw==
X-Gm-Message-State: APjAAAUuO+bdjvDxhzVlkbBKdkd9wVYIcoKFeU6I3iJf+Jd33AeIErVe
	GgcAX49vsKl7xdAGPRbfUGym41q8kxELvv8gx95hyaOA6EaEP2lSMP6HeeouH5e/q/5RJ9AXK0R
	H/7Ut1iyeUI2FXecTJOu6q0r+9u3VB4ZAb4/zxw7WA7+8PAkpNlhlAVndGWfsZbi6QQ==
X-Received: by 2002:a25:eb04:: with SMTP id d4mr29479684ybs.409.1563579156894;
        Fri, 19 Jul 2019 16:32:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyork4hjr4t6DnzLRRXFcsp9sYhehiQe+PDVowixhBmDhiIhI/7NExpljAvz7oCf7bM96ry
X-Received: by 2002:a25:eb04:: with SMTP id d4mr29479659ybs.409.1563579156216;
        Fri, 19 Jul 2019 16:32:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563579156; cv=none;
        d=google.com; s=arc-20160816;
        b=p+ignwb/mQiDaIsTo7Wocp905iphSXB9bJi5V6WVUvx/iVCSDnH0n2+idMJh97gzCn
         BixK3oRjt0LuybmcITkNEseyRmfR7TS+jLV8asgV4s8ylpOR/PoVdc8Z4+0vnBbPWAvF
         NaWPQCQwCUcO5I5QfLDR+L1Wv2h8hOPhm4LPWD5tW84eOU9zHr3sWBqUT3qtBpBZAmNO
         dmtkFl1DrrbYwy28vsV9ySg08hC55he9UUjtWcvyEJYEK7dv/IGRFOXqit+pvrRpetjI
         MqKPgn+HUxchThhktaV4FfsLuvckGV5FUODtjD6aAHoajpYQcHloyLU6mupFsd0fIG3d
         O6xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=cBV6E3QUPkSFHVwkOFQ0NgttBSDLgksbh5PnUNNrN0w=;
        b=FaPDxbN7e/fsq3ZqBz9Bb0TlvgWO6jlA7qyewaZU0/yfAswGlyXpGSq4axSeVDOBRL
         adn8W6Op8PBTviGX4+sRBFp36MIVSmoKbzV7JUBos6xe3vvcMhIufUN0I5ZYFS4aamKA
         DYKCENHSKnQ5xHgvGokNw1UgK2umgHVsPDfbHoGvFLmSc/5aWtsZevxOAqKO1Ktc4IvG
         lxIiwucIiP8BwT6rqYnjM2N/Xe5C6rbnHnJXPxyfPm1G0HwxvNlHf2iQbyqeUMqP0P1a
         Ny0xy9ppNgKo3pfgHWZ9Uxj2CPafzWJhgg3qebBBU+WBkixWtma4iNqrov0Uwf7IbWfV
         /ltA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kSM15fI5;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id m3si12310382ybp.462.2019.07.19.16.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 16:32:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kSM15fI5;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3253190000>; Fri, 19 Jul 2019 16:32:41 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 16:32:35 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 16:32:35 -0700
Received: from HQMAIL109.nvidia.com (172.20.187.15) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 23:32:34 +0000
Received: from HQMAIL104.nvidia.com (172.18.146.11) by HQMAIL109.nvidia.com
 (172.20.187.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 23:32:34 +0000
Received: from hqnvemgw02.nvidia.com (172.16.227.111) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 19 Jul 2019 23:32:34 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw02.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3253120000>; Fri, 19 Jul 2019 16:32:34 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	<stable@vger.kernel.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH] mm/migrate: initialize pud_entry in migrate_vma()
Date: Fri, 19 Jul 2019 16:32:25 -0700
Message-ID: <20190719233225.12243-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563579161; bh=cBV6E3QUPkSFHVwkOFQ0NgttBSDLgksbh5PnUNNrN0w=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=kSM15fI5BAWSOEp5MwrwxhHFCEKX/TAHdTgJ7Umkm6B4XXIZWumZsK8I6vNXvxlBf
	 mFrioVqQhDUY9lYgLXSEnboJcf1bL/ZoAKjGMjxauf+fSi4rSqbEMXL47cK9CyGGTF
	 g6UlqhfdPh1zpX6I83oWpf4TQZ5ThZp39QFmpxmGe0zDXrvtiRevb+VXkN4GGzgnTj
	 j2UwuGP1+O33GpEIbinCf9pcrWajXQUHszoY1LGP8X93xswc/goUG/PiV0lKQP61j0
	 yyhegnK0/aA1cHamqHHjTT59Bc4wWgAHlHX8HarC1Pa3Ate7T5z0I+3qd3KlqLYSpG
	 ucjUxT5cNsAQw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When CONFIG_MIGRATE_VMA_HELPER is enabled, migrate_vma() calls
migrate_vma_collect() which initializes a struct mm_walk but
didn't initialize mm_walk.pud_entry. (Found by code inspection)
Use a C structure initialization to make sure it is set to NULL.

Fixes: 8763cb45ab967 ("mm/migrate: new memory migration helper for use with
device memory")
Cc: stable@vger.kernel.org
Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/migrate.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 515718392b24..a42858d8e00b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2340,16 +2340,13 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 static void migrate_vma_collect(struct migrate_vma *migrate)
 {
 	struct mmu_notifier_range range;
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
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm_walk.mm,
 				migrate->start,
--=20
2.20.1

