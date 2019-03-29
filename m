Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B07C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:57:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09FD72183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:57:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09FD72183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DB8F6B0006; Thu, 28 Mar 2019 20:57:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98B2A6B0007; Thu, 28 Mar 2019 20:57:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 878FF6B0008; Thu, 28 Mar 2019 20:57:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 659906B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 20:57:00 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f89so726414qtb.4
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:57:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=v36YaSlOp5D85V/nvkPMoZ9snIQMlD87a22vYcoupBs=;
        b=CHq5KlR4L9Ujuy9jr4HGdfpHe6LKZWdllFacehtMNlKSBzx5rq1AhtklDg5tVmKktM
         LyVCNyykl4HI9ocJPugoquTBcTQVsOmOp+Tio03Xhi7jwOkEp+gy9Yi4/Ke2eG+XtEUt
         wwKWYHveom6GXUT9ZlYRTR74DEOirqulaQw9zJuTOwDyWr+VNbWhm1U/TnJbd/SFRpJM
         b8oxQfQLbGt9tQ3ZoLwYo5wrLd2fVyH6R2CNJO8/ZjKO+/wPCIlk3CYuW+PagdgCFlLB
         0d3GMd4QC/DFYUbeAZtbDeb6xepR9Jle0zMVwZP9F9q2TpJG6aQOn4svvnqgVxC416eW
         Mt4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUUSz72MID5ZithrMXhRNYI1Po5hVS7Duag1udaLBRJpqBDjjpT
	7U/AAnmRjh8K+H45zQMUnNsN5XQmU3WnnB4e92+WyX/Cs+0pkRFvz0hPtmGv9nreflY/420fQuc
	rrO6ukWYRZ7CoY9aVeZ/uivo8i0hsjI7Wd78aaNmIUJoa89S+kDPee/+m3n9/y8TCNQ==
X-Received: by 2002:a37:bd81:: with SMTP id n123mr36913027qkf.249.1553821020077;
        Thu, 28 Mar 2019 17:57:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxu10bI5gdb24y42rde51M+ik7pIDJTpBYvHif8d1TozRVy5Im12Suv8JlJAJ6hccpLeWyl
X-Received: by 2002:a37:bd81:: with SMTP id n123mr36912986qkf.249.1553821019285;
        Thu, 28 Mar 2019 17:56:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553821019; cv=none;
        d=google.com; s=arc-20160816;
        b=FfwzRO6EnocnRAH/AQ7VTh6RV+7kbtdBR3sqLEGx4FR9GohWL9YmHz5oNehoanQc+Y
         Efni92Fu+qfC+bs6iwTpV1utMpQEqKg/w52HYFD8k1YUAkH9lAfsznJquYuKonF9hHOU
         rHcRMso4aZ5JheBdnCT8dLrPjr4oCabb5F3EThWGMd/jkxqUAe1HywxHNKTo6MdE1cpT
         OIhWJmQMXSGWwBnw2d5S2nyTJHXYoNySXj93phYNFkZhCt1ed5R0/IKXyf2+QcKx9MbM
         ABpRPFLUBZ1iznJBMekfpKUuz+tRY6QTzdv54y0cZqfrkDyu2kyxY3ns26SZY8wneArB
         fTPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=v36YaSlOp5D85V/nvkPMoZ9snIQMlD87a22vYcoupBs=;
        b=naEoBDitZ6XXIwhc2RKRDbVS8ISWhba3d4wAm1NoSYY4l2sBZRQTFLjJJWMEcWXfjk
         O0dEAYwPMv29B5D65pDPjFvDDzCE4NyFG5p6W6x9p8JGltl4qE0+o0JyX+feOBgNVbHy
         11Mv2rjn7Y+/BDNU6cjv3tGJngBLArr8hZquyrK52qug2bmh/rvP7cf6+/Q2BKO1mkwQ
         YBxZBRAhxxkGk9LEKvaWUvBON6AYq1sU5uON9cRFSDmLLJArGwO57vC4FB4yOdd64Ucu
         0l0/+/aZo4XPzmr4Y9BiI7AeTOZdoKdv+uUJT+Th+j5flLtaoUQWrF8iyuVIiqH5NFdT
         Z26g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u4si259834qkj.110.2019.03.28.17.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 17:56:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 44454C057F30;
	Fri, 29 Mar 2019 00:56:58 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E8A68608BC;
	Fri, 29 Mar 2019 00:56:56 +0000 (UTC)
Date: Thu, 28 Mar 2019 20:56:54 -0400
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
Message-ID: <20190329005654.GA16680@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-7-jglisse@redhat.com>
 <20190328161221.GE31324@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190328161221.GE31324@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Fri, 29 Mar 2019 00:56:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 09:12:21AM -0700, Ira Weiny wrote:
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
> 
> The above comment is great!  But I think you also need to update
> Documentation/vm/hmm.rst:hmm_range_snapshot() to show the use of
> hmm_range_[un]register()
> 
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
> > +		return -EAGAIN;
> > +	}
> > +
> > +	ret = hmm_range_fault(range, block);
> > +	if (ret <= 0) {
> > +		if (ret == -EBUSY || !ret) {
> > +			up_read(&range->vma->vm_mm->mmap_sem);
> > +			ret = -EBUSY;
> > +		} else if (ret == -EAGAIN)
> > +			ret = -EBUSY;
> > +		hmm_range_unregister(range);
> > +		return ret;
> > +	}
> > +	return 0;
> 
> Is hmm_vma_fault() also temporary to keep the nouveau driver working?  It looks
> like it to me.
> 
> This and hmm_vma_range_done() above are part of the old interface which is in
> the Documentation correct?  As stated above we should probably change that
> documentation with this patch to ensure no new users of these 2 functions
> appear.

Ok will update the documentation, note that i already posted patches to use
this new API see the ODP RDMA link in the cover letter.

Cheers,
Jérôme

