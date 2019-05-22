Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E95B1C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:04:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CFD421882
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:04:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CFD421882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 506E46B0003; Wed, 22 May 2019 18:04:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B79D6B0006; Wed, 22 May 2019 18:04:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A7146B0007; Wed, 22 May 2019 18:04:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18B1E6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 18:04:25 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n65so3616284qke.12
        for <linux-mm@kvack.org>; Wed, 22 May 2019 15:04:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1WvnCpDI4degmWHh2Yepf5NGjP/HsIC7dDgR58DjkZc=;
        b=SsoBl6Y94jMp2cASDk2iCwmUsp2aILsSttoP3xoDteX+wFm9T+s70R17wFCA9SBflK
         0BTXayO+PUCIKEBVIlA06pX+4m9/LvejjICS3UxgrtgSm9P1cuLWxBWe5NNBFtsABYZr
         eX5BwtJyiQn1nHZz3SHf+LAWV5PewjSxGn4+T4xoi9OFZcvN6b66gziIyrSBbz2zLq1d
         8ARdGP9yTU/Stm+8CkkTCDHLE78LOzp1p0NqtFU/wd5Txu8bbTqGWJUCSin/4o5opHDH
         kywDMyyhzeu6p2KLsA84OuErwqHUuTUUJ4QkbuaTik4RnrolyfC6YqsAbCmYPSqC22j0
         au6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWuzCSNKGtpno8d9wvD+qtz22D2NYZM8N7DiVmnxE/m1ycfFjcK
	8NGK8sB/onac7SwdoSmrsoP61SrtGZy7dtLVqhJymoo0BSWeJ885RKKOHUzHhHE5Ici3Wh7g81v
	2PK3fIAco/V5Uxf48D4Y2MxWrfGHH6fw9JMnyTj/ROrlJHWx2EJMh5z8YEIxLJBeETg==
X-Received: by 2002:a37:a157:: with SMTP id k84mr70146477qke.250.1558562664866;
        Wed, 22 May 2019 15:04:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDE8A4up2DaePEV7bevKMKyd2Pd/8GE4RMc0DPpCi8ix7QRkc+t4ddZSDLS81Eyn7q5WAe
X-Received: by 2002:a37:a157:: with SMTP id k84mr70146434qke.250.1558562664290;
        Wed, 22 May 2019 15:04:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558562664; cv=none;
        d=google.com; s=arc-20160816;
        b=F9n6oq1zInXcPcepyfn4Gfg47Nzz470TcgMsn0aY2ntYdb8cBGbIN1tE100I5lgS14
         KPiUiJ92ptvrp6ZoEvuReFhRscVRPy6qQO/e6hvwxzMI7ScGPz73PA/nmwY3hiNGDRbP
         8sihhptw3JV+xjPvFGqfZLY/v8J7yUyU8Oa+H3X4s8/9jOD11GPa3zMBGqR8k7CzQLOL
         O/nke498OwTxH5lTpW192B68cS14dYOzpLOuhRvN2m37XOABSfv1xAwFP4J3LcQWuoCd
         0igsvWArtY6Javv+iJ74RwBdOcjvVZA3e6mT9NStSF7uiEpTvivQ7MN8/tpYiR/lIUwQ
         P46Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1WvnCpDI4degmWHh2Yepf5NGjP/HsIC7dDgR58DjkZc=;
        b=m2pYeF0kwZzRgYj/p+BdDPaGXtonklq9+dg/x5j6532s1CGjE47QAHzP01Ihd01//B
         qt7mcIjdMmT7w4Gw0xUZ8SlgkszFI0s4YvPmiieWo9ybHo6/o6kzn5qsNSEo8+TUF39Z
         spdDBPYJx6LjvzOUTVyuLbybpwYdP1oKxSr4tQegoNNrMCntZt8wp2JaWqvr2nJvyTal
         ldy6nJGvk7eCfgqZ7RgFZjvTJmjPxkpEoEgfA3NdbBN3dXJMfIwOInBrwdUFFjVM1yNo
         YcPS4+YVSo/YCuANEVETQ7s/VFkYBQa27Zh66+PQ6AJxzqh/uua56qkG7LoOYNZX8wZf
         cL3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r31si10293926qte.279.2019.05.22.15.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 15:04:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EA61059463;
	Wed, 22 May 2019 22:04:22 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D79D917AC6;
	Wed, 22 May 2019 22:04:21 +0000 (UTC)
Date: Wed, 22 May 2019 18:04:20 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
Message-ID: <20190522220419.GB20179@redhat.com>
References: <20190411181314.19465-1-jglisse@redhat.com>
 <20190506195657.GA30261@ziepe.ca>
 <20190521205321.GC3331@redhat.com>
 <20190522005225.GA30819@ziepe.ca>
 <20190522174852.GA23038@redhat.com>
 <20190522201247.GH6054@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522201247.GH6054@ziepe.ca>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 22 May 2019 22:04:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 05:12:47PM -0300, Jason Gunthorpe wrote:
> On Wed, May 22, 2019 at 01:48:52PM -0400, Jerome Glisse wrote:
> 
> >  static void put_per_mm(struct ib_umem_odp *umem_odp)
> >  {
> >  	struct ib_ucontext_per_mm *per_mm = umem_odp->per_mm;
> > @@ -325,9 +283,10 @@ static void put_per_mm(struct ib_umem_odp *umem_odp)
> >  	up_write(&per_mm->umem_rwsem);
> >  
> >  	WARN_ON(!RB_EMPTY_ROOT(&per_mm->umem_tree.rb_root));
> > -	mmu_notifier_unregister_no_release(&per_mm->mn, per_mm->mm);
> > +	hmm_mirror_unregister(&per_mm->mirror);
> >  	put_pid(per_mm->tgid);
> > -	mmu_notifier_call_srcu(&per_mm->rcu, free_per_mm);
> > +
> > +	kfree(per_mm);
> 
> Notice that mmu_notifier only uses SRCU to fence in-progress ops
> callbacks, so I think hmm internally has the bug that this ODP
> approach prevents.
> 
> hmm should follow the same pattern ODP has and 'kfree_srcu' the hmm
> struct, use container_of in the mmu_notifier callbacks, and use the
> otherwise vestigal kref_get_unless_zero() to bail:
> 
> From 0cb536dc0150ba964a1d655151d7b7a84d0f915a Mon Sep 17 00:00:00 2001
> From: Jason Gunthorpe <jgg@mellanox.com>
> Date: Wed, 22 May 2019 16:52:52 -0300
> Subject: [PATCH] hmm: Fix use after free with struct hmm in the mmu notifiers
> 
> mmu_notifier_unregister_no_release() is not a fence and the mmu_notifier
> system will continue to reference hmm->mn until the srcu grace period
> expires.
> 
>          CPU0                                     CPU1
>                                                __mmu_notifier_invalidate_range_start()
>                                                  srcu_read_lock
>                                                  hlist_for_each ()
>                                                    // mn == hmm->mn
> hmm_mirror_unregister()
>   hmm_put()
>     hmm_free()
>       mmu_notifier_unregister_no_release()
>          hlist_del_init_rcu(hmm-mn->list)
> 			                           mn->ops->invalidate_range_start(mn, range);
> 					             mm_get_hmm()
>       mm->hmm = NULL;
>       kfree(hmm)
>                                                      mutex_lock(&hmm->lock);
> 
> Use SRCU to kfree the hmm memory so that the notifiers can rely on hmm
> existing. Get the now-safe hmm struct through container_of and directly
> check kref_get_unless_zero to lock it against free.

It is already badly handled with BUG_ON(), i just need to convert
those to return and to use mmu_notifier_call_srcu() to free hmm
struct.

The way race is avoided is because mm->hmm will either be NULL or
point to another hmm struct before an existing hmm is free. Also
if range_start/range_end use kref_get_unless_zero() but right now
this is BUG_ON if it turn out to be NULL, it should just return
on NULL.

> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> ---
>  include/linux/hmm.h |  1 +
>  mm/hmm.c            | 25 +++++++++++++++++++------
>  2 files changed, 20 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 51ec27a8466816..8b91c90d3b88cb 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -102,6 +102,7 @@ struct hmm {
>  	struct mmu_notifier	mmu_notifier;
>  	struct rw_semaphore	mirrors_sem;
>  	wait_queue_head_t	wq;
> +	struct rcu_head		rcu;
>  	long			notifiers;
>  	bool			dead;
>  };
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 816c2356f2449f..824e7e160d8167 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -113,6 +113,11 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  	return NULL;
>  }
>  
> +static void hmm_fee_rcu(struct rcu_head *rcu)
> +{
> +	kfree(container_of(rcu, struct hmm, rcu));
> +}
> +
>  static void hmm_free(struct kref *kref)
>  {
>  	struct hmm *hmm = container_of(kref, struct hmm, kref);
> @@ -125,7 +130,7 @@ static void hmm_free(struct kref *kref)
>  		mm->hmm = NULL;
>  	spin_unlock(&mm->page_table_lock);
>  
> -	kfree(hmm);
> +	mmu_notifier_call_srcu(&hmm->rcu, hmm_fee_rcu);
>  }
>  
>  static inline void hmm_put(struct hmm *hmm)
> @@ -153,10 +158,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
>  
>  static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
> -	struct hmm *hmm = mm_get_hmm(mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>  	struct hmm_mirror *mirror;
>  	struct hmm_range *range;
>  
> +	/* hmm is in progress to free */
> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return;
> +
>  	/* Report this HMM as dying. */
>  	hmm->dead = true;
>  
> @@ -194,13 +203,15 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  			const struct mmu_notifier_range *nrange)
>  {
> -	struct hmm *hmm = mm_get_hmm(nrange->mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>  	struct hmm_mirror *mirror;
>  	struct hmm_update update;
>  	struct hmm_range *range;
>  	int ret = 0;
>  
> -	VM_BUG_ON(!hmm);
> +	/* hmm is in progress to free */
> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return 0;
>  
>  	update.start = nrange->start;
>  	update.end = nrange->end;
> @@ -248,9 +259,11 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  static void hmm_invalidate_range_end(struct mmu_notifier *mn,
>  			const struct mmu_notifier_range *nrange)
>  {
> -	struct hmm *hmm = mm_get_hmm(nrange->mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>  
> -	VM_BUG_ON(!hmm);
> +	/* hmm is in progress to free */
> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return;
>  
>  	mutex_lock(&hmm->lock);
>  	hmm->notifiers--;
> -- 
> 2.21.0
> 

