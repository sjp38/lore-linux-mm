Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5819C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 02:38:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EA0C20B1F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 02:38:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IvagmT+J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EA0C20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CAB16B0006; Sun,  4 Aug 2019 22:38:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1537C6B0007; Sun,  4 Aug 2019 22:38:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01B1A6B0008; Sun,  4 Aug 2019 22:38:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBA3A6B0006
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 22:38:23 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so45355882plp.12
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 19:38:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=30MQZ7ywyXKAPoZ0MqYExKYsjkeLdKEHUByfnmRZCb0=;
        b=uLV8TlpggEMOlR45k3Dq578YjJtKvs9c1YS9cq7CUEVUIjlOKKj9ynR37pe1p8bJQl
         3U8lBOxyUrarbFlZyxuRwHoJMqMEW5PHPmypRVvHms1IwJPBNIksRk7IkhdJeOp+eyRo
         O1QJbTGW5i7GAadIEv54XNAlljQdI2teeWxd4Z/x1Prp9e6LV4rYFT0ziND6gTFOGRjU
         u4vzofgB8yEDq/W+Y2p3BHgxOcKK656yJWeMyXS7YIb1PtFhCTmwtpjoEzUhI3LCASB7
         QmRh7Ux9DNasHqTngFz1u6i06Mz0GDuonZ/Satf/AKT/5rel9qPjMwIFgHulGBJjOEII
         IDtQ==
X-Gm-Message-State: APjAAAUWz+hHxZWTxqBRi//yRFrdOwGyL34IO2J3b9cGWUJB4Ee9ORPB
	q89uFOVn284eol89jRJ5KXWrdYW1RrR+nkJHfZsNfiLFe6+VmpxnlGEKWzWLy5/Ex4Vj4hf05Dy
	S700QnkpjGDlryb7V4ozNaLUOOKzNLVtPXoDjYZuB9OQTAslxe5+Z6BVbLmYW4vUOrA==
X-Received: by 2002:a62:5c01:: with SMTP id q1mr48723798pfb.53.1564972703431;
        Sun, 04 Aug 2019 19:38:23 -0700 (PDT)
X-Received: by 2002:a62:5c01:: with SMTP id q1mr48723763pfb.53.1564972702635;
        Sun, 04 Aug 2019 19:38:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564972702; cv=none;
        d=google.com; s=arc-20160816;
        b=ryjircEPBqD4en4NaXO4bQFCnEJUsZFN82DDb9puAlflZQVZoQbQsrjYowKsAYsPiK
         u/rWcP5w4dILGl83VdThBo8ysUdlXv4duB9swzCKSwMSEK+9av2i+/aPxwKzMVoaviHr
         e/Yxxpu+nprePrgpPXTRRC1GKAcP8d69BVp3Qf47/NYu84YDPXaG6oH5So4pbOvDmmIN
         E/2KxquAPt0o+PJL3JkQ8gjNDBHp7JTR4igfvD4KrTTMj9CYwYm8pm1TGLHZevyJpyDu
         cakrt0sdyHYKl3e7ugIS3hk3+3hZsQo/wBoaZvNuo/aiu/VbsXDcL7ugQMDxVempk3eH
         E3sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=30MQZ7ywyXKAPoZ0MqYExKYsjkeLdKEHUByfnmRZCb0=;
        b=SAdWDJHxhizD3QqsTmf+Pnm+61UhUVbTB/Xo09PAYPlvSN0IBLNPQ21db0fM/8sZYy
         5oM3wO0SDXaKHC6t0+34Ke+oCE8nSVzjyWjQBrtX97pRaFgsDzTzGaS/w+1EOmE99g9l
         899YizDESg3gcnE1HtU50IB1g/IwGfVFPa6VWWh0mD4hEgSp3KWWlrZ8qkO6Yf9rXY0a
         Ui5T6/FlHMiysOwwHJN0idSrsfRuH8c36DHaaIB5Rhk0ahwh7dWxivFa1xg9SAb1rWnj
         IXDLIEiF6Hq/xLAKet+apDHaE84KiTwcGgb439TJGx1/5yJpmCJR/Oo5Qp5lvm2RdtvS
         rqRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IvagmT+J;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a25sor60887612pfi.29.2019.08.04.19.38.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 19:38:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IvagmT+J;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=30MQZ7ywyXKAPoZ0MqYExKYsjkeLdKEHUByfnmRZCb0=;
        b=IvagmT+JjyfUCHaWI+oWVe83Vd/BxQOf8lwVAIUGNrLrImKDoBg69DgWJgweIFVTTb
         t9Fd81BoXyIbeQKtADBPM518HlERGQ3S9QcdZHl5GHiZ+3CZc/mG3ldNB0DFVA+oLUky
         4YoCR5Kn54jmKeO0SgOFTU8UIG8AhTiXpPY6aJvZHzWR0iW1+d6D4ft05gUFQbHqtsLD
         2zVi6PAEyNlZ9Rcwg5VvXyY5LHWfMMKMh+VnR92xmXqN8pMV8+STxr2eXC203UO1Tpla
         uNVcRsRdtOQH81N2Ng5sIXu+JR5jaekJfCc+SvAJlP4bu/MpAl9h4hDu3E/NASSFtOhS
         NHbA==
X-Google-Smtp-Source: APXvYqxhbQJILXTxhwn1nUnYV8i/zFa6et+z4o7S2/4wOMnlr3FWVDcMtMr/x65TCuwWLuIgS9IZbw==
X-Received: by 2002:a62:7a8a:: with SMTP id v132mr70688812pfc.103.1564972702334;
        Sun, 04 Aug 2019 19:38:22 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id p13sm25433972pjb.30.2019.08.04.19.38.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 19:38:21 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christoph Hellwig <hch@lst.de>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linuxppc-dev@lists.ozlabs.org
Subject: [PATCH] powerpc: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 19:38:19 -0700
Message-Id: <20190805023819.11001-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Note that this effectively changes the code's behavior in
mm_iommu_unpin(): it now ultimately calls set_page_dirty_lock(),
instead of set_page_dirty(). This is probably more accurate.

As Christoph Hellwig put it, "set_page_dirty() is only safe if we are
dealing with a file backed page where we have reference on the inode it
hangs off." [1]

[1] https://lore.kernel.org/r/20190723153640.GB720@lst.de

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 arch/powerpc/kvm/book3s_64_mmu_hv.c    |  4 ++--
 arch/powerpc/kvm/book3s_64_mmu_radix.c | 19 ++++++++++++++-----
 arch/powerpc/kvm/e500_mmu.c            |  3 +--
 arch/powerpc/mm/book3s64/iommu_api.c   | 11 +++++------
 4 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 9a75f0e1933b..18646b738ce1 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -731,7 +731,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 		 * we have to drop the reference on the correct tail
 		 * page to match the get inside gup()
 		 */
-		put_page(pages[0]);
+		put_user_page(pages[0]);
 	}
 	return ret;
 
@@ -1206,7 +1206,7 @@ void kvmppc_unpin_guest_page(struct kvm *kvm, void *va, unsigned long gpa,
 	unsigned long gfn;
 	int srcu_idx;
 
-	put_page(page);
+	put_user_page(page);
 
 	if (!dirty)
 		return;
diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index 2d415c36a61d..f53273fbfa2d 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -821,8 +821,12 @@ int kvmppc_book3s_instantiate_page(struct kvm_vcpu *vcpu,
 	 */
 	if (!ptep) {
 		local_irq_enable();
-		if (page)
-			put_page(page);
+		if (page) {
+			if (upgrade_write)
+				put_user_page(page);
+			else
+				put_page(page);
+		}
 		return RESUME_GUEST;
 	}
 	pte = *ptep;
@@ -870,9 +874,14 @@ int kvmppc_book3s_instantiate_page(struct kvm_vcpu *vcpu,
 		*levelp = level;
 
 	if (page) {
-		if (!ret && (pte_val(pte) & _PAGE_WRITE))
-			set_page_dirty_lock(page);
-		put_page(page);
+		bool dirty = !ret && (pte_val(pte) & _PAGE_WRITE);
+		if (upgrade_write)
+			put_user_pages_dirty_lock(&page, 1, dirty);
+		else {
+			if (dirty)
+				set_page_dirty_lock(page);
+			put_page(page);
+		}
 	}
 
 	/* Increment number of large pages if we (successfully) inserted one */
diff --git a/arch/powerpc/kvm/e500_mmu.c b/arch/powerpc/kvm/e500_mmu.c
index 2d910b87e441..67bb8d59d4b1 100644
--- a/arch/powerpc/kvm/e500_mmu.c
+++ b/arch/powerpc/kvm/e500_mmu.c
@@ -850,8 +850,7 @@ int kvm_vcpu_ioctl_config_tlb(struct kvm_vcpu *vcpu,
  free_privs_first:
 	kfree(privs[0]);
  put_pages:
-	for (i = 0; i < num_pages; i++)
-		put_page(pages[i]);
+	put_user_pages(pages, num_pages);
  free_pages:
 	kfree(pages);
 	return ret;
diff --git a/arch/powerpc/mm/book3s64/iommu_api.c b/arch/powerpc/mm/book3s64/iommu_api.c
index b056cae3388b..e126193ba295 100644
--- a/arch/powerpc/mm/book3s64/iommu_api.c
+++ b/arch/powerpc/mm/book3s64/iommu_api.c
@@ -170,9 +170,8 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
 	return 0;
 
 free_exit:
-	/* free the reference taken */
-	for (i = 0; i < pinned; i++)
-		put_page(mem->hpages[i]);
+	/* free the references taken */
+	put_user_pages(mem->hpages, pinned);
 
 	vfree(mem->hpas);
 	kfree(mem);
@@ -203,6 +202,7 @@ static void mm_iommu_unpin(struct mm_iommu_table_group_mem_t *mem)
 {
 	long i;
 	struct page *page = NULL;
+	bool dirty = false;
 
 	if (!mem->hpas)
 		return;
@@ -215,10 +215,9 @@ static void mm_iommu_unpin(struct mm_iommu_table_group_mem_t *mem)
 		if (!page)
 			continue;
 
-		if (mem->hpas[i] & MM_IOMMU_TABLE_GROUP_PAGE_DIRTY)
-			SetPageDirty(page);
+		dirty = mem->hpas[i] & MM_IOMMU_TABLE_GROUP_PAGE_DIRTY;
 
-		put_page(page);
+		put_user_pages_dirty_lock(&page, 1, dirty);
 		mem->hpas[i] = 0;
 	}
 }
-- 
2.22.0

