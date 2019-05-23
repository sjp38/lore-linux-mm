Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6C1AC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FD7721773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ZAWb6C2Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FD7721773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1D936B0278; Thu, 23 May 2019 11:34:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 972076B027A; Thu, 23 May 2019 11:34:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FF4A6B027C; Thu, 23 May 2019 11:34:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4354E6B0278
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:42 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l20so5645699qtq.21
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o0fnCIS1UU2Yl5HFhaP9USXWVXi3ioUfilGqBeg9WXo=;
        b=JuKEI2pnFHD7k0z35Cb3SuaXJGs6fCjnF4Rhld1GGjCNW5JMj4SMEaU0sJLS9YSJ1M
         OYj4gKrb4bhwV+boqWle/UCMsFOd96pOnECVeS6Z4IAI3IVs0zurgKO5chHsXk/7QBau
         J/FdgxmNWnrJPqS+rwui1DFU7y+7dpbkZiOwY9IOmnGFhWtea63aIf1BAlgS4kkc4MsT
         4NTJfTCrkttALnEPg7VBS+MWipfzGGMUJ15tAGqt0ymcj+Dirb5jFNr8uyShOqnykmAR
         RdeBcRLdBi7PyMniIRVWzTGBfVpWh3+4nq0Xwvt7hpcsWPsR6v2c3Yl+bajvMK6GFZy4
         TJyg==
X-Gm-Message-State: APjAAAXNnkAvVyZSP1/IY+QenTy0muCHAVug73JBb3IcatVPGKM+2jqM
	gDo/chTxg5YNe9nH9ImB0GTUn9FFzOZtyd1zPnGF6NZpJkSi3eGVFYKPE8609kYI5s08LVVMN64
	qp8y0XEEOIMNzVDwMZB/dBlllFpytdNScj6zY2S95xlnhrw6UOc2ZvzDDY0D/sY+S4Q==
X-Received: by 2002:aed:3a23:: with SMTP id n32mr28872611qte.360.1558625682018;
        Thu, 23 May 2019 08:34:42 -0700 (PDT)
X-Received: by 2002:aed:3a23:: with SMTP id n32mr28872476qte.360.1558625680809;
        Thu, 23 May 2019 08:34:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625680; cv=none;
        d=google.com; s=arc-20160816;
        b=jEkvkGNeifjT0dhwfvLwYdhZlo6py4akIwBcd11mDuBGLA3jsfw+JFYfrPN3NgA4Nj
         tY2HkBfM6dvAtexkVW0DA0t15v3IktoRIxZW50BwUwPzSbxm6tzizKMO/kwppLYYtLHw
         d6YdniZNHsYj8kyhZfeJSERPGXQgO+bNfLXFxot7KQnr61yIJwtp29vxUVEFv1cyIvZB
         hWTU1IqvxIWHDnf2lY5t8NsB/3OQQHxA7x835En9jjXFknp2lkN5t+pTSnXTrSnJFFOt
         hQ1Kpw60ZnjpizrSQT6eOg9gV9iewDQj9s7rFQeYjxwal+lzAImtRxQXRwiGB/VTRHhg
         ZrAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=o0fnCIS1UU2Yl5HFhaP9USXWVXi3ioUfilGqBeg9WXo=;
        b=tL9wPKuCivM/mdZ+T7+RSdJxfdxXtaTTAp0tvuODTHDZKlYEYSzVe43taF9dkmNaHY
         0V5EFnoK/Qsr7vvZxtsDkVYnZ7oiZ8kgFgl8B37tpJt5sJAyAYmdfpngaengxbzdQaYf
         VlM1uzA15aVzZRgfgq9ASTNr9z+iCxfF6v4DgvMJX9XdbQlKEWhG8tGNdomzWcQ6xJG/
         NkLwBgM4Te9xHsV3RF8XgCWjxn6qlXRzSMPlVZ+tP3HhSXhEHkMB3XZ/9aw0KhHa7xfN
         ArFICw+r3o2uVrAiAtaBOiUt8xTGwQolXCGW5NpIkqGtY85B0r1Qy1WSCM39YaKsd4e2
         mEYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ZAWb6C2Z;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor17611268qvc.0.2019.05.23.08.34.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ZAWb6C2Z;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=o0fnCIS1UU2Yl5HFhaP9USXWVXi3ioUfilGqBeg9WXo=;
        b=ZAWb6C2Zy9X1DesFJzdUY1NrKsPiS5Jvp1PCkg+zTa3+HZUKgu72kwwZR9Zz7cuUsN
         hqHmPHEl1SZqi6Ksxs8IWDmWa8NYcaq27MZg4o43q9cS1rMdNIwjOHXVvrNrUhmerPLH
         2C4RM0d83niUVSA60rDZxLiCaCg0XIRLCrxlMxIAkpDCL2qGgOJrwg93mDBo0owbS9wG
         GigRKCJfgXFzftD8yNj5WhTzw0oUfA/5axgHUIGjENJUBHkLPDeOC2pI2f/yYxuyr07Y
         3SKahFyaohSEsYHGIuLk/ql8MKS182Eez2RiWCFyOULJUSZK8ElKWKLASN/yeR0Yf0fy
         jaIQ==
X-Google-Smtp-Source: APXvYqyWStElkAeFxeRHIt8qw7jwn+e9hRhuM1POWa1lozD72Ww5AlAsfY/GROw/QPhwUqv3LHvK6A==
X-Received: by 2002:a0c:8b6f:: with SMTP id d47mr30646505qvc.32.1558625680542;
        Thu, 23 May 2019 08:34:40 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id r47sm18148670qtc.14.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjp-0004zN-WB; Thu, 23 May 2019 12:34:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 03/11] mm/hmm: Hold a mmgrab from hmm to mm
Date: Thu, 23 May 2019 12:34:28 -0300
Message-Id: <20190523153436.19102-4-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

So long a a struct hmm pointer exists, so should the struct mm it is
linked too. Hold the mmgrab() as soon as a hmm is created, and mmdrop() it
once the hmm refcount goes to zero.

Since mmdrop() (ie a 0 kref on struct mm) is now impossible with a !NULL
mm->hmm delete the hmm_hmm_destroy().

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 include/linux/hmm.h |  3 ---
 kernel/fork.c       |  1 -
 mm/hmm.c            | 21 +++------------------
 3 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 87d29e085a69f7..2a7346384ead13 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -584,14 +584,11 @@ static inline int hmm_vma_fault(struct hmm_mirror *mirror,
 }
 
 /* Below are for HMM internal use only! Not to be used by device driver! */
-void hmm_mm_destroy(struct mm_struct *mm);
-
 static inline void hmm_mm_init(struct mm_struct *mm)
 {
 	mm->hmm = NULL;
 }
 #else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
diff --git a/kernel/fork.c b/kernel/fork.c
index b4cba953040a0f..51b114ec6c395c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -672,7 +672,6 @@ void __mmdrop(struct mm_struct *mm)
 	WARN_ON_ONCE(mm == current->active_mm);
 	mm_free_pgd(mm);
 	destroy_context(mm);
-	hmm_mm_destroy(mm);
 	mmu_notifier_mm_destroy(mm);
 	check_mm(mm);
 	put_user_ns(mm->user_ns);
diff --git a/mm/hmm.c b/mm/hmm.c
index fa1b04fcfc2549..e27058e92508b9 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -29,6 +29,7 @@
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
 #include <linux/memremap.h>
+#include <linux/sched/mm.h>
 #include <linux/jump_label.h>
 #include <linux/dma-mapping.h>
 #include <linux/mmu_notifier.h>
@@ -82,6 +83,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	hmm->notifiers = 0;
 	hmm->dead = false;
 	hmm->mm = mm;
+	mmgrab(hmm->mm);
 
 	spin_lock(&mm->page_table_lock);
 	if (!mm->hmm)
@@ -130,6 +132,7 @@ static void hmm_free(struct kref *kref)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 
+	mmdrop(hmm->mm);
 	mmu_notifier_call_srcu(&hmm->rcu, hmm_fee_rcu);
 }
 
@@ -138,24 +141,6 @@ static inline void hmm_put(struct hmm *hmm)
 	kref_put(&hmm->kref, hmm_free);
 }
 
-void hmm_mm_destroy(struct mm_struct *mm)
-{
-	struct hmm *hmm;
-
-	spin_lock(&mm->page_table_lock);
-	hmm = mm_get_hmm(mm);
-	mm->hmm = NULL;
-	if (hmm) {
-		hmm->mm = NULL;
-		hmm->dead = true;
-		spin_unlock(&mm->page_table_lock);
-		hmm_put(hmm);
-		return;
-	}
-
-	spin_unlock(&mm->page_table_lock);
-}
-
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
-- 
2.21.0

