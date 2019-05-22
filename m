Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1957C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 20:12:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45A2221019
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 20:12:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="YE0IpP8H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45A2221019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B761C6B0003; Wed, 22 May 2019 16:12:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B271B6B0006; Wed, 22 May 2019 16:12:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3D5E6B0007; Wed, 22 May 2019 16:12:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84D0B6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 16:12:49 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v2so2782022qkd.11
        for <linux-mm@kvack.org>; Wed, 22 May 2019 13:12:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7Cnh1zv+MpTD//W/ZciU7p3rLJeN3HTGu169lbfCN2g=;
        b=aYowSoAVE8u+M3/7f4nfC6r0XpbDaf8etqZMWq7pQi9BZCZkg9GPrRXcnv7XCS6hd5
         gfQMKZgYt2JE4hC621oMIM39HFSbn85KB4LKuLG+R6h1+2AX+pWzOYabzOKccHKbduB6
         4WgSEKwl37ShdEWSqRcamDfPOpH0rnoxpDTdfZPnCVtiDOn/JJ2qfXBvspONuq24cnzX
         KJIskq6/+TISAcYmLvSDrolatdxExXqIIXD+omVI2YkW5AB4KExa0LTY8m/T86Suk7V+
         5CJ7S1Kx9lbbIEAnYYuK3O/lYqgfFW2QwpHu8ihUySd3N4yTpo2l3hTSas/pmHW4IU3K
         DfNQ==
X-Gm-Message-State: APjAAAW6Ac0o5P0Rv6x+nuh8fDUe/YXQZ/V+/jB4dDbSMRmWeYxs0ZC+
	fxLOUrTZDCycYE6vXWMyOJhzaCTQZ1wRSQojxy8yBWhWd5c3W38eYcrnorbXfd6WUSh2mH9godt
	9nWoNxNf1reAVPa2bcUKAgaZEHam9vAoTioqHWDwIQO+r2rJhcAGmSci73cUD+zmI6Q==
X-Received: by 2002:aed:2209:: with SMTP id n9mr74373111qtc.377.1558555969287;
        Wed, 22 May 2019 13:12:49 -0700 (PDT)
X-Received: by 2002:aed:2209:: with SMTP id n9mr74373065qtc.377.1558555968757;
        Wed, 22 May 2019 13:12:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558555968; cv=none;
        d=google.com; s=arc-20160816;
        b=vReVDtOUaQRmP5oYjIlvopjN1gB9iHtLdt5oS5XDmM5NuSzqA4VTWnjYPj64F3b7in
         /HvhTUZTupq9a0Ct0vzRChMUh/EQbo1DnkgGEicOuaeFYvsxUEr+Todn32EKYIU/d++q
         TvdcvjuxFysB0WkxD78spqUxO0cson2iX/ImkNRZUwIttVdecTuvjgzFQh9mMouaSQSf
         pRklXu4gWDScqoY0y1wSzIDZ78rsYzqyiyO3ERVnKeM26z15COKdZJTu4eYaZtp1LsmQ
         7Q+U/VzmVxzhpmpsQvVJYI62RckzmboUe5PVZ/+vI+oNJmeCHgzPvKYjHKdgpFcDTuso
         E6cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7Cnh1zv+MpTD//W/ZciU7p3rLJeN3HTGu169lbfCN2g=;
        b=uKersmK0xaSij/JjVG6cs+qfZlx48IFGBQoQu+I9sTTXnS/Bdd6OR2R/uDCqxbzct/
         oNbKFb8n/eOgVB4Q8Sv9hbXSVAGUhVrnuTyDUoLwRyGuCh2ONlXMiKHygCksW1DORot2
         OhTrPZwAibeuPT8P8A7jEO2UmB83yWiD8Qa/BRueZ/TZKhoVQ+X7u1UHmpx9xsOj96zH
         3l5EB6XOkuo9ywHtfsXZQCxbL8Dy261V0d4+fBf/bEDZ4CbzoXQ+ZuZ3uOziUZl5VVtU
         NblRSJ4E+vJyZJMdkOIOUtX2YcVHyzIPv3W5TiTDBm+xrybi8wkyVy+35V/MMlXcOtfx
         pbIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YE0IpP8H;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w45sor11126241qvc.66.2019.05.22.13.12.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 13:12:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YE0IpP8H;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7Cnh1zv+MpTD//W/ZciU7p3rLJeN3HTGu169lbfCN2g=;
        b=YE0IpP8H/ucijkv4/zVjJ988m9xdFimUhpaxBkJCS59qhW+IMnbR5pbeV+sCn5JTOS
         gnpOAP2B7c7aSbThavZLfsAIQj0lK8/J6U5K81Q9AEGVlG1oL3YLff6Xl2EKWr9XjEkA
         geDiqGupSN0dwV7h2nmanpeorMbMVIzI3K66c6I1FbvRklAixBgNAHFgUgLIYhWM7+87
         SqNE9J6Q2mU7C2V1w8oSbOzkukq9H2Wzl4FjIBKmYR1zkdE4CtQVQu2NgFSgxYgzoLx7
         EninpQWhc6XcEFj3CacFG5qrFVCVGo4ER7wIDqD+nMQ8C1GEk+QD3ezARs843/aXHBk3
         jb9A==
X-Google-Smtp-Source: APXvYqwkv+L37w9ixCVNgbTzJP9c7J84nOh7MnCV4O6X3TGfqnjt15mUAu7vDi6h84TgA4gSyjkUXA==
X-Received: by 2002:a0c:b04f:: with SMTP id l15mr59907485qvc.191.1558555968376;
        Wed, 22 May 2019 13:12:48 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id g65sm1475777qkb.1.2019.05.22.13.12.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 May 2019 13:12:47 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTXbT-0003PL-Eq; Wed, 22 May 2019 17:12:47 -0300
Date: Wed, 22 May 2019 17:12:47 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
Message-ID: <20190522201247.GH6054@ziepe.ca>
References: <20190411181314.19465-1-jglisse@redhat.com>
 <20190506195657.GA30261@ziepe.ca>
 <20190521205321.GC3331@redhat.com>
 <20190522005225.GA30819@ziepe.ca>
 <20190522174852.GA23038@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522174852.GA23038@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 01:48:52PM -0400, Jerome Glisse wrote:

>  static void put_per_mm(struct ib_umem_odp *umem_odp)
>  {
>  	struct ib_ucontext_per_mm *per_mm = umem_odp->per_mm;
> @@ -325,9 +283,10 @@ static void put_per_mm(struct ib_umem_odp *umem_odp)
>  	up_write(&per_mm->umem_rwsem);
>  
>  	WARN_ON(!RB_EMPTY_ROOT(&per_mm->umem_tree.rb_root));
> -	mmu_notifier_unregister_no_release(&per_mm->mn, per_mm->mm);
> +	hmm_mirror_unregister(&per_mm->mirror);
>  	put_pid(per_mm->tgid);
> -	mmu_notifier_call_srcu(&per_mm->rcu, free_per_mm);
> +
> +	kfree(per_mm);

Notice that mmu_notifier only uses SRCU to fence in-progress ops
callbacks, so I think hmm internally has the bug that this ODP
approach prevents.

hmm should follow the same pattern ODP has and 'kfree_srcu' the hmm
struct, use container_of in the mmu_notifier callbacks, and use the
otherwise vestigal kref_get_unless_zero() to bail:

From 0cb536dc0150ba964a1d655151d7b7a84d0f915a Mon Sep 17 00:00:00 2001
From: Jason Gunthorpe <jgg@mellanox.com>
Date: Wed, 22 May 2019 16:52:52 -0300
Subject: [PATCH] hmm: Fix use after free with struct hmm in the mmu notifiers

mmu_notifier_unregister_no_release() is not a fence and the mmu_notifier
system will continue to reference hmm->mn until the srcu grace period
expires.

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
 include/linux/hmm.h |  1 +
 mm/hmm.c            | 25 +++++++++++++++++++------
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 51ec27a8466816..8b91c90d3b88cb 100644
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
index 816c2356f2449f..824e7e160d8167 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -113,6 +113,11 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	return NULL;
 }
 
+static void hmm_fee_rcu(struct rcu_head *rcu)
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
+	mmu_notifier_call_srcu(&hmm->rcu, hmm_fee_rcu);
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
@@ -248,9 +259,11 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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

