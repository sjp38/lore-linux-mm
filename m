Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7404DC76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3072821993
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TXUpZd6L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3072821993
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1A896B000E; Mon, 22 Jul 2019 05:44:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98D628E0005; Mon, 22 Jul 2019 05:44:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87B0E8E0003; Mon, 22 Jul 2019 05:44:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45D566B0266
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:44:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 191so23497305pfy.20
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:44:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=urPxkwOym5lxnAAUEUOneOxI40UkREYaiMYiFYZBiIs=;
        b=LBvZ5aTYk0VSsvitE09JDQ5xW3jtSI67mesa0VRYtvalvNLb4gXU0fqfT3/bXrxRbP
         kH+VGbCfmQ8vYwb08HUmnpCpOAXXm0uF5lCBqTGNBt1hs60TsNLEf5nWg2l4bCPAU1eD
         FJAoXb2igoK6I2UFvTIGnbtYC/5McQSD2fZrQfjoAUK77oYa4C8a2IzyEHx0znjbTiiA
         Du5oxhLIqRT3wbTeUAjFz4BT+EYVtz8jsiFX6ohFByH/BrnLaS6agqDMOah46wvRRV+T
         +X9+zk7FmuZ+VkRx9jJMYKNi36VmkPnUF3L8TfjU+gIYHdLuz9Hn+JpYctgh2yzafqzx
         b4Fg==
X-Gm-Message-State: APjAAAXAsCRPnWFJmANEezoNfzxErvPHf+PrSgaPFbYzdAYkCVzZn8lp
	knRksYTs7Lk5w2Fdk66fRDiT5tPDrsnAfkgzMylY7d7nI1v3RV/bUmpTcfXAV4eX1QxUZBUhL8C
	hAb/e7zotKH7s1s8+8trQFGQw6nmSRYDaCT++CB/GxSkUGlFMEDZMO/1iIyRyoxI=
X-Received: by 2002:a17:902:7288:: with SMTP id d8mr74378604pll.133.1563788676949;
        Mon, 22 Jul 2019 02:44:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZ+HLFmIgNNb+ZFfT451rz24ee8ms7jvIhAbqI3yzY8VPdmW1tGaKrcBb4+xrNhmUdU/ZA
X-Received: by 2002:a17:902:7288:: with SMTP id d8mr74378516pll.133.1563788675982;
        Mon, 22 Jul 2019 02:44:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788675; cv=none;
        d=google.com; s=arc-20160816;
        b=h1CiQa2pIjnFFehKYRav4wPtIKUAlozgTeHCxPmg2xYjXYL61qMb6YaVTLQaYl8MFE
         7x67IG4DsTIQrU1mUAFo2bOlrVdzfuPOa6iBGVx41zrfrVS8YNFiJo4K7vn65uft6O0L
         iLzn6FYq/IHqYyVbmwnvC5BAZkkajbJgO3pqQ+bXasNxENdWDVyvahuWwXDPY4FPALCL
         3oiqiIUrdVOFyVzx3T3UJ6SNpADsMfI+439p/iAdy+ziAQRPqFChUjhyayTjt/SZKewK
         niNx1q4XlMBYwLQ0iiQDjkH+9Za4WjKik3MrIwD4qic3vgEuR3goha7/jvNIJx2s9dlC
         yMBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=urPxkwOym5lxnAAUEUOneOxI40UkREYaiMYiFYZBiIs=;
        b=sOA/eUTuIcB3+DM7IDMU0tO6jKgML/Zl3hA2VVpi7uFu1oGdD+8wxipenKCQKvtbk5
         ZzFU5eQn4/rKkrrnaE7OfMmW+3SU3fSZcMKyaWdERQ44LDSvlaxBGzD/PQMN3bNU+JMB
         WoYuxLiCdmWCvbycAAa9agmxmxeRJVWSQ9ALImNq4aIpJwtSsTh18sOBJriyKaA4pNCA
         TkpSFFou99jOXO1txYs/VSraD33mPCXmMQQPtTVgvpl74omOR7uYIP7HU5m7qj5I/fFO
         MD5bVJJWGL2p4VLBVK1THuttqev+9q6oQOpft6h6mXqW4AZruIl8HNCtJmHLVewZID/Z
         WAZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TXUpZd6L;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 188si10198975pfv.146.2019.07.22.02.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 02:44:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TXUpZd6L;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=urPxkwOym5lxnAAUEUOneOxI40UkREYaiMYiFYZBiIs=; b=TXUpZd6L0YbxCncr1sT24mkFmX
	KdB/rJzomvHFe2vcYwtDiUWfXEb1N01spG6VnZkFRqZff6JTTSyVg6e2XYqqfAEPSFbxcPRWZvq7C
	X2Qor61E/+M2izt/dhGwdlhTh/mx4lUGDG9IFMT3BJGDUGZYpplivXhqVFZhj1Yts7FzlI5fZ0EuQ
	HPaB2GbWNvXyIHipogv1Dam/RNzkNllIiqYX3fN8H+EielY8T5BUPYFjBqVtiWN7qpDT6hCZdSE5Z
	e0YIgF2g0ItU/oWpaJMr+Lj/9moAJg5bcrft1jtgZcH8pGR341dRszQE/TWWzSWibmPDL0j4K+oQ3
	g/VnYbfw==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hpUru-0001rb-RN; Mon, 22 Jul 2019 09:44:31 +0000
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
Date: Mon, 22 Jul 2019 11:44:21 +0200
Message-Id: <20190722094426.18563-2-hch@lst.de>
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
index e1eedef129cf..16b6731a34db 100644
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

