Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 825EEC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 451E9216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="ILjJA4n/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 451E9216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44DAD6B0266; Wed, 21 Aug 2019 14:32:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3366E6B0269; Wed, 21 Aug 2019 14:32:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1620B6B026A; Wed, 21 Aug 2019 14:32:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0094.hostedemail.com [216.40.44.94])
	by kanga.kvack.org (Postfix) with ESMTP id D9BF76B0266
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:13 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8BB72181AC9D3
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:13 +0000 (UTC)
X-FDA: 75847279746.24.mine91_3064062bfd91c
X-HE-Tag: mine91_3064062bfd91c
X-Filterd-Recvd-Size: 5463
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:12 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id g17so2707230qkk.8
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bQvsgscqpy4gJx0RSAZHmPdNixt0ATCDS0WU9XTwyb8=;
        b=ILjJA4n/giE8JmPiexv7Bw1nwvbRl2Z+YSLoE4FuqVk0Cy9Y8l0Z/Oi043el4txkPI
         biHES+QyYLZFcNUoZPuckwwgZ/ZXoRyQ8rxMSMLPx468ECFak95S7bHRA5hE7sgYwLo1
         ERLOIgzIGS0X8aQ1hin4TNUKMPvt4jZ8F71XOY2yF9JNx+98bKfh5WdXq2GAL7Nq6Uo3
         KfLn8Kp0O5dqjYZeCaQSMuaUmJE3xMJ+Hjjv8je7GShbQFFNY8YKqG+42V9uOpm21DqX
         2cavH9DsopJFxHmz518GX7AOejraE2dw00Ly+gcqnjNxEU861osit10n9wkODkePQq2J
         VOJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=bQvsgscqpy4gJx0RSAZHmPdNixt0ATCDS0WU9XTwyb8=;
        b=QULp9cMyctyWoMtBcizJsTx9kogvMrEa1zS1I4R2qDNhAoU/K+2JxU1Qiyox3UN/+D
         CVYSAqXXf/kg+7oTxHbIDDhEGYouq4tGM+mcGdX4L7jqITgOu5crIqAxxwzDyBe/pArS
         SSsSN2PMsFgxgvRY5WbWgDhYGSBMMXysS1Ys2NqziEWlV742hZDotpXETSluW/MfeLzb
         y2p4KTjdM5mrBueg++ntykpfQxcP+M+jQGWaRr6NA7Wz/B9cny0DmScbecI6UN4+R9lJ
         ttOLZN29XgnPmxj0FCE++JkP1LmBy6dipho3CKFxCeYtQxQIsVpeAP1XT7YfH098nplG
         UEGA==
X-Gm-Message-State: APjAAAUxyFMnuY0NBFa/xohlgafiDcEsc9EPyze0REQax/z4igK9FFF4
	ydlbA0fn8gBAaENbyHKl7no3CQ==
X-Google-Smtp-Source: APXvYqzfJ8BXdrEH0K8CKkw4fBwWFDafodl10SDkUCPN4bBIEhI2MWQI353Halx8ux+skSlbJLzXYQ==
X-Received: by 2002:ae9:ec1a:: with SMTP id h26mr17120619qkg.80.1566412331857;
        Wed, 21 Aug 2019 11:32:11 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:11 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v3 04/17] arm64, hibernate: rename dst to page in create_safe_exec_page
Date: Wed, 21 Aug 2019 14:31:51 -0400
Message-Id: <20190821183204.23576-5-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190821183204.23576-1-pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

create_safe_exec_page() allocates a safe page and maps it at a
specific location, also this function returns the physical address
of newly allocated page.

The destination VA, and PA are specified in arguments: dst_addr,
phys_dst_addr

However, within the function it uses "dst" which has unsigned long
type, but is actually a pointers in the current virtual space. This
is confusing to read.

Rename dst to more appropriate page (page that is created), and also
change its time to "void *"

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/kernel/hibernate.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index c8211108ec11..ee34a06d8a35 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -198,17 +198,17 @@ static int create_safe_exec_page(void *src_start, s=
ize_t length,
 				 unsigned long dst_addr,
 				 phys_addr_t *phys_dst_addr)
 {
+	void *page =3D (void *)get_safe_page(GFP_ATOMIC);
 	pgd_t *pgdp;
 	pud_t *pudp;
 	pmd_t *pmdp;
 	pte_t *ptep;
-	unsigned long dst =3D get_safe_page(GFP_ATOMIC);
=20
-	if (!dst)
+	if (!page)
 		return -ENOMEM;
=20
-	memcpy((void *)dst, src_start, length);
-	__flush_icache_range(dst, dst + length);
+	memcpy(page, src_start, length);
+	__flush_icache_range((unsigned long)page, (unsigned long)page + length)=
;
=20
 	pgdp =3D pgd_offset_raw((void *)get_safe_page(GFP_ATOMIC), dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
@@ -235,7 +235,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	}
=20
 	ptep =3D pte_offset_kernel(pmdp, dst_addr);
-	set_pte(ptep, pfn_pte(virt_to_pfn(dst), PAGE_KERNEL_EXEC));
+	set_pte(ptep, pfn_pte(virt_to_pfn(page), PAGE_KERNEL_EXEC));
=20
 	/*
 	 * Load our new page tables. A strict BBM approach requires that we
@@ -254,7 +254,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	write_sysreg(phys_to_ttbr(virt_to_phys(pgdp)), ttbr0_el1);
 	isb();
=20
-	*phys_dst_addr =3D virt_to_phys((void *)dst);
+	*phys_dst_addr =3D virt_to_phys(page);
=20
 	return 0;
 }
--=20
2.23.0


