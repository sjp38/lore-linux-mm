Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A3E8C76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 064A02190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dis5qQNz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 064A02190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F1D46B0266; Mon, 22 Jul 2019 05:44:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C8E16B000E; Mon, 22 Jul 2019 05:44:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F5336B026A; Mon, 22 Jul 2019 05:44:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF146B000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:44:37 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n4so19066893plp.4
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:44:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3uvTtAB60j2sX58BYKBbOjuVpS09AJwPFJhgG33SN6g=;
        b=j8Z7HDZXjHn4xG5boGARtVJvAY6uEhBJp5w5oBe7lsOuK+mxqw5t+T8UDYp3pEJYc+
         t1SrZUieO7Ij1zgMGSz+5gq70x07scIMynWJjLW7nv3gbYVWRFpyvlLAsKhzVbMqfVQo
         g4S15/O6hwtlwmlbGn4t0QZwgcm3EdztoRpu8DhwH5nNR8pAaXPohVU/X21+NiB+Kra2
         g4DHxWRech9ZoyTtliyFFaLJH2KbYJHBRifgVAJ6kVipFAGp2rbUJCJ+WYk1X+qS0TZl
         dk1C4WMYsKWoSuRj0FwB3yvhg/BvoseM7nS7x+eLRxrpnWBja7H/euInAzx9otTZHXPX
         97jg==
X-Gm-Message-State: APjAAAU9xxpogpfcy9LzNajeDPP6Z3uS+YZu84iDlh90D8DFyb6G/7T7
	qNV8xOvc/l9inM4GmfAf1cBF62ypK08K5YvytdTbiRhakU/W85HJakskJWhx0Q7cYSDi89W6YWr
	shamsdlRVWCgR6mqAzvwqKiM/dcBGvRjXgSHEUYHe7S5P6ZZ/N3ijZ2OASVay4as=
X-Received: by 2002:a17:902:968d:: with SMTP id n13mr26896731plp.257.1563788676797;
        Mon, 22 Jul 2019 02:44:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4AUmhi9UD8tNvditv3u0DzfTO7NG4vM0r7f1pfizVDkbUnRlZIVSTV35CftIGicL6rP4B
X-Received: by 2002:a17:902:968d:: with SMTP id n13mr26896636plp.257.1563788675555;
        Mon, 22 Jul 2019 02:44:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788675; cv=none;
        d=google.com; s=arc-20160816;
        b=IL2alWRx6zm7jMVSKbbC5VkYAFXYPh1g/s2rjK/e7U+AclI9eLl0o5WzzGCgC8WkQc
         +3eQK5AuYRjE4sWEO1kt2wWOVlb3xIB3hdyIFGRu4uBDK3xfonBD19O0B4YmHmSbOFfU
         74bQ+h/Za667VYm1MzdDqdNAzIBb+heOkDpYGSLvSmAmTM2+WXihLOdTY+12rCLDl4nr
         SiFt3E8D/FXJnOhceAH5FjFARlSWR3tmQzn3Uf8Ij0AjNV7d/xmWg3N4IiDb8WaHRPX4
         R2zSqVkGnL+RgQ/R8m2kHPu/f6oHmpLfW/AwDn9YY/Z1QD0Ky3zxKg6TscQVohgrFE64
         DpKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3uvTtAB60j2sX58BYKBbOjuVpS09AJwPFJhgG33SN6g=;
        b=WRRUL0SldtF1ELwJ8YkErSpU1PwprvQcH64pYPuZevjnORumpfwER9K5tfGiNi0Qz2
         FJufy8Q6S8lFHedTgn12w0gpDakYOXXrvuV1FTsapU66fRcT/aDNWtYhRObcu/DfXNhL
         bk+MRAuJvXQjVamQ+xN2Mj6ZoC0NTr7uUJfU/SDrcx7UjBMh4SFEsuzEVOtzeKWBfPIf
         RviC1lFhJVyfiMyLJXGQVKUBhpM9xh0A8Rqz/qvnQ8ggB1QLEnDXh+6F/WkNJcqxeUBW
         oY8bo7xo9MfCK1Ay/39nyuh0I+OwBqw5e5xI/W82Nj4LasEr1FHHGLrXhpSUBIS30NUg
         enAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dis5qQNz;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l10si8332243plb.314.2019.07.22.02.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 02:44:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dis5qQNz;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=3uvTtAB60j2sX58BYKBbOjuVpS09AJwPFJhgG33SN6g=; b=dis5qQNzsIQBdOBibWkzOcJ4gK
	wStPEqafXe7BljX8GR9Ovc0C8MOXMPORFunkej4Z2wtu/1OAGwdDhQil4cSP3APO0tdpl5KEEkciz
	9ZHJB9c2O+QWlBVXDRJs4F0usZmTE9XcH/83CA8fIyRrAI9bwxm9bx6+iyh8mVs3DLPWVq6Mxhosk
	6h/WbrwjMpFCEqgg6v+Rg4UR5WAk++SEIdLwxzAQi1T3cXDvo12hZrZxN7hKlFcvOh6ZGBjTWt2Ck
	V04FZyL5dp0fidDGE36KR/hilcR9x4PmNpoWu28WqJRzfaJE+lyH6dPVXuAXRiQ8yH78kBeHbWB5C
	R8GIBJhQ==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hpUrx-0001s1-9G; Mon, 22 Jul 2019 09:44:33 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/6] mm: move hmm_vma_range_done and hmm_vma_fault to nouveau
Date: Mon, 22 Jul 2019 11:44:22 +0200
Message-Id: <20190722094426.18563-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722094426.18563-1-hch@lst.de>
References: <20190722094426.18563-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These two functions are marked as a legacy APIs to get rid of, but seem
to suit the current nouveau flow.  Move it to the only user in
preparation for fixing a locking bug involving caller and callee.
All comments referring to the old API have been removed as this now
is a driver private helper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 45 +++++++++++++++++++++-
 include/linux/hmm.h                   | 54 ---------------------------
 2 files changed, 43 insertions(+), 56 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 8c92374afcf2..cde09003c06b 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -475,6 +475,47 @@ nouveau_svm_fault_cache(struct nouveau_svm *svm,
 		fault->inst, fault->addr, fault->access);
 }
 
+static inline bool nouveau_range_done(struct hmm_range *range)
+{
+	bool ret = hmm_range_valid(range);
+
+	hmm_range_unregister(range);
+	return ret;
+}
+
+static int
+nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
+		    bool block)
+{
+	long ret;
+
+	range->default_flags = 0;
+	range->pfn_flags_mask = -1UL;
+
+	ret = hmm_range_register(range, mirror,
+				 range->start, range->end,
+				 PAGE_SHIFT);
+	if (ret)
+		return (int)ret;
+
+	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
+		up_read(&range->vma->vm_mm->mmap_sem);
+		return -EAGAIN;
+	}
+
+	ret = hmm_range_fault(range, block);
+	if (ret <= 0) {
+		if (ret == -EBUSY || !ret) {
+			up_read(&range->vma->vm_mm->mmap_sem);
+			ret = -EBUSY;
+		} else if (ret == -EAGAIN)
+			ret = -EBUSY;
+		hmm_range_unregister(range);
+		return ret;
+	}
+	return 0;
+}
+
 static int
 nouveau_svm_fault(struct nvif_notify *notify)
 {
@@ -649,10 +690,10 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = hmm_vma_fault(&svmm->mirror, &range, true);
+		ret = nouveau_range_fault(&svmm->mirror, &range, true);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
-			if (!hmm_vma_range_done(&range)) {
+			if (!nouveau_range_done(&range)) {
 				mutex_unlock(&svmm->mutex);
 				goto again;
 			}
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index b8a08b2a10ca..7ef56dc18050 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -484,60 +484,6 @@ long hmm_range_dma_unmap(struct hmm_range *range,
  */
 #define HMM_RANGE_DEFAULT_TIMEOUT 1000
 
-/* This is a temporary helper to avoid merge conflict between trees. */
-static inline bool hmm_vma_range_done(struct hmm_range *range)
-{
-	bool ret = hmm_range_valid(range);
-
-	hmm_range_unregister(range);
-	return ret;
-}
-
-/* This is a temporary helper to avoid merge conflict between trees. */
-static inline int hmm_vma_fault(struct hmm_mirror *mirror,
-				struct hmm_range *range, bool block)
-{
-	long ret;
-
-	/*
-	 * With the old API the driver must set each individual entries with
-	 * the requested flags (valid, write, ...). So here we set the mask to
-	 * keep intact the entries provided by the driver and zero out the
-	 * default_flags.
-	 */
-	range->default_flags = 0;
-	range->pfn_flags_mask = -1UL;
-
-	ret = hmm_range_register(range, mirror,
-				 range->start, range->end,
-				 PAGE_SHIFT);
-	if (ret)
-		return (int)ret;
-
-	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
-		/*
-		 * The mmap_sem was taken by driver we release it here and
-		 * returns -EAGAIN which correspond to mmap_sem have been
-		 * drop in the old API.
-		 */
-		up_read(&range->vma->vm_mm->mmap_sem);
-		return -EAGAIN;
-	}
-
-	ret = hmm_range_fault(range, block);
-	if (ret <= 0) {
-		if (ret == -EBUSY || !ret) {
-			/* Same as above, drop mmap_sem to match old API. */
-			up_read(&range->vma->vm_mm->mmap_sem);
-			ret = -EBUSY;
-		} else if (ret == -EAGAIN)
-			ret = -EBUSY;
-		hmm_range_unregister(range);
-		return ret;
-	}
-	return 0;
-}
-
 /* Below are for HMM internal use only! Not to be used by device driver! */
 static inline void hmm_mm_init(struct mm_struct *mm)
 {
-- 
2.20.1

