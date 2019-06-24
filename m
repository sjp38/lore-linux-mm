Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D8BCC4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD59720656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="i+h5jdKO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD59720656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E51FB8E0009; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD8988E000A; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF0978E0009; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 71BC28E000A
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i2so6891574wrp.12
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Y7+HSfyIPKIyVRlHiPSUTXfMPMA2cBMnzwF3/BJJWoM=;
        b=BqOmy/kO2Y2p/J/T2qLA+VYJgg2PUcvXM3rwZ6J7724FSm9FohhjG9RoE/Gb26Pf/+
         fB0gG4c7SJcUAdjkV6+qhy0u1o07YrH+Jccjm3rmGLMwcCzly/sihTnN+tZOtfIpqeWh
         CCDXohxqB7kqGvKR5K1He24fBWKjv8kigrslVsB14LVUD/3zZThNJ2p1w4kmDpZqvOKT
         plURq46XuWaceZO8Feg0fsEih/dKpbhIPaDLlnLEr07dxEGmumhyUUePkzKAzP75oCV2
         faZaz2m/KjBiRsSRNY3IR6Qp8o+9lylWjjkG26rvmpANAxmYlBQ9PnmTiwRE/vmCaMl9
         B1sQ==
X-Gm-Message-State: APjAAAUw3X2/P0/St9CP5pEx0MTB7OsvdnJBWkCN3ZBzqrYwvPjtyY7O
	JO6LjjJYtrAH3NqL891A5kwv0ZkPiLGZ4W9PvH4ejz1YykeDpJ8sqfSa9uMNYOSCvIIc875lLmE
	tumySIpbKOrDov4uMv1Km1NWTMqS1ANuZDegv+WItxCB5NjWZATc9Ni11A4is906vqQ==
X-Received: by 2002:adf:f542:: with SMTP id j2mr49635972wrp.16.1561410127955;
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
X-Received: by 2002:adf:f542:: with SMTP id j2mr49635944wrp.16.1561410127141;
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410127; cv=none;
        d=google.com; s=arc-20160816;
        b=W/6Xwd8ef2k1kDRE8q7pBcnjqoio+NNsNVYOjnqfuXWaPDA6TeqxoYbBXPncVzoWCt
         iouHgZ/G6gNEEcf1vWkD1dpUu+DixqvDORXjDnkQrex6HPjGLiXXxGGKbrEtXCi7LZYF
         puD4AOkk3mvR5ex2KV88aqAKt7zxCoRhIJRjHtAYYMQCL0cbxVfXL6ruXP0lz59PNGjs
         kKmP5BpZhOS4rcsp9IkEv8rTBOI62BHzfWz4QEiXZn0j2GKT0N+1NhxyO4o2RbnxO5An
         1dHicIsxBpuwg/DcHuIiQeqKE1R1ieI5Wl0ZGdWHD5Ix1BSBa3rImvydn4dpM1ljya4f
         0S9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Y7+HSfyIPKIyVRlHiPSUTXfMPMA2cBMnzwF3/BJJWoM=;
        b=aju9sPxXNd3bPGvytfRbhyWBAOGnz55byW4SDOfH3zs6IrMFKTY2t+7MNtC7+x1mz+
         RwQe9R/Ww+2fMAAwHPffWKrfB+0BfYRV2g48rmcNklVQKLLsXLOR9vzWUinoCJy+L/bB
         lk4ChepYi6F05p85mT8Cs0S3S/GkNHCAYNKbi/SaGgVrqQIFEeMCGHH717gPXCBs9IYx
         MViFmdQyrS0UhJbsVqmjYptvWCW7hocxVm5bHV1zgY2IiUo/fKIPb63Gom3gUACq2dDK
         QhOzuF1nZ+DMo9hU/jxtWNfykKh/SAiwi0INNRYPOrHbFuEPZ2hzorsvZguS7pkSkz9S
         qRUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=i+h5jdKO;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p2sor350098wma.27.2019.06.24.14.02.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=i+h5jdKO;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Y7+HSfyIPKIyVRlHiPSUTXfMPMA2cBMnzwF3/BJJWoM=;
        b=i+h5jdKODrJM6HAgihfib7r1p3HTIoXotHgwp0BCzd39jXyo1BGTDGN5CpLNMF70TR
         V6PVWeRW3fvAO6anYPbAasncAm2gfDig99onMjq8DGbcxmOsbdJoUx+UOv3Ew172buN4
         Vpsbiiy/5q+1oRn8UdTlfhMTuBnx4G1ji+wcVIaoYK5Nbt5H8mqxT5v/JzerbsooORD5
         HimcJCbD82rblSOa3TsdNlNx3R6AxGDFuxuK+lEyTuOggfGhT5ua5kBPNLimVjJkqu5U
         RIddsbNK0RH7LIGRspoDR8r0YYISQuOycZZHVH/0xfxFXODjXkabiQ3hMa0QYuximxJ6
         o2Mg==
X-Google-Smtp-Source: APXvYqxYsEWfPj+ojP/Pdo0/oemDCD+9/xSgl5N/QS6OZzqvHa256HMQOw+3zV/4M5gAiwA2ZCoPBA==
X-Received: by 2002:a1c:228b:: with SMTP id i133mr17321325wmi.140.1561410126760;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id k125sm600943wmf.41.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6D-0001Mv-3O; Mon, 24 Jun 2019 18:02:01 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v4 hmm 10/12] mm/hmm: Poison hmm_range during unregister
Date: Mon, 24 Jun 2019 18:01:08 -0300
Message-Id: <20190624210110.5098-11-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190624210110.5098-1-jgg@ziepe.ca>
References: <20190624210110.5098-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

Trying to misuse a range outside its lifetime is a kernel bug. Use poison
bytes to help detect this condition. Double unregister will reliably crash.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2
- Keep range start/end valid after unregistration (Jerome)
v3
- Revise some comments (John)
- Remove start/end WARN_ON (Souptick)
v4
- Fix tabs vs spaces in comment (Christoph)
---
 mm/hmm.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 2ef14b2b5505f6..c30aa9403dbe4d 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -925,19 +925,21 @@ void hmm_range_unregister(struct hmm_range *range)
 {
 	struct hmm *hmm = range->hmm;
 
-	/* Sanity check this really should not happen. */
-	if (hmm == NULL || range->end <= range->start)
-		return;
-
 	mutex_lock(&hmm->lock);
 	list_del_init(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
-	range->valid = false;
 	mmput(hmm->mm);
 	hmm_put(hmm);
-	range->hmm = NULL;
+
+	/*
+	 * The range is now invalid and the ref on the hmm is dropped, so
+	 * poison the pointer.  Leave other fields in place, for the caller's
+	 * use.
+	 */
+	range->valid = false;
+	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
 }
 EXPORT_SYMBOL(hmm_range_unregister);
 
-- 
2.22.0

