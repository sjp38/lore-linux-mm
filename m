Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01B68C73C66
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF01721743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g67RvuXx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF01721743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EAE76B02A4; Tue,  6 Aug 2019 21:34:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5049A6B02A6; Tue,  6 Aug 2019 21:34:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23BEA6B02A7; Tue,  6 Aug 2019 21:34:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D39556B02A4
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:46 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n4so48888997plp.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=30MQZ7ywyXKAPoZ0MqYExKYsjkeLdKEHUByfnmRZCb0=;
        b=P40lOzhZu38F5ahEPbORr8yU0a5caDQYnkZVwaCKzpAs9S+ZHqSrMsiOcq+I9KNjWu
         DnNGXk4kbvq+vEkaDUBO9HVt5dcXqNwT/F80GPoYOheDoRmmzm8ql73XasGSSz8Qkj+s
         TN/usKxR6oW3LQltOdpLBdCD0ijiTgGbeAcoNI7kOiJPo3EY+2ZQNd/YmAxtBEBkr3Eu
         6qlPNt7+T7ubnGMOJljSvffvuQXVl0a8qcoVC0bBecWDze3W7yX0EoPOp2B0nci8egym
         xu9DgKSxUAeWLGt4eD6iDWyL6lVoevRtnBtsjkC+b1hJrYVDlvXswAtSGqcB20o1CWlQ
         enDw==
X-Gm-Message-State: APjAAAXVoMKo5nCoyBPe/LMi3FIw3k3uNHFZpamHbeU1Lv4TV83UxgUN
	hwz7Mb8OL49WWDHkls2R9taEJzWfR0l1sCzQTRUpsD72hbAUPKxHuc5UttB5RgPCDqD4eSIxnnk
	JfeYRXtWr3PI0C4dXl7pPvNf0QEBxdMgm6m1MIp3CJeeuxxrDqqOSGpwv77iz+I2l5Q==
X-Received: by 2002:a62:754d:: with SMTP id q74mr6516781pfc.211.1565141686543;
        Tue, 06 Aug 2019 18:34:46 -0700 (PDT)
X-Received: by 2002:a62:754d:: with SMTP id q74mr6516731pfc.211.1565141685758;
        Tue, 06 Aug 2019 18:34:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141685; cv=none;
        d=google.com; s=arc-20160816;
        b=M9HfVp4GmIVng2+31KRgsEQT6oRDqLPnBoudH6KLPAZ7s/TN214yZy84etgUnx3t0w
         dJmwXf6HJodG7MLj6Dd+6lnNVIh9W51Gh1DzY82pcr6g/FpdvzW0xhkLXC5tVEDf9OFq
         fHiJ/AKHcH2OR8P4E2NafebqeyMJWwaeleMovcjbm59xpgipNQG34tEbvCVctlCifYRt
         y5rzD2TkVFExgQBeGQbLa7jvyOJAzkonAnB91wLhxDRqQxw+FzV49U/q8Z5tvn1aP3YL
         GQ1EzzewvZ9yzrVP5yIfijN/dsUtoHQOvnfQRm/8gvhVZFJmVH6e0amIfAMsEVvtEWnk
         QToQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=30MQZ7ywyXKAPoZ0MqYExKYsjkeLdKEHUByfnmRZCb0=;
        b=mLnKhaZWFewIx02ORoXcgfF6VR5jsO8EJ/h2f/WAy4MUTx266a+R4EpxldnIHFw69M
         kYuAf0+p1yJZJgTMTD4T5QNj4Re6H+/Ct5O25U34TU+CuXU28f11+JbRj2loGyo4pA8c
         RnpNYCLVe0YsHrtQsHRpXstTi++Dua3Le5WlU/wWsgjUYtuckLC25PRr8k1BaCT48yBM
         6n1Shsbd4AYZX44E44Ku6Cf9mSw8ydn/eLQkw7KguK1hQX+9ChXNq0klc7eaFsTaXqlC
         e1LcXvQbTFEMcdCRB3UVYq8oks7IV+OUbf0EShBVxLiKdYelEsGL2Jy1vjF17nfqhB3/
         rdLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=g67RvuXx;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o8sor3818572pgn.59.2019.08.06.18.34.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=g67RvuXx;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=30MQZ7ywyXKAPoZ0MqYExKYsjkeLdKEHUByfnmRZCb0=;
        b=g67RvuXxl/7UgwJ5Nsn5m7mCWAd1eJK19OdXPfHISavNg0/hlxqTRWRiZsiObbIxd1
         z7nTlGaqHPYV4ywgcbsmss6gPc+YHifTLpOQY0K91PQUhyOYukJschqLsfaVLze8bLh+
         aV53NaTAotE5e+jR4GjhaqKTLNaydraqrAumktndCtlF4SiNrqRjpIehSehjFa47DX/L
         ADmdLxhsKJt3PHVHlUoQeH6o3x8T/NrnTA5b/OM8c9NkahQxV1Hajc7XXSthUzvuQiX4
         tXYs8SD3Ckew9oHpIJy9DZatkhmnngs/Je/q+s3mKD0DprEGB/SuCd9kYNKpjjLfUk8q
         m4IA==
X-Google-Smtp-Source: APXvYqw4IyvxT+a447mG7S7T32nq/0vx/OylsLzm55tU7UOjf2NCx+Dmal9oDg9eNuXVr0J1x2ZUyQ==
X-Received: by 2002:a63:36cc:: with SMTP id d195mr5452828pga.157.1565141685421;
        Tue, 06 Aug 2019 18:34:45 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:44 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christoph Hellwig <hch@lst.de>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linuxppc-dev@lists.ozlabs.org
Subject: [PATCH v3 38/41] powerpc: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:37 -0700
Message-Id: <20190807013340.9706-39-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

