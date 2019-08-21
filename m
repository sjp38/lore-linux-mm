Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91D18C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3952B216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="S8Ph5X/i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3952B216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38A996B0275; Wed, 21 Aug 2019 14:32:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24D9A6B0276; Wed, 21 Aug 2019 14:32:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07B3D6B0277; Wed, 21 Aug 2019 14:32:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0069.hostedemail.com [216.40.44.69])
	by kanga.kvack.org (Postfix) with ESMTP id D12C56B0275
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:24 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 98A2E180AD80C
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:24 +0000 (UTC)
X-FDA: 75847280208.26.grain84_3214741ad3a23
X-HE-Tag: grain84_3214741ad3a23
X-Filterd-Recvd-Size: 11385
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:24 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id w18so2749127qki.0
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ksR9xp0U0gVZu5yAF7PYymq+gEdUwe+c7E47Th0fsxc=;
        b=S8Ph5X/in9QeZhKZShUNmP6k2QaJ3hKTjre5+EqRcapJytZCXaoEmP+cy1RR5PYlit
         YFnL4BLZNfVWIa9f1YBiGO+PWTknBsAGdcCVWhTHsqDQmGjMqshd9FSL0uzIhgCepTul
         0ac8HqtZwfN7Gknx1VizkXQ/xAccS2nub9T1gfXD+8/iprt1BG+soJ3rJZXnJVEC4mTh
         v/v8bjI7kgQVR0HdVN+1yWJpCegksG4qyYp4ZYMZzStsiRcS0kkxgDrdqcJm1oyneD6u
         iC9HQmGHKzLBr1tLUXIK7NVSL4CYro/qpoDA9s4BaXZjCA2D1I88Gcrhvw4JQdbwh6w0
         YsuQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ksR9xp0U0gVZu5yAF7PYymq+gEdUwe+c7E47Th0fsxc=;
        b=ZId45uHUxNouFDBpg229tTKeFSgtmBNDwzLKiFO3bCk3gQvjaJw6WDOSqa9LKKRdIP
         O5aaBH5vqHrEbLGqwnYHM7qDgXLINzzzsf25vFmL4yq/gaIZgdOM3B3VBob9NIV/QUxF
         qssyXXOSsomouoP0suTNhCjSg7cDyMuhlTtAg9FJBoPDi5F5K2epqLcNrij8AckkKw/q
         Kl6CDDYgevg6SmQDwMjHapAv86gjGsMklH+xDG8cj+gOTELOffjwoTSmaOgL1K4zmdaA
         8n4jZCmoCSUHdPBAOIRKfUgpGCh93pbVvWhRyx8nzsuaKzSa/2W9rFJUtpEPown0w26d
         QnGg==
X-Gm-Message-State: APjAAAWoa9uYNcHAym+ncaUKqYLjzF1nh/sHBIdyf0Stmfgj7c+6tZmc
	/neZlBEkHB0x3uYqjd5bh30ihw==
X-Google-Smtp-Source: APXvYqwmiZKW750IQ6F3/v/nNdiOXrrwA8yH3qVIWUdWB0CRR7pVV1emTiriHCZzhOC5wTx53UWEuA==
X-Received: by 2002:a37:b4c4:: with SMTP id d187mr31068784qkf.459.1566412343453;
        Wed, 21 Aug 2019 11:32:23 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:22 -0700 (PDT)
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
Subject: [PATCH v3 12/17] arm64, trans_pgd: complete generalization of trans_pgds
Date: Wed, 21 Aug 2019 14:31:59 -0400
Message-Id: <20190821183204.23576-13-pasha.tatashin@soleen.com>
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

Make the last private functions in page table copy path generlized for us=
e
outside of hibernate.

Switch to use the provided allocator, flags, and source page table. Also,
unify all copy function implementations to reduce the possibility of bugs=
.
All page table levels are implemented symmetrically.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/mm/trans_pgd.c | 200 +++++++++++++++++++++-----------------
 1 file changed, 109 insertions(+), 91 deletions(-)

diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
index efd42509d069..ccd9900f8edb 100644
--- a/arch/arm64/mm/trans_pgd.c
+++ b/arch/arm64/mm/trans_pgd.c
@@ -27,139 +27,157 @@ static void *trans_alloc(struct trans_pgd_info *inf=
o)
 	return page;
 }
=20
-static void _copy_pte(pte_t *dst_ptep, pte_t *src_ptep, unsigned long ad=
dr)
+static int copy_pte(struct trans_pgd_info *info, pte_t *dst_ptep,
+		    pte_t *src_ptep, unsigned long start, unsigned long end)
 {
-	pte_t pte =3D READ_ONCE(*src_ptep);
-
-	if (pte_valid(pte)) {
-		/*
-		 * Resume will overwrite areas that may be marked
-		 * read only (code, rodata). Clear the RDONLY bit from
-		 * the temporary mappings we use during restore.
-		 */
-		set_pte(dst_ptep, pte_mkwrite(pte));
-	} else if (debug_pagealloc_enabled() && !pte_none(pte)) {
-		/*
-		 * debug_pagealloc will removed the PTE_VALID bit if
-		 * the page isn't in use by the resume kernel. It may have
-		 * been in use by the original kernel, in which case we need
-		 * to put it back in our copy to do the restore.
-		 *
-		 * Before marking this entry valid, check the pfn should
-		 * be mapped.
-		 */
-		BUG_ON(!pfn_valid(pte_pfn(pte)));
-
-		set_pte(dst_ptep, pte_mkpresent(pte_mkwrite(pte)));
-	}
-}
-
-static int copy_pte(pmd_t *dst_pmdp, pmd_t *src_pmdp, unsigned long star=
t,
-		    unsigned long end)
-{
-	pte_t *src_ptep;
-	pte_t *dst_ptep;
 	unsigned long addr =3D start;
+	int i =3D pte_index(addr);
=20
-	dst_ptep =3D (pte_t *)get_safe_page(GFP_ATOMIC);
-	if (!dst_ptep)
-		return -ENOMEM;
-	pmd_populate_kernel(&init_mm, dst_pmdp, dst_ptep);
-	dst_ptep =3D pte_offset_kernel(dst_pmdp, start);
-
-	src_ptep =3D pte_offset_kernel(src_pmdp, start);
 	do {
-		_copy_pte(dst_ptep, src_ptep, addr);
-	} while (dst_ptep++, src_ptep++, addr +=3D PAGE_SIZE, addr !=3D end);
+		pte_t src_pte =3D READ_ONCE(src_ptep[i]);
+
+		if (pte_none(src_pte))
+			continue;
+		if (info->trans_flags & TRANS_MKWRITE)
+			src_pte =3D pte_mkwrite(src_pte);
+		if (info->trans_flags & TRANS_MKVALID)
+			src_pte =3D pte_mkpresent(src_pte);
+		if (info->trans_flags & TRANS_CHECKPFN) {
+			if (!pfn_valid(pte_pfn(src_pte)))
+				return -ENXIO;
+		}
+		set_pte(&dst_ptep[i], src_pte);
+	} while (addr +=3D PAGE_SIZE, i++, addr !=3D end && i < PTRS_PER_PTE);
=20
 	return 0;
 }
=20
-static int copy_pmd(pud_t *dst_pudp, pud_t *src_pudp, unsigned long star=
t,
-		    unsigned long end)
+static int copy_pmd(struct trans_pgd_info *info, pmd_t *dst_pmdp,
+		    pmd_t *src_pmdp, unsigned long start, unsigned long end)
 {
-	pmd_t *src_pmdp;
-	pmd_t *dst_pmdp;
 	unsigned long next;
 	unsigned long addr =3D start;
+	int i =3D pmd_index(addr);
+	int rc;
=20
-	if (pud_none(READ_ONCE(*dst_pudp))) {
-		dst_pmdp =3D (pmd_t *)get_safe_page(GFP_ATOMIC);
-		if (!dst_pmdp)
-			return -ENOMEM;
-		pud_populate(&init_mm, dst_pudp, dst_pmdp);
-	}
-	dst_pmdp =3D pmd_offset(dst_pudp, start);
-
-	src_pmdp =3D pmd_offset(src_pudp, start);
 	do {
-		pmd_t pmd =3D READ_ONCE(*src_pmdp);
+		pmd_t src_pmd =3D READ_ONCE(src_pmdp[i]);
+		pmd_t dst_pmd =3D READ_ONCE(dst_pmdp[i]);
+		pte_t *dst_ptep, *src_ptep;
=20
 		next =3D pmd_addr_end(addr, end);
-		if (pmd_none(pmd))
+		if (pmd_none(src_pmd))
+			continue;
+
+		if (!pmd_table(src_pmd)) {
+			if (info->trans_flags & TRANS_MKWRITE)
+				pmd_val(src_pmd) &=3D ~PMD_SECT_RDONLY;
+			set_pmd(&dst_pmdp[i], src_pmd);
 			continue;
-		if (pmd_table(pmd)) {
-			if (copy_pte(dst_pmdp, src_pmdp, addr, next))
+		}
+
+		if (pmd_none(dst_pmd)) {
+			pte_t *t =3D trans_alloc(info);
+
+			if (!t)
 				return -ENOMEM;
-		} else {
-			set_pmd(dst_pmdp,
-				__pmd(pmd_val(pmd) & ~PMD_SECT_RDONLY));
+
+			__pmd_populate(&dst_pmdp[i], __pa(t), PTE_TYPE_PAGE);
+			dst_pmd =3D READ_ONCE(dst_pmdp[i]);
 		}
-	} while (dst_pmdp++, src_pmdp++, addr =3D next, addr !=3D end);
+
+		src_ptep =3D __va(pmd_page_paddr(src_pmd));
+		dst_ptep =3D __va(pmd_page_paddr(dst_pmd));
+
+		rc =3D copy_pte(info, dst_ptep, src_ptep, addr, next);
+		if (rc)
+			return rc;
+	} while (addr =3D next, i++, addr !=3D end && i < PTRS_PER_PMD);
=20
 	return 0;
 }
=20
-static int copy_pud(pgd_t *dst_pgdp, pgd_t *src_pgdp, unsigned long star=
t,
-		    unsigned long end)
+static int copy_pud(struct trans_pgd_info *info, pud_t *dst_pudp,
+		    pud_t *src_pudp, unsigned long start, unsigned long end)
 {
-	pud_t *dst_pudp;
-	pud_t *src_pudp;
 	unsigned long next;
 	unsigned long addr =3D start;
+	int i =3D pud_index(addr);
+	int rc;
=20
-	if (pgd_none(READ_ONCE(*dst_pgdp))) {
-		dst_pudp =3D (pud_t *)get_safe_page(GFP_ATOMIC);
-		if (!dst_pudp)
-			return -ENOMEM;
-		pgd_populate(&init_mm, dst_pgdp, dst_pudp);
-	}
-	dst_pudp =3D pud_offset(dst_pgdp, start);
-
-	src_pudp =3D pud_offset(src_pgdp, start);
 	do {
-		pud_t pud =3D READ_ONCE(*src_pudp);
+		pud_t src_pud =3D READ_ONCE(src_pudp[i]);
+		pud_t dst_pud =3D READ_ONCE(dst_pudp[i]);
+		pmd_t *dst_pmdp, *src_pmdp;
=20
 		next =3D pud_addr_end(addr, end);
-		if (pud_none(pud))
+		if (pud_none(src_pud))
 			continue;
-		if (pud_table(pud)) {
-			if (copy_pmd(dst_pudp, src_pudp, addr, next))
+
+		if (!pud_table(src_pud)) {
+			if (info->trans_flags & TRANS_MKWRITE)
+				pud_val(src_pud) &=3D ~PUD_SECT_RDONLY;
+			set_pud(&dst_pudp[i], src_pud);
+			continue;
+		}
+
+		if (pud_none(dst_pud)) {
+			pmd_t *t =3D trans_alloc(info);
+
+			if (!t)
 				return -ENOMEM;
-		} else {
-			set_pud(dst_pudp,
-				__pud(pud_val(pud) & ~PUD_SECT_RDONLY));
+
+			__pud_populate(&dst_pudp[i], __pa(t), PMD_TYPE_TABLE);
+			dst_pud =3D READ_ONCE(dst_pudp[i]);
 		}
-	} while (dst_pudp++, src_pudp++, addr =3D next, addr !=3D end);
+
+		src_pmdp =3D __va(pud_page_paddr(src_pud));
+		dst_pmdp =3D __va(pud_page_paddr(dst_pud));
+
+		rc =3D copy_pmd(info, dst_pmdp, src_pmdp, addr, next);
+		if (rc)
+			return rc;
+	} while (addr =3D next, i++, addr !=3D end && i < PTRS_PER_PUD);
=20
 	return 0;
 }
=20
-static int copy_page_tables(pgd_t *dst_pgdp, unsigned long start,
-			    unsigned long end)
+static int copy_pgd(struct trans_pgd_info *info, pgd_t *dst_pgdp,
+		    pgd_t *src_pgdp, unsigned long start, unsigned long end)
 {
 	unsigned long next;
 	unsigned long addr =3D start;
-	pgd_t *src_pgdp =3D pgd_offset_k(start);
+	int i =3D pgd_index(addr);
+	int rc;
=20
-	dst_pgdp =3D pgd_offset_raw(dst_pgdp, start);
 	do {
+		pgd_t src_pgd;
+		pgd_t dst_pgd;
+		pud_t *dst_pudp, *src_pudp;
+
+		src_pgd =3D READ_ONCE(src_pgdp[i]);
+		dst_pgd =3D READ_ONCE(dst_pgdp[i]);
 		next =3D pgd_addr_end(addr, end);
-		if (pgd_none(READ_ONCE(*src_pgdp)))
+		if (pgd_none(src_pgd))
 			continue;
-		if (copy_pud(dst_pgdp, src_pgdp, addr, next))
-			return -ENOMEM;
-	} while (dst_pgdp++, src_pgdp++, addr =3D next, addr !=3D end);
+
+		if (pgd_none(dst_pgd)) {
+			pud_t *t =3D trans_alloc(info);
+
+			if (!t)
+				return -ENOMEM;
+
+			__pgd_populate(&dst_pgdp[i], __pa(t), PUD_TYPE_TABLE);
+			dst_pgd =3D READ_ONCE(dst_pgdp[i]);
+		}
+
+		src_pudp =3D __va(pgd_page_paddr(src_pgd));
+		dst_pudp =3D __va(pgd_page_paddr(dst_pgd));
+
+		rc =3D copy_pud(info, dst_pudp, src_pudp, addr, next);
+		if (rc)
+			return rc;
+	} while (addr =3D next, i++, addr !=3D end && i < PTRS_PER_PGD);
=20
 	return 0;
 }
@@ -186,7 +204,7 @@ int trans_pgd_create_copy(struct trans_pgd_info *info=
, pgd_t **trans_pgd,
 	if (rc)
 		return rc;
=20
-	return copy_page_tables(*trans_pgd, start, end);
+	return copy_pgd(info, *trans_pgd, from_table, start, end);
 }
=20
 int trans_pgd_map_page(struct trans_pgd_info *info, pgd_t *trans_pgd,
--=20
2.23.0


