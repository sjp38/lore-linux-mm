Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16B1EC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:44:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C08452173C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:44:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ceFocxAl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C08452173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A79C6B000E; Thu, 13 Jun 2019 20:44:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12A066B026A; Thu, 13 Jun 2019 20:44:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6DE76B026B; Thu, 13 Jun 2019 20:44:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B77EC6B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:55 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t196so669417qke.0
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pwIeL+wG8OH0fR+HAJUAqgJL6j2cGj41BLXWfdyXw+8=;
        b=ABTpH5vIF1JTk0vYntORhW/OK/dFSws597b2F0GrBYV/T93xTlG1dHzkdTgxePRr8f
         qe1vVwuwpDwEpw12mqgXEs8GQQaRZEPTsz7vem+IHS5FJoDOr9/OPVcbXEmp89NZWcx1
         zxq/wSGb7Qh3+67QkPJ5sfWw54EbYD0bzyW9TmeeC5QNz+U7p8mIIIlUfNugGZpDwxfN
         CVKiXkZ8/tbEe9vAt4ceq9iyVjftKMQdVsjLPUzaIepR3Ew/uGSq3qnGD1jqCQ4sZ/t+
         q18vH0Zvndpst0tQrUTP9sBb12DRZLCTGtSdRON2sC1N+bBEeWj8GW3aKD4tZnAUOItx
         cayg==
X-Gm-Message-State: APjAAAVQyt9g9IcV6dbn66mqaNdnrHVPP7t3Lf/s++P0d/xFjL84xWO3
	DaNYPyhMGocxiuVHiASY0xxuvDnFOrtBTR4TVztgndYUrA3hFrNbErmQ4EfhWQdMmznWlybP2hU
	Mrm1048bD86wHuZLM/uxC11fC2rft0ijfuSWTnibJpFMF+S4bgVD94drODavrZOdRxA==
X-Received: by 2002:a05:620a:15b3:: with SMTP id f19mr9830224qkk.314.1560473095504;
        Thu, 13 Jun 2019 17:44:55 -0700 (PDT)
X-Received: by 2002:a05:620a:15b3:: with SMTP id f19mr9830200qkk.314.1560473094911;
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473094; cv=none;
        d=google.com; s=arc-20160816;
        b=unUXESpH2GZIybLfKOVBd9LMEL9PBNSrDj/dXqg3C5zicgfONgQn+cN1GqDmgLATZ0
         OooxOW2xoGSNXHEGFk5Js9GNkdQBSBEwy3umlOcuaT60yKiNhw69R6cNmRA/CJcwtZHO
         F51b1o2CT939TdGYBPRzIqt07US0HccNopakJnyQlqKtajD2RfzUUG8iKjRqp+Tc99RZ
         PM3R0gG/afGJeFIt28rfLeg0Wbz3zK+L6/RpICIMYXdlNcra3FT4s4n6gzSLLamcOwjU
         7chvQy2H9rHBx077iRD0I9QxdSyCbhScShtJ0uA+Kl0WcgWPK+ZVOVn5+/O6XrnQHQ03
         10Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pwIeL+wG8OH0fR+HAJUAqgJL6j2cGj41BLXWfdyXw+8=;
        b=wMLgmCiMvS94DXYNeN2HL+3Ues+OG/wCmw32olDxXr41MWRiJqR+yZ6bvexYAmu+Yc
         o8MidWjn6DwK3RtEnwPK53mefasTMDoZEFDbBMg3So3Uxz9IArVWPOrKfd72M3PAvmKZ
         dzY3msOiXeZ9LUsFtJBTLsc6/M+JLMNPbuH7144saSAP7o4jJq0erCg94wCj/URdLLMq
         BohYYI5a/Vm8wP1NGusjalPIZ+XL9exkgXbXCJajdAW/wvO1y9htybz/lG4F3mMZz7Dh
         JpAiqBgi/EVy+GQ0f+ckyRmJSvbY+is3ErQeYQ8/kYVEtHkYtJGi8e40JjjFNcf0cRGR
         E3Og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ceFocxAl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o10sor2375783qte.26.2019.06.13.17.44.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ceFocxAl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pwIeL+wG8OH0fR+HAJUAqgJL6j2cGj41BLXWfdyXw+8=;
        b=ceFocxAlhwC8ooDNQRZa8uwa3+dU+B2w/i8m8E2hFOYMSjwgE+QDjK2xkLm6VD72gE
         WwLJsyaKZvlbLH1T3GBNub1NlDlCK6BubNsnv1WbkKG8RNUlggQq8bBRTYJ5ZD3RlBUe
         5Xc4hRx6laHCPEGJWrsK7S9WLrDOWPmFo5Th/r3RbossSgw6mMZGxENAPWZu3X3SfIxe
         NKWPsMMCkPfwjaA/cZXhWZkA83335+sxM+8H517upoEyeM0OgJPsn7GyvWZ56NeXZYZ/
         EkASXeoAhhhAsXq8AEvm382rhtOeMbcMdaynxt6xBN1zXqpJZUfvbUeY29aKi9gpY3TE
         tkiw==
X-Google-Smtp-Source: APXvYqwfWvFSMiMgzDqFFMCY1VR/I1m7UwfYWn0XpXg+QyDkHYMt7hRBdXD727WohxKVcOUw6fUB+w==
X-Received: by 2002:ac8:1a3c:: with SMTP id v57mr77400825qtj.339.1560473094617;
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id w55sm902620qtw.11.2019.06.13.17.44.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005JX-Je; Thu, 13 Jun 2019 21:44:53 -0300
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
	Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH v3 hmm 01/12] mm/hmm: fix use after free with struct hmm in the mmu notifiers
Date: Thu, 13 Jun 2019 21:44:39 -0300
Message-Id: <20190614004450.20252-2-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190614004450.20252-1-jgg@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
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
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2:
- Spell 'free' properly (Jerome/Ralph)
v3:
- Have only one clearer comment about kref_get_unless_zero (John)
---
 include/linux/hmm.h |  1 +
 mm/hmm.c            | 23 +++++++++++++++++------
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 7007123842ba76..cb01cf1fa3c08b 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -93,6 +93,7 @@ struct hmm {
 	struct mmu_notifier	mmu_notifier;
 	struct rw_semaphore	mirrors_sem;
 	wait_queue_head_t	wq;
+	struct rcu_head		rcu;
 	long			notifiers;
 	bool			dead;
 };
diff --git a/mm/hmm.c b/mm/hmm.c
index 826816ab237799..f6956d78e3cb25 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -104,6 +104,11 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
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
@@ -116,7 +121,7 @@ static void hmm_free(struct kref *kref)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 
-	kfree(hmm);
+	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
 static inline void hmm_put(struct hmm *hmm)
@@ -144,10 +149,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
 
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	struct hmm *hmm = mm_get_hmm(mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
 	struct hmm_range *range;
 
+	/* Bail out if hmm is in the process of being freed */
+	if (!kref_get_unless_zero(&hmm->kref))
+		return;
+
 	/* Report this HMM as dying. */
 	hmm->dead = true;
 
@@ -185,13 +194,14 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
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
+	if (!kref_get_unless_zero(&hmm->kref))
+		return 0;
 
 	update.start = nrange->start;
 	update.end = nrange->end;
@@ -236,9 +246,10 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
-	struct hmm *hmm = mm_get_hmm(nrange->mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 
-	VM_BUG_ON(!hmm);
+	if (!kref_get_unless_zero(&hmm->kref))
+		return;
 
 	mutex_lock(&hmm->lock);
 	hmm->notifiers--;
-- 
2.21.0

