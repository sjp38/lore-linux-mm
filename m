Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35E89C32756
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF3CC20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="WIvITimi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF3CC20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16CA26B0007; Tue,  6 Aug 2019 19:16:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11D9F6B0008; Tue,  6 Aug 2019 19:16:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E42846B000A; Tue,  6 Aug 2019 19:16:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAD456B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:16:16 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k31so80596476qte.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qo3M/m6bAMWNKeEf1KSsSvYS6KA/79bnXZ/MG9HQ7+c=;
        b=eHfFsvBTnp98+vCQpplcbL8T3REYSdRFc84dyLOi6sACCI+u9cFsKXOBRwtNqRSfy3
         +vhmbvP2Wah8pRRtfdr/oGxPUrQsTXbE11z3pBWqV0hcO+xC6g3QYyHhPcUL4t4MNUpL
         6bMCiVPBDnrFdt1OP4sce/egw8VIJRwhk4rW55ciYsaNNClOCFPeWV8ugY27TohELk9e
         ue0xuxhgwV1MwJq1zrcCajEXv8OJS2VzZWFm3L+8MT5XhVxokllEL/RV4RNZPIaXivBI
         w5LYFuhS1JA4jLM9o7/KzpCou8Nb1DS2z1yZBguSkqf1yTkVzKb4ir8oetd3ODxr5OJ9
         EHLg==
X-Gm-Message-State: APjAAAV/FH2aPU2vrzd15LSoq/V7pZULmHvWLCS4AC7OZRB9RlzLaeKv
	OTQfKITqvW+kmDEAYnVQocMVOe6EmrTLXDbZGBbF39xGmoNQZU3HKmlEjw654LY2A12qIeCF1+I
	+x383f/w7TgFXUixR23vsYCCfoAkqvnJbgQTUViKZiTmGAQ7C0bSxFPrz5HIMKPWP/A==
X-Received: by 2002:a37:6397:: with SMTP id x145mr5382806qkb.56.1565133376492;
        Tue, 06 Aug 2019 16:16:16 -0700 (PDT)
X-Received: by 2002:a37:6397:: with SMTP id x145mr5382762qkb.56.1565133375863;
        Tue, 06 Aug 2019 16:16:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565133375; cv=none;
        d=google.com; s=arc-20160816;
        b=VgPVoW4Qxd215EAjksidYwc9wtERby6AOKpO3eyD2K91UqxiLVooGaMkkJ1cNmESa8
         vIfduTuU4CSHvmBinz6YN7ysuKmFj2iYlxNp63YZn3TfqOmXIpz9ghuW1l4T1GaNGzjR
         znWs85PC8dSCPsP058CzheMY3S5KwxuTPdqX3HMGkasOZcyLv5Qg3/KPsAQNuDxC5yZR
         IuSTEZxP+y1DwM6i6IcZmjpUMl/H7CX24eynek2u7YTKFDeeFXctX41h6Knnhmebyf21
         vVFCHVisqoqpHsRKl2sFt5Qp/vtPYNMh7slytji6zV1Gckjr+elac0ALHS36cUAji26c
         1xAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qo3M/m6bAMWNKeEf1KSsSvYS6KA/79bnXZ/MG9HQ7+c=;
        b=ESBHGiqxKjEzhaVAsJm4aHSItM2yCTKPiq8qb9gpxxY2ZcgT6klRMbhaAG9QwvHDRV
         ujpzZ98sIoXMleJfXVwZ9qQXiqlRsEbo5CWkOEq+L2fK5vzKaEGPY5Nk1dHsOI0zVnKS
         eD7BJuPHjtfQMt/OYta6U9o6XZnVZ0IvEmNzpG3FM27AooJuRryQMq/TgzcyjItrSup/
         pI+/82o0kGTERKzs9FFQzawPfMrBxXhxFnsWWRLk0cprgWvh3vJ3HKQVXDDhEuAwz02Y
         zWocUfga+w0BgZwpdFKoaXN7SsYwfbHFTUgvGvuw0jH+HxgHRoT8VyctV/BhSvZdvf8Q
         cztA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WIvITimi;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i38sor75731308qvd.21.2019.08.06.16.16.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:16:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WIvITimi;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qo3M/m6bAMWNKeEf1KSsSvYS6KA/79bnXZ/MG9HQ7+c=;
        b=WIvITimiWkKwXR9MAnwvbjPd/jMGoFdgSbKJFYsFUTclr60pQsMdghZmIOiCh5YXC0
         UttFPobZS06cPlOZT0PF7D3HVksfWxSV4t/CAk8TXFyUTmugFgIF0+8oo8kipepx+JH2
         FaOArh02dXo+Kn1J1o19Ll/t6xFzUWU5L8C0euhgPJsWnHYPCsSB+yc+FHlEmVCAuX1U
         +F5OWyMlJ9C8l6nJvwq0WdkKMN98R7WVkx30edRvtFR93R5JGnJIrzkZgNRu9P36xdgz
         ULUtU6UxEUUqnG9agwf1nN+Htatwu+jA9bbrHaEueg4ngKDbsCMWsyahgp9VLjoDhgxe
         +acQ==
X-Google-Smtp-Source: APXvYqwzSzqBhit7womFZned74qAW6JuvC+DaQssS9gJgppa+iNTQrGgfDRkcUg2AKLeoxFn+koswg==
X-Received: by 2002:a0c:ad6f:: with SMTP id v44mr5590212qvc.40.1565133375491;
        Tue, 06 Aug 2019 16:16:15 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id l5sm38853627qte.9.2019.08.06.16.16.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 16:16:14 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv8gg-0006eL-1z; Tue, 06 Aug 2019 20:16:14 -0300
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
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v3 hmm 02/11] mm/mmu_notifiers: do not speculatively allocate a mmu_notifier_mm
Date: Tue,  6 Aug 2019 20:15:39 -0300
Message-Id: <20190806231548.25242-3-jgg@ziepe.ca>
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

A prior commit e0f3c3f78da2 ("mm/mmu_notifier: init notifier if necessary")
made an attempt at doing this, but had to be reverted as calling
the GFP_KERNEL allocator under the i_mmap_mutex causes deadlock, see
commit 35cfa2b0b491 ("mm/mmu_notifier: allocate mmu_notifier in advance").

However, we can avoid that problem by doing the allocation only under
the mmap_sem, which is already happening.

Since all writers to mm->mmu_notifier_mm hold the write side of the
mmap_sem reading it under that sem is deterministic and we can use that to
decide if the allocation path is required, without speculation.

The actual update to mmu_notifier_mm must still be done under the
mm_take_all_locks() to ensure read-side coherency.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/mmu_notifier.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 218a6f108bc2d0..696810f632ade1 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -242,27 +242,32 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
  */
 int __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	struct mmu_notifier_mm *mmu_notifier_mm;
+	struct mmu_notifier_mm *mmu_notifier_mm = NULL;
 	int ret;
 
 	lockdep_assert_held_write(&mm->mmap_sem);
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
-	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
-	if (unlikely(!mmu_notifier_mm))
-		return -ENOMEM;
+	if (!mm->mmu_notifier_mm) {
+		/*
+		 * kmalloc cannot be called under mm_take_all_locks(), but we
+		 * know that mm->mmu_notifier_mm can't change while we hold
+		 * the write side of the mmap_sem.
+		 */
+		mmu_notifier_mm =
+			kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
+		if (!mmu_notifier_mm)
+			return -ENOMEM;
+
+		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
+		spin_lock_init(&mmu_notifier_mm->lock);
+	}
 
 	ret = mm_take_all_locks(mm);
 	if (unlikely(ret))
 		goto out_clean;
 
-	if (!mm_has_notifiers(mm)) {
-		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
-		spin_lock_init(&mmu_notifier_mm->lock);
-
-		mm->mmu_notifier_mm = mmu_notifier_mm;
-		mmu_notifier_mm = NULL;
-	}
+	/* Pairs with the mmdrop in mmu_notifier_unregister_* */
 	mmgrab(mm);
 
 	/*
@@ -273,14 +278,19 @@ int __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
 	 * We can't race against any other mmu notifier method either
 	 * thanks to mm_take_all_locks().
 	 */
+	if (mmu_notifier_mm)
+		mm->mmu_notifier_mm = mmu_notifier_mm;
+
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	mm_drop_all_locks(mm);
+	BUG_ON(atomic_read(&mm->mm_users) <= 0);
+	return 0;
+
 out_clean:
 	kfree(mmu_notifier_mm);
-	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_register);
-- 
2.22.0

