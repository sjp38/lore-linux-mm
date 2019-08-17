Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 841ABC3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39F7E21019
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="KemMiArf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39F7E21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDEC96B026C; Fri, 16 Aug 2019 22:46:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D68216B026D; Fri, 16 Aug 2019 22:46:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C07736B026E; Fri, 16 Aug 2019 22:46:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6006B026C
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:35 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 5298B348D
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:35 +0000 (UTC)
X-FDA: 75830381550.16.hope83_90c544d270c16
X-HE-Tag: hope83_90c544d270c16
X-Filterd-Recvd-Size: 6900
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:34 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id x4so8219165qts.5
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K4mtuNsym73dHWEDL4hJM0gd2cT9s68JdquM/qnM6EE=;
        b=KemMiArfhB/bkmgPhLe269DxdJ2sfUaz9BBRBWeEwBei3UcHKilv5YTdxNIM4RiWZH
         Lom5gHj4hJWo1eaeNJD82dMK3k2fH0A5/ReY1tb8n89jgfH9sJymNlsHbUReswF741Ee
         D6XAyOB5PE3OJRfWPTXL7s49Q2cskfn/e6NkuL9zjzno9KVLjDTcc6sP7R0OOIkFKtit
         5jdvxdN8IjqB75e7PwasKxUnAxP2j8IdmYiNE7eLGhlFq1ZcUQLsE2Y/r6NPFy3Ajc1O
         HvoVAdk5fv0xOTZIGQZmY96Kd3bjixZ21+14XkaZMM1xQJg/N2IKZsH4DVlHDwJs6nP2
         PhUw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=K4mtuNsym73dHWEDL4hJM0gd2cT9s68JdquM/qnM6EE=;
        b=ZExl9LVHj0msGj/RanzmYPvCphTJugXOmQVjPqzS3EMBurf4v4cob/oqryR5LensMF
         kNS9596/m17ekyx0LsqQ7uPMGta9XHH+tGT0UPjbpt8Tbs6fFVXLe8WOlpkKy2MMIgc+
         5gMZXczuTzHaPyS1UjtiYwAD8ri9gvtUsKELCeMh7FqM92nyUztG5MRj4MYQ4FfVXerM
         3BW3rFdgVJoa2tiicOkpOfGNYHhKUbRX4MKrGQz+HeSxgPVTzbcY82GeUDbI5wEdTasF
         EHHSnrQRxqXz+IzQGtWdZEVnzAzTTqatGzORO5enDQ0XtKtcqlkfcrs12ulnM86/rTkc
         CEkg==
X-Gm-Message-State: APjAAAUQNylJAdzldnZzwaxavS6YEqX1i8Ljn2d26KTj5B/m19RMlTnX
	069TSVCa5J3NKO0LoqAEgXd+NA==
X-Google-Smtp-Source: APXvYqwLah3JFnz5InFyJaEdMbrmW5wa4z0VC1v4yTqNJxq6j6zENAvViIR8vGnHzPMR31kzpHCCug==
X-Received: by 2002:a0c:ffc5:: with SMTP id h5mr3894666qvv.43.1566009994194;
        Fri, 16 Aug 2019 19:46:34 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:33 -0700 (PDT)
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
	linux-mm@kvack.org
Subject: [PATCH v2 02/14] arm64, hibernate: create_safe_exec_page cleanup
Date: Fri, 16 Aug 2019 22:46:17 -0400
Message-Id: <20190817024629.26611-3-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190817024629.26611-1-pasha.tatashin@soleen.com>
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

create_safe_exec_page() is going to be split into two parts in preparatio=
n
of moving page table handling code out of hibernate.c

Remove allocator parameter, and rename dst to page. Also, remove the
goto's, as we can return directly without cleanups.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/kernel/hibernate.c | 60 +++++++++++++++--------------------
 1 file changed, 26 insertions(+), 34 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 9341fcc6e809..96b6f8da7e49 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -196,57 +196,51 @@ EXPORT_SYMBOL(arch_hibernation_header_restore);
  */
 static int create_safe_exec_page(void *src_start, size_t length,
 				 unsigned long dst_addr,
-				 phys_addr_t *phys_dst_addr,
-				 void *(*allocator)(gfp_t mask),
-				 gfp_t mask)
+				 phys_addr_t *phys_dst_addr)
 {
-	int rc =3D 0;
+	void *page =3D (void *)get_safe_page(GFP_ATOMIC);
+	pgd_t *trans_table;
 	pgd_t *pgdp;
 	pud_t *pudp;
 	pmd_t *pmdp;
 	pte_t *ptep;
-	unsigned long dst =3D (unsigned long)allocator(mask);
=20
-	if (!dst) {
-		rc =3D -ENOMEM;
-		goto out;
-	}
+	if (!page)
+		return -ENOMEM;
+
+	memcpy((void *)page, src_start, length);
+	__flush_icache_range((unsigned long)page, (unsigned long)page + length)=
;
=20
-	memcpy((void *)dst, src_start, length);
-	__flush_icache_range(dst, dst + length);
+	trans_table =3D (void *)get_safe_page(GFP_ATOMIC);
+	if (!trans_table)
+		return -ENOMEM;
=20
-	pgdp =3D pgd_offset_raw(allocator(mask), dst_addr);
+	pgdp =3D pgd_offset_raw(trans_table, dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
-		pudp =3D allocator(mask);
-		if (!pudp) {
-			rc =3D -ENOMEM;
-			goto out;
-		}
+		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
+		if (!pudp)
+			return -ENOMEM;
 		pgd_populate(&init_mm, pgdp, pudp);
 	}
=20
 	pudp =3D pud_offset(pgdp, dst_addr);
 	if (pud_none(READ_ONCE(*pudp))) {
-		pmdp =3D allocator(mask);
-		if (!pmdp) {
-			rc =3D -ENOMEM;
-			goto out;
-		}
+		pmdp =3D (void *)get_safe_page(GFP_ATOMIC);
+		if (!pmdp)
+			return -ENOMEM;
 		pud_populate(&init_mm, pudp, pmdp);
 	}
=20
 	pmdp =3D pmd_offset(pudp, dst_addr);
 	if (pmd_none(READ_ONCE(*pmdp))) {
-		ptep =3D allocator(mask);
-		if (!ptep) {
-			rc =3D -ENOMEM;
-			goto out;
-		}
+		ptep =3D (void *)get_safe_page(GFP_ATOMIC);
+		if (!ptep)
+			return -ENOMEM;
 		pmd_populate_kernel(&init_mm, pmdp, ptep);
 	}
=20
 	ptep =3D pte_offset_kernel(pmdp, dst_addr);
-	set_pte(ptep, pfn_pte(virt_to_pfn(dst), PAGE_KERNEL_EXEC));
+	set_pte(ptep, pfn_pte(virt_to_pfn(page), PAGE_KERNEL_EXEC));
=20
 	/*
 	 * Load our new page tables. A strict BBM approach requires that we
@@ -262,13 +256,12 @@ static int create_safe_exec_page(void *src_start, s=
ize_t length,
 	 */
 	cpu_set_reserved_ttbr0();
 	local_flush_tlb_all();
-	write_sysreg(phys_to_ttbr(virt_to_phys(pgdp)), ttbr0_el1);
+	write_sysreg(phys_to_ttbr(virt_to_phys(trans_table)), ttbr0_el1);
 	isb();
=20
-	*phys_dst_addr =3D virt_to_phys((void *)dst);
+	*phys_dst_addr =3D virt_to_phys((void *)page);
=20
-out:
-	return rc;
+	return 0;
 }
=20
 #define dcache_clean_range(start, end)	__flush_dcache_area(start, (end -=
 start))
@@ -523,8 +516,7 @@ int swsusp_arch_resume(void)
 	 */
 	rc =3D create_safe_exec_page(__hibernate_exit_text_start, exit_size,
 				   (unsigned long)hibernate_exit,
-				   &phys_hibernate_exit,
-				   (void *)get_safe_page, GFP_ATOMIC);
+				   &phys_hibernate_exit);
 	if (rc) {
 		pr_err("Failed to create safe executable page for hibernate_exit code.=
\n");
 		goto out;
--=20
2.22.1


