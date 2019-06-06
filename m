Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 207D7C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 23:53:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1D8820825
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 23:53:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1D8820825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D8DC6B02FF; Thu,  6 Jun 2019 19:53:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 189C36B0300; Thu,  6 Jun 2019 19:53:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07BDA6B0301; Thu,  6 Jun 2019 19:53:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0F666B02FF
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 19:53:31 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d2so191616pla.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 16:53:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=w0UzD8vpGx8Y9hab+EX8DHDogBKgUG5tx0JaXOGz2Z8=;
        b=TMXQAvVpc3VDQe5zRfAZkrNarnwaVgisgtY6gQYsDazZ/VFhHTXXGATSFvHzSP8BcZ
         1wI/8GwptcKcrkTJJJG4vgeMzk0/ZpaSJwmGbK65ehX9+lH1yUrcwEW+JXBk3ph5MM8X
         j8+2BR59WGChWCBwrpV2cpk600dZMLOMU+1+MtMwlA6F9ASicUxBKFxe/jmqZN52VvSs
         gU1Bv5lX1g9GvhikVZOJgCrS6cKMDQgwHLgs5d/ad7ZdHMAMIWTrqqX9Q8dUsBLGDzyR
         Sp5z5Dkedeo7bGjTsH9dvCb7cSaK/3YQMDQUNU1ep9sBV+z710zWvNrdcWe3g6W005PI
         WowA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUP5UnEbBGvBu+IJFRPNsEDlgA1Cm4BC0K8sIKJkN4M7GNraqdH
	MQUAlzIvDB4xDI/juKrAwNqbafzkEzKLIIRO1DJPBkMViakHamcI2jjRzWb0kNa1oaWW2R/AQxJ
	/GkAsX6smwVUdYkVFd2sZ8HeUn0Jx8FWM8ijnO2In8yPDA8XozgGsuiNsXp4qwvKlTg==
X-Received: by 2002:a17:90a:9514:: with SMTP id t20mr2430524pjo.124.1559865211330;
        Thu, 06 Jun 2019 16:53:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxt1g99yadYkjyp+toNG6f7uiO3Nm331mfTWlTY+blf2txqwjDFZuy9K1VZN7Uw0OAjf29
X-Received: by 2002:a17:90a:9514:: with SMTP id t20mr2430474pjo.124.1559865210326;
        Thu, 06 Jun 2019 16:53:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559865210; cv=none;
        d=google.com; s=arc-20160816;
        b=v6WpQYxqa9lRTVbvbEW65DyqC0mq7/h01Zj3FX6AgAOLQ59BrSysWV5axTWMNQvFoV
         Dw0q9ipo2zSB5cMYR5TqvwgWYGJgwHoJMn8stekCdHNuhYdL4cPxmd9/I8+ZAG7QqRv9
         dJRwzlneM5Av8U/8Ix0wwWcmsm0FqaWg+m1WCP4I/zn59vun22F7CYdv2a/Vsfx7QtTr
         gQ0/n9k3bGnB1/qH3rRT15PsOtho4C5z+hn9rRIl8qsMgt9HXCCz4g6/gNNJS+FzZmU8
         FfjdWd/SK4wWitdPqNvef1GfGjhz3zR6VVLPwmGa/d7s6NQHdepHJzRTqkoOY2WIfMcA
         f8Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=w0UzD8vpGx8Y9hab+EX8DHDogBKgUG5tx0JaXOGz2Z8=;
        b=cC74j0p0JlSAGS/awOfHTVowBEsfpkyC2mUnbFbfAm26SYCNTB/IOD7ctPOnq/L4Fo
         jyLGRvAIbyFY0uHjkdbjpPr9QumFcENVluGf2w+Z4QNsJfweIikx0kcRqJ/5R0YcOy21
         6b/natPOzZhJJVpDKBbp3ay/ED8LSi/P4SBe7oPBe9Qm7vpKrGOEZQe/3ebccMVDtqKH
         LHdascjRc8GmYF67+24J6ReCV6T2cG/T/HwAjyeJfQqWBP5qHKF1iSqEIZUP7QQ3uDmU
         UIiNTKh17s8wN3UOOctCvQDh0AqAK8MbhsWvyyVbMU4N3gEvidvLiGlHTjpqPBkv4bPV
         10Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id e18si433164pgk.236.2019.06.06.16.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 16:53:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 16:53:29 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 16:53:29 -0700
Date: Thu, 6 Jun 2019 16:54:41 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [RFC PATCH 01/11] mm/hmm: Fix use after free with struct hmm in
 the mmu notifiers
Message-ID: <20190606235440.GA13674@iweiny-DESK2.sc.intel.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-2-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523153436.19102-2-jgg@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:34:26PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> mmu_notifier_unregister_no_release() is not a fence and the mmu_notifier
> system will continue to reference hmm->mn until the srcu grace period
> expires.
> 
> Resulting in use after free races like this:
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

NIT: "free"

Other than that looks good.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

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

