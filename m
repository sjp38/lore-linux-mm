Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B5D8C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:11:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 554C6217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:11:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 554C6217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E09FE8E0002; Tue, 12 Feb 2019 11:11:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB9678E0001; Tue, 12 Feb 2019 11:11:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCF278E0002; Tue, 12 Feb 2019 11:11:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A258C8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:11:30 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w134so7700542qka.6
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:11:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=9LF/5D9lAWXHWfFDCyl89SmnGJ5RpyrtHHHbjBjTgoI=;
        b=f5gJ6U5NTOneHC6zI8eyae7O0RMy6Ouuym/rs4659A/Et8LzBglcMVCBH59Uohpwof
         wFS/cEfMEsA3DXjiR8ChUuG/aUfoYZ5L245GHcEjPc98bFBUD7fh6ekeFl0Rv+1G4phL
         f7Kmhd2TcalkpqXrJ4/A/UVULCFWG5rr+LxZ80iN2WKmpsiduT3uBlyW3hovnP1gjF3g
         tRYJdUxO0KMC7Uyugf8/Wa/wR2IeL4iRnRGkfVg8nyBAzPwjMLTuKx6w0CIZLzLH6AuR
         tBoCveWLRiXqW5qLtCCUbVGZKbvZyVGc+A2XVFdfcm/Vw/d3+yzs/0vrK6j+PVtmbQ7k
         TNtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub2uthD/gZG3Tal1JEilac29R2M1T4YqHsCxJd5P7zLJ54+I6v7
	4CS1FyoCcZ3K+Xbj1OSPacDkosMcy6TzbFDdKh0v1yV0jDs5scL5IYW9qKqgtZi9AICIPZflOjs
	htUFY/wMJ9wZHfeX6NzkfqA1fiCy6a0URTV8hxAyi94Ow8csnbqURzG1gXOnGYy/WWg==
X-Received: by 2002:ac8:2190:: with SMTP id 16mr3468755qty.365.1549987890382;
        Tue, 12 Feb 2019 08:11:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia1Xk8PHnm6spXbnamPkDvu4B+y+bxEIWXOfWuIIFAnfXaPVV+nFJ1tFfOpLAcX8kNgOC/O
X-Received: by 2002:ac8:2190:: with SMTP id 16mr3468662qty.365.1549987889288;
        Tue, 12 Feb 2019 08:11:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549987889; cv=none;
        d=google.com; s=arc-20160816;
        b=rtj049D7ZrmYC1YBAVxk00vHoD9Lfo+ANaWcEVzqjLn4HTkn0OE2KIe2IRd812oUMU
         I1FTSKEpsRLz4k/vlQ6SJIGrLPi/MrGdzQBIqTtO2ePvUpj5gH3Nxpm0LkBV9uNE5hjF
         fbg4qMwgBjqMF/0gUx1FGFVCx9rL86Q4P1mzEqP9i1UUK5qEt9d9o3/ppvIh+2c3IHHv
         wU3CE/03SReJTK7f+tj+2oivqB6t/jGWmzDP4kS6CSrQG8pSX4jxzdZSCgxCJu4t2qMb
         VyXuQ9gG+2kkOjO7vwXWteAln5QXg+6NJfYTB84pYhaQt9faagdZIHRpKffW7TsdBOKj
         qkTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=9LF/5D9lAWXHWfFDCyl89SmnGJ5RpyrtHHHbjBjTgoI=;
        b=daiMigTBjrEIpmXhpiV5kyIQZf3JQ4YRTjqB8a4tQUI6fkgHOPUn9lxqAW/CorqjX7
         fdtRtjOv8RChRDryFfkVQ0m6+0Fgy/rM8BVGm8IiAoHCkCqPikrT9tS6vHvvfDI0VGmX
         KBxxdkvj53epAMzrXl+76v0sHGBx1wAcmL8o7QvfKW3ke912siWQCaDwRJ937XPMhh7j
         MI64CVFK/4O/9Zy9J5ciA3CJagKasPs4iOb9eoUHr3MRZ6G9AsAyVQrRQ6wrpiO1yqUR
         d0V1gt+iD5ffj8wwBY7j+oHlaNtVdmJQjubbb1SOIgln2E26CmhjyLTslFwxE2Pw8CZ7
         QSVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s16si3724245qtq.248.2019.02.12.08.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:11:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F2589C058CB1;
	Tue, 12 Feb 2019 16:11:27 +0000 (UTC)
Received: from redhat.com (ovpn-125-41.rdu2.redhat.com [10.10.125.41])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 14ED419741;
	Tue, 12 Feb 2019 16:11:25 +0000 (UTC)
Date: Tue, 12 Feb 2019 11:11:24 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Haggai Eran <haggaie@mellanox.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Aviad Yehezkel <aviadye@mellanox.com>
Subject: Re: [PATCH 1/1] RDMA/odp: convert to use HMM for ODP
Message-ID: <20190212161123.GA4629@redhat.com>
References: <20190129165839.4127-1-jglisse@redhat.com>
 <20190129165839.4127-2-jglisse@redhat.com>
 <f48ed64f-22fe-c366-6a0e-1433e72b9359@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f48ed64f-22fe-c366-6a0e-1433e72b9359@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 12 Feb 2019 16:11:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 08:44:26AM +0000, Haggai Eran wrote:
> On 1/29/2019 6:58 PM, jglisse@redhat.com wrote:
>  > Convert ODP to use HMM so that we can build on common infrastructure
>  > for different class of devices that want to mirror a process address
>  > space into a device. There is no functional changes.
> 
> Thanks for sending this patch. I think in general it is a good idea to 
> use a common infrastructure for ODP.
> 
> I have a couple of questions below.
> 
> > -static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
> > -				const struct mmu_notifier_range *range)
> > -{
> > -	struct ib_ucontext_per_mm *per_mm =
> > -		container_of(mn, struct ib_ucontext_per_mm, mn);
> > -
> > -	if (unlikely(!per_mm->active))
> > -		return;
> > -
> > -	rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
> > -				      range->end,
> > -				      invalidate_range_end_trampoline, true, NULL);
> >   	up_read(&per_mm->umem_rwsem);
> > +	return ret;
> >   }
> Previously the code held the umem_rwsem between range_start and 
> range_end calls. I guess that was in order to guarantee that no device 
> page faults take reference to the pages being invalidated while the 
> invalidation is ongoing. I assume this is now handled by hmm instead, 
> correct?

It is a mix of HMM and driver in pagefault_mr() mlx5/odp.c
    mutex_lock(&odp->umem_mutex);
    if (hmm_vma_range_done(range)) {
    ...

This is what serialize programming the hw and any concurrent CPU page
table invalidation. This is also one of the thing i want to improve
long term as mlx5_ib_update_xlt() can do memory allocation and i would
like to avoid that ie make mlx5_ib_update_xlt() and its sub-functions
as small and to the points as possible so that they could only fail if
the hardware is in bad state not because of memory allocation issues.


> 
> > +
> > +static uint64_t odp_hmm_flags[HMM_PFN_FLAG_MAX] = {
> > +	ODP_READ_BIT,	/* HMM_PFN_VALID */
> > +	ODP_WRITE_BIT,	/* HMM_PFN_WRITE */
> > +	ODP_DEVICE_BIT,	/* HMM_PFN_DEVICE_PRIVATE */
> It seems that the mlx5_ib code in this patch currently ignores the 
> ODP_DEVICE_BIT (e.g., in umem_dma_to_mtt). Is that okay? Or is it 
> handled implicitly by the HMM_PFN_SPECIAL case?

This is because HMM except a bit for device memory as same API is
use for GPU which have device memory. I can add a comment explaining
that it is not use for ODP but there just to comply with HMM API.

> 
> > @@ -327,9 +287,10 @@ void put_per_mm(struct ib_umem_odp *umem_odp)
> >  	up_write(&per_mm->umem_rwsem);
> >  
> >  	WARN_ON(!RB_EMPTY_ROOT(&per_mm->umem_tree.rb_root));
> > -	mmu_notifier_unregister_no_release(&per_mm->mn, per_mm->mm);
> > +	hmm_mirror_unregister(&per_mm->mirror);
> >  	put_pid(per_mm->tgid);
> > -	mmu_notifier_call_srcu(&per_mm->rcu, free_per_mm);
> > +
> > +	kfree(per_mm);
> >  }
> Previously the per_mm struct was released through call srcu, but now it 
> is released immediately. Is it safe? I saw that hmm_mirror_unregister 
> calls mmu_notifier_unregister_no_release, so I don't understand what 
> prevents concurrently running invalidations from accessing the released 
> per_mm struct.

Yes it is safe, the hmm struct has its own refcount and mirror holds a
reference on it, the mm struct itself has a reference on the mm struct.
So no structure can vanish before the other. However once release call-
back happens you can no longer fault anything it will -EFAULT if you
try to (not to mention that by then all the vma have been tear down).
So even if some kernel thread race with destruction it will not be able
to fault anything or use mirror struct in any meaning full way.

Note that in a regular tear down the ODP put_per_mm() will happen before
the release callback as iirc file including device file get close before
the mm is teardown. But in anycase it would work no matter what the order
is.

> 
> > @@ -578,11 +578,27 @@ static int pagefault_mr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr,
> >  
> >  next_mr:
> >  	size = min_t(size_t, bcnt, ib_umem_end(&odp->umem) - io_virt);
> > -
> >  	page_shift = mr->umem->page_shift;
> >  	page_mask = ~(BIT(page_shift) - 1);
> > +	off = (io_virt & (~page_mask));
> > +	size += (io_virt & (~page_mask));
> > +	io_virt = io_virt & page_mask;
> > +	off += (size & (~page_mask));
> > +	size = ALIGN(size, 1UL << page_shift);
> > +
> > +	if (io_virt < ib_umem_start(&odp->umem))
> > +		return -EINVAL;
> > +
> >  	start_idx = (io_virt - (mr->mmkey.iova & page_mask)) >> page_shift;
> >  
> > +	if (odp_mr->per_mm == NULL || odp_mr->per_mm->mm == NULL)
> > +		return -ENOENT;
> > +
> > +	ret = hmm_range_register(&range, odp_mr->per_mm->mm,
> > +				 io_virt, io_virt + size, page_shift);
> > +	if (ret)
> > +		return ret;
> > +
> >  	if (prefetch && !downgrade && !mr->umem->writable) {
> >  		/* prefetch with write-access must
> >  		 * be supported by the MR
> Isn't there a mistake in the calculation of the variable size? Itis 
> first set to the size of the page fault range, but then you add the 
> virtual address, so I guess it is actually the range end. Then you pass 
> io_virt + size to hmm_range_register. Doesn't it double the size of the 
> range

No i think it is correct, bcnt is the byte count we are ask to fault,
we align that on the maximum size the current mr covers (min_t above)
then we align with the page size so that fault address is page align.
hmm_range_register() takes start address and end address which is the
start address + size.

off is the offset ie the number of extra byte we are faulting to align
start on page size. If there is a bug this might be:
     off += (size & (~page_mask));

I need to review before and after to double check that again.

> 
> > -void ib_umem_odp_unmap_dma_pages(struct ib_umem_odp *umem_odp, u64 virt,
> > -				 u64 bound)
> > +void ib_umem_odp_unmap_dma_pages(struct ib_umem_odp *umem_odp,
> > +				 u64 virt, u64 bound)
> >  {
> > +	struct device *device = umem_odp->umem.context->device->dma_device;
> >  	struct ib_umem *umem = &umem_odp->umem;
> > -	int idx;
> > -	u64 addr;
> > -	struct ib_device *dev = umem->context->device;
> > +	unsigned long idx, page_mask;
> > +	struct hmm_range range;
> > +	long ret;
> > +
> > +	if (!umem->npages)
> > +		return;
> > +
> > +	bound = ALIGN(bound, 1UL << umem->page_shift);
> > +	page_mask = ~(BIT(umem->page_shift) - 1);
> > +	virt &= page_mask;
> >  
> >  	virt  = max_t(u64, virt,  ib_umem_start(umem));
> >  	bound = min_t(u64, bound, ib_umem_end(umem));
> > -	/* Note that during the run of this function, the
> > -	 * notifiers_count of the MR is > 0, preventing any racing
> > -	 * faults from completion. We might be racing with other
> > -	 * invalidations, so we must make sure we free each page only
> > -	 * once. */
> > +
> > +	idx = ((unsigned long)virt - ib_umem_start(umem)) >> PAGE_SHIFT;
> > +
> > +	range.page_shift = umem->page_shift;
> > +	range.pfns = &umem_odp->pfns[idx];
> > +	range.pfn_shift = ODP_FLAGS_BITS;
> > +	range.values = odp_hmm_values;
> > +	range.flags = odp_hmm_flags;
> > +	range.start = virt;
> > +	range.end = bound;
> > +
> >  	mutex_lock(&umem_odp->umem_mutex);
> > -	for (addr = virt; addr < bound; addr += BIT(umem->page_shift)) {
> > -		idx = (addr - ib_umem_start(umem)) >> umem->page_shift;
> > -		if (umem_odp->page_list[idx]) {
> > -			struct page *page = umem_odp->page_list[idx];
> > -			dma_addr_t dma = umem_odp->dma_list[idx];
> > -			dma_addr_t dma_addr = dma & ODP_DMA_ADDR_MASK;
> > -
> > -			WARN_ON(!dma_addr);
> > -
> > -			ib_dma_unmap_page(dev, dma_addr, PAGE_SIZE,
> > -					  DMA_BIDIRECTIONAL);
> > -			if (dma & ODP_WRITE_ALLOWED_BIT) {
> > -				struct page *head_page = compound_head(page);
> > -				/*
> > -				 * set_page_dirty prefers being called with
> > -				 * the page lock. However, MMU notifiers are
> > -				 * called sometimes with and sometimes without
> > -				 * the lock. We rely on the umem_mutex instead
> > -				 * to prevent other mmu notifiers from
> > -				 * continuing and allowing the page mapping to
> > -				 * be removed.
> > -				 */
> > -				set_page_dirty(head_page);
> > -			}
> > -			/* on demand pinning support */
> > -			if (!umem->context->invalidate_range)
> > -				put_page(page);
> > -			umem_odp->page_list[idx] = NULL;
> > -			umem_odp->dma_list[idx] = 0;
> > -			umem->npages--;
> > -		}
> > -	}
> > +	ret = hmm_range_dma_unmap(&range, NULL, device,
> > +		&umem_odp->dma_list[idx], true);
> > +	if (ret > 0)
> > +		umem->npages -= ret;
> Can hmm_range_dma_unmap fail? If it does, we do we simply leak the DMA 
> mappings?

It can only fails if you provide bogus range structure (like end address
before start address). This is just a safety next really. It also returns
the number of page that have been unmap just like hmm_range_dma_map()
returns the number of page that have been map. So you can keep a count of
the number of pages map with umem->npages

Cheers,
Jérôme

