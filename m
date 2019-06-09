Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 421E1C28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 19:45:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C892D206BB
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 19:45:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C892D206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CED26B0266; Sun,  9 Jun 2019 15:45:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37E6A6B0269; Sun,  9 Jun 2019 15:45:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 295726B026D; Sun,  9 Jun 2019 15:45:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E5A326B0266
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 15:45:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u21so2483569pfn.15
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 12:45:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bh9ZnrZBjcqHp55Fbr34HGe2zjkIzfrP4x/GwijvMIs=;
        b=Tnin0k4CD+EJAV0aUpLODbh2p99/hsilgrQlhB8vDlMisDOZrW8LkbRz9FBXg+pddH
         eU69l2z1XJgH88Rn03GHDmQL7B3JZV4u/1wsChlOWa5TMQ57BwnTMk+0L3xo7kCI1pa1
         9D/sWin8Dp0sytA+x6xN8KIzig9bCcSpfi+0OT7rQqmQKc9V4Mpiwga606aJ3PUWCjRX
         gdlbbTk1AsuSi4829OzDjC1M3FLXOBZQkFU8/5zEmdcYJ9YZ8tK9E6bBDQIbMKJBAre9
         nWn6rj3SdMg6QoFIpPoznWeqETwouBsVbbL/fDWPo9VaFOoyXs7rafbFwT/KsrYz3vLq
         TxRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXfOhJcNy3JXU9HRCF01KvxXDBS7nfa6vPcKzucX93GK5P972+Y
	rKW+BJUpGJlQuM8D4FOCFEzWVJsL1g+eeHYvNi204XFKHkLlVZeJr6JrUWZk0D+kB2eW7wJCGAr
	9ss8KgodN/0tp7ZmeZPqWyWzPFP14onvEXkpt8nbWKdRRKO/c1h1kecN8ekF/WxI9vg==
X-Received: by 2002:a63:649:: with SMTP id 70mr12728558pgg.445.1560109518409;
        Sun, 09 Jun 2019 12:45:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSJ/8D++ZYnAThZMfK6GT3uB/oKZV5lfxzmne2U48gT+Oy2BnoczxDqUiM5x1C397EA9AD
X-Received: by 2002:a63:649:: with SMTP id 70mr12728502pgg.445.1560109517359;
        Sun, 09 Jun 2019 12:45:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560109517; cv=none;
        d=google.com; s=arc-20160816;
        b=GcDcagIqVaHxvEd7XyDy0+FkXNOVjW5c+qyEfukzrdQxLcKpIEpCsblav5JxTBM4jm
         /3DMXZ8oXdIwcKkzQDFFNYkhvx04Xhe7FsxY4MuclMgFgwENrXF4FTqDzqlQGHLK9P5s
         MUIT0zwKjJbZ99kU5gZfLfg8nChT13piwSQEzfC9oYOAlo84ywN1SA0a1BiaJnZydus3
         YryP4dvEFsesLXfIYqzXU0Oxx4mOZ20nt9ibs6RvfKMSJ/SfPQYJta98Zcjl03TKV2TC
         xxs1D8NdUCzBq8hvEUwZX5cfb0R5w9duEQxQQ4J4BywxpUF7kMNSQn0w6ezD9hNA53BW
         hKiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bh9ZnrZBjcqHp55Fbr34HGe2zjkIzfrP4x/GwijvMIs=;
        b=JfQ0mymNw5Ku6SMs+iyx6RxSops99n4eO9FR/pHD6n3KoIYWBUTp34qPdcEoAbrYCf
         GS6Hz0VsKt74To3z8CQHWAHS4F3ub8qZtlvsOCT36wF6mYn1fZNRbp1yiY+Wn+vZAKNo
         rgrvOLrXcX1mbfL8MPg7p1PzmAsvM9nkPFeAb6sf+j9iL4NFxHRbf5Xjxtkh4l0F09LX
         Ke/+YbpSa+MPKGByqqk0fjQaF/J2o6SY1Vm3Epy0GrMtSQ4/UvFjE3v61LKp9V1bGHKz
         tgxXGSurKDuyPG7xKVkS8XqGyw1OSx3/xI+Cj1fforRD72I8RAJy8Vha1LL/Fkrb+0ks
         l9tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f4si8069323pgo.216.2019.06.09.12.45.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 12:45:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Jun 2019 12:45:16 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 09 Jun 2019 12:45:16 -0700
Date: Sun, 9 Jun 2019 12:46:32 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com, Jason Gunthorpe <jgg@mellanox.com>,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Message-ID: <20190609194632.GB19825@iweiny-DESK2.sc.intel.com>
References: <20190608001452.7922-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190608001452.7922-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 05:14:52PM -0700, Ralph Campbell wrote:
> HMM defines its own struct hmm_update which is passed to the
> sync_cpu_device_pagetables() callback function. This is
> sufficient when the only action is to invalidate. However,
> a device may want to know the reason for the invalidation and
> be able to see the new permissions on a range, update device access
> rights or range statistics. Since sync_cpu_device_pagetables()
> can be called from try_to_unmap(), the mmap_sem may not be held
> and find_vma() is not safe to be called.
> Pass the struct mmu_notifier_range to sync_cpu_device_pagetables()
> to allow the full invalidation information to be used.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>

I don't disagree with Christoph or Jason but since I've been trying to sort out
where hmm does and does not fit any chance to remove a custom structure is a
good simplification IMO.  So...

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
> 
> I'm sending this out now since we are updating many of the HMM APIs
> and I think it will be useful.
> 
> 
>  drivers/gpu/drm/nouveau/nouveau_svm.c |  4 ++--
>  include/linux/hmm.h                   | 27 ++-------------------------
>  mm/hmm.c                              | 13 ++++---------
>  3 files changed, 8 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
> index 8c92374afcf2..c34b98fafe2f 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_svm.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
> @@ -252,13 +252,13 @@ nouveau_svmm_invalidate(struct nouveau_svmm *svmm, u64 start, u64 limit)
>  
>  static int
>  nouveau_svmm_sync_cpu_device_pagetables(struct hmm_mirror *mirror,
> -					const struct hmm_update *update)
> +					const struct mmu_notifier_range *update)
>  {
>  	struct nouveau_svmm *svmm = container_of(mirror, typeof(*svmm), mirror);
>  	unsigned long start = update->start;
>  	unsigned long limit = update->end;
>  
> -	if (!update->blockable)
> +	if (!mmu_notifier_range_blockable(update))
>  		return -EAGAIN;
>  
>  	SVMM_DBG(svmm, "invalidate %016lx-%016lx", start, limit);
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 0fa8ea34ccef..07a2d38fde34 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -377,29 +377,6 @@ static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
>  
>  struct hmm_mirror;
>  
> -/*
> - * enum hmm_update_event - type of update
> - * @HMM_UPDATE_INVALIDATE: invalidate range (no indication as to why)
> - */
> -enum hmm_update_event {
> -	HMM_UPDATE_INVALIDATE,
> -};
> -
> -/*
> - * struct hmm_update - HMM update information for callback
> - *
> - * @start: virtual start address of the range to update
> - * @end: virtual end address of the range to update
> - * @event: event triggering the update (what is happening)
> - * @blockable: can the callback block/sleep ?
> - */
> -struct hmm_update {
> -	unsigned long start;
> -	unsigned long end;
> -	enum hmm_update_event event;
> -	bool blockable;
> -};
> -
>  /*
>   * struct hmm_mirror_ops - HMM mirror device operations callback
>   *
> @@ -420,7 +397,7 @@ struct hmm_mirror_ops {
>  	/* sync_cpu_device_pagetables() - synchronize page tables
>  	 *
>  	 * @mirror: pointer to struct hmm_mirror
> -	 * @update: update information (see struct hmm_update)
> +	 * @update: update information (see struct mmu_notifier_range)
>  	 * Return: -EAGAIN if update.blockable false and callback need to
>  	 *          block, 0 otherwise.
>  	 *
> @@ -434,7 +411,7 @@ struct hmm_mirror_ops {
>  	 * synchronous call.
>  	 */
>  	int (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
> -					  const struct hmm_update *update);
> +				const struct mmu_notifier_range *update);
>  };
>  
>  /*
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 9aad3550f2bb..b49a43712554 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -164,7 +164,6 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  {
>  	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>  	struct hmm_mirror *mirror;
> -	struct hmm_update update;
>  	struct hmm_range *range;
>  	unsigned long flags;
>  	int ret = 0;
> @@ -173,15 +172,10 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  	if (!kref_get_unless_zero(&hmm->kref))
>  		return 0;
>  
> -	update.start = nrange->start;
> -	update.end = nrange->end;
> -	update.event = HMM_UPDATE_INVALIDATE;
> -	update.blockable = mmu_notifier_range_blockable(nrange);
> -
>  	spin_lock_irqsave(&hmm->ranges_lock, flags);
>  	hmm->notifiers++;
>  	list_for_each_entry(range, &hmm->ranges, list) {
> -		if (update.end < range->start || update.start >= range->end)
> +		if (nrange->end < range->start || nrange->start >= range->end)
>  			continue;
>  
>  		range->valid = false;
> @@ -198,9 +192,10 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  	list_for_each_entry(mirror, &hmm->mirrors, list) {
>  		int rc;
>  
> -		rc = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
> +		rc = mirror->ops->sync_cpu_device_pagetables(mirror, nrange);
>  		if (rc) {
> -			if (WARN_ON(update.blockable || rc != -EAGAIN))
> +			if (WARN_ON(mmu_notifier_range_blockable(nrange) ||
> +				    rc != -EAGAIN))
>  				continue;
>  			ret = -EAGAIN;
>  			break;
> -- 
> 2.20.1
> 

