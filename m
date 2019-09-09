Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 668F7C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 279A121A4A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="cSdHPRA/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 279A121A4A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7FBB6B0269; Mon,  9 Sep 2019 14:12:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8E816B026A; Mon,  9 Sep 2019 14:12:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DEEF6B026B; Mon,  9 Sep 2019 14:12:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id 65F6C6B0269
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:40 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BEB61181AC9B4
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:39 +0000 (UTC)
X-FDA: 75916177638.05.ocean11_6e81c20ecd713
X-HE-Tag: ocean11_6e81c20ecd713
X-Filterd-Recvd-Size: 8330
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:39 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id j10so17240283qtp.8
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZHG0D4w8NA29VDHLYB2t8LbjxPlHMjl2c22MdMK04CY=;
        b=cSdHPRA/60dwpAtXYvhf1a+RMMcaKgv6gU4EjBWSJPtMj9S2QBYH0FE6afP+FsFqwX
         oitZfbzciQNQh9f97nfeWBh5L9xdpgVQew2KcwnrrgG56odQNrpZicV1PixyPmKrhxFF
         u7WRQcE11yWWOw46vBjiGO72W0EeBZfHqz0DI8RU1Bg87FZJY9WrRRkmEGUCpTBW6fYZ
         UylCKei3xXj4rdc/yuXtr/rGN65ZL9dnNMVYm61FgIJ0Gw3vBbRHu/jzNssLj2VKBfxU
         Z3ekz6dNhg1yA9bt9NuUJiLDjwfSM7DpS74ENyIHU9U0UfUU902affVWQv3c/9cgQFkI
         lmnA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ZHG0D4w8NA29VDHLYB2t8LbjxPlHMjl2c22MdMK04CY=;
        b=pXAHDh2BaovxMLyeYueBZ/mStYz0a6jj10hxglWdAVJKoNHtYV2WUUxXLEENso1A83
         e2V7OMNci7+VPsjgo2G7Tyg5XMovqpKCTPJN7PjNA90LI+/X8cUYaPd9Hvg1lBvNh+1H
         pABtcsJ3543kh+l1w0TisV5NJnI5nzEkGWJF1XEo7VWG1P6chgqDpflnZ9sU55x1CylA
         HmP++hTDWJGjrLLUTlDSvf3+27Aog+FGjdDYGcs6TqrgsUCp9aQKMpqcHS+haW4HC1Ec
         pB2wdbQV9z8m7QjGtwgzfBZSDQDlSXJBbQWheY9SIQjCQpNr3sk7RKCOIMdB9I3JLFHX
         zv+g==
X-Gm-Message-State: APjAAAWMiRWOD2fV6WDdw/712l/iLjCXJreK87cbK6KIsMvuSuMD0jkR
	4LyrE93k+LRXr/t++42JJBmVrw==
X-Google-Smtp-Source: APXvYqw4No4l7eCxQyc6PhyGalmXf3BDwqCQRB91iT7eD7N2fKHAG7uDuT90z/VyBs2VaIOxC1pelA==
X-Received: by 2002:a05:6214:1591:: with SMTP id m17mr7217259qvw.222.1568052758733;
        Mon, 09 Sep 2019 11:12:38 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:37 -0700 (PDT)
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
Subject: [PATCH v4 10/17] arm64: trans_pgd: make trans_pgd_map_page generic
Date: Mon,  9 Sep 2019 14:12:14 -0400
Message-Id: <20190909181221.309510-11-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190909181221.309510-1-pasha.tatashin@soleen.com>
References: <20190909181221.309510-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kexec is going to use a different allocator, so make
trans_pgd_map_page to accept allocator as an argument, and also
kexec is going to use a different map protection, so also pass
it via argument.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/trans_pgd.h | 24 ++++++++++++++++++++++--
 arch/arm64/kernel/hibernate.c      | 12 +++++++++++-
 arch/arm64/mm/trans_pgd.c          | 17 +++++++++++------
 3 files changed, 44 insertions(+), 9 deletions(-)

diff --git a/arch/arm64/include/asm/trans_pgd.h b/arch/arm64/include/asm/=
trans_pgd.h
index c7b5402b7d87..53f67ec84cdc 100644
--- a/arch/arm64/include/asm/trans_pgd.h
+++ b/arch/arm64/include/asm/trans_pgd.h
@@ -11,10 +11,30 @@
 #include <linux/bits.h>
 #include <asm/pgtable-types.h>
=20
+/*
+ * trans_alloc_page
+ *	- Allocator that should return exactly one zeroed page, if this
+ *	 allocator fails, trans_pgd returns -ENOMEM error.
+ *
+ * trans_alloc_arg
+ *	- Passed to trans_alloc_page as an argument
+ */
+
+struct trans_pgd_info {
+	void * (*trans_alloc_page)(void *arg);
+	void *trans_alloc_arg;
+};
+
 int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
 			  unsigned long end);
=20
-int trans_pgd_map_page(pgd_t *trans_pgd, void *page, unsigned long dst_a=
ddr,
-		       pgprot_t pgprot);
+/*
+ * Add map entry to trans_pgd for a base-size page at PTE level.
+ * page:	page to be mapped.
+ * dst_addr:	new VA address for the pages
+ * pgprot:	protection for the page.
+ */
+int trans_pgd_map_page(struct trans_pgd_info *info, pgd_t *trans_pgd,
+		       void *page, unsigned long dst_addr, pgprot_t pgprot);
=20
 #endif /* _ASM_TRANS_TABLE_H */
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 94ede33bd777..9b75b680ab70 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -179,6 +179,12 @@ int arch_hibernation_header_restore(void *addr)
 }
 EXPORT_SYMBOL(arch_hibernation_header_restore);
=20
+static void *
+hibernate_page_alloc(void *arg)
+{
+	return (void *)get_safe_page((gfp_t)(unsigned long)arg);
+}
+
 /*
  * Copies length bytes, starting at src_start into an new page,
  * perform cache maintenance, then maps it at the specified address low
@@ -195,6 +201,10 @@ static int create_safe_exec_page(void *src_start, si=
ze_t length,
 				 unsigned long dst_addr,
 				 phys_addr_t *phys_dst_addr)
 {
+	struct trans_pgd_info trans_info =3D {
+		.trans_alloc_page	=3D hibernate_page_alloc,
+		.trans_alloc_arg	=3D (void *)GFP_ATOMIC,
+	};
 	void *page =3D (void *)get_safe_page(GFP_ATOMIC);
 	pgd_t *trans_pgd;
 	int rc;
@@ -209,7 +219,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	if (!trans_pgd)
 		return -ENOMEM;
=20
-	rc =3D trans_pgd_map_page(trans_pgd, page, dst_addr,
+	rc =3D trans_pgd_map_page(&trans_info, trans_pgd, page, dst_addr,
 				PAGE_KERNEL_EXEC);
 	if (rc)
 		return rc;
diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
index 5ac712b92439..7521d558a0b9 100644
--- a/arch/arm64/mm/trans_pgd.c
+++ b/arch/arm64/mm/trans_pgd.c
@@ -25,6 +25,11 @@
 #include <linux/mm.h>
 #include <linux/mmzone.h>
=20
+static void *trans_alloc(struct trans_pgd_info *info)
+{
+	return info->trans_alloc_page(info->trans_alloc_arg);
+}
+
 static void _copy_pte(pte_t *dst_ptep, pte_t *src_ptep, unsigned long ad=
dr)
 {
 	pte_t pte =3D READ_ONCE(*src_ptep);
@@ -180,8 +185,8 @@ int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned =
long start,
 	return rc;
 }
=20
-int trans_pgd_map_page(pgd_t *trans_pgd, void *page, unsigned long dst_a=
ddr,
-		       pgprot_t pgprot)
+int trans_pgd_map_page(struct trans_pgd_info *info, pgd_t *trans_pgd,
+		       void *page, unsigned long dst_addr, pgprot_t pgprot)
 {
 	pgd_t *pgdp;
 	pud_t *pudp;
@@ -190,7 +195,7 @@ int trans_pgd_map_page(pgd_t *trans_pgd, void *page, =
unsigned long dst_addr,
=20
 	pgdp =3D pgd_offset_raw(trans_pgd, dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
-		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
+		pudp =3D trans_alloc(info);
 		if (!pudp)
 			return -ENOMEM;
 		pgd_populate(&init_mm, pgdp, pudp);
@@ -198,7 +203,7 @@ int trans_pgd_map_page(pgd_t *trans_pgd, void *page, =
unsigned long dst_addr,
=20
 	pudp =3D pud_offset(pgdp, dst_addr);
 	if (pud_none(READ_ONCE(*pudp))) {
-		pmdp =3D (void *)get_safe_page(GFP_ATOMIC);
+		pmdp =3D trans_alloc(info);
 		if (!pmdp)
 			return -ENOMEM;
 		pud_populate(&init_mm, pudp, pmdp);
@@ -206,14 +211,14 @@ int trans_pgd_map_page(pgd_t *trans_pgd, void *page=
, unsigned long dst_addr,
=20
 	pmdp =3D pmd_offset(pudp, dst_addr);
 	if (pmd_none(READ_ONCE(*pmdp))) {
-		ptep =3D (void *)get_safe_page(GFP_ATOMIC);
+		ptep =3D trans_alloc(info);
 		if (!ptep)
 			return -ENOMEM;
 		pmd_populate_kernel(&init_mm, pmdp, ptep);
 	}
=20
 	ptep =3D pte_offset_kernel(pmdp, dst_addr);
-	set_pte(ptep, pfn_pte(virt_to_pfn(page), PAGE_KERNEL_EXEC));
+	set_pte(ptep, pfn_pte(virt_to_pfn(page), pgprot));
=20
 	return 0;
 }
--=20
2.23.0


