Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87B18C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:49:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D8F420868
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:49:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D8F420868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B546C6B0003; Wed, 22 May 2019 17:49:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B056F6B0006; Wed, 22 May 2019 17:49:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F4326B0007; Wed, 22 May 2019 17:49:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB4F6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 17:49:38 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n5so3599804qkf.7
        for <linux-mm@kvack.org>; Wed, 22 May 2019 14:49:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=LRo4VGRsl7kicGk6iiUo7Xqj2A9IYpSwo4i215RcJnc=;
        b=MykRmtggohHZaK0ZJe0zsNSphvzDHB/JPOLUz9JzjnEO/z4c9Eh8dxgVTWhF7cjg88
         dXr93FggIN51puYlfNYMpNGgUyCfMLXViW3Af/cyKUtSgHVTskD1/EQauJ3Mi2fp8XM1
         SJq7kwdTdX0p9LQjiTcryC09EfBcpRmaIoCbl+ObGk+l+2ngm+y2poeVVuTWimdH1L4z
         vXdLDUCIpO6pocX/Sx3Nx3BYUUjvJCN1NAu4fV0XUmxPmkf5XghEmPk/NAPXI4zcfCgY
         TMS9yH36B7nX2FvCPe5AmGWRmknN5Kjz5ICUwdqUnu3HJv2YYD56go+afVRcDZAuMipV
         jh0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUuZZmfieFgQazyAvAA6Mjux828wIwGTxIsT7wNINt9L16QwISS
	x+oXW7iN36Q1hBlD1pkdqyuD4WJau7f6syZTaTIqjOiOxnK9ex4+AsXVA4PwksI95dcrZw01vVX
	xu0y7p6bcTS/bmxuBRpLlpIEflUyw26rSzBinDLRvL1R7V6hH9ySo4jfwY1zGPyxkzQ==
X-Received: by 2002:ac8:35fb:: with SMTP id l56mr76320572qtb.130.1558561778251;
        Wed, 22 May 2019 14:49:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDdnq0Ezx3+NyGwnWw+vl1QsEj8JQd6n1ce98sNIhPAC/FrQlkYNN/OMKhYPLsUDokwitq
X-Received: by 2002:ac8:35fb:: with SMTP id l56mr76320529qtb.130.1558561777511;
        Wed, 22 May 2019 14:49:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558561777; cv=none;
        d=google.com; s=arc-20160816;
        b=ftaRnDxIVKRpJyuVmHleOl67NX8rS7e8uYQokLF0b73z0MTO3QLpm3TblF0oUTfPQJ
         VB5J2eJdEhoU1WbzZOs1xc0f5Ldrx30f/o7tyZ5KijALIPxNGiZJottUb1dt/QhHSVaj
         fyFy8rSzTLA/YJKB+mQR40cOqHnejPK3PlD9tf4gVb5cUBOgLvDENN1lSrUpWg8QSIc9
         fpSqMKw7QXzWk8EaogNmvzSdZVmTQwwxO6so6fNJmWSK4iV99CXGRgaOLd1lps/9eCwE
         SNkIEqecO04xvYQwW+hk4bEot1oMCRJUBHfU83V3XaPdCBFEqD+7JkK/fxOzbb0opfrU
         h9kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=LRo4VGRsl7kicGk6iiUo7Xqj2A9IYpSwo4i215RcJnc=;
        b=S8G6q67pQVlReg7DPh+g0PNNnJDbwlkITuoYIC5wz2PXvUhp7IdO7iH7y5zZX90Ruq
         rtW/Bgw2ymNn7w61aBaqpCvRc8roWMFUZnd3uiWuGMd4dbEkqd26DXHe/B1DQMdIocQ2
         TbMHMpJLyXv7d4ntTfJImAl0W6M0wb5YLh0cqlIivUJ7hWYoE02SxFQuZyuAbhvC4I4S
         S1TOziktEHITFKnfyz2YhPf592771FUjrP/42utcLYTLhQJ/dk9X+VisQeHz1H5EJoRz
         kLNjsMkGeMkGSP6uU+C6q5PFtUIHFECo/BTxrmsKHBDgTGbsv9qm68q/uIY051e1FSqL
         ru1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j39si9024065qtb.388.2019.05.22.14.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 14:49:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E276837EEB;
	Wed, 22 May 2019 21:49:22 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CADDF52E7;
	Wed, 22 May 2019 21:49:19 +0000 (UTC)
Date: Wed, 22 May 2019 17:49:18 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
Message-ID: <20190522214917.GA20179@redhat.com>
References: <20190411181314.19465-1-jglisse@redhat.com>
 <20190506195657.GA30261@ziepe.ca>
 <20190521205321.GC3331@redhat.com>
 <20190522005225.GA30819@ziepe.ca>
 <20190522174852.GA23038@redhat.com>
 <20190522192219.GF6054@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190522192219.GF6054@ziepe.ca>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 22 May 2019 21:49:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 04:22:19PM -0300, Jason Gunthorpe wrote:
> On Wed, May 22, 2019 at 01:48:52PM -0400, Jerome Glisse wrote:
> 
> > > > +long ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp,
> > > > +			       struct hmm_range *range)
> > > >  {
> > > > +	struct device *device = umem_odp->umem.context->device->dma_device;
> > > > +	struct ib_ucontext_per_mm *per_mm = umem_odp->per_mm;
> > > >  	struct ib_umem *umem = &umem_odp->umem;
> > > > -	struct task_struct *owning_process  = NULL;
> > > > -	struct mm_struct *owning_mm = umem_odp->umem.owning_mm;
> > > > -	struct page       **local_page_list = NULL;
> > > > -	u64 page_mask, off;
> > > > -	int j, k, ret = 0, start_idx, npages = 0, page_shift;
> > > > -	unsigned int flags = 0;
> > > > -	phys_addr_t p = 0;
> > > > -
> > > > -	if (access_mask == 0)
> > > > +	struct mm_struct *mm = per_mm->mm;
> > > > +	unsigned long idx, npages;
> > > > +	long ret;
> > > > +
> > > > +	if (mm == NULL)
> > > > +		return -ENOENT;
> > > > +
> > > > +	/* Only drivers with invalidate support can use this function. */
> > > > +	if (!umem->context->invalidate_range)
> > > >  		return -EINVAL;
> > > >  
> > > > -	if (user_virt < ib_umem_start(umem) ||
> > > > -	    user_virt + bcnt > ib_umem_end(umem))
> > > > -		return -EFAULT;
> > > > +	/* Sanity checks. */
> > > > +	if (range->default_flags == 0)
> > > > +		return -EINVAL;
> > > >  
> > > > -	local_page_list = (struct page **)__get_free_page(GFP_KERNEL);
> > > > -	if (!local_page_list)
> > > > -		return -ENOMEM;
> > > > +	if (range->start < ib_umem_start(umem) ||
> > > > +	    range->end > ib_umem_end(umem))
> > > > +		return -EINVAL;
> > > >  
> > > > -	page_shift = umem->page_shift;
> > > > -	page_mask = ~(BIT(page_shift) - 1);
> > > > -	off = user_virt & (~page_mask);
> > > > -	user_virt = user_virt & page_mask;
> > > > -	bcnt += off; /* Charge for the first page offset as well. */
> > > > +	idx = (range->start - ib_umem_start(umem)) >> umem->page_shift;
> > > 
> > > Is this math OK? What is supposed to happen if the range->start is not
> > > page aligned to the internal page size?
> > 
> > range->start is align on 1 << page_shift boundary within pagefault_mr
> > thus the above math is ok. We can add a BUG_ON() and comments if you
> > want.
> 
> OK
> 
> > > > +	range->pfns = &umem_odp->pfns[idx];
> > > > +	range->pfn_shift = ODP_FLAGS_BITS;
> > > > +	range->values = odp_hmm_values;
> > > > +	range->flags = odp_hmm_flags;
> > > >  
> > > >  	/*
> > > > -	 * owning_process is allowed to be NULL, this means somehow the mm is
> > > > -	 * existing beyond the lifetime of the originating process.. Presumably
> > > > -	 * mmget_not_zero will fail in this case.
> > > > +	 * If mm is dying just bail out early without trying to take mmap_sem.
> > > > +	 * Note that this might race with mm destruction but that is fine the
> > > > +	 * is properly refcounted so are all HMM structure.
> > > >  	 */
> > > > -	owning_process = get_pid_task(umem_odp->per_mm->tgid, PIDTYPE_PID);
> > > > -	if (!owning_process || !mmget_not_zero(owning_mm)) {
> > > 
> > > But we are not in a HMM context here, and per_mm is not a HMM
> > > structure. 
> > > 
> > > So why is mm suddenly guarenteed valid? It was a bug report that
> > > triggered the race the mmget_not_zero is fixing, so I need a better
> > > explanation why it is now safe. From what I see the hmm_range_fault
> > > is doing stuff like find_vma without an active mmget??
> > 
> > So the mm struct can not go away as long as we hold a reference on
> > the hmm struct and we hold a reference on it through both hmm_mirror
> > and hmm_range struct. So struct mm can not go away and thus it is
> > safe to try to take its mmap_sem.
> 
> This was always true here, though, so long as the umem_odp exists the
> the mm has a grab on it. But a grab is not a get..
> 
> The point here was the old code needed an mmget() in order to do
> get_user_pages_remote()
> 
> If hmm does not need an external mmget() then fine, we delete this
> stuff and rely on hmm.
> 
> But I don't think that is true as we have:
> 
>           CPU 0                                           CPU1
>                                                        mmput()
>                        				        __mmput()
> 							 exit_mmap()
> down_read(&mm->mmap_sem);
> hmm_range_dma_map(range, device,..
>   ret = hmm_range_fault(range, block);
>      if (hmm->mm == NULL || hmm->dead)
> 							   mmu_notifier_release()
> 							     hmm->dead = true
>      vma = find_vma(hmm->mm, start);
>         .. rb traversal ..                                 while (vma) remove_vma()
> 
> *goes boom*
> 
> I think this is violating the basic constraint of the mm by acting on
> a mm's VMA's without holding a mmget() to prevent concurrent
> destruction.
> 
> In other words, mmput() destruction does not respect the mmap_sem - so
> holding the mmap sem alone is not enough locking.
> 
> The unlucked hmm->dead simply can't save this. Frankly every time I
> look a struct with 'dead' in it, I find races like this.
> 
> Thus we should put the mmget_notzero back in.

So for some reason i thought exit_mmap() was setting the mm_rb
to empty node and flushing vmacache so that find_vma() would
fail. Might have been in some patch that never went upstream.

Note that right before find_vma() there is also range->valid
check which will also intercept mm release.

Anyway the easy fix is to get ref on mm user in range_register.

> 
> I saw some other funky looking stuff in hmm as well..
> 
> > Hence it is safe to take mmap_sem and it is safe to call in hmm, if
> > mm have been kill it will return EFAULT and this will propagate to
> > RDMA.
>  
> > As per_mm i removed the per_mm->mm = NULL from release so that it is
> > always safe to use that field even in face of racing mm "killing".
> 
> Yes, that certainly wasn't good.
> 
> > > > -	 * An array of the pages included in the on-demand paging umem.
> > > > -	 * Indices of pages that are currently not mapped into the device will
> > > > -	 * contain NULL.
> > > > +	 * An array of the pages included in the on-demand paging umem. Indices
> > > > +	 * of pages that are currently not mapped into the device will contain
> > > > +	 * 0.
> > > >  	 */
> > > > -	struct page		**page_list;
> > > > +	uint64_t *pfns;
> > > 
> > > Are these actually pfns, or are they mangled with some shift? (what is range->pfn_shift?)
> > 
> > They are not pfns they have flags (hence range->pfn_shift) at the
> > bottoms i just do not have a better name for this.
> 
> I think you need to have a better name then

Suggestion ? i have no idea for a better name, it has pfn value
in it.

Cheers,
Jérôme

