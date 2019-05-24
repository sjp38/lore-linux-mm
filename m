Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC91EC282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:02:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A087321850
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:02:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A087321850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47E1D6B026E; Fri, 24 May 2019 13:02:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42EEA6B026F; Fri, 24 May 2019 13:02:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31D726B0270; Fri, 24 May 2019 13:02:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14A336B026E
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:02:00 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id w6so10834742qki.5
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:02:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HBSOx6I4JG0PGTiLTAC0swj4BnTCNfDJ4n7Ol2c5J3I=;
        b=ki19lZ7MiJ2JM1VuyAnSLME/W03aPo0rKHO6nAE6h982nSRaXMEW/xnTbZW8Ro5NTJ
         PdF3MODrA4v4tdPmBS2liGHcSlyUyPoAGIh7xoOu2ikLgzEfByF9LOMpmNZVf7SzumiK
         VLBq87OO9lWBq1YYpymDEM1OHFKG5x6TqRdyF4uhToucCReApTWUD0gRfxHiKTfTsZVT
         AQTPp8PtZPNmf4knw+X+l5ZPM4VS23sbouZ2S5176j/ye+QJFZBtpUeL0xllO6zNdVYQ
         BNGN8AtSIOc0ZHUz5uzdrQTncKhcIk9xKx70MZ9Mw0FpN4o3ogSjSKx3JHOlqhiNkunF
         qQWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVWPFxEqmQQSqU7vp3hpybFgrapOuNj3l9jEwQB6dZDe0Ii2hEo
	n1fYqklWM0oQHUbfHCvxTV61FT2zlsjEpucjamAofJyO1Zz+NctYxZxGWo8RyfIrBlyLlS3+QaE
	RxkgC+DyoZs4ul40aNDZMI6eGkI74oihWG7uRFAlPXPeVyW8AfB0xY13Ar21aJBBACA==
X-Received: by 2002:a0c:932f:: with SMTP id d44mr75671550qvd.187.1558717317670;
        Fri, 24 May 2019 10:01:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHveZ158QTq/yETX7oU859BrDn6WlxHPxcYxS48uXs0sVHFXikJBkJdOB09rUO5b+EU6Jp
X-Received: by 2002:a0c:932f:: with SMTP id d44mr75671218qvd.187.1558717314106;
        Fri, 24 May 2019 10:01:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558717314; cv=none;
        d=google.com; s=arc-20160816;
        b=PCXzWkVweNbk5/J99qH4zy+fFV1XO7M0LqnnsBKrAwp16clTfIC8VjPAq+inDWETdN
         t97q9z47C9fw8apDctDecvKSFDC78xvJY/yqxZNTGZdNeRutx7TiHN24rw2vxSXDXD0a
         VG8p1cBYrtd9RsU6ncwavOlPxxDfA4wOtNBg8g4RPKfUOAJgdgoYRcbLw0Kr1MjYkrk5
         lJsyKnMTqN+zaNW8/eY+jKezig/AnpFKBRgsKiRJ8FDnaP5oY1ibt3JYxHsu4MlcAIZG
         lxW3RiI/NO6g+tArGw0msCaoodGrcb5kAEbt78BEa4A+aftAeQhEuTo3182Yq2jventm
         5Fuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HBSOx6I4JG0PGTiLTAC0swj4BnTCNfDJ4n7Ol2c5J3I=;
        b=rcabtZHhaAY/nW1/3MytybR6uq3N4T7Yv0E/XBupuHml9acxC2pNQTG5CZyEWDuTt9
         HhupZ+U3BRqmtPt0rLHwqouWsfQK/RIyj5auo5tB773pL/8ev6KiY3FvT+M/V1XaQzX7
         TmuHVqCP7KSUSISJ5kTC6T5mn4IjPIHp6CEQTSon1xkFGP2prquXNOCYR4RcN5jlNv0x
         huR74mNa81GgZiktc3nmWFQZaEWbhUxpnWdNvPX39MyaOm8s+6CGcO4YNHU2H+rYUPjw
         HsqgMcyMT8tMiamNQ8vokpa8sFVj9pFA0Jxyeu0l9mpTRTssTZ70AAJgLGztkvhd7Q4E
         yUBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d3si908115vsk.175.2019.05.24.10.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 10:01:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 47BC286663;
	Fri, 24 May 2019 17:01:53 +0000 (UTC)
Received: from redhat.com (ovpn-120-223.rdu2.redhat.com [10.10.120.223])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4F71152F3;
	Fri, 24 May 2019 17:01:52 +0000 (UTC)
Date: Fri, 24 May 2019 13:01:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524170148.GB3346@redhat.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190524143649.GA14258@ziepe.ca>
 <20190524164902.GA3346@redhat.com>
 <20190524165931.GF16845@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524165931.GF16845@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 24 May 2019 17:01:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 01:59:31PM -0300, Jason Gunthorpe wrote:
> On Fri, May 24, 2019 at 12:49:02PM -0400, Jerome Glisse wrote:
> > On Fri, May 24, 2019 at 11:36:49AM -0300, Jason Gunthorpe wrote:
> > > On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
> > > > From: Jason Gunthorpe <jgg@mellanox.com>
> > > > 
> > > > This patch series arised out of discussions with Jerome when looking at the
> > > > ODP changes, particularly informed by use after free races we have already
> > > > found and fixed in the ODP code (thanks to syzkaller) working with mmu
> > > > notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> > > 
> > > So the last big difference with ODP's flow is how 'range->valid'
> > > works.
> > > 
> > > In ODP this was done using the rwsem umem->umem_rwsem which is
> > > obtained for read in invalidate_start and released in invalidate_end.
> > > 
> > > Then any other threads that wish to only work on a umem which is not
> > > undergoing invalidation will obtain the write side of the lock, and
> > > within that lock's critical section the virtual address range is known
> > > to not be invalidating.
> > > 
> > > I cannot understand how hmm gets to the same approach. It has
> > > range->valid, but it is not locked by anything that I can see, so when
> > > we test it in places like hmm_range_fault it seems useless..
> > > 
> > > Jerome, how does this work?
> > > 
> > > I have a feeling we should copy the approach from ODP and use an
> > > actual lock here.
> > 
> > range->valid is use as bail early if invalidation is happening in
> > hmm_range_fault() to avoid doing useless work. The synchronization
> > is explained in the documentation:
> 
> That just says the hmm APIs handle locking. I asked how the apis
> implement that locking internally.
> 
> Are you trying to say that if I do this, hmm will still work completely
> correctly?

Yes it will keep working correctly. You would just be doing potentialy
useless work.

> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 8396a65710e304..42977744855d26 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -981,8 +981,8 @@ long hmm_range_snapshot(struct hmm_range *range)
>  
>  	do {
>  		/* If range is no longer valid force retry. */
> -		if (!range->valid)
> -			return -EAGAIN;
> +/*		if (!range->valid)
> +			return -EAGAIN;*/
>  
>  		vma = find_vma(hmm->mm, start);
>  		if (vma == NULL || (vma->vm_flags & device_vma))
> @@ -1080,10 +1080,10 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>  
>  	do {
>  		/* If range is no longer valid force retry. */
> -		if (!range->valid) {
> +/*		if (!range->valid) {
>  			up_read(&hmm->mm->mmap_sem);
>  			return -EAGAIN;
> -		}
> +		}*/
>  
>  		vma = find_vma(hmm->mm, start);
>  		if (vma == NULL || (vma->vm_flags & device_vma))
> @@ -1134,7 +1134,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>  			start = hmm_vma_walk.last;
>  
>  			/* Keep trying while the range is valid. */
> -		} while (ret == -EBUSY && range->valid);
> +		} while (ret == -EBUSY /*&& range->valid*/);
>  
>  		if (ret) {
>  			unsigned long i;

