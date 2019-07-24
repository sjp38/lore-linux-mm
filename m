Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40243C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:41:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9D0922387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:41:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nuwmBoyk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9D0922387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C64C6B000A; Wed, 24 Jul 2019 07:41:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 979118E0002; Wed, 24 Jul 2019 07:41:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88E2F6B000D; Wed, 24 Jul 2019 07:41:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 521E86B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:41:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m17so19198356pgh.21
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:41:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3/B7iS7twoHuFiN2Sq9UrpmOirWTgDsR38WI+eokeIw=;
        b=TE2BpcfMbUguQG5k/GV5nstt8Llic0/pOrYorKhCtZHxRcuwy39/D0Z4OByozSQK1h
         k0/EmVRNr1McOSyHch4t/Kmzzht89lwNH6PBhs5dpDwlKGFVM1JhJHXXRgykXGZU9ybU
         /vT4qLy3MUPpIanEagh2tmMzgFeLHHQaUpq1fQd9yjiBHV4r9tMrS5LTJCe5HUEciTLq
         8hDDLGmdvNlwUJJ+8iwX/v8426XMjdN3ZBG6tFtWqd1fcgDcZ0BUBD0g7XjlMS1JNcga
         0KkFzOfqJpWWbXbzIxQRF24N5rGRNPb7zsQCWL28UKZCOx418CdP9uTA7+pL7trzPylJ
         W2XQ==
X-Gm-Message-State: APjAAAXGHk6CKP1JeZIuex9RgdeHdcLrnzAz5IYMygE5o2SyKTxsO8OV
	egXZEayghYchpljVmPS48l6zPNrrIhU4zEj04zDZNBSf0FDfydLinrRwPqIM1B1xqxjK82AWvjr
	Gvh3FvHM9MUKRw6ttW/EiAueelp8GVfpjda9z0X217Fp+5GZ2CZKswpgGnOViIsP4gw==
X-Received: by 2002:a62:f20b:: with SMTP id m11mr10981143pfh.125.1563968505997;
        Wed, 24 Jul 2019 04:41:45 -0700 (PDT)
X-Received: by 2002:a62:f20b:: with SMTP id m11mr10981061pfh.125.1563968504879;
        Wed, 24 Jul 2019 04:41:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563968504; cv=none;
        d=google.com; s=arc-20160816;
        b=U3rKACXqBOW0m4FGWbepUVIeYR1LiKSDXUuZJo+7/fkGoN0CK3Uf796HtE+VLo8eG1
         kDCfPMNs73RsnBuPIJKTQEtUsxRaXEbWEhnthqJUzJtFEJKiZIWSqovOrEx0F3gjizGj
         6wHRsn0vN0QPFFBcmPY6j/Jf7J+vpADRcdHqJIjZUC+b8g7sau2cn0LLsHNV+83o3bAv
         iXuvM3Pe9AfXM+EOfn67mWGywYcTJ/R5RYVVKqgbc6hNEQbPHHRh/QYkFu3h4sFi6zLP
         7kzm1gSAa0/U1i4EgBb0thd8g/YHSCemPUG6UwkWp8jaFyV93axsnVwK/C2ausulb7N4
         4KEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3/B7iS7twoHuFiN2Sq9UrpmOirWTgDsR38WI+eokeIw=;
        b=ljqTt5XPoY8QwWUqbZ0F3diF+C6lFhuhItwO4qWnhsAFGziFrEZcLTfwc+rsa7LbHC
         N9B4Le0OHKu+Yy7RH2yI3uBNwUJghwbxSioq85x9/8dwwOro0ZU9+u+w7lq2Zyw5mk4A
         DynXshNHAz9TyHyQaSqOULIMLhmjtoNjZ4BE9N0o/x2fPqu6Kqtf1wLaZTsTi57L+3Tg
         TDiQIt0FcECMvDLdX8DIHGoQFGs0+/pGwSfA+urt9+TQw1q+CQ/HDs2HKqKAHYGDYBOG
         +5j2+j6AOXCy9KPgCO/c/PFc3B12cOJ0oqvo6bGfxJs9H9cGoZtvwz0vOMECCDMeJHub
         MPlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nuwmBoyk;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor26748905pfd.59.2019.07.24.04.41.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 04:41:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nuwmBoyk;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=3/B7iS7twoHuFiN2Sq9UrpmOirWTgDsR38WI+eokeIw=;
        b=nuwmBoyk/4mjKCCvHAMVDXxEHZeOXfghybqdlk45TABHI4NUxhZ7qZwTt4dgyuKVLk
         FdDuimPLodOe8X9r/jmApQ7hICQ2IjRf0du84YnIZK7DyFIncOglG/om0sL0N3Q7irou
         odpU3/NHnGVesgsh+LUJ3gU2qlBu0HUuj0dB/IVHsAQSalNpQstuQw9Rj9a+ibPlb8Mq
         4zCr9nj3e5eppuywNhUaSody/+rxS7Fyt1hQWYs+9lfgebNTWkb9Xg+m8jf9qQBUoUSI
         mhSFVpXKlTKpoVv/wQOx20JWHfTeApoEsLMG3H2PcnTnUqr5PMtCAprlqC0JQeu2QWu9
         7MhA==
X-Google-Smtp-Source: APXvYqxyAvff4hzpbzMvBi/f0yE9LGLNcoyt7PgpRZOhB0FTxC0vLmHV/OJZGDPHCOMBdk5syS84iA==
X-Received: by 2002:aa7:957c:: with SMTP id x28mr10859669pfq.42.1563968504581;
        Wed, 24 Jul 2019 04:41:44 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id o14sm46177906pjp.29.2019.07.24.04.41.43
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Jul 2019 04:41:44 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	arnd@arndb.de,
	jhubbard@nvidia.com
Cc: ira.weiny@intel.com,
	jglisse@redhat.com,
	gregkh@linuxfoundation.org,
	william.kucharski@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [PATCH v2 3/3] sgi-gru: Use __get_user_pages_fast in atomic_pte_lookup
Date: Wed, 24 Jul 2019 17:11:16 +0530
Message-Id: <1563968476-12785-4-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1563968476-12785-1-git-send-email-linux.bhar@gmail.com>
References: <1563968476-12785-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

*pte_lookup functions get the physical address for a given virtual
address by getting a physical page using gup and use page_to_phys to get
the physical address.

Currently, atomic_pte_lookup manually walks the page tables. If this
function fails to get a physical page, it will fall back too
non_atomic_pte_lookup to get a physical page which uses the slow gup
path to get the physical page.

Instead of manually walking the page tables use __get_user_pages_fast
which does the same thing and it does not fall back to the slow gup
path.

Also, the function atomic_pte_lookup's return value has been changed to boolean.
The callsites have been appropriately modified.

This is largely inspired from kvm code. kvm uses __get_user_pages_fast
in hva_to_pfn_fast function which can run in an atomic context.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: William Kucharski <william.kucharski@oracle.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
Changes since v2
	- Modified the return value of atomic_pte_lookup
	to use booleans rather than numeric values.
	This was suggested by John Hubbard.
---
 drivers/misc/sgi-gru/grufault.c | 56 +++++++++++------------------------------
 1 file changed, 15 insertions(+), 41 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index bce47af..da2d2cc 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -193,9 +193,11 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 }
 
 /*
- * atomic_pte_lookup
+ * atomic_pte_lookup() - Convert a user virtual address 
+ * to a physical address.
+ * @Return: true for success, false for failure. Failure means that
+ * the page could not be pinned via gup fast.
  *
- * Convert a user virtual address to a physical address
  * Only supports Intel large pages (2MB only) on x86_64.
  *	ZZZ - hugepage support is incomplete
  *
@@ -205,49 +207,20 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
 	int write, unsigned long *paddr, int *pageshift)
 {
-	pgd_t *pgdp;
-	p4d_t *p4dp;
-	pud_t *pudp;
-	pmd_t *pmdp;
-	pte_t pte;
-
-	pgdp = pgd_offset(vma->vm_mm, vaddr);
-	if (unlikely(pgd_none(*pgdp)))
-		goto err;
-
-	p4dp = p4d_offset(pgdp, vaddr);
-	if (unlikely(p4d_none(*p4dp)))
-		goto err;
-
-	pudp = pud_offset(p4dp, vaddr);
-	if (unlikely(pud_none(*pudp)))
-		goto err;
-
-	pmdp = pmd_offset(pudp, vaddr);
-	if (unlikely(pmd_none(*pmdp)))
-		goto err;
-#ifdef CONFIG_X86_64
-	if (unlikely(pmd_large(*pmdp)))
-		pte = *(pte_t *) pmdp;
-	else
-#endif
-		pte = *pte_offset_kernel(pmdp, vaddr);
-
-	if (unlikely(!pte_present(pte) ||
-		     (write && (!pte_write(pte) || !pte_dirty(pte)))))
-		return 1;
-
-	*paddr = pte_pfn(pte) << PAGE_SHIFT;
+	struct page *page;
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		*pageshift = HPAGE_SHIFT;
 	else
 		*pageshift = PAGE_SHIFT;
 
-	return 0;
+	if (!__get_user_pages_fast(vaddr, 1, write, &page))
+		return false;
 
-err:
-	return 1;
+	*paddr = page_to_phys(page);
+	put_user_page(page);
+
+	return true;
 }
 
 static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
@@ -256,7 +229,8 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
 	struct mm_struct *mm = gts->ts_mm;
 	struct vm_area_struct *vma;
 	unsigned long paddr;
-	int ret, ps;
+	int ps;
+	bool success;
 
 	vma = find_vma(mm, vaddr);
 	if (!vma)
@@ -267,8 +241,8 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
 	 * context.
 	 */
 	rmb();	/* Must/check ms_range_active before loading PTEs */
-	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
-	if (ret) {
+	success = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
+	if (!success) {
 		if (atomic)
 			goto upm;
 		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
-- 
2.7.4

