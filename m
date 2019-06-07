Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 496D0C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:37:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05BDA2067C
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:37:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05BDA2067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FE0D6B0276; Fri,  7 Jun 2019 18:37:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AEBA6B0278; Fri,  7 Jun 2019 18:37:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79EAA6B0279; Fri,  7 Jun 2019 18:37:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FDEC6B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 18:37:04 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id m12so2227572pls.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 15:37:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=NRDMGW5Lu4AU8xEemraHpSsEffW2eFa90xi/QbrqeOI=;
        b=cq9Xs+RKJuAVINUieXsi2A6go0GbbA9UBOKPLWbwTCmNxG/zpUwHAlI0otEhArr/2J
         0x8wyu7cmyltKOUylgNFQl1xbjMy5O++N07oGb/erq4ljXwnnwCgF+0khzR7y4eub3Dc
         u5APVsPEQBFveN1xBTYqC6ge4PxE7oYxdkzW486caP4cjI1WEG1OVO8ES8+OPkIdV7/H
         lj5aFMUHGLBCUi+6CdO5Zdr82PAtsyv8Q/BGtmt6kj8j2pCniXq17JWBjV6Myj3fDBOi
         bziZoQPW21HDRYB6ack6IAvgy/o3MOxPYucBz+kmm7DQGC/KhMebI+yeBWlqNZmcWyeh
         49UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUpUGfGrg+bRtI/a8NgYWijs8OSJzP4uj2UzJALmt9luqQZCQdS
	Biu4XgcZNbpBXSLKtqf+kl0so/YHRsPeUueU9uKs0EDwV6ma7+uCB4bGbWOuVUY7KFXoHumxy01
	0YRWGfMEkDLyiqX1u1bkqq6dmR27uz3hpbMaiudhr0lmUouzCzoV3TYsd9ayhIm2QOg==
X-Received: by 2002:a63:2224:: with SMTP id i36mr5174682pgi.70.1559947023837;
        Fri, 07 Jun 2019 15:37:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzS+anwALVx/CUyuKK+qRtAEi09a5254VJJI9v1LPvXeyISawxdZ/knaDSc3InsOFCzwLXF
X-Received: by 2002:a63:2224:: with SMTP id i36mr5174653pgi.70.1559947023143;
        Fri, 07 Jun 2019 15:37:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559947023; cv=none;
        d=google.com; s=arc-20160816;
        b=Wp9QLlQ5NcMeeTSBQgG8ZS+pSTIdUumWUGSXfvkZFOmrWJQgNQ57be68laDKgDzO9i
         Fv65QjuqePgUCXxBTJ7zYP4P3gigkRx4IQPbqVQs8M0vwPvDB9sMSzUxAWL6/UaeByt2
         cjhdkc08Xiad8QN0Kv5bLN3iBHXEX/+rrg2kGK540Kgucc/GljAr1yO2/3VtEnJmQXuH
         rqKrJhq1DaDKIGrVYNDl8BvTOi6kJGQPtV+3KDLLqcVgzLkeVYARDP6oE4sZLhnNCyZu
         AYzMn1AubFQhTdfVrtUAY9bMS4Ek7Og5OJclaRjU9MlAMdFZjXSSXzvArCaefhpwimhB
         AOfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=NRDMGW5Lu4AU8xEemraHpSsEffW2eFa90xi/QbrqeOI=;
        b=UZAWBD3zBmAqJWNbihf0cOskSNw8jECKaNO1+dPWJYtMuhKn08tsnSfOwHznuaHt2X
         AYuWRZ6hUPdrcds6D2hE4i1hg/aDCWYmXG5lwaRThp7WKQtN3URZOxILnBfKERea0Lre
         DLAqgnkks1Y/su3XdIiKK/RSLrJI7WVtH71tYt0DHUqEOiYe7oYPvdv1M81rvP89SiVJ
         ojcfrS4eA0FmzJSdYtUEdMg3F6VcUUV6gG9YMolrLX3nvV44IG17zkwRr6Da5n15iWz1
         pfDa4wF7y3lFDAgHR+w9n3jlbdaOnjDar14+pZE/Peu49h36adQ2766RK5El8280Sa72
         Ay4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id w12si3046417pgr.55.2019.06.07.15.37.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 15:37:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 15:37:02 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga004.jf.intel.com with ESMTP; 07 Jun 2019 15:37:01 -0700
Date: Fri, 7 Jun 2019 15:38:16 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v2 hmm 03/11] mm/hmm: Hold a mmgrab from hmm to mm
Message-ID: <20190607223815.GE14559@iweiny-DESK2.sc.intel.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-4-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190606184438.31646-4-jgg@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 03:44:30PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> So long a a struct hmm pointer exists, so should the struct mm it is
> linked too. Hold the mmgrab() as soon as a hmm is created, and mmdrop() it
> once the hmm refcount goes to zero.
> 
> Since mmdrop() (ie a 0 kref on struct mm) is now impossible with a !NULL
> mm->hmm delete the hmm_hmm_destroy().
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
> v2:
>  - Fix error unwind paths in hmm_get_or_create (Jerome/Jason)
> ---
>  include/linux/hmm.h |  3 ---
>  kernel/fork.c       |  1 -
>  mm/hmm.c            | 22 ++++------------------
>  3 files changed, 4 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 2d519797cb134a..4ee3acabe5ed22 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -586,14 +586,11 @@ static inline int hmm_vma_fault(struct hmm_mirror *mirror,
>  }
>  
>  /* Below are for HMM internal use only! Not to be used by device driver! */
> -void hmm_mm_destroy(struct mm_struct *mm);
> -
>  static inline void hmm_mm_init(struct mm_struct *mm)
>  {
>  	mm->hmm = NULL;
>  }
>  #else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> -static inline void hmm_mm_destroy(struct mm_struct *mm) {}
>  static inline void hmm_mm_init(struct mm_struct *mm) {}
>  #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
>  
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b2b87d450b80b5..588c768ae72451 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -673,7 +673,6 @@ void __mmdrop(struct mm_struct *mm)
>  	WARN_ON_ONCE(mm == current->active_mm);
>  	mm_free_pgd(mm);
>  	destroy_context(mm);
> -	hmm_mm_destroy(mm);
>  	mmu_notifier_mm_destroy(mm);
>  	check_mm(mm);
>  	put_user_ns(mm->user_ns);
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 8796447299023c..cc7c26fda3300e 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -29,6 +29,7 @@
>  #include <linux/swapops.h>
>  #include <linux/hugetlb.h>
>  #include <linux/memremap.h>
> +#include <linux/sched/mm.h>
>  #include <linux/jump_label.h>
>  #include <linux/dma-mapping.h>
>  #include <linux/mmu_notifier.h>
> @@ -82,6 +83,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  	hmm->notifiers = 0;
>  	hmm->dead = false;
>  	hmm->mm = mm;
> +	mmgrab(hmm->mm);
>  
>  	spin_lock(&mm->page_table_lock);
>  	if (!mm->hmm)
> @@ -109,6 +111,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  		mm->hmm = NULL;
>  	spin_unlock(&mm->page_table_lock);
>  error:
> +	mmdrop(hmm->mm);
>  	kfree(hmm);
>  	return NULL;
>  }
> @@ -130,6 +133,7 @@ static void hmm_free(struct kref *kref)
>  		mm->hmm = NULL;
>  	spin_unlock(&mm->page_table_lock);
>  
> +	mmdrop(hmm->mm);
>  	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
>  }
>  
> @@ -138,24 +142,6 @@ static inline void hmm_put(struct hmm *hmm)
>  	kref_put(&hmm->kref, hmm_free);
>  }
>  
> -void hmm_mm_destroy(struct mm_struct *mm)
> -{
> -	struct hmm *hmm;
> -
> -	spin_lock(&mm->page_table_lock);
> -	hmm = mm_get_hmm(mm);
> -	mm->hmm = NULL;
> -	if (hmm) {
> -		hmm->mm = NULL;
> -		hmm->dead = true;
> -		spin_unlock(&mm->page_table_lock);
> -		hmm_put(hmm);
> -		return;
> -	}
> -
> -	spin_unlock(&mm->page_table_lock);
> -}
> -
>  static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
>  	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
> -- 
> 2.21.0
> 

