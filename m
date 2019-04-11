Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 724FFC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:39:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B43A206BA
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:39:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B43A206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5F796B0010; Thu, 11 Apr 2019 10:39:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0DE06B0266; Thu, 11 Apr 2019 10:39:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFD416B0269; Thu, 11 Apr 2019 10:39:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA2C6B0010
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:39:33 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b1so5694898qtk.11
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:39:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=3oBVorYpbYaCOG8xuNrbAJ3SsIkrM7e1ltZ4cvCOLEQ=;
        b=fMetgo9mqI7bEq8pfZmXbyfUHyRXhu8E+tIP5QcwufF9SJnIIzlxZSYREOINZZD7mW
         xX/gsvks3yNURguVax6XNn6yTirKFugsCXK6SXqy2So2QzswihT/6XcjCikZCH3D6mqG
         gIuaiCDaG77bIj1gmNZDMjee3UkQ0Cfrp3dejj2IBX6al5r4ZSDNVtIpHoycd0TBN1S1
         qXxWaFdWokITY+3xo9JFpuBIb4gjgYVlKIYs3BsyT81eeLQYO4+glJ8oRBPYi6DE8aaT
         2FTBpfN3nNm8HNYjxpnvle3m6QEyJGF1st/im1rjyKQThslNNSXLBVn9xXYAtNnwWSv1
         RIHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVMK4e/7AuI3qHRTZibg19JbBpvy/H2rZ/KQbekjeScRBXypU42
	jhDLjbC3YmUbVkwekyHBf0QBJMG++n+KIGbwMxPhp+O2xgqU0IuTo5YI8HNQvLjJ4oYEtS6fTCx
	YDVRrUiN3XRHrRSqsut930oHCYN/HqoCIFdqhAcgFIedH8MnnnLXs7xx5lomYPjhb6g==
X-Received: by 2002:ac8:280d:: with SMTP id 13mr42830237qtq.188.1554993573307;
        Thu, 11 Apr 2019 07:39:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSFO8uzq3dZ55A2wZ0WRqRcL+53WMx3uhRsTnciVSd01uAA/WW/yyhfmpTxWPYcpOM6Arg
X-Received: by 2002:ac8:280d:: with SMTP id 13mr42830182qtq.188.1554993572480;
        Thu, 11 Apr 2019 07:39:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554993572; cv=none;
        d=google.com; s=arc-20160816;
        b=VFqNHAeTocV+zxHgwH/P+ob0uMxZ5RzO6VfCy734nI5NQu+2zKKUIrHYm9/8Pzslc+
         fx3HHoB2CLOubuExVQjtoCy0uSfmDDDeJCfcCYOR3GmqnKoPyArmyZL9uqsG/7BIgdR5
         fwza795ZwDAbDFiE16bR8RsMnVtly8VcfuVpgTVHfA4lN4S5OhpTtMAhH0AX70PujQVZ
         NqwwaOzLHoAyYoZoZfIjVyPRBFWS+ASkcOwXEQEouc5Y+Tz9aGAQDePs/RdHot20Y67R
         Zn0LyLs8/AU6+19S4bCKR93H73IaCWHPxzzG2j6kiIljHRPDA5IhP967OYnk28WFczn9
         tjww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=3oBVorYpbYaCOG8xuNrbAJ3SsIkrM7e1ltZ4cvCOLEQ=;
        b=gAKjWyYVusPFTsTUC7nupHACUU0y/6d59uK4erA144FboGOIVBj4pr/8LIXehKg+va
         bg+sftZDtMdnk/xhxKfBA9e6p3D2l33aovl0Tk/WWDR0/QxXJCMGNQfqnn7vOfhu1gGq
         v1HXoLxXGkWMrws/90M/STtABdckP+3xmJ7E6cvsv5pEIlYKYbHqLLVdP666jvY/Iq/o
         p0JnPUjKj9Qr8OW95W56UVV6UPtZG4cXgdsIMa4qeieyH4eoDa/bIlwslad9HIQk+uKI
         mIme6nlpnKhjU9/WzzDpQZBQ5IVa6behyex4XRT7ZwhAk7VEWMiHhZs+PLcLvCuwhQIT
         Aksw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j200si5758200qke.177.2019.04.11.07.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 07:39:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 773A3307B487;
	Thu, 11 Apr 2019 14:39:26 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CE2F65D9C8;
	Thu, 11 Apr 2019 14:39:20 +0000 (UTC)
Date: Thu, 11 Apr 2019 10:39:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v6 7/8] mm/mmu_notifier: pass down vma and reasons why
 mmu notifier is happening v2
Message-ID: <20190411143918.GA4266@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
 <20190326164747.24405-8-jglisse@redhat.com>
 <20190410234124.GE22989@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190410234124.GE22989@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 11 Apr 2019 14:39:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 04:41:57PM -0700, Ira Weiny wrote:
> On Tue, Mar 26, 2019 at 12:47:46PM -0400, Jerome Glisse wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > CPU page table update can happens for many reasons, not only as a result
> > of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> > as a result of kernel activities (memory compression, reclaim, migration,
> > ...).
> > 
> > Users of mmu notifier API track changes to the CPU page table and take
> > specific action for them. While current API only provide range of virtual
> > address affected by the change, not why the changes is happening
> > 
> > This patch is just passing down the new informations by adding it to the
> > mmu_notifier_range structure.
> > 
> > Changes since v1:
> >     - Initialize flags field from mmu_notifier_range_init() arguments
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: linux-mm@kvack.org
> > Cc: Christian König <christian.koenig@amd.com>
> > Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> > Cc: Jani Nikula <jani.nikula@linux.intel.com>
> > Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Peter Xu <peterx@redhat.com>
> > Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > Cc: Ross Zwisler <zwisler@kernel.org>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Paolo Bonzini <pbonzini@redhat.com>
> > Cc: Radim Krčmář <rkrcmar@redhat.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Christian Koenig <christian.koenig@amd.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: kvm@vger.kernel.org
> > Cc: dri-devel@lists.freedesktop.org
> > Cc: linux-rdma@vger.kernel.org
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  include/linux/mmu_notifier.h | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> > index 62f94cd85455..0379956fff23 100644
> > --- a/include/linux/mmu_notifier.h
> > +++ b/include/linux/mmu_notifier.h
> > @@ -58,10 +58,12 @@ struct mmu_notifier_mm {
> >  #define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
> >  
> >  struct mmu_notifier_range {
> > +	struct vm_area_struct *vma;
> >  	struct mm_struct *mm;
> >  	unsigned long start;
> >  	unsigned long end;
> >  	unsigned flags;
> > +	enum mmu_notifier_event event;
> >  };
> >  
> >  struct mmu_notifier_ops {
> > @@ -363,10 +365,12 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
> >  					   unsigned long start,
> >  					   unsigned long end)
> >  {
> > +	range->vma = vma;
> > +	range->event = event;
> >  	range->mm = mm;
> >  	range->start = start;
> >  	range->end = end;
> > -	range->flags = 0;
> > +	range->flags = flags;
> 
> Which of the "user patch sets" uses the new flags?
> 
> I'm not seeing that user yet.  In general I don't see anything wrong with the
> series and I like the idea of telling drivers why the invalidate has fired.
> 
> But is the flags a future feature?
> 

I believe the link were in the cover:

https://lkml.org/lkml/2019/1/23/833
https://lkml.org/lkml/2019/1/23/834
https://lkml.org/lkml/2019/1/23/832
https://lkml.org/lkml/2019/1/23/831

I have more coming for HMM but i am waiting after 5.2 once amdgpu
HMM patch are merge upstream as it will change what is passed down
to driver and it would conflict with non merged HMM driver (like
amdgpu today).

Cheers,
Jérôme

