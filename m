Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57BB8C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:43:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E6AB20840
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:43:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E6AB20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 947A46B0276; Fri,  7 Jun 2019 18:43:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D1916B0278; Fri,  7 Jun 2019 18:43:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BFDD6B0279; Fri,  7 Jun 2019 18:43:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 431056B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 18:43:21 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i3so2231674plb.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 15:43:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Cw1ZOtFKxtKpnp5wfJTyVdugntcUO5xL68Kaj8AEsJg=;
        b=HHMWPuazj8fpobew8S3yvqzXU+t0xtQeY+ZXBa/cULK7RQ4qLmT97AJUiskZuQOhod
         6ybOXIYNEeeKL1SewCG1RfD0F3l77BnXBi9vZDX4XaMXSlzEApeaUN2S1R9ikyEiPIqS
         m6EemQ7BilVOJ/y8hyhPU1SEZYbM24/PR+Gjw2nrOKHu9jn/M9AT2KLr4GKdlBM4rNtl
         9cMVYoy0oyLtxixdfs9TQqaRZTa8FOV0IfUzgZgqSh9t4R9g95CBQM3pJCPl4UAGNDAm
         XNea6iHSqB2InzmpYziTA7F7LFqP2LdalZjvGeobL4t5Bl5zL9OjfA6uwcnvOGlfXUWR
         c+Vw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUxuzq5+8DxWJbF3xQna+cLUGW13M95UdQAqX9UxSpW0RJm+Bzl
	5B5KX4NJjEI4aa4iiTDuv/TFwmL4y13t/zb1d0GqwLL6Si68IWnDtbWuGHtJ8uKdQ9zQ9gbFEv0
	58CVFu0NGV3z1u81Sm07v54+yGYmaVII97zv3hsPOUUPfRasIU+g5pXVZqc6K9Plppw==
X-Received: by 2002:a63:fa16:: with SMTP id y22mr5143417pgh.15.1559947400843;
        Fri, 07 Jun 2019 15:43:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxe9vmRGmrPFVosm3GyEVk5tqCw5VEnmRqZd2t37lq0QolX5PmG2mKfMd5t0zzpZ5euMPGk
X-Received: by 2002:a63:fa16:: with SMTP id y22mr5143380pgh.15.1559947400054;
        Fri, 07 Jun 2019 15:43:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559947400; cv=none;
        d=google.com; s=arc-20160816;
        b=f61HIDT0h2ANQUjkmbi+WGFI7ylM1HNHCIQRRJ12zuNvZo6eezTn66zEwxqHNCSyHF
         y2wpgg114jVykLe5zMA6CHJVyGGgTfp23MsOWBZBtZl+N30oH/BavmS8QjN4Hgfeg31e
         EaYKKHX+/hMPLM7eSSxxy20Elo6U2MF+aa65ZmT+VxeNwROh05TV3383BtnT/RPSsKdQ
         1gqTPN7E6JHpUZnIWjIXBWNXf0olVIkidCLaWObR7JQf+JsTkC0GK2LNBXSX3NGekY/n
         7GKuQt4y9mUbY/zEAlvwxTFExsMo2GIT7KAs+4z3oS+J4+VD4NOtvImb4DVjIb37qSmb
         3ebA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Cw1ZOtFKxtKpnp5wfJTyVdugntcUO5xL68Kaj8AEsJg=;
        b=Snm+RG24PkzKEH59aU5TGkl22+jC4lXd22CxVdXJTxnBlgOkFk+YU3U/rdifWlOXZQ
         RHQ0mYiO7WTJobfKIWQGQ/yfOlkUNUkaLidfqDuleu0mc2t1tvAC9ZGZzGfnGUcqPE9d
         NjvdwjijZE+jFtCeDlniknosrbQUmb1h2FXQ84op/XeBBZIgTYX0Y8nkOPvT7wyxtInk
         LB9mYsIloo9esGcJbgowhWJWF07jHZSGo/cEIxbgBIAP0Kd5uVPjVe1KLUvf0/20/mSK
         ZndHtAEXFt8+A7jjjhDuv65ZPxmgjqv0WNM6NvHiQOj4NUWXUtBGjJsAb03JC/NltvCf
         BQeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e64si3353048pfe.178.2019.06.07.15.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 15:43:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 15:43:19 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga007.jf.intel.com with ESMTP; 07 Jun 2019 15:43:19 -0700
Date: Fri, 7 Jun 2019 15:44:32 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v2 hmm 04/11] mm/hmm: Simplify hmm_get_or_create and make
 it reliable
Message-ID: <20190607224432.GF14559@iweiny-DESK2.sc.intel.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-5-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606184438.31646-5-jgg@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 03:44:31PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> As coded this function can false-fail in various racy situations. Make it
> reliable by running only under the write side of the mmap_sem and avoiding
> the false-failing compare/exchange pattern.
> 
> Also make the locking very easy to understand by only ever reading or
> writing mm->hmm while holding the write side of the mmap_sem.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
> v2:
> - Fix error unwind of mmgrab (Jerome)
> - Use hmm local instead of 2nd container_of (Jerome)
> ---
>  mm/hmm.c | 80 ++++++++++++++++++++------------------------------------
>  1 file changed, 29 insertions(+), 51 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index cc7c26fda3300e..dc30edad9a8a02 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -40,16 +40,6 @@
>  #if IS_ENABLED(CONFIG_HMM_MIRROR)
>  static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
>  
> -static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
> -{
> -	struct hmm *hmm = READ_ONCE(mm->hmm);
> -
> -	if (hmm && kref_get_unless_zero(&hmm->kref))
> -		return hmm;
> -
> -	return NULL;
> -}
> -
>  /**
>   * hmm_get_or_create - register HMM against an mm (HMM internal)
>   *
> @@ -64,11 +54,20 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>   */
>  static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  {
> -	struct hmm *hmm = mm_get_hmm(mm);
> -	bool cleanup = false;
> +	struct hmm *hmm;
>  
> -	if (hmm)
> -		return hmm;
> +	lockdep_assert_held_exclusive(&mm->mmap_sem);
> +
> +	if (mm->hmm) {
> +		if (kref_get_unless_zero(&mm->hmm->kref))
> +			return mm->hmm;
> +		/*
> +		 * The hmm is being freed by some other CPU and is pending a
> +		 * RCU grace period, but this CPU can NULL now it since we
> +		 * have the mmap_sem.
> +		 */
> +		mm->hmm = NULL;
> +	}
>  
>  	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
>  	if (!hmm)
> @@ -83,57 +82,36 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  	hmm->notifiers = 0;
>  	hmm->dead = false;
>  	hmm->mm = mm;
> -	mmgrab(hmm->mm);
> -
> -	spin_lock(&mm->page_table_lock);
> -	if (!mm->hmm)
> -		mm->hmm = hmm;
> -	else
> -		cleanup = true;
> -	spin_unlock(&mm->page_table_lock);
>  
> -	if (cleanup)
> -		goto error;
> -
> -	/*
> -	 * We should only get here if hold the mmap_sem in write mode ie on
> -	 * registration of first mirror through hmm_mirror_register()
> -	 */
>  	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
> -	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
> -		goto error_mm;
> +	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
> +		kfree(hmm);
> +		return NULL;
> +	}
>  
> +	mmgrab(hmm->mm);
> +	mm->hmm = hmm;
>  	return hmm;
> -
> -error_mm:
> -	spin_lock(&mm->page_table_lock);
> -	if (mm->hmm == hmm)
> -		mm->hmm = NULL;
> -	spin_unlock(&mm->page_table_lock);
> -error:
> -	mmdrop(hmm->mm);
> -	kfree(hmm);
> -	return NULL;
>  }
>  
>  static void hmm_free_rcu(struct rcu_head *rcu)
>  {
> -	kfree(container_of(rcu, struct hmm, rcu));
> +	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
> +
> +	down_write(&hmm->mm->mmap_sem);
> +	if (hmm->mm->hmm == hmm)
> +		hmm->mm->hmm = NULL;
> +	up_write(&hmm->mm->mmap_sem);
> +	mmdrop(hmm->mm);
> +
> +	kfree(hmm);
>  }
>  
>  static void hmm_free(struct kref *kref)
>  {
>  	struct hmm *hmm = container_of(kref, struct hmm, kref);
> -	struct mm_struct *mm = hmm->mm;
> -
> -	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
>  
> -	spin_lock(&mm->page_table_lock);
> -	if (mm->hmm == hmm)
> -		mm->hmm = NULL;
> -	spin_unlock(&mm->page_table_lock);
> -
> -	mmdrop(hmm->mm);
> +	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
>  	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
>  }
>  
> -- 
> 2.21.0
> 

