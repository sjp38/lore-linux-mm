Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE5F7C32754
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72D5820B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="MzTXpv/R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72D5820B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C90496B0003; Tue,  6 Aug 2019 19:16:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3F956B0006; Tue,  6 Aug 2019 19:16:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE9E46B0008; Tue,  6 Aug 2019 19:16:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB246B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:16:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l9so80222944qtu.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=evI7jo74G4Gx7Gga7ZV8g3f7D3AhHv7OMI4oYy7KjpQ=;
        b=lrf+LECSpFVpbNY7ytBclsIZaemZEIhu9YCSRqXkiqEH6sgrikttAMmBrESw/kDZAj
         w/A0OyNlqChtyrq1Fa5GqC1IiuYCzOWUPTDE3XdACcM57sd8MoB0ZFp5I5OiITsMGM88
         gYILy9UAlRtuy30i32nE+xoYbAgmkdKk9Mw+owc0O8iK+5XrGDFJNp11WoissBr1C0O0
         l1Rstcs7Ly0qczDYB/PsLrZz2ogVmkd+u4M8RSM9y93AfsIf2O++kHKiqNkHFVgQd+eC
         uok67B+RW50SN4aeqeuyDEjxAg/q3UyAYd1SHpMIOtBvQKJDvR1VxQpDNi42mUjXgghT
         OdVg==
X-Gm-Message-State: APjAAAVwNf7c1+SpCR1cL467yj9F/qYjexRVPGc9qZMUav7/pKeUQOUo
	Rfh6UEJZA9diBCx5ccvssA5QN+MAi6O48eDONR3BJmREn2FduK9vRe7j/pt3kAHmnqfwmcS8sCG
	6RAQqI4Z7/66UkrFbvgHomMp3GRJcLa+9PjeD6ZplsczqIalrXdKlp5SKqINnXO4mGQ==
X-Received: by 2002:ac8:f4b:: with SMTP id l11mr5291320qtk.215.1565133376338;
        Tue, 06 Aug 2019 16:16:16 -0700 (PDT)
X-Received: by 2002:ac8:f4b:: with SMTP id l11mr5291267qtk.215.1565133375413;
        Tue, 06 Aug 2019 16:16:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565133375; cv=none;
        d=google.com; s=arc-20160816;
        b=eR2MFLO8BN/VcomOf2DAmvSlCXDpqUwMQCOjrEx9exxcXBDOuvf/2b/7Kqh90UfJHt
         lWGhzJ8h1kI/3+Ml35ilS92UCjlGFnufvXsqrZSyjwgetzh3rHSwVc0TZCZ/tOh7I45D
         095vnWjTpRxnVlqnqZNMoDX3cQBfcy+AKZ7LOV/OyhnjY2dcgch3IvIu3mSUYp2mKtKi
         ik18DA7Q5r6AKcO4jgl4Fr/9nBjeEFcCbVkL+JTI6lJBVbl0yS/zBH6PGMo1Bo/s5bN3
         F/rqSsemm72L61RvAwzIYuXrhzpUkUBcI4vWWU3M213X90r2vWcuiDPUGDYCdx7r0Kht
         SIyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=evI7jo74G4Gx7Gga7ZV8g3f7D3AhHv7OMI4oYy7KjpQ=;
        b=A8DTtVZ3MxX/qjKqo8HptRpGr4m1ox8axkPAjCDVobYKEmA1ldklIUd6GfmnuIOCfo
         3uR/65CNUXWpBZyvKlR7WJ6KMp+mL84I2LiqH5QBtO51qIbVxgo13TX4TO4kQeuXvM86
         rvbd3Y1qBR02Cpd5FyGZhvcaqkxi36ZF+7Xuh/G23DefmYLw5mLEAql0qHUMRIeM1vrq
         S80SbKiwpj9C7Hv6tyf6H5cBt55E6yKgBYW8pRAlinQ2KMWbOq21UpuBean6p6nnHc51
         qu5sCd6C4bj/OYeYJ1GyWNogK1UodSb1NzDjez4DB97+7xoPM0UXCJMCzYjujE48zqGS
         KzlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="MzTXpv/R";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor50981160qkd.153.2019.08.06.16.16.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:16:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="MzTXpv/R";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=evI7jo74G4Gx7Gga7ZV8g3f7D3AhHv7OMI4oYy7KjpQ=;
        b=MzTXpv/RThZvTM0oekrE0HbJIq9MDfLDK/pFUY/Kg6pyTj13D+sPiKCI/dSGwPAxpY
         66cmu6NttsKhYSMYlnguyr7uhmgAbn3zoEecwJHbFK40+26VHkYuF99AdRjGXrECGqPh
         vtfbOQsp5XxERMNpAIlGBC0fNvBHCI4Xe9NbY9LiKeaS2gZSeE7ortCdr7AwymC1bQMf
         tH8isbUtYa12pesEmXPJTyySS7DaU/IrFA7s+yY18pgcvmsoF40zJdJl86bWxSpitktu
         59wGxHKZqUMMqNyx4DORY6ozb2JQGWE2AME4lSBAP89G+fxJ+NZfrKn08DfZpc+bITKO
         VTAg==
X-Google-Smtp-Source: APXvYqylqTmNzPQYqTYhRiwrI4AtCqibIZpw6EBPoIBj42tnctW/9AiKc7I50IcPqwnV2QCyiSKRxQ==
X-Received: by 2002:a37:660d:: with SMTP id a13mr5780388qkc.36.1565133374824;
        Tue, 06 Aug 2019 16:16:14 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f22sm35086171qkk.45.2019.08.06.16.16.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 16:16:14 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv8gg-0006eG-0j; Tue, 06 Aug 2019 20:16:14 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v3 hmm 01/11] mm/mmu_notifiers: hoist do_mmu_notifier_register down_write to the caller
Date: Tue,  6 Aug 2019 20:15:38 -0300
Message-Id: <20190806231548.25242-2-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190806231548.25242-1-jgg@ziepe.ca>
References: <20190806231548.25242-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

This simplifies the code to not have so many one line functions and extra
logic. __mmu_notifier_register() simply becomes the entry point to
register the notifier, and the other one calls it under lock.

Also add a lockdep_assert to check that the callers are holding the lock
as expected.

Suggested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/mmu_notifier.c | 35 ++++++++++++++---------------------
 1 file changed, 14 insertions(+), 21 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index b5670620aea0fc..218a6f108bc2d0 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -236,22 +236,22 @@ void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
 
-static int do_mmu_notifier_register(struct mmu_notifier *mn,
-				    struct mm_struct *mm,
-				    int take_mmap_sem)
+/*
+ * Same as mmu_notifier_register but here the caller must hold the
+ * mmap_sem in write mode.
+ */
+int __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct mmu_notifier_mm *mmu_notifier_mm;
 	int ret;
 
+	lockdep_assert_held_write(&mm->mmap_sem);
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
-	ret = -ENOMEM;
 	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
 	if (unlikely(!mmu_notifier_mm))
-		goto out;
+		return -ENOMEM;
 
-	if (take_mmap_sem)
-		down_write(&mm->mmap_sem);
 	ret = mm_take_all_locks(mm);
 	if (unlikely(ret))
 		goto out_clean;
@@ -279,13 +279,11 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 
 	mm_drop_all_locks(mm);
 out_clean:
-	if (take_mmap_sem)
-		up_write(&mm->mmap_sem);
 	kfree(mmu_notifier_mm);
-out:
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(__mmu_notifier_register);
 
 /*
  * Must not hold mmap_sem nor any other VM related lock when calling
@@ -302,19 +300,14 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
  */
 int mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	return do_mmu_notifier_register(mn, mm, 1);
-}
-EXPORT_SYMBOL_GPL(mmu_notifier_register);
+	int ret;
 
-/*
- * Same as mmu_notifier_register but here the caller must hold the
- * mmap_sem in write mode.
- */
-int __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
-{
-	return do_mmu_notifier_register(mn, mm, 0);
+	down_write(&mm->mmap_sem);
+	ret = __mmu_notifier_register(mn, mm);
+	up_write(&mm->mmap_sem);
+	return ret;
 }
-EXPORT_SYMBOL_GPL(__mmu_notifier_register);
+EXPORT_SYMBOL_GPL(mmu_notifier_register);
 
 /* this is called after the last mmu_notifier_unregister() returned */
 void __mmu_notifier_mm_destroy(struct mm_struct *mm)
-- 
2.22.0

