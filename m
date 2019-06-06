Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E2BBC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EFF320868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="i1eoUPW+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EFF320868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B13E6B0279; Thu,  6 Jun 2019 14:44:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35C206B027D; Thu,  6 Jun 2019 14:44:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 274686B027E; Thu,  6 Jun 2019 14:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E11C26B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:47 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o16so2886232qtj.6
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lL1gh8nawE6RFwsPdkPriGSJ+VnlR7Td1463Tqz8utE=;
        b=YEpz0rj4Ok/HROHP2BgxlpInnpQDk63LZ/lEbE3kcj7J6u/9bgCC52hTYkSvM7Y5mm
         Im0bgrRyhUVbRcnTBp4yWXhcGinNO65w4A29ATxU/MbNkJJK+M18BevhgeSTUaPdMeUu
         R+JmuXGSLgCTBZj/okuzqPKllUswhoS1qx2YgCw70UTSa0BGixvaPqm1kzy+TrX7tpTd
         zpv8S125uo3X4Jr7pcA5PRQaWj20zxZ2McCt9QEw7CqLu3xHLfgUv0cEwpCY9EihRIuB
         1+927sBp15d2jpJEgHfkEayazBUAQgA+j3v/roLUARjhLYInT3s7SdnhGyoZ5a5ATjji
         vGow==
X-Gm-Message-State: APjAAAWlAMzpUt28nixmvr88BoMBFQcB1hRBcvVNbsR+f1Q/HtVc5eT+
	4d0RFb6cGZBq/FxMZ56u+FUGMKYPp1OYfFFy9Ki1ko2ZBmthq8hGeDpkQwSHfeAoXjEGIvTIJ95
	A8bteM/w8I9G/igloT16+F7IemWsZ6So+9eg5X4qUdtw8+hVqzvateeuOYlU73Uhspw==
X-Received: by 2002:a0c:81e7:: with SMTP id 36mr7255112qve.5.1559846687661;
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
X-Received: by 2002:a0c:81e7:: with SMTP id 36mr7255081qve.5.1559846687055;
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846687; cv=none;
        d=google.com; s=arc-20160816;
        b=ZRTlH+59H/h4lfYD3ad3wZFxSFdHy3xy+4jQQWzw0Kp0bA5MxC4CKqeM9BP0Mx0svK
         iRWYvvCNeMGMf9fo/hb6EJN5EBz4hPlcL9n5fREYd2zqpxgwwRxQYIZSI1/g4ry0E+AQ
         mO4fMJqqiPYVBp7Kn/G8eVlqVnBkTgUiV94rZ12jEWHV4y91x60eVHN/zlMIvl019+kq
         KmDBYyLPL1sIpZbwHZ+FS336koneIymPk+vcXNlmYWlO4aDprboBvV+vMPCezkmrs/KO
         jKa+cpJw8q2XE4RsyBYoLS+dMzfLq8RKZxV93bW4L3b25VboAKIZS3E6HNidWgWgVlEP
         Ni+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lL1gh8nawE6RFwsPdkPriGSJ+VnlR7Td1463Tqz8utE=;
        b=rTN/+/1Uz0KcPCmK26famY/T2AihnkEQ6y2DlcoQrz8ScNKQSYSUaDqn0+EXScCTMQ
         HERAz2fUAJ+cfQl2J0nk1XgNAjEUWemd7lb9M68JF9v6+qI3tdnXx8DMmczQvnXusKlI
         HGYmFbI99lvRgZ2gR+bZ5YgYuugMcYiqARWM7Z2B7E7DyzILfRC+BI/cMTF+mTGPaNqW
         mFHJKSwBysWdhrGyqPH8Ui/IuqFmGVoZn6WLlIIWX0XchUQqhw0zEryaUqojm+1QqazX
         92hoOLHS/lzYdmJFxnQCkZguY9fELg9ZrdU0TyfNmXUo+PuGylFccQg6ridiW1zaBeMZ
         xX9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=i1eoUPW+;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l12sor1433048qkg.113.2019.06.06.11.44.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=i1eoUPW+;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=lL1gh8nawE6RFwsPdkPriGSJ+VnlR7Td1463Tqz8utE=;
        b=i1eoUPW+Np1ntz3bbKM3DpfMNN3rtSLjFDcmDB0vnq8UBH26kk63yNvtdKWmYVv2TV
         Pi+BVA4ti/NZ/Kxq6fbwoxDlR7kj35FAE/DOaimNUrZ5r1sTA5O/bAcr13jRwmRbnpxo
         TDFODNWEBAT/btsMWcqDTmLq2sZ6BFWqMBX8F+5SG9cP5jttZex0XY8bZAT3yEvhQllA
         Ti/dQpvuTYxWENCc1huucv5i9yrAjKo9CBNJ/Lo8NX9PMfBSb4jhB683uChR8oVThjIV
         ISzCmuSiYW97tizaIYodsqJaggibXGQKh2/eAvL6GclckuApULlhfSiRO/Br537Ceq9G
         qQdQ==
X-Google-Smtp-Source: APXvYqysUYNwLpFGpXB7aK6DBYGI6cTSoPBzuRqVbpub4N7BK9TEIAgc5KayvZk47O3Fq3EpoC7BwA==
X-Received: by 2002:a37:6f81:: with SMTP id k123mr4055833qkc.321.1559846686738;
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id e128sm1194796qkf.90.2019.06.06.11.44.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008I5-Dx; Thu, 06 Jun 2019 15:44:45 -0300
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
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v2 hmm 01/11] mm/hmm: fix use after free with struct hmm in the mmu notifiers
Date: Thu,  6 Jun 2019 15:44:28 -0300
Message-Id: <20190606184438.31646-2-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

mmu_notifier_unregister_no_release() is not a fence and the mmu_notifier
system will continue to reference hmm->mn until the srcu grace period
expires.

Resulting in use after free races like this:

         CPU0                                     CPU1
                                               __mmu_notifier_invalidate_range_start()
                                                 srcu_read_lock
                                                 hlist_for_each ()
                                                   // mn == hmm->mn
hmm_mirror_unregister()
  hmm_put()
    hmm_free()
      mmu_notifier_unregister_no_release()
         hlist_del_init_rcu(hmm-mn->list)
			                           mn->ops->invalidate_range_start(mn, range);
					             mm_get_hmm()
      mm->hmm = NULL;
      kfree(hmm)
                                                     mutex_lock(&hmm->lock);

Use SRCU to kfree the hmm memory so that the notifiers can rely on hmm
existing. Get the now-safe hmm struct through container_of and directly
check kref_get_unless_zero to lock it against free.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
v2:
- Spell 'free' properly (Jerome/Ralph)
---
 include/linux/hmm.h |  1 +
 mm/hmm.c            | 25 +++++++++++++++++++------
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 092f0234bfe917..688c5ca7068795 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -102,6 +102,7 @@ struct hmm {
 	struct mmu_notifier	mmu_notifier;
 	struct rw_semaphore	mirrors_sem;
 	wait_queue_head_t	wq;
+	struct rcu_head		rcu;
 	long			notifiers;
 	bool			dead;
 };
diff --git a/mm/hmm.c b/mm/hmm.c
index 8e7403f081f44a..547002f56a163d 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -113,6 +113,11 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	return NULL;
 }
 
+static void hmm_free_rcu(struct rcu_head *rcu)
+{
+	kfree(container_of(rcu, struct hmm, rcu));
+}
+
 static void hmm_free(struct kref *kref)
 {
 	struct hmm *hmm = container_of(kref, struct hmm, kref);
@@ -125,7 +130,7 @@ static void hmm_free(struct kref *kref)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 
-	kfree(hmm);
+	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
 static inline void hmm_put(struct hmm *hmm)
@@ -153,10 +158,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
 
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	struct hmm *hmm = mm_get_hmm(mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
 	struct hmm_range *range;
 
+	/* hmm is in progress to free */
+	if (!kref_get_unless_zero(&hmm->kref))
+		return;
+
 	/* Report this HMM as dying. */
 	hmm->dead = true;
 
@@ -194,13 +203,15 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
-	struct hmm *hmm = mm_get_hmm(nrange->mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
 	struct hmm_update update;
 	struct hmm_range *range;
 	int ret = 0;
 
-	VM_BUG_ON(!hmm);
+	/* hmm is in progress to free */
+	if (!kref_get_unless_zero(&hmm->kref))
+		return 0;
 
 	update.start = nrange->start;
 	update.end = nrange->end;
@@ -245,9 +256,11 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
-	struct hmm *hmm = mm_get_hmm(nrange->mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 
-	VM_BUG_ON(!hmm);
+	/* hmm is in progress to free */
+	if (!kref_get_unless_zero(&hmm->kref))
+		return;
 
 	mutex_lock(&hmm->lock);
 	hmm->notifiers--;
-- 
2.21.0

