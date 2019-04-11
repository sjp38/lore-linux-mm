Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8AB1C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:50:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92E202184B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:50:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92E202184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32F5C6B026B; Thu, 11 Apr 2019 17:50:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DEEA6B026E; Thu, 11 Apr 2019 17:50:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A55B6B0271; Thu, 11 Apr 2019 17:50:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D45626B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:50:37 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e20so5058656pfn.8
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:50:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=VtQniyTaWjnyVv9AmcP6kZ9G1PeQJJ0NeZwu9AyPhjU=;
        b=nz6UXRpXXNxS5r6ew23ixbJMCwf2/GnR5TUsaSvUtNVtCk+1eR8sYNGKtIuCR2zPwM
         jyc2GRSvLUa3h8xjjfwh8f4m4T59VVqCy+j1fnayVPpyt7q4h8hkIIBkrgN48HyxBZ0s
         9Smh+PovEJM8a+q32x3OiQKzYXF+/WQlD7LnLCmZb1MIUcKmuP/zQ7ko04tu6g6r+Nvj
         X/3bISOYfo6WUvCFedP1k/wAb9v4m+BjfiS1AwblUhZDaTr8DADC7zF1/tNv1luX/TdO
         uvTLgiEwuh+ZDlWpRz1e8iFXe1JsTHNjm3hM7qI7n9DphghUiV1odlruW5y9jMQmfNuD
         zeMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXrAxxPp7VeL3mN2Xp08axYUW64HBh4mDY8y0TgueGnmfk3dfHd
	tLWCJ6xvb9AJPEMnH0PFOzzZok3tvhbJNu+Qv7At2/DE/PZd5fnnd7k551+ehkbJ1VGPr8iK+wp
	wjOx7LNYxmnfdGcdP5cm5UfErtvv/RkcQRMbOJvT3QAHInUSW+yX1UZ+fSCW0r022RA==
X-Received: by 2002:a65:4589:: with SMTP id o9mr32438147pgq.381.1555019437447;
        Thu, 11 Apr 2019 14:50:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxipsKQ/FsaDkmMEknN9IyVmbsFPu1MoAjjpDT7cmX3v9jCLR8utL03qnq+XT+ndyWcoP1f
X-Received: by 2002:a65:4589:: with SMTP id o9mr32438096pgq.381.1555019436605;
        Thu, 11 Apr 2019 14:50:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555019436; cv=none;
        d=google.com; s=arc-20160816;
        b=Fqtky3zKKUr4OizQSZVtMqUeYDswE9Y4IHLo4Mgk1rAvcJym4WDpTdjKNTKex84EpU
         KflU/YXDcSohb1/nBQ8u0O1AOyLq6UhA5cmj0Hv28tc4r9JFnlllWlMWko7jOe1L2Du+
         sjPnjRUv6grXdXPSBTDJM0+8nSuT8twaHIzxsSQgsaKICTg3jMrWk/CWNIQPamB3ydFh
         MYL+wPglVHCfv4n7Ol0WY8YwOpJ2ZzmXTtbCMeiXnE1Jui2cGdxlhSN0UOG8N+q9bpJb
         xOHrpjktFhaCW17mhLAqcYpcGXxNE2hV5MyQg36b8b3CDe1iCSYN/FfnuWIJXsvVxdg0
         dWOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=VtQniyTaWjnyVv9AmcP6kZ9G1PeQJJ0NeZwu9AyPhjU=;
        b=km6lnEaagrreu/Jh/rc9KKr1iVmkjCev6zB+AlkDkePKh7W6A/Kiif+DzJ8B7lwH6S
         FFdrOAW6XJlgw7yx8b4hWL4scHDQ1dq13R7epWmTk2dBQl7AUlsRglqVC3PSfufmw2wv
         4uouVw6SpYP/XNT8XfmXag+I/KHe21CU5r7VpzyCZQSRzxkT3OWkuwVAeDa4noLraMSo
         JZ22kr1t5HKSgRziedYUFabG+RzPkBUNK8IJ/feze4JU49/IZsPLJCCyiS00uY+bHswo
         k36WENjeAK0XH0hAmg5JsogNzh7Sj8qkHKUQrCWduGvkJ0fH3DhJtnrm+JVi3sBTCIti
         /7vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y13si26951868pgf.252.2019.04.11.14.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:50:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Apr 2019 14:50:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,338,1549958400"; 
   d="scan'208";a="335989192"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga006.fm.intel.com with ESMTP; 11 Apr 2019 14:50:35 -0700
Date: Thu, 11 Apr 2019 14:50:33 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Leon Romanovsky <leon@kernel.org>
Cc: jglisse@redhat.com, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
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
Message-ID: <20190411215033.GH22989@iweiny-DESK2.sc.intel.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
 <20190326164747.24405-8-jglisse@redhat.com>
 <20190410234124.GE22989@iweiny-DESK2.sc.intel.com>
 <20190411054130.GY3201@mtr-leonro.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411054130.GY3201@mtr-leonro.mtl.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 08:41:30AM +0300, Leon Romanovsky wrote:
> On Wed, Apr 10, 2019 at 04:41:57PM -0700, Ira Weiny wrote:
> > On Tue, Mar 26, 2019 at 12:47:46PM -0400, Jerome Glisse wrote:
> > > From: Jérôme Glisse <jglisse@redhat.com>
> > >

[snip]

> > > diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> > > index 62f94cd85455..0379956fff23 100644
> > > --- a/include/linux/mmu_notifier.h
> > > +++ b/include/linux/mmu_notifier.h
> > > @@ -58,10 +58,12 @@ struct mmu_notifier_mm {
> > >  #define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
> > >
> > >  struct mmu_notifier_range {
> > > +	struct vm_area_struct *vma;
> > >  	struct mm_struct *mm;
> > >  	unsigned long start;
> > >  	unsigned long end;
> > >  	unsigned flags;
> > > +	enum mmu_notifier_event event;
> > >  };
> > >
> > >  struct mmu_notifier_ops {
> > > @@ -363,10 +365,12 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
> > >  					   unsigned long start,
> > >  					   unsigned long end)
> > >  {
> > > +	range->vma = vma;
> > > +	range->event = event;
> > >  	range->mm = mm;
> > >  	range->start = start;
> > >  	range->end = end;
> > > -	range->flags = 0;
> > > +	range->flags = flags;
> >
> > Which of the "user patch sets" uses the new flags?
> >
> > I'm not seeing that user yet.  In general I don't see anything wrong with the
> > series and I like the idea of telling drivers why the invalidate has fired.
> >
> > But is the flags a future feature?
> 
> It seems that it is used in HMM ODP patch.
> https://patchwork.kernel.org/patch/10894281/

AFAICT the flags in that patch are "hmm_range->flags"  not
"mmu_notifier_range->flags"

They are not the same.

Ira

> 
> Thanks
> 
> >
> > For the series:
> >
> > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> >
> > Ira
> >
> > >  }
> > >
> > >  #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
> > > --
> > > 2.20.1
> > >


