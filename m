Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A5F1C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF0BB21852
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="BlA5dAkf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF0BB21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAE468E001A; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B372E8E0019; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A25D68E001A; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 691048E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 59so1811680plb.14
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:45:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R2IKJDEoBTtrdnvArsNvIg0bEouxs/Ep6eg9PGhct3U=;
        b=mzTjBN4/G4RyNlwilBR/DO2sq86LA1Mnf6EAWZfIDDUZolfwa9bSMKG9hy+TGU8q7R
         ygA50h9TjbjlFOunxkaTQlBg4y10Zox3FsfRpUDXvPt0sWMcKeAIMLp8uwRYGqGgY0Oi
         /T1pJuhZMGpEFzDCE19wzP7GkrZqyXZbIJKbXTyBpNV2e16SGgN2KiCMWbMbG5/gqkBM
         Cfh3fjoxXRARkb7FgDlsKPScZcK9DVXy4AYV/ka4yL3FtZCoQT+q1N5b5kyjwOBRNKP0
         CrM/L4n7kzaOegsE2vvvbtudUhuhbRVXWt49MwlyzfupjyXP2ymHvJpjkIBhwQhZCgQQ
         DVrg==
X-Gm-Message-State: APjAAAXKqTRZLJ7LiN9n5Kd/j8cfVZiTGt67DUTHNmC5uSSy4XkwY4pa
	H8Wme2oJMRi5LYi6XzYCzB/jNq+6EEMheSWH9F0Gj1B1hKOlzpYWZYuWgDGPHZlTz5CVn7hnwTe
	HmnLSonijsTE1+cLMpauNI4NZHOnYsvhrDAsNwYzNBVPFiSV22BequBX7r+LeKBo=
X-Received: by 2002:a63:7a4f:: with SMTP id j15mr39525811pgn.427.1562179510702;
        Wed, 03 Jul 2019 11:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3nFOw58S8r2Pyx9jH7CB3l0cAgKwmXTJUu/x2ighT8QbDLSRT6fqJtWJ749iHiNo9NHVV
X-Received: by 2002:a63:7a4f:: with SMTP id j15mr39525688pgn.427.1562179509153;
        Wed, 03 Jul 2019 11:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562179509; cv=none;
        d=google.com; s=arc-20160816;
        b=kaUXRUo9glKvXBUjgTj11j2ve3ryiLXaaSZxAup9GEUV+MwVjSnoVJ1iyQXLt+oPFA
         ZdFY96cUjVp0zL/zroYGypifBjYxhEzERzrhN2OlbR7BBRl05ujXkuwQoUHTaPk89XaT
         UtyJu0UFmfF3VeLHDp+/V2PoZ1AaG2uWo5BiJiPHprNbwjeJjTCfXf5R/vVIUJg9kFgM
         ITQg3Rj7maq/RWSWGDPPzsmAo87eHbzeYUTaAMKDChb/PZKnSTjrfYjHKfEavlFpdSRR
         sz7RYz7OrhqB1OuOjZIcwHRGKgOF2YvJj1oD5UFe0glRSYsqr5qg+qEIQNowUa9GymDN
         h6ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=R2IKJDEoBTtrdnvArsNvIg0bEouxs/Ep6eg9PGhct3U=;
        b=0XhDAbqt7nkmPMhQAKZWQXwtnGCpaa+naSPvc5egrNiIPOYPgyjRn6dQIFg846P/Xi
         LP5SaeEvYGpcOp02MgOrQMrAs34yFcXb1oc8d/YVuqO3gCv0c7AEzwYwuv97hprxWKTh
         H+NdMZ14hBb5mCOW9N3oGvR9DcD+VS2auPMm4PKScpDzLHIr9mWEn3l4pcTpfR9T9vuW
         3UnML6PBxmVSw3Ga/ajNV21U4tXleJ1xB2ntIwwPI6FkPp0+N3QgZrhVT9jNTsqF6ZsS
         ztR+f5lhZGzOnBIMsetv5a4YdpHqiy5vJya3JUAE15W0ePTiWTJ9teMHuC4oIrdFghOX
         MMQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=BlA5dAkf;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j36si2963564plb.77.2019.07.03.11.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 11:45:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=BlA5dAkf;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=R2IKJDEoBTtrdnvArsNvIg0bEouxs/Ep6eg9PGhct3U=; b=BlA5dAkfa9XMUD9jvGrc0232RZ
	iZAb/Solva5+7b6CeewDjYUi3nVNSc3Y5Vj+XgHfbDmlC0iu05TXVzvkPsP2zIAARSyEp/3hcr1jO
	sNbbIMUpAz7/1ee7T2ZFVL4l5/eeWDXxjn9SrSVxsrHm60pXcTj7Miq1xEyTOj5CkGTSwt9XJgdVd
	9x90lGMU+wCDPzSCMRCB/Bfo9rxv07Aj4hz7ZCfkUdcS/DPpHVLrEfXievanIbqVwcRF70IRpMb2D
	0Ocnxbgl710VUzNX3BNPFhddrHQVm9BDJ7VLcSx7rzf8TH2hoWntc7qJQxEL8IvzBO/8OxF7NRiNA
	87ZsaxZw==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hikFb-0007Bw-7r; Wed, 03 Jul 2019 18:45:03 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 1/5] mm: return valid info from hmm_range_unregister
Date: Wed,  3 Jul 2019 11:44:58 -0700
Message-Id: <20190703184502.16234-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703184502.16234-1-hch@lst.de>
References: <20190703184502.16234-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Checking range->valid is trivial and has no meaningful cost, but
nicely simplifies the fastpath in typical callers.  Also remove the
hmm_vma_range_done function, which now is a trivial wrapper around
hmm_range_unregister.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
 include/linux/hmm.h                   | 11 +----------
 mm/hmm.c                              |  7 ++++++-
 3 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 8c92374afcf2..9d40114d7949 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -652,7 +652,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		ret = hmm_vma_fault(&svmm->mirror, &range, true);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
-			if (!hmm_vma_range_done(&range)) {
+			if (!hmm_range_unregister(&range)) {
 				mutex_unlock(&svmm->mutex);
 				goto again;
 			}
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index b8a08b2a10ca..6b55e59fd8e3 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -462,7 +462,7 @@ int hmm_range_register(struct hmm_range *range,
 		       unsigned long start,
 		       unsigned long end,
 		       unsigned page_shift);
-void hmm_range_unregister(struct hmm_range *range);
+bool hmm_range_unregister(struct hmm_range *range);
 long hmm_range_snapshot(struct hmm_range *range);
 long hmm_range_fault(struct hmm_range *range, bool block);
 long hmm_range_dma_map(struct hmm_range *range,
@@ -484,15 +484,6 @@ long hmm_range_dma_unmap(struct hmm_range *range,
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
 /* This is a temporary helper to avoid merge conflict between trees. */
 static inline int hmm_vma_fault(struct hmm_mirror *mirror,
 				struct hmm_range *range, bool block)
diff --git a/mm/hmm.c b/mm/hmm.c
index d48b9283725a..ac238d3f1f4e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -917,11 +917,15 @@ EXPORT_SYMBOL(hmm_range_register);
  *
  * Range struct is used to track updates to the CPU page table after a call to
  * hmm_range_register(). See include/linux/hmm.h for how to use it.
+ *
+ * Return:	%true if the range was still valid at the time of unregistering,
+ *		else %false.
  */
-void hmm_range_unregister(struct hmm_range *range)
+bool hmm_range_unregister(struct hmm_range *range)
 {
 	struct hmm *hmm = range->hmm;
 	unsigned long flags;
+	bool ret = range->valid;
 
 	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	list_del_init(&range->list);
@@ -938,6 +942,7 @@ void hmm_range_unregister(struct hmm_range *range)
 	 */
 	range->valid = false;
 	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
+	return ret;
 }
 EXPORT_SYMBOL(hmm_range_unregister);
 
-- 
2.20.1

