Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7A82C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:13:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D77D217F5
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:13:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D77D217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF1DA6B0284; Thu, 28 Mar 2019 17:13:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A790D6B0286; Thu, 28 Mar 2019 17:13:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 941886B0287; Thu, 28 Mar 2019 17:13:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC0D6B0284
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:13:05 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s15so138158plp.6
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:13:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xafyTgRpa0Gmjl61VGGAC/t41M9N9Vz3JEUE8SQnR7w=;
        b=P8elkNbGXcRvBdwGztNgKlz1uC/xG/gibma1tJwhNMo6d9YbFR5w5iBq50WW9W0SsQ
         yDbA1dlyoFwoceyhamTGMf115vhrc5Ns2PWqzHXwyHHU47K71fFzupm04JoeM70XcpR9
         /MMtkVtPUb1Qm/+iQst32VpPSs+NaMepb9vLGqhnoXxbbywx1qM3JunGwShYt2qEuOIu
         h6YcZ5VR1XVTdE7qAIzF1psdD5D84PHVaG/7hVFxtrcaLNBc0+phDStHNgApx5gEo8iA
         46XJT9JbltmwTlyQrUl03Hv9327gJi5F2Y57xYxODybaYhbPC5tpnXI8/3i4cuRDXx9T
         USeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXT+EiWgliEPl5/C8WGXAofjrXrw5IhHKr7+mTH9iJ0OQ9/0H4o
	GbCq0obMVJsFZQTqTDLvOHk1Ms6SnVQf+FmKpcLyoG2kSmm7Epc/KIYMI5jgd7KuSkM6BSXECfK
	tbQAI9N4FmljcAh3JxDsCXNyajWnXEl0mVpxs8nVHkEh3THBUk0EEZy5PGuy0szE/fw==
X-Received: by 2002:a63:54b:: with SMTP id 72mr41652657pgf.323.1553807584738;
        Thu, 28 Mar 2019 14:13:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmp8w/B7vJ8OwuwJ5J+rh4tQCulr+6rgMWj5tJN2fAzt3PweCQdoYI3uoANfWSCefVnYiH
X-Received: by 2002:a63:54b:: with SMTP id 72mr41652551pgf.323.1553807583208;
        Thu, 28 Mar 2019 14:13:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553807583; cv=none;
        d=google.com; s=arc-20160816;
        b=aZg6CHq5evaGOdxR89moiYcqYf7UNxWTnTvLQnjUo8WsX+LK3P28DStLJq08YG48zs
         s7MxhCd3KTvi4usWHFrq8ZhDiO8VkE5dqMim2WXraKgtGxY5QDe1ZQzULm+S/S4vw6q+
         Y1E6Yl1BekZK6jp6P8nRD5cpDHlAzt6hRJ6a6vpI9AvP7iZdaySSsjdM1SkE310A2HD8
         xA8w2QTUZq7i4bgVOD8/Q1cDULe8LYTEQdZwvzcXJKh5b/ufnEz81s9IuYhSptjkFqO1
         eXW+ZaY1R5/lJqmk1HHAmrB/QxfOgaFOM3YqQ5iRGsZ1u+C4mZncQdvptGhBcoy6NOcr
         BI4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=xafyTgRpa0Gmjl61VGGAC/t41M9N9Vz3JEUE8SQnR7w=;
        b=h5S7aL9DwuJaynFPnaeMCctF13LAvkg7L4pUczwJoMq3Qc4wXaJ1YzQ6ToxMpq7aos
         jywS9kXFLKStsGfot381vwfFTs+bnYGfLok8NuHtF2XLpgUDYAk9OlFcrm30r3+5/3F+
         Eq1Yp6vNqxWBnxYoo2KV4lAOCzMkzhv4MhuPMbkcCrv95VOOByLd6pa10EsNbpSMaSl4
         EB5khLnlOY5mclc+dM1bud653nCi4P8zxEh+fSGB9PKwaEirRwSa1je8/l9A0UiwVqpc
         WvKVdbkRtaxXs2FNRdfezaGRp4JGuhgjgpBCxt9K7+m1GcnzBqMgcTvMVNrtXfHBA281
         XZFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 32si150209pgz.259.2019.03.28.14.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:13:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 14:13:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,281,1549958400"; 
   d="scan'208";a="311272310"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga005.jf.intel.com with ESMTP; 28 Mar 2019 14:13:01 -0700
Date: Thu, 28 Mar 2019 06:11:54 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 06/11] mm/hmm: improve driver API to work and wait
 over a range v2
Message-ID: <20190328131154.GB31324@iweiny-DESK2.sc.intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-7-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190325144011.10560-7-jglisse@redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 10:40:06AM -0400, Jerome Glisse wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> A common use case for HMM mirror is user trying to mirror a range
> and before they could program the hardware it get invalidated by
> some core mm event. Instead of having user re-try right away to
> mirror the range provide a completion mechanism for them to wait
> for any active invalidation affecting the range.
> 
> This also changes how hmm_range_snapshot() and hmm_range_fault()
> works by not relying on vma so that we can drop the mmap_sem
> when waiting and lookup the vma again on retry.
> 
> Changes since v1:
>     - squashed: Dan Carpenter: potential deadlock in nonblocking code
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> ---
>  include/linux/hmm.h | 208 ++++++++++++++---
>  mm/hmm.c            | 528 +++++++++++++++++++++-----------------------
>  2 files changed, 428 insertions(+), 308 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index e9afd23c2eac..79671036cb5f 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -77,8 +77,34 @@
>  #include <linux/migrate.h>
>  #include <linux/memremap.h>
>  #include <linux/completion.h>
> +#include <linux/mmu_notifier.h>
>  
> -struct hmm;
> +
> +/*
> + * struct hmm - HMM per mm struct
> + *
> + * @mm: mm struct this HMM struct is bound to
> + * @lock: lock protecting ranges list
> + * @ranges: list of range being snapshotted
> + * @mirrors: list of mirrors for this mm
> + * @mmu_notifier: mmu notifier to track updates to CPU page table
> + * @mirrors_sem: read/write semaphore protecting the mirrors list
> + * @wq: wait queue for user waiting on a range invalidation
> + * @notifiers: count of active mmu notifiers
> + * @dead: is the mm dead ?
> + */
> +struct hmm {
> +	struct mm_struct	*mm;
> +	struct kref		kref;
> +	struct mutex		lock;
> +	struct list_head	ranges;
> +	struct list_head	mirrors;
> +	struct mmu_notifier	mmu_notifier;
> +	struct rw_semaphore	mirrors_sem;
> +	wait_queue_head_t	wq;
> +	long			notifiers;
> +	bool			dead;
> +};
>  
>  /*
>   * hmm_pfn_flag_e - HMM flag enums
> @@ -155,6 +181,38 @@ struct hmm_range {
>  	bool			valid;
>  };
>  
> +/*
> + * hmm_range_wait_until_valid() - wait for range to be valid
> + * @range: range affected by invalidation to wait on
> + * @timeout: time out for wait in ms (ie abort wait after that period of time)
> + * Returns: true if the range is valid, false otherwise.
> + */
> +static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
> +					      unsigned long timeout)
> +{
> +	/* Check if mm is dead ? */
> +	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
> +		range->valid = false;
> +		return false;
> +	}
> +	if (range->valid)
> +		return true;
> +	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
> +			   msecs_to_jiffies(timeout));
> +	/* Return current valid status just in case we get lucky */
> +	return range->valid;
> +}
> +
> +/*
> + * hmm_range_valid() - test if a range is valid or not
> + * @range: range
> + * Returns: true if the range is valid, false otherwise.
> + */
> +static inline bool hmm_range_valid(struct hmm_range *range)
> +{
> +	return range->valid;
> +}
> +
>  /*
>   * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
>   * @range: range use to decode HMM pfn value
> @@ -357,51 +415,133 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
>  
>  
>  /*
> - * To snapshot the CPU page table, call hmm_vma_get_pfns(), then take a device
> - * driver lock that serializes device page table updates, then call
> - * hmm_vma_range_done(), to check if the snapshot is still valid. The same
> - * device driver page table update lock must also be used in the
> - * hmm_mirror_ops.sync_cpu_device_pagetables() callback, so that CPU page
> - * table invalidation serializes on it.
> + * To snapshot the CPU page table you first have to call hmm_range_register()
> + * to register the range. If hmm_range_register() return an error then some-
> + * thing is horribly wrong and you should fail loudly. If it returned true then
> + * you can wait for the range to be stable with hmm_range_wait_until_valid()
> + * function, a range is valid when there are no concurrent changes to the CPU
> + * page table for the range.
> + *
> + * Once the range is valid you can call hmm_range_snapshot() if that returns
> + * without error then you can take your device page table lock (the same lock
> + * you use in the HMM mirror sync_cpu_device_pagetables() callback). After
> + * taking that lock you have to check the range validity, if it is still valid
> + * (ie hmm_range_valid() returns true) then you can program the device page
> + * table, otherwise you have to start again. Pseudo code:
> + *
> + *      mydevice_prefault(mydevice, mm, start, end)
> + *      {
> + *          struct hmm_range range;
> + *          ...
>   *
> - * YOU MUST CALL hmm_vma_range_done() ONCE AND ONLY ONCE EACH TIME YOU CALL
> - * hmm_range_snapshot() WITHOUT ERROR !
> + *          ret = hmm_range_register(&range, mm, start, end);
> + *          if (ret)
> + *              return ret;
>   *
> - * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE INVALID !
> - */
> -long hmm_range_snapshot(struct hmm_range *range);
> -bool hmm_vma_range_done(struct hmm_range *range);
> -
> -
> -/*
> - * Fault memory on behalf of device driver. Unlike handle_mm_fault(), this will
> - * not migrate any device memory back to system memory. The HMM pfn array will
> - * be updated with the fault result and current snapshot of the CPU page table
> - * for the range.
> + *          down_read(mm->mmap_sem);
> + *      again:
> + *
> + *          if (!hmm_range_wait_until_valid(&range, TIMEOUT)) {
> + *              up_read(&mm->mmap_sem);
> + *              hmm_range_unregister(range);
> + *              // Handle time out, either sleep or retry or something else
> + *              ...
> + *              return -ESOMETHING; || goto again;
> + *          }
> + *
> + *          ret = hmm_range_snapshot(&range); or hmm_range_fault(&range);
> + *          if (ret == -EAGAIN) {
> + *              down_read(mm->mmap_sem);
> + *              goto again;
> + *          } else if (ret == -EBUSY) {
> + *              goto again;
> + *          }
> + *
> + *          up_read(&mm->mmap_sem);
> + *          if (ret) {
> + *              hmm_range_unregister(range);
> + *              return ret;
> + *          }
> + *
> + *          // It might not have snap-shoted the whole range but only the first
> + *          // npages, the return values is the number of valid pages from the
> + *          // start of the range.
> + *          npages = ret;
>   *
> - * The mmap_sem must be taken in read mode before entering and it might be
> - * dropped by the function if the block argument is false. In that case, the
> - * function returns -EAGAIN.
> + *          ...
>   *
> - * Return value does not reflect if the fault was successful for every single
> - * address or not. Therefore, the caller must to inspect the HMM pfn array to
> - * determine fault status for each address.
> + *          mydevice_page_table_lock(mydevice);
> + *          if (!hmm_range_valid(range)) {
> + *              mydevice_page_table_unlock(mydevice);
> + *              goto again;
> + *          }
>   *
> - * Trying to fault inside an invalid vma will result in -EINVAL.
> + *          mydevice_populate_page_table(mydevice, range, npages);
> + *          ...
> + *          mydevice_take_page_table_unlock(mydevice);
> + *          hmm_range_unregister(range);
>   *
> - * See the function description in mm/hmm.c for further documentation.
> + *          return 0;
> + *      }
> + *
> + * The same scheme apply to hmm_range_fault() (ie replace hmm_range_snapshot()
> + * with hmm_range_fault() in above pseudo code).
> + *
> + * YOU MUST CALL hmm_range_unregister() ONCE AND ONLY ONCE EACH TIME YOU CALL
> + * hmm_range_register() AND hmm_range_register() RETURNED TRUE ! IF YOU DO NOT
> + * FOLLOW THIS RULE MEMORY CORRUPTION WILL ENSUE !
>   */
> +int hmm_range_register(struct hmm_range *range,
> +		       struct mm_struct *mm,
> +		       unsigned long start,
> +		       unsigned long end);
> +void hmm_range_unregister(struct hmm_range *range);
> +long hmm_range_snapshot(struct hmm_range *range);
>  long hmm_range_fault(struct hmm_range *range, bool block);
>  
> +/*
> + * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
> + *
> + * When waiting for mmu notifiers we need some kind of time out otherwise we
> + * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
> + * wait already.
> + */
> +#define HMM_RANGE_DEFAULT_TIMEOUT 1000
> +
>  /* This is a temporary helper to avoid merge conflict between trees. */
> +static inline bool hmm_vma_range_done(struct hmm_range *range)
> +{
> +	bool ret = hmm_range_valid(range);
> +
> +	hmm_range_unregister(range);
> +	return ret;
> +}
> +
>  static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>  {
> -	long ret = hmm_range_fault(range, block);
> -	if (ret == -EBUSY)
> -		ret = -EAGAIN;
> -	else if (ret == -EAGAIN)
> -		ret = -EBUSY;
> -	return ret < 0 ? ret : 0;
> +	long ret;
> +
> +	ret = hmm_range_register(range, range->vma->vm_mm,
> +				 range->start, range->end);
> +	if (ret)
> +		return (int)ret;
> +
> +	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> +		up_read(&range->vma->vm_mm->mmap_sem);

Where is the down_read() which correspond to this?

> +		return -EAGAIN;
> +	}
> +
> +	ret = hmm_range_fault(range, block);
> +	if (ret <= 0) {
> +		if (ret == -EBUSY || !ret) {
> +			up_read(&range->vma->vm_mm->mmap_sem);

Or this...?

> +			ret = -EBUSY;
> +		} else if (ret == -EAGAIN)
> +			ret = -EBUSY;
> +		hmm_range_unregister(range);
> +		return ret;
> +	}

And is the side effect of this call that the mmap_sem has been taken?
Or is the side effect that the mmap_sem was released?

I'm not saying this is wrong, but I can't tell so it seems like a comment on
the function would help.

Ira

> +	return 0;
>  }
>  
>  /* Below are for HMM internal use only! Not to be used by device driver! */
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 7860e63c3ba7..fa9498eeb9b6 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -38,26 +38,6 @@
>  #if IS_ENABLED(CONFIG_HMM_MIRROR)
>  static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
>  
> -/*
> - * struct hmm - HMM per mm struct
> - *
> - * @mm: mm struct this HMM struct is bound to
> - * @lock: lock protecting ranges list
> - * @ranges: list of range being snapshotted
> - * @mirrors: list of mirrors for this mm
> - * @mmu_notifier: mmu notifier to track updates to CPU page table
> - * @mirrors_sem: read/write semaphore protecting the mirrors list
> - */
> -struct hmm {
> -	struct mm_struct	*mm;
> -	struct kref		kref;
> -	spinlock_t		lock;
> -	struct list_head	ranges;
> -	struct list_head	mirrors;
> -	struct mmu_notifier	mmu_notifier;
> -	struct rw_semaphore	mirrors_sem;
> -};
> -
>  static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>  {
>  	struct hmm *hmm = READ_ONCE(mm->hmm);
> @@ -87,12 +67,15 @@ static struct hmm *hmm_register(struct mm_struct *mm)
>  	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
>  	if (!hmm)
>  		return NULL;
> +	init_waitqueue_head(&hmm->wq);
>  	INIT_LIST_HEAD(&hmm->mirrors);
>  	init_rwsem(&hmm->mirrors_sem);
>  	hmm->mmu_notifier.ops = NULL;
>  	INIT_LIST_HEAD(&hmm->ranges);
> -	spin_lock_init(&hmm->lock);
> +	mutex_init(&hmm->lock);
>  	kref_init(&hmm->kref);
> +	hmm->notifiers = 0;
> +	hmm->dead = false;
>  	hmm->mm = mm;
>  
>  	spin_lock(&mm->page_table_lock);
> @@ -154,6 +137,7 @@ void hmm_mm_destroy(struct mm_struct *mm)
>  	mm->hmm = NULL;
>  	if (hmm) {
>  		hmm->mm = NULL;
> +		hmm->dead = true;
>  		spin_unlock(&mm->page_table_lock);
>  		hmm_put(hmm);
>  		return;
> @@ -162,43 +146,22 @@ void hmm_mm_destroy(struct mm_struct *mm)
>  	spin_unlock(&mm->page_table_lock);
>  }
>  
> -static int hmm_invalidate_range(struct hmm *hmm, bool device,
> -				const struct hmm_update *update)
> +static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
> +	struct hmm *hmm = mm_get_hmm(mm);
>  	struct hmm_mirror *mirror;
>  	struct hmm_range *range;
>  
> -	spin_lock(&hmm->lock);
> -	list_for_each_entry(range, &hmm->ranges, list) {
> -		if (update->end < range->start || update->start >= range->end)
> -			continue;
> +	/* Report this HMM as dying. */
> +	hmm->dead = true;
>  
> +	/* Wake-up everyone waiting on any range. */
> +	mutex_lock(&hmm->lock);
> +	list_for_each_entry(range, &hmm->ranges, list) {
>  		range->valid = false;
>  	}
> -	spin_unlock(&hmm->lock);
> -
> -	if (!device)
> -		return 0;
> -
> -	down_read(&hmm->mirrors_sem);
> -	list_for_each_entry(mirror, &hmm->mirrors, list) {
> -		int ret;
> -
> -		ret = mirror->ops->sync_cpu_device_pagetables(mirror, update);
> -		if (!update->blockable && ret == -EAGAIN) {
> -			up_read(&hmm->mirrors_sem);
> -			return -EAGAIN;
> -		}
> -	}
> -	up_read(&hmm->mirrors_sem);
> -
> -	return 0;
> -}
> -
> -static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> -{
> -	struct hmm_mirror *mirror;
> -	struct hmm *hmm = mm_get_hmm(mm);
> +	wake_up_all(&hmm->wq);
> +	mutex_unlock(&hmm->lock);
>  
>  	down_write(&hmm->mirrors_sem);
>  	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
> @@ -224,36 +187,80 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  }
>  
>  static int hmm_invalidate_range_start(struct mmu_notifier *mn,
> -			const struct mmu_notifier_range *range)
> +			const struct mmu_notifier_range *nrange)
>  {
> -	struct hmm *hmm = mm_get_hmm(range->mm);
> +	struct hmm *hmm = mm_get_hmm(nrange->mm);
> +	struct hmm_mirror *mirror;
>  	struct hmm_update update;
> -	int ret;
> +	struct hmm_range *range;
> +	int ret = 0;
>  
>  	VM_BUG_ON(!hmm);
>  
> -	update.start = range->start;
> -	update.end = range->end;
> +	update.start = nrange->start;
> +	update.end = nrange->end;
>  	update.event = HMM_UPDATE_INVALIDATE;
> -	update.blockable = range->blockable;
> -	ret = hmm_invalidate_range(hmm, true, &update);
> +	update.blockable = nrange->blockable;
> +
> +	if (nrange->blockable)
> +		mutex_lock(&hmm->lock);
> +	else if (!mutex_trylock(&hmm->lock)) {
> +		ret = -EAGAIN;
> +		goto out;
> +	}
> +	hmm->notifiers++;
> +	list_for_each_entry(range, &hmm->ranges, list) {
> +		if (update.end < range->start || update.start >= range->end)
> +			continue;
> +
> +		range->valid = false;
> +	}
> +	mutex_unlock(&hmm->lock);
> +
> +	if (nrange->blockable)
> +		down_read(&hmm->mirrors_sem);
> +	else if (!down_read_trylock(&hmm->mirrors_sem)) {
> +		ret = -EAGAIN;
> +		goto out;
> +	}
> +	list_for_each_entry(mirror, &hmm->mirrors, list) {
> +		int ret;
> +
> +		ret = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
> +		if (!update.blockable && ret == -EAGAIN) {
> +			up_read(&hmm->mirrors_sem);
> +			ret = -EAGAIN;
> +			goto out;
> +		}
> +	}
> +	up_read(&hmm->mirrors_sem);
> +
> +out:
>  	hmm_put(hmm);
>  	return ret;
>  }
>  
>  static void hmm_invalidate_range_end(struct mmu_notifier *mn,
> -			const struct mmu_notifier_range *range)
> +			const struct mmu_notifier_range *nrange)
>  {
> -	struct hmm *hmm = mm_get_hmm(range->mm);
> -	struct hmm_update update;
> +	struct hmm *hmm = mm_get_hmm(nrange->mm);
>  
>  	VM_BUG_ON(!hmm);
>  
> -	update.start = range->start;
> -	update.end = range->end;
> -	update.event = HMM_UPDATE_INVALIDATE;
> -	update.blockable = true;
> -	hmm_invalidate_range(hmm, false, &update);
> +	mutex_lock(&hmm->lock);
> +	hmm->notifiers--;
> +	if (!hmm->notifiers) {
> +		struct hmm_range *range;
> +
> +		list_for_each_entry(range, &hmm->ranges, list) {
> +			if (range->valid)
> +				continue;
> +			range->valid = true;
> +		}
> +		wake_up_all(&hmm->wq);
> +	}
> +	mutex_unlock(&hmm->lock);
> +
>  	hmm_put(hmm);
>  }
>  
> @@ -405,7 +412,6 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
>  {
>  	struct hmm_range *range = hmm_vma_walk->range;
>  
> -	*fault = *write_fault = false;
>  	if (!hmm_vma_walk->fault)
>  		return;
>  
> @@ -444,10 +450,11 @@ static void hmm_range_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
>  		return;
>  	}
>  
> +	*fault = *write_fault = false;
>  	for (i = 0; i < npages; ++i) {
>  		hmm_pte_need_fault(hmm_vma_walk, pfns[i], cpu_flags,
>  				   fault, write_fault);
> -		if ((*fault) || (*write_fault))
> +		if ((*write_fault))
>  			return;
>  	}
>  }
> @@ -702,162 +709,152 @@ static void hmm_pfns_special(struct hmm_range *range)
>  }
>  
>  /*
> - * hmm_range_snapshot() - snapshot CPU page table for a range
> + * hmm_range_register() - start tracking change to CPU page table over a range
>   * @range: range
> - * Returns: number of valid pages in range->pfns[] (from range start
> - *          address). This may be zero. If the return value is negative,
> - *          then one of the following values may be returned:
> + * @mm: the mm struct for the range of virtual address
> + * @start: start virtual address (inclusive)
> + * @end: end virtual address (exclusive)
> + * Returns 0 on success, -EFAULT if the address space is no longer valid
>   *
> - *           -EINVAL  invalid arguments or mm or virtual address are in an
> - *                    invalid vma (ie either hugetlbfs or device file vma).
> - *           -EPERM   For example, asking for write, when the range is
> - *                    read-only
> - *           -EAGAIN  Caller needs to retry
> - *           -EFAULT  Either no valid vma exists for this range, or it is
> - *                    illegal to access the range
> - *
> - * This snapshots the CPU page table for a range of virtual addresses. Snapshot
> - * validity is tracked by range struct. See hmm_vma_range_done() for further
> - * information.
> + * Track updates to the CPU page table see include/linux/hmm.h
>   */
> -long hmm_range_snapshot(struct hmm_range *range)
> +int hmm_range_register(struct hmm_range *range,
> +		       struct mm_struct *mm,
> +		       unsigned long start,
> +		       unsigned long end)
>  {
> -	struct vm_area_struct *vma = range->vma;
> -	struct hmm_vma_walk hmm_vma_walk;
> -	struct mm_walk mm_walk;
> -	struct hmm *hmm;
> -
> +	range->start = start & PAGE_MASK;
> +	range->end = end & PAGE_MASK;
> +	range->valid = false;
>  	range->hmm = NULL;
>  
> -	/* Sanity check, this really should not happen ! */
> -	if (range->start < vma->vm_start || range->start >= vma->vm_end)
> -		return -EINVAL;
> -	if (range->end < vma->vm_start || range->end > vma->vm_end)
> +	if (range->start >= range->end)
>  		return -EINVAL;
>  
> -	hmm = hmm_register(vma->vm_mm);
> -	if (!hmm)
> -		return -ENOMEM;
> +	range->hmm = hmm_register(mm);
> +	if (!range->hmm)
> +		return -EFAULT;
>  
>  	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL) {
> -		hmm_put(hmm);
> -		return -EINVAL;
> +	if (range->hmm->mm == NULL || range->hmm->dead) {
> +		hmm_put(range->hmm);
> +		return -EFAULT;
>  	}
>  
> -	/* FIXME support hugetlb fs */
> -	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
> -			vma_is_dax(vma)) {
> -		hmm_pfns_special(range);
> -		hmm_put(hmm);
> -		return -EINVAL;
> -	}
> +	/* Initialize range to track CPU page table update */
> +	mutex_lock(&range->hmm->lock);
>  
> -	if (!(vma->vm_flags & VM_READ)) {
> -		/*
> -		 * If vma do not allow read access, then assume that it does
> -		 * not allow write access, either. Architecture that allow
> -		 * write without read access are not supported by HMM, because
> -		 * operations such has atomic access would not work.
> -		 */
> -		hmm_pfns_clear(range, range->pfns, range->start, range->end);
> -		hmm_put(hmm);
> -		return -EPERM;
> -	}
> +	list_add_rcu(&range->list, &range->hmm->ranges);
>  
> -	/* Initialize range to track CPU page table update */
> -	spin_lock(&hmm->lock);
> -	range->valid = true;
> -	list_add_rcu(&range->list, &hmm->ranges);
> -	spin_unlock(&hmm->lock);
> -
> -	hmm_vma_walk.fault = false;
> -	hmm_vma_walk.range = range;
> -	mm_walk.private = &hmm_vma_walk;
> -	hmm_vma_walk.last = range->start;
> -
> -	mm_walk.vma = vma;
> -	mm_walk.mm = vma->vm_mm;
> -	mm_walk.pte_entry = NULL;
> -	mm_walk.test_walk = NULL;
> -	mm_walk.hugetlb_entry = NULL;
> -	mm_walk.pmd_entry = hmm_vma_walk_pmd;
> -	mm_walk.pte_hole = hmm_vma_walk_hole;
> -
> -	walk_page_range(range->start, range->end, &mm_walk);
>  	/*
> -	 * Transfer hmm reference to the range struct it will be drop inside
> -	 * the hmm_vma_range_done() function (which _must_ be call if this
> -	 * function return 0).
> +	 * If there are any concurrent notifiers we have to wait for them for
> +	 * the range to be valid (see hmm_range_wait_until_valid()).
>  	 */
> -	range->hmm = hmm;
> -	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
> +	if (!range->hmm->notifiers)
> +		range->valid = true;
> +	mutex_unlock(&range->hmm->lock);
> +
> +	return 0;
>  }
> -EXPORT_SYMBOL(hmm_range_snapshot);
> +EXPORT_SYMBOL(hmm_range_register);
>  
>  /*
> - * hmm_vma_range_done() - stop tracking change to CPU page table over a range
> - * @range: range being tracked
> - * Returns: false if range data has been invalidated, true otherwise
> + * hmm_range_unregister() - stop tracking change to CPU page table over a range
> + * @range: range
>   *
>   * Range struct is used to track updates to the CPU page table after a call to
> - * either hmm_vma_get_pfns() or hmm_vma_fault(). Once the device driver is done
> - * using the data,  or wants to lock updates to the data it got from those
> - * functions, it must call the hmm_vma_range_done() function, which will then
> - * stop tracking CPU page table updates.
> - *
> - * Note that device driver must still implement general CPU page table update
> - * tracking either by using hmm_mirror (see hmm_mirror_register()) or by using
> - * the mmu_notifier API directly.
> - *
> - * CPU page table update tracking done through hmm_range is only temporary and
> - * to be used while trying to duplicate CPU page table contents for a range of
> - * virtual addresses.
> - *
> - * There are two ways to use this :
> - * again:
> - *   hmm_vma_get_pfns(range); or hmm_vma_fault(...);
> - *   trans = device_build_page_table_update_transaction(pfns);
> - *   device_page_table_lock();
> - *   if (!hmm_vma_range_done(range)) {
> - *     device_page_table_unlock();
> - *     goto again;
> - *   }
> - *   device_commit_transaction(trans);
> - *   device_page_table_unlock();
> - *
> - * Or:
> - *   hmm_vma_get_pfns(range); or hmm_vma_fault(...);
> - *   device_page_table_lock();
> - *   hmm_vma_range_done(range);
> - *   device_update_page_table(range->pfns);
> - *   device_page_table_unlock();
> + * hmm_range_register(). See include/linux/hmm.h for how to use it.
>   */
> -bool hmm_vma_range_done(struct hmm_range *range)
> +void hmm_range_unregister(struct hmm_range *range)
>  {
> -	bool ret = false;
> -
>  	/* Sanity check this really should not happen. */
> -	if (range->hmm == NULL || range->end <= range->start) {
> -		BUG();
> -		return false;
> -	}
> +	if (range->hmm == NULL || range->end <= range->start)
> +		return;
>  
> -	spin_lock(&range->hmm->lock);
> +	mutex_lock(&range->hmm->lock);
>  	list_del_rcu(&range->list);
> -	ret = range->valid;
> -	spin_unlock(&range->hmm->lock);
> -
> -	/* Is the mm still alive ? */
> -	if (range->hmm->mm == NULL)
> -		ret = false;
> +	mutex_unlock(&range->hmm->lock);
>  
> -	/* Drop reference taken by hmm_vma_fault() or hmm_vma_get_pfns() */
> +	/* Drop reference taken by hmm_range_register() */
> +	range->valid = false;
>  	hmm_put(range->hmm);
>  	range->hmm = NULL;
> -	return ret;
>  }
> -EXPORT_SYMBOL(hmm_vma_range_done);
> +EXPORT_SYMBOL(hmm_range_unregister);
> +
> +/*
> + * hmm_range_snapshot() - snapshot CPU page table for a range
> + * @range: range
> + * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
> + *          permission (for instance asking for write and range is read only),
> + *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
> + *          vma or it is illegal to access that range), number of valid pages
> + *          in range->pfns[] (from range start address).
> + *
> + * This snapshots the CPU page table for a range of virtual addresses. Snapshot
> + * validity is tracked by range struct. See in include/linux/hmm.h for example
> + * on how to use.
> + */
> +long hmm_range_snapshot(struct hmm_range *range)
> +{
> +	unsigned long start = range->start, end;
> +	struct hmm_vma_walk hmm_vma_walk;
> +	struct hmm *hmm = range->hmm;
> +	struct vm_area_struct *vma;
> +	struct mm_walk mm_walk;
> +
> +	/* Check if hmm_mm_destroy() was call. */
> +	if (hmm->mm == NULL || hmm->dead)
> +		return -EFAULT;
> +
> +	do {
> +		/* If range is no longer valid force retry. */
> +		if (!range->valid)
> +			return -EAGAIN;
> +
> +		vma = find_vma(hmm->mm, start);
> +		if (vma == NULL || (vma->vm_flags & VM_SPECIAL))
> +			return -EFAULT;
> +
> +		/* FIXME support hugetlb fs/dax */
> +		if (is_vm_hugetlb_page(vma) || vma_is_dax(vma)) {
> +			hmm_pfns_special(range);
> +			return -EINVAL;
> +		}
> +
> +		if (!(vma->vm_flags & VM_READ)) {
> +			/*
> +			 * If vma do not allow read access, then assume that it
> +			 * does not allow write access, either. HMM does not
> +			 * support architecture that allow write without read.
> +			 */
> +			hmm_pfns_clear(range, range->pfns,
> +				range->start, range->end);
> +			return -EPERM;
> +		}
> +
> +		range->vma = vma;
> +		hmm_vma_walk.last = start;
> +		hmm_vma_walk.fault = false;
> +		hmm_vma_walk.range = range;
> +		mm_walk.private = &hmm_vma_walk;
> +		end = min(range->end, vma->vm_end);
> +
> +		mm_walk.vma = vma;
> +		mm_walk.mm = vma->vm_mm;
> +		mm_walk.pte_entry = NULL;
> +		mm_walk.test_walk = NULL;
> +		mm_walk.hugetlb_entry = NULL;
> +		mm_walk.pmd_entry = hmm_vma_walk_pmd;
> +		mm_walk.pte_hole = hmm_vma_walk_hole;
> +
> +		walk_page_range(start, end, &mm_walk);
> +		start = end;
> +	} while (start < range->end);
> +
> +	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
> +}
> +EXPORT_SYMBOL(hmm_range_snapshot);
>  
>  /*
>   * hmm_range_fault() - try to fault some address in a virtual address range
> @@ -889,96 +886,79 @@ EXPORT_SYMBOL(hmm_vma_range_done);
>   */
>  long hmm_range_fault(struct hmm_range *range, bool block)
>  {
> -	struct vm_area_struct *vma = range->vma;
> -	unsigned long start = range->start;
> +	unsigned long start = range->start, end;
>  	struct hmm_vma_walk hmm_vma_walk;
> +	struct hmm *hmm = range->hmm;
> +	struct vm_area_struct *vma;
>  	struct mm_walk mm_walk;
> -	struct hmm *hmm;
>  	int ret;
>  
> -	range->hmm = NULL;
> -
> -	/* Sanity check, this really should not happen ! */
> -	if (range->start < vma->vm_start || range->start >= vma->vm_end)
> -		return -EINVAL;
> -	if (range->end < vma->vm_start || range->end > vma->vm_end)
> -		return -EINVAL;
> +	/* Check if hmm_mm_destroy() was call. */
> +	if (hmm->mm == NULL || hmm->dead)
> +		return -EFAULT;
>  
> -	hmm = hmm_register(vma->vm_mm);
> -	if (!hmm) {
> -		hmm_pfns_clear(range, range->pfns, range->start, range->end);
> -		return -ENOMEM;
> -	}
> +	do {
> +		/* If range is no longer valid force retry. */
> +		if (!range->valid) {
> +			up_read(&hmm->mm->mmap_sem);
> +			return -EAGAIN;
> +		}
>  
> -	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL) {
> -		hmm_put(hmm);
> -		return -EINVAL;
> -	}
> +		vma = find_vma(hmm->mm, start);
> +		if (vma == NULL || (vma->vm_flags & VM_SPECIAL))
> +			return -EFAULT;
>  
> -	/* FIXME support hugetlb fs */
> -	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
> -			vma_is_dax(vma)) {
> -		hmm_pfns_special(range);
> -		hmm_put(hmm);
> -		return -EINVAL;
> -	}
> +		/* FIXME support hugetlb fs/dax */
> +		if (is_vm_hugetlb_page(vma) || vma_is_dax(vma)) {
> +			hmm_pfns_special(range);
> +			return -EINVAL;
> +		}
>  
> -	if (!(vma->vm_flags & VM_READ)) {
> -		/*
> -		 * If vma do not allow read access, then assume that it does
> -		 * not allow write access, either. Architecture that allow
> -		 * write without read access are not supported by HMM, because
> -		 * operations such has atomic access would not work.
> -		 */
> -		hmm_pfns_clear(range, range->pfns, range->start, range->end);
> -		hmm_put(hmm);
> -		return -EPERM;
> -	}
> +		if (!(vma->vm_flags & VM_READ)) {
> +			/*
> +			 * If vma do not allow read access, then assume that it
> +			 * does not allow write access, either. HMM does not
> +			 * support architecture that allow write without read.
> +			 */
> +			hmm_pfns_clear(range, range->pfns,
> +				range->start, range->end);
> +			return -EPERM;
> +		}
>  
> -	/* Initialize range to track CPU page table update */
> -	spin_lock(&hmm->lock);
> -	range->valid = true;
> -	list_add_rcu(&range->list, &hmm->ranges);
> -	spin_unlock(&hmm->lock);
> -
> -	hmm_vma_walk.fault = true;
> -	hmm_vma_walk.block = block;
> -	hmm_vma_walk.range = range;
> -	mm_walk.private = &hmm_vma_walk;
> -	hmm_vma_walk.last = range->start;
> -
> -	mm_walk.vma = vma;
> -	mm_walk.mm = vma->vm_mm;
> -	mm_walk.pte_entry = NULL;
> -	mm_walk.test_walk = NULL;
> -	mm_walk.hugetlb_entry = NULL;
> -	mm_walk.pmd_entry = hmm_vma_walk_pmd;
> -	mm_walk.pte_hole = hmm_vma_walk_hole;
> +		range->vma = vma;
> +		hmm_vma_walk.last = start;
> +		hmm_vma_walk.fault = true;
> +		hmm_vma_walk.block = block;
> +		hmm_vma_walk.range = range;
> +		mm_walk.private = &hmm_vma_walk;
> +		end = min(range->end, vma->vm_end);
> +
> +		mm_walk.vma = vma;
> +		mm_walk.mm = vma->vm_mm;
> +		mm_walk.pte_entry = NULL;
> +		mm_walk.test_walk = NULL;
> +		mm_walk.hugetlb_entry = NULL;
> +		mm_walk.pmd_entry = hmm_vma_walk_pmd;
> +		mm_walk.pte_hole = hmm_vma_walk_hole;
> +
> +		do {
> +			ret = walk_page_range(start, end, &mm_walk);
> +			start = hmm_vma_walk.last;
> +
> +			/* Keep trying while the range is valid. */
> +		} while (ret == -EBUSY && range->valid);
> +
> +		if (ret) {
> +			unsigned long i;
> +
> +			i = (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
> +			hmm_pfns_clear(range, &range->pfns[i],
> +				hmm_vma_walk.last, range->end);
> +			return ret;
> +		}
> +		start = end;
>  
> -	do {
> -		ret = walk_page_range(start, range->end, &mm_walk);
> -		start = hmm_vma_walk.last;
> -		/* Keep trying while the range is valid. */
> -	} while (ret == -EBUSY && range->valid);
> -
> -	if (ret) {
> -		unsigned long i;
> -
> -		i = (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
> -		hmm_pfns_clear(range, &range->pfns[i], hmm_vma_walk.last,
> -			       range->end);
> -		hmm_vma_range_done(range);
> -		hmm_put(hmm);
> -		return ret;
> -	} else {
> -		/*
> -		 * Transfer hmm reference to the range struct it will be drop
> -		 * inside the hmm_vma_range_done() function (which _must_ be
> -		 * call if this function return 0).
> -		 */
> -		range->hmm = hmm;
> -	}
> +	} while (start < range->end);
>  
>  	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
>  }
> -- 
> 2.17.2
> 

