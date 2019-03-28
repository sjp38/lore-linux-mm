Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75C3CC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:39:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FF642184C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:39:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FF642184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8AB06B0293; Thu, 28 Mar 2019 17:39:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3BC46B0294; Thu, 28 Mar 2019 17:39:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B04A16B0295; Thu, 28 Mar 2019 17:39:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87DC86B0293
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:39:20 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k13so208790qtc.23
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:39:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=YClccBs2dzxkc8QNh59xI4nQB2eRXjjXHsh8EnXPFUI=;
        b=UimYAQGa/ECLtf/yW+eI/yw6sy0lRnThMvpKtrvE99khOdiaS05m2C2wcsopN2j5Dd
         C7WfKEDO6FLDnl/rRZEy08vx21IqxY3IyqhtVxrpFDhX2CG1Cc9JhFbHaIrBky7DR9RD
         UbjqEQv+eSeFoIee0YYL0OWc8/qv7z8x20r/zl5sQO7XnDLUNfXaxojhkIMLL/eJr0l1
         vMS3uzbaBq84kzqkyDKY7EHKTcQEMor4XfVKpFdmVZcsdttmAGUa+o/ArUHvZWa9qyoR
         cakhnsuiKnntAQv/fpF8pPv0Y/86UGlv8kEae/KeFQIYwzwzQm5vgcdpjdbwpWK1wgzv
         KTeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXGhsPMiCbP7OvtcbjXGSQqi/YVdd8wyLUrCMOotY/KJ6hGr/kN
	4fOD6GZWXYUB69vH7zrmOCc9qBr1TwuxpUWKHjJJJX7BsLt2IDef2zcdTFg6uf9BIRu/1FeqN/r
	Qt94v9mP5n8f+5Fo+rTAYrvXZzFtGaSF+sdcseufN4zgHWL/vleUM5B8Y23paIG0bKA==
X-Received: by 2002:a05:620a:101b:: with SMTP id z27mr35221813qkj.160.1553809160249;
        Thu, 28 Mar 2019 14:39:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8v6rY/y7G+JZ0Z82Fti6C5D4ZThzp7ZzJCMDDxE1kAqOWX8MMC+rhZkiRjEtGxF0rXn9n
X-Received: by 2002:a05:620a:101b:: with SMTP id z27mr35221767qkj.160.1553809159378;
        Thu, 28 Mar 2019 14:39:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553809159; cv=none;
        d=google.com; s=arc-20160816;
        b=KfxkI516axAttFi6hSEWn1gS2cSlQLYt3d4xTtV2VdnqffiAmdLpkwaYVdC+5y+pRp
         +uSHNj+Mo9Jgm9Cv9nPG56XMPEb2meLyZcPEh4VjD29YhzFxzB2nKQF4h9wYWZhORpev
         53qQa7/jpnUOmfL2++SdhlDGyaVKxKRoM8QoqjiUe5fdsZYqPfzUaKIeVvlZnpRigGsY
         rbrvw0IND3h+50NTKXVZjng/DbvYV+TQwCZGu7Mskmy38jcg4Yo7EXYKjzDB+pTsSsTt
         nUDQS4JhcmS0fuM/1Gvhj0AGQB4EsoDo7rNpOso2MAx2BiYMPIK3guXx/p32PPPBnhJ/
         /MiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=YClccBs2dzxkc8QNh59xI4nQB2eRXjjXHsh8EnXPFUI=;
        b=f6T5Psv4xSgBB4f5du92zux4mGNYnFyJR5pqS5xACrHOZI7Yev6JO0vZOS8ZozGSjo
         eHAvU/OA+9r5Ej5L7EpguG2DwmmBLvqw1U+KIyBWrtim3sN+SYIhwTqWNTy+bGJ6v3Wr
         K6dzxNZmp/bd8dgErxeUcyDYeCCULoNa9c/lq0emcHrW09neIVOuTmFo6g1C3ml6+cuU
         0Iwyn501aN4JAp+3zmTytZ0aAMXVhuURme68hVgady3XsuSIO1SB3C2Cco7fZuKahHby
         0ZrwcQf0M7MhQlRQvlkvbXNlI+VsVOaRn6MUmlJ9qajqtrAaDtCuy1xEWMMSkFMjk5bH
         yk1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u49si90249qtk.310.2019.03.28.14.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:39:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8426531688E1;
	Thu, 28 Mar 2019 21:39:18 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0F77B8389E;
	Thu, 28 Mar 2019 21:39:16 +0000 (UTC)
Date: Thu, 28 Mar 2019 17:39:14 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 06/11] mm/hmm: improve driver API to work and wait
 over a range v2
Message-ID: <20190328213913.GC13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-7-jglisse@redhat.com>
 <20190328131154.GB31324@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190328131154.GB31324@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 28 Mar 2019 21:39:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 06:11:54AM -0700, Ira Weiny wrote:
> On Mon, Mar 25, 2019 at 10:40:06AM -0400, Jerome Glisse wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > A common use case for HMM mirror is user trying to mirror a range
> > and before they could program the hardware it get invalidated by
> > some core mm event. Instead of having user re-try right away to
> > mirror the range provide a completion mechanism for them to wait
> > for any active invalidation affecting the range.
> > 
> > This also changes how hmm_range_snapshot() and hmm_range_fault()
> > works by not relying on vma so that we can drop the mmap_sem
> > when waiting and lookup the vma again on retry.
> > 
> > Changes since v1:
> >     - squashed: Dan Carpenter: potential deadlock in nonblocking code
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > ---
> >  include/linux/hmm.h | 208 ++++++++++++++---
> >  mm/hmm.c            | 528 +++++++++++++++++++++-----------------------
> >  2 files changed, 428 insertions(+), 308 deletions(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index e9afd23c2eac..79671036cb5f 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -77,8 +77,34 @@
> >  #include <linux/migrate.h>
> >  #include <linux/memremap.h>
> >  #include <linux/completion.h>
> > +#include <linux/mmu_notifier.h>
> >  
> > -struct hmm;
> > +
> > +/*
> > + * struct hmm - HMM per mm struct
> > + *
> > + * @mm: mm struct this HMM struct is bound to
> > + * @lock: lock protecting ranges list
> > + * @ranges: list of range being snapshotted
> > + * @mirrors: list of mirrors for this mm
> > + * @mmu_notifier: mmu notifier to track updates to CPU page table
> > + * @mirrors_sem: read/write semaphore protecting the mirrors list
> > + * @wq: wait queue for user waiting on a range invalidation
> > + * @notifiers: count of active mmu notifiers
> > + * @dead: is the mm dead ?
> > + */
> > +struct hmm {
> > +	struct mm_struct	*mm;
> > +	struct kref		kref;
> > +	struct mutex		lock;
> > +	struct list_head	ranges;
> > +	struct list_head	mirrors;
> > +	struct mmu_notifier	mmu_notifier;
> > +	struct rw_semaphore	mirrors_sem;
> > +	wait_queue_head_t	wq;
> > +	long			notifiers;
> > +	bool			dead;
> > +};
> >  
> >  /*
> >   * hmm_pfn_flag_e - HMM flag enums
> > @@ -155,6 +181,38 @@ struct hmm_range {
> >  	bool			valid;
> >  };
> >  
> > +/*
> > + * hmm_range_wait_until_valid() - wait for range to be valid
> > + * @range: range affected by invalidation to wait on
> > + * @timeout: time out for wait in ms (ie abort wait after that period of time)
> > + * Returns: true if the range is valid, false otherwise.
> > + */
> > +static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
> > +					      unsigned long timeout)
> > +{
> > +	/* Check if mm is dead ? */
> > +	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
> > +		range->valid = false;
> > +		return false;
> > +	}
> > +	if (range->valid)
> > +		return true;
> > +	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
> > +			   msecs_to_jiffies(timeout));
> > +	/* Return current valid status just in case we get lucky */
> > +	return range->valid;
> > +}
> > +
> > +/*
> > + * hmm_range_valid() - test if a range is valid or not
> > + * @range: range
> > + * Returns: true if the range is valid, false otherwise.
> > + */
> > +static inline bool hmm_range_valid(struct hmm_range *range)
> > +{
> > +	return range->valid;
> > +}
> > +
> >  /*
> >   * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
> >   * @range: range use to decode HMM pfn value
> > @@ -357,51 +415,133 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
> >  
> >  
> >  /*
> > - * To snapshot the CPU page table, call hmm_vma_get_pfns(), then take a device
> > - * driver lock that serializes device page table updates, then call
> > - * hmm_vma_range_done(), to check if the snapshot is still valid. The same
> > - * device driver page table update lock must also be used in the
> > - * hmm_mirror_ops.sync_cpu_device_pagetables() callback, so that CPU page
> > - * table invalidation serializes on it.
> > + * To snapshot the CPU page table you first have to call hmm_range_register()
> > + * to register the range. If hmm_range_register() return an error then some-
> > + * thing is horribly wrong and you should fail loudly. If it returned true then
> > + * you can wait for the range to be stable with hmm_range_wait_until_valid()
> > + * function, a range is valid when there are no concurrent changes to the CPU
> > + * page table for the range.
> > + *
> > + * Once the range is valid you can call hmm_range_snapshot() if that returns
> > + * without error then you can take your device page table lock (the same lock
> > + * you use in the HMM mirror sync_cpu_device_pagetables() callback). After
> > + * taking that lock you have to check the range validity, if it is still valid
> > + * (ie hmm_range_valid() returns true) then you can program the device page
> > + * table, otherwise you have to start again. Pseudo code:
> > + *
> > + *      mydevice_prefault(mydevice, mm, start, end)
> > + *      {
> > + *          struct hmm_range range;
> > + *          ...
> >   *
> > - * YOU MUST CALL hmm_vma_range_done() ONCE AND ONLY ONCE EACH TIME YOU CALL
> > - * hmm_range_snapshot() WITHOUT ERROR !
> > + *          ret = hmm_range_register(&range, mm, start, end);
> > + *          if (ret)
> > + *              return ret;
> >   *
> > - * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE INVALID !
> > - */
> > -long hmm_range_snapshot(struct hmm_range *range);
> > -bool hmm_vma_range_done(struct hmm_range *range);
> > -
> > -
> > -/*
> > - * Fault memory on behalf of device driver. Unlike handle_mm_fault(), this will
> > - * not migrate any device memory back to system memory. The HMM pfn array will
> > - * be updated with the fault result and current snapshot of the CPU page table
> > - * for the range.
> > + *          down_read(mm->mmap_sem);
> > + *      again:
> > + *
> > + *          if (!hmm_range_wait_until_valid(&range, TIMEOUT)) {
> > + *              up_read(&mm->mmap_sem);
> > + *              hmm_range_unregister(range);
> > + *              // Handle time out, either sleep or retry or something else
> > + *              ...
> > + *              return -ESOMETHING; || goto again;
> > + *          }
> > + *
> > + *          ret = hmm_range_snapshot(&range); or hmm_range_fault(&range);
> > + *          if (ret == -EAGAIN) {
> > + *              down_read(mm->mmap_sem);
> > + *              goto again;
> > + *          } else if (ret == -EBUSY) {
> > + *              goto again;
> > + *          }
> > + *
> > + *          up_read(&mm->mmap_sem);
> > + *          if (ret) {
> > + *              hmm_range_unregister(range);
> > + *              return ret;
> > + *          }
> > + *
> > + *          // It might not have snap-shoted the whole range but only the first
> > + *          // npages, the return values is the number of valid pages from the
> > + *          // start of the range.
> > + *          npages = ret;
> >   *
> > - * The mmap_sem must be taken in read mode before entering and it might be
> > - * dropped by the function if the block argument is false. In that case, the
> > - * function returns -EAGAIN.
> > + *          ...
> >   *
> > - * Return value does not reflect if the fault was successful for every single
> > - * address or not. Therefore, the caller must to inspect the HMM pfn array to
> > - * determine fault status for each address.
> > + *          mydevice_page_table_lock(mydevice);
> > + *          if (!hmm_range_valid(range)) {
> > + *              mydevice_page_table_unlock(mydevice);
> > + *              goto again;
> > + *          }
> >   *
> > - * Trying to fault inside an invalid vma will result in -EINVAL.
> > + *          mydevice_populate_page_table(mydevice, range, npages);
> > + *          ...
> > + *          mydevice_take_page_table_unlock(mydevice);
> > + *          hmm_range_unregister(range);
> >   *
> > - * See the function description in mm/hmm.c for further documentation.
> > + *          return 0;
> > + *      }
> > + *
> > + * The same scheme apply to hmm_range_fault() (ie replace hmm_range_snapshot()
> > + * with hmm_range_fault() in above pseudo code).
> > + *
> > + * YOU MUST CALL hmm_range_unregister() ONCE AND ONLY ONCE EACH TIME YOU CALL
> > + * hmm_range_register() AND hmm_range_register() RETURNED TRUE ! IF YOU DO NOT
> > + * FOLLOW THIS RULE MEMORY CORRUPTION WILL ENSUE !
> >   */
> > +int hmm_range_register(struct hmm_range *range,
> > +		       struct mm_struct *mm,
> > +		       unsigned long start,
> > +		       unsigned long end);
> > +void hmm_range_unregister(struct hmm_range *range);
> > +long hmm_range_snapshot(struct hmm_range *range);
> >  long hmm_range_fault(struct hmm_range *range, bool block);
> >  
> > +/*
> > + * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
> > + *
> > + * When waiting for mmu notifiers we need some kind of time out otherwise we
> > + * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
> > + * wait already.
> > + */
> > +#define HMM_RANGE_DEFAULT_TIMEOUT 1000
> > +
> >  /* This is a temporary helper to avoid merge conflict between trees. */
> > +static inline bool hmm_vma_range_done(struct hmm_range *range)
> > +{
> > +	bool ret = hmm_range_valid(range);
> > +
> > +	hmm_range_unregister(range);
> > +	return ret;
> > +}
> > +
> >  static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> >  {
> > -	long ret = hmm_range_fault(range, block);
> > -	if (ret == -EBUSY)
> > -		ret = -EAGAIN;
> > -	else if (ret == -EAGAIN)
> > -		ret = -EBUSY;
> > -	return ret < 0 ? ret : 0;
> > +	long ret;
> > +
> > +	ret = hmm_range_register(range, range->vma->vm_mm,
> > +				 range->start, range->end);
> > +	if (ret)
> > +		return (int)ret;
> > +
> > +	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> > +		up_read(&range->vma->vm_mm->mmap_sem);
> 
> Where is the down_read() which correspond to this?
> 
> > +		return -EAGAIN;
> > +	}
> > +
> > +	ret = hmm_range_fault(range, block);
> > +	if (ret <= 0) {
> > +		if (ret == -EBUSY || !ret) {
> > +			up_read(&range->vma->vm_mm->mmap_sem);
> 
> Or this...?
> 
> > +			ret = -EBUSY;
> > +		} else if (ret == -EAGAIN)
> > +			ret = -EBUSY;
> > +		hmm_range_unregister(range);
> > +		return ret;
> > +	}
> 
> And is the side effect of this call that the mmap_sem has been taken?
> Or is the side effect that the mmap_sem was released?
> 
> I'm not saying this is wrong, but I can't tell so it seems like a comment on
> the function would help.
> 

The comments above:

/* This is a temporary helper to avoid merge conflict between trees. */

Do matter, here i am updating HMM API and thus the old API which is
hmm_vma_fault() no longer exist and is replaced internaly by the new
API hmm_range_register() and hmm_range_fault().

To avoid complex cross tree merging i introduce this inline function
that reproduce the old API on top of the new API. The intent is that
once this is merged, then the next merge window i will drop the old
API from the upstream user (ie update the nouveau driver) and convert
them to the new API. Then i will remove this inline function.

This was discuss extensively already. Cross tree synchronization is
painfull and it is best to do this dance. Upstream something in at
relase N, update everyone in each indepedent tree in N+1, cleanup if
any in N+2


If you want to check that the above code is valid then you need to
look at the comment above the old API function which describe the
old API and also probably look at the code to understand all the cases.

Then you can compare against what this _temporary_ wrapper do with
the new API and that it does match the old API.


I have tested all this with nouveau which is upstream and nouveau
keep working unmodified before and after this patch.


Cheers,
Jérôme

