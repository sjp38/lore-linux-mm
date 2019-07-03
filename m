Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A46DC5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5421F218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UdUPRM97"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5421F218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E7B18E0025; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 797F98E0027; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48BF48E0025; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EDC528E0025
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 18:02:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a5so2068348pla.3
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 15:02:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NS2VTlTL88GXGtGIYTIdIxcDk6oTfWlSKFcdult1b6c=;
        b=i5ZZ5ZIpejJYY1qeAvLMZ71D0TRKb4ohR7xev+ioMWDqzGS29/0mAt4XMNv1Gq34pX
         6aAzUfQ7bK8aHNQ9FvgD6UdsCeM35l8Fv+1jQTNP1QPqMgW1aVn4tz63huNnpuJ64yLc
         rcN1s/VbiMmbmFA3k0MaQ3aPyTRV0d6+4fpSSyPUtrBC1K1Vf+F8Hy74FwIifssvYuma
         Sx6WOpeSgLRrvtB7VbPIrbeTjrhE9HJTHcAljgWJt74wEZF8M/9ZDBJW5Tspq+G+42wN
         kBXUe+bEXkAujEyetQhqFy76Iq+qWgeyPOu25iGBJpAJ758kZ8KOpVOOYNXjMZgtdTP0
         MmUw==
X-Gm-Message-State: APjAAAXkeCoyx5REqdayy565hqc9d+bWHPv+plKxOcSGPT9t6JfBGB1R
	0VoMNmn3IEaIb8bFQVdSZ/wYgxEqidCbRzNzgq8YIcyVdYzMoyZ5SByFeoWFLwsM1Sbm9nXjm1T
	5VnTxnAHJCXBqNb3uvcoU7ySccSIx+n8kkzyq42+TyWw0Q9yUuYR/LRPYDq+M7dE=
X-Received: by 2002:a17:90a:fa07:: with SMTP id cm7mr15551218pjb.115.1562191340612;
        Wed, 03 Jul 2019 15:02:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8jEYC1a1LueUKwEEGMZHVuN4jPAJ6z6Emmhl1aBMOFvKJsNbV8S/qpQknWxTRjB3neOVE
X-Received: by 2002:a17:90a:fa07:: with SMTP id cm7mr15551118pjb.115.1562191339442;
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562191339; cv=none;
        d=google.com; s=arc-20160816;
        b=mH80nLOUxOb73gUcPwnuFXMTzlW04H4Kvmb/znWU7XXZ0P/mwFOT3hRRQxgNF90REJ
         xuhf05vzecTFr89lcl1APdaHxUeMZNlRbcDEJt0sf6fAmi6Kx1tO/yDdXYuskS5tArn9
         dCBZxOfPfJdVNHubCYB8npXrMmV7ANacjHuI4UoJ+XuWrWW1ZtxsZFDvALaIhiRwZCJp
         ulrZ+FJT7ujmhnjUv4+r6wFpbOZHek9bz0S5prW7fRhSNnzN/B8cLF80ZaefgSZbdqYh
         KldU5T1GJt447eZKB8nbN5pa3lIDweEcP2BnWqeCe7qRJeuaTAUCuPJc41jmhc63t1fY
         rpVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NS2VTlTL88GXGtGIYTIdIxcDk6oTfWlSKFcdult1b6c=;
        b=pcwgzmIZUFx6l9xmRT9X7mUHvKILjX40s8Me+SqfrkFuaxn+LjTaFj2G72wBNZvzkC
         UNWA/Aj9MhTRm58kPwro6yeUVNeOzJ1UA/mZprwfc56E2xehaHR7So51oQUql4d68nmw
         +vrYJDel9pFh/HT7IKX28bnb4gDgPbjA7lEq6MiqWOxvsCax3Z6ri9DopVjXiBS9LkTv
         vdcpo6mG3Yptx/2kpnUWhW4Dq+WZvHG70G48fx+Ov2RfF+qzBUgPDOaTZ3DXe/He3k94
         6AfgK6aMsJqkaN6Rdm/GQGTMMDZQDTPnehA3Mifv5kxqHAp/7yB6p8UDTrbcOte8cRz8
         XmNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UdUPRM97;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x63si3384334pgd.224.2019.07.03.15.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UdUPRM97;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=NS2VTlTL88GXGtGIYTIdIxcDk6oTfWlSKFcdult1b6c=; b=UdUPRM9702sfvLifCc8pPMC2aw
	LKUsn7kyOwVNfN6MlrKBQNCi3nL1x8SmpXj43Q3xEMu+cfuC1MdIb1fHyxiZlXTDu6PCk1+p7niBV
	FZ4+8Xio8+nJ67X+uBfr7pTHgYLPuNjdCCO9+K0R9zqULuTbibDw/B77irgHa+EZfA77+WmQv5ySC
	y8D4s0hg1LlbsNh7JmvGGCBqtoHIRkMxn1/F2W/r0h7nD9QHSYIsKtQLm6F8yk4X9R3DdzINGvsSO
	F3c/PXuwTOr4ghT6Wy+P1265stXrlBzmxchknyosBXC9J8PZzgsJzPZlCsyGNOEAFf57nQ6sHdKzN
	H+pV8yAg==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hinKR-0004EQ-QL; Wed, 03 Jul 2019 22:02:15 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>
Subject: [PATCH 1/6] mm: always return EBUSY for invalid ranges in hmm_range_{fault,snapshot}
Date: Wed,  3 Jul 2019 15:02:09 -0700
Message-Id: <20190703220214.28319-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703220214.28319-1-hch@lst.de>
References: <20190703220214.28319-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We should not have two different error codes for the same condition.  In
addition this really complicates the code due to the special handling of
EAGAIN that drops the mmap_sem due to the FAULT_FLAG_ALLOW_RETRY logic
in the core vm.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
---
 Documentation/vm/hmm.rst |  2 +-
 mm/hmm.c                 | 10 ++++------
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 7d90964abbb0..710ce1c701bf 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -237,7 +237,7 @@ The usage pattern is::
       ret = hmm_range_snapshot(&range);
       if (ret) {
           up_read(&mm->mmap_sem);
-          if (ret == -EAGAIN) {
+          if (ret == -EBUSY) {
             /*
              * No need to check hmm_range_wait_until_valid() return value
              * on retry we will get proper error with hmm_range_snapshot()
diff --git a/mm/hmm.c b/mm/hmm.c
index d48b9283725a..1d57c39c1d8b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -946,7 +946,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
  * @range: range
  * Return: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
  *          permission (for instance asking for write and range is read only),
- *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
+ *          -EBUSY if you need to retry, -EFAULT invalid (ie either no valid
  *          vma or it is illegal to access that range), number of valid pages
  *          in range->pfns[] (from range start address).
  *
@@ -967,7 +967,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 	do {
 		/* If range is no longer valid force retry. */
 		if (!range->valid)
-			return -EAGAIN;
+			return -EBUSY;
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
@@ -1062,10 +1062,8 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 
 	do {
 		/* If range is no longer valid force retry. */
-		if (!range->valid) {
-			up_read(&hmm->mm->mmap_sem);
-			return -EAGAIN;
-		}
+		if (!range->valid)
+			return -EBUSY;
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
-- 
2.20.1

