Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C37EC06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37A67212F5
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="almZJDAb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37A67212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DACC6B000C; Mon,  1 Jul 2019 02:21:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EF6A8E000E; Mon,  1 Jul 2019 02:21:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 005BE8E000D; Mon,  1 Jul 2019 02:21:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id A75036B000C
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:21:02 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id u10so6739454plq.21
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:21:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MFOQKdBekg4uOAbPxr4fTMLEjMHRTQOu8rr2EDfIjss=;
        b=LUMzs9Hqy9K9Y4l5XmCEVSlERPR7HRgC7rHiVRjB9CnMmNU4DU9SdJquYszTUocLVI
         8pXsrcO7yvFokwzeBdNVKkQkRJbUhkDhW/qtzghNUWykVigXTytxZCBeGQj0Q1TMBQwz
         vRKp5srcANBHfQfNIG+eAemRjBGiYzE5w5y+xZJQDGgvifBcrrvlonhoPX5xKIAhCVTL
         HtEvmYg/8niIl5x9LnAc6tlJx74Rr/W81GGmRmMEbDn6wV+O7Dn1jjcRNykw0DM1+Yik
         ogxFM7U4lzYYxBELxcM9PGkWUzdGxLu1Tm+z1ZllxpVa0i7cKD5zMu4/Ww9bhayxkMIM
         m4rA==
X-Gm-Message-State: APjAAAWRUogPqlDSeUv5LaURwLcBzfI3HUCYO0+GJy4FExG2Q6E/8/0P
	Blh5i86y+QZHxNcf/7xUGLD+Yi06qn2jhdT5u/46g7LYgJFRMF4TphyYbYTG/joflPHu1DP6c6t
	7uMlVbiu1bVHKSORicIUGYdnaSgdHIPRYqLdAJcSu/R6LlEWBETTp0foMpScSHIg=
X-Received: by 2002:a63:5212:: with SMTP id g18mr22075543pgb.387.1561962062276;
        Sun, 30 Jun 2019 23:21:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwR5quLLVJENpY2qKFxGidN+XDWQ0mMKKhYpp0urQvkTnmj9JNFH0jvrpLCeGrkZ1C6j3fE
X-Received: by 2002:a63:5212:: with SMTP id g18mr22075489pgb.387.1561962061528;
        Sun, 30 Jun 2019 23:21:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962061; cv=none;
        d=google.com; s=arc-20160816;
        b=BCaOtgakAra0Nq9cEGtLadcmqVdLzYs+WZFZsUr+vKx+g7ScjhWa4pi/qRdiK+J+/C
         GhAEB76CTmwi1JxQK8hUGvMC/dWdCIxqUcv0cyPmzDElpewLvjSvQJxK87WO00n+lvtx
         gwtO/yVSK9S/Tua46fLBa8Tz24eaRkwJlFZjALqRpQKKAmDFjC0A8nz7qp7MNKrGklOi
         ZnCU5Lno8/Lzf4S9QHOTMAyAIZF7pHvXJU480KpTstwby5hOd8IYgmlGHJAuFgl/ePkp
         rnHx+AljyYzqJ22pgFa+xMDdL1Lm1P5zIPmLbf2xqsmkPU8pErc+utne2SuIOINyzbws
         Q7NA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MFOQKdBekg4uOAbPxr4fTMLEjMHRTQOu8rr2EDfIjss=;
        b=q+bJRRH0aC6XJBTaJaCld6FEjEjMBnl32scfxz2SpHeFxJq6iZpqtyr18R0t6LePAX
         ve7E279ca48/PBtKrzPBNDPNSw8fu2hlO63M8L/w8DH9XLMZaKZzUD3KzrfXwxCHKY2G
         s97+eC/xwDRwVbGQhyxdixkuA/tvoFNSWNS0WCi+/nfTXD512+hRQUEe3OBOogA1G1UO
         VXpxuZWQEKLQe3H7thMOcDd3jj/vORujYUWNEDxWLXNmavexNkaviai9QW6VL8vumJC0
         5/U+eFQQYynly4LjYuS56sjQ0NMh1p6629WGjxtDRFG7xv1J0iLOaXBsPBwtFBIY5xiA
         R53A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=almZJDAb;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g7si9732100plb.29.2019.06.30.23.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:21:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=almZJDAb;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=MFOQKdBekg4uOAbPxr4fTMLEjMHRTQOu8rr2EDfIjss=; b=almZJDAbXnBzGls3pOj8NvkNrg
	EDtv5JCQhprtUoj3msL+8HdfB1SF/bGw3a7VYmwkTA3dICFI4cqC6GaUuZTpYn1JfQvs8543MUZQa
	/cjCFY7Nb30zzkZ1LWtxW1UbEYJtXcLWKms8VR3iI42b3WG6HreqXzn/j+dgC92Bh3IT+9q76eFjs
	HdoS+gFfVfgE0Ik93/RTa7Pft0ZeMVk5W+f1ouhTl61ym6nAg6Lq3hqUVshyyXXLoAgViMSi61syX
	4zsqcXeDSTjSDrYePaOl1SrEhHZHmGtM+ScRgoGqpBcAAWLJo17YUdU+msd/f6SA00fh++p5Z0Q+O
	AKbcbwVQ==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgQ-00036S-QO; Mon, 01 Jul 2019 06:20:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 16/22] mm/hmm: Remove confusing comment and logic from hmm_release
Date: Mon,  1 Jul 2019 08:20:14 +0200
Message-Id: <20190701062020.19239-17-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

hmm_release() is called exactly once per hmm. ops->release() cannot
accidentally trigger any action that would recurse back onto
hmm->mirrors_sem.

This fixes a use after-free race of the form:

       CPU0                                   CPU1
                                           hmm_release()
                                             up_write(&hmm->mirrors_sem);
 hmm_mirror_unregister(mirror)
  down_write(&hmm->mirrors_sem);
  up_write(&hmm->mirrors_sem);
  kfree(mirror)
                                             mirror->ops->release(mirror)

The only user we have today for ops->release is an empty function, so this
is unambiguously safe.

As a consequence of plugging this race drivers are not allowed to
register/unregister mirrors from within a release op.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 28 +++++++++-------------------
 1 file changed, 9 insertions(+), 19 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index c30aa9403dbe..b224ea635a77 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -130,26 +130,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	 */
 	WARN_ON(!list_empty_careful(&hmm->ranges));
 
-	down_write(&hmm->mirrors_sem);
-	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
-					  list);
-	while (mirror) {
-		list_del_init(&mirror->list);
-		if (mirror->ops->release) {
-			/*
-			 * Drop mirrors_sem so the release callback can wait
-			 * on any pending work that might itself trigger a
-			 * mmu_notifier callback and thus would deadlock with
-			 * us.
-			 */
-			up_write(&hmm->mirrors_sem);
+	down_read(&hmm->mirrors_sem);
+	list_for_each_entry(mirror, &hmm->mirrors, list) {
+		/*
+		 * Note: The driver is not allowed to trigger
+		 * hmm_mirror_unregister() from this thread.
+		 */
+		if (mirror->ops->release)
 			mirror->ops->release(mirror);
-			down_write(&hmm->mirrors_sem);
-		}
-		mirror = list_first_entry_or_null(&hmm->mirrors,
-						  struct hmm_mirror, list);
 	}
-	up_write(&hmm->mirrors_sem);
+	up_read(&hmm->mirrors_sem);
 
 	hmm_put(hmm);
 }
@@ -279,7 +269,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 	struct hmm *hmm = mirror->hmm;
 
 	down_write(&hmm->mirrors_sem);
-	list_del_init(&mirror->list);
+	list_del(&mirror->list);
 	up_write(&hmm->mirrors_sem);
 	hmm_put(hmm);
 }
-- 
2.20.1

