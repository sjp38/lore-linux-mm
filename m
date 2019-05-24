Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9877C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:59:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A18D217F9
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:59:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="HrCziIIg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A18D217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0617D6B026B; Fri, 24 May 2019 12:59:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0121C6B026C; Fri, 24 May 2019 12:59:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E43086B026D; Fri, 24 May 2019 12:59:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDD9D6B026B
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:59:33 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id k25so2309982uaq.8
        for <linux-mm@kvack.org>; Fri, 24 May 2019 09:59:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=O9bMjKCyr7eNelVQt8Zjl1TFCNvm0TrsCVv9SV5F2LA=;
        b=Q/pINMR9VRaEc1bgCohDnCkzqTMTmrMQjaPiuqblw6v/fM62HGnUH+6Cz+gaaHmjsu
         7O+E9HURp9IdNxCubDqGWeTSy8X5w3brXYNufBNOc13fzj6B0v4ixSllBQf8DMrTXx6s
         3oVYpl1vB2NEsbt6jJA07tyjTdg2s8agi9rb6n/6jEDU9gf2AKZOI62fwQE086Ie1KxL
         VtJh4LhSSo6qGTXIJXTxNO70TUuMw1A/kk/kEnqnpowUXoAxuGlbnkwGce/X5heVAt4W
         Bj/Kio1IEXraLif1Nb5du1mdVDVuYmoPdyX9Xj7JDcH6vp5QiffvVYyqW9Mcg9FgzkTW
         qOQw==
X-Gm-Message-State: APjAAAUMdLQefzUM7iK7V+S8W2Yh4ilRS3QyDRPWUS8nVdL3XqKLresF
	EvD/gyPqxF7t4ndrU7huU5QCb2sYy9ULpdnA7QEKoeES/GyVMxg6o6Sq/HFO4rBildqREclu5Qb
	fnzGa+/y+KN1GPjGbSmpG8q4yLjMWzkAWCEVnT1hr423M1xJPuLOjRJFyu0WAKAdC6w==
X-Received: by 2002:a9f:366b:: with SMTP id s40mr3684635uad.121.1558717173467;
        Fri, 24 May 2019 09:59:33 -0700 (PDT)
X-Received: by 2002:a9f:366b:: with SMTP id s40mr3684540uad.121.1558717172726;
        Fri, 24 May 2019 09:59:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558717172; cv=none;
        d=google.com; s=arc-20160816;
        b=vMw2xDGPz6sfpVEw9sDxxkx0jo9Ck/w9JdfWXTEtLRW0TXjfab3skB8+7gt1ST7qdv
         HT7Yb861bil6VM0Q/qNEx4MOsUivLIq0mIXx6QZ5ZfYMh2h/rELHS6hMpnQ0igUgmxMm
         MvEK+S6MppCs+a+7q0QXd9l12I8/hQfVLnisbCocdGroaNXt4O9nnR6NbTFrq0MR/STy
         o2AtAYFwkHV0CYUWkOYYQkocmVKky7nhRihPG+b5NHfBAOlNwRVluWoSBVNHUOYYNA/a
         lKNanwM5yXsdh3CIzULFXp8yixnmhnyIeJHuK+IfeeWp8mYE73a2dhmEFaNqnm1RjFWQ
         mVbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=O9bMjKCyr7eNelVQt8Zjl1TFCNvm0TrsCVv9SV5F2LA=;
        b=nmYhxnoYUO61pSWS1/Jh24evlYOiAs/YYhbyH1SxtkYZCYclRgldq+L3BAru1ahDeD
         7A+rTnx+8ygSqeLESoz1fG6WMKYdclyktoeKQZ7wUWnx3aa/RMosGkfaaZfz4SW0+KYx
         1ybI4ZMMhHTWluWMl/WxrzmRQ62peYnmGoLh0mqTUzdv+BN/4yXaF7tIJ1ZPWrQbS2Fl
         jhLPiZvPWwq0r4EoiFME5fbVEp48H7QjknxQlI5YPK1DTnMr1e6JhlIbYkLirk9Oi5q5
         Dk9DDgamT2/0EfACVYXuXQlVoesDGZirO/VfbN1Q1lqYpeSL98HyLBUznWolcHLarMwg
         Fi+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=HrCziIIg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o1sor1508068ual.4.2019.05.24.09.59.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 09:59:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=HrCziIIg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=O9bMjKCyr7eNelVQt8Zjl1TFCNvm0TrsCVv9SV5F2LA=;
        b=HrCziIIgnkfF6lnXZ9I93PRqTjpRSMycNPK6S9UnR++m//3vRAc2gt5C6JjLlu7y91
         EChv41pTNRKeh3Lfe2OVbQw3LV/q1HRxCZ18sTGXDYQrAXNfPEuZYbDD+3wPqpNLJlMe
         zvwBDd4SfbF5JZClyBUra+5k2sbDB/c3Bs3MpNhnp25dqW3dqi2Ts8wyvsKX8w1bUcBn
         LlOkyGzBIz4QCHZf7hkoLlRp7hZ7flsPqVMqx8GZE3mvBzaUQnd0qJ2KDgk1J6LHLwhr
         thF4EEDyFxbeYWxe96Jr5GRyEUnhExvyJjfZXSUtoSj5thcJFZc1QFlT7anNaqWFByPj
         0qkA==
X-Google-Smtp-Source: APXvYqzCugFsX5gP7tzOEzB1injnMH4R7g32RSkMVvqSHiKmxtd7YAkP43CL3FRq24fYgKSISuo1ag==
X-Received: by 2002:ab0:688b:: with SMTP id t11mr16535128uar.70.1558717172439;
        Fri, 24 May 2019 09:59:32 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id n23sm1918465vsj.27.2019.05.24.09.59.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 09:59:31 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hUDXX-0008IP-GX; Fri, 24 May 2019 13:59:31 -0300
Date: Fri, 24 May 2019 13:59:31 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524165931.GF16845@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190524143649.GA14258@ziepe.ca>
 <20190524164902.GA3346@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524164902.GA3346@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 12:49:02PM -0400, Jerome Glisse wrote:
> On Fri, May 24, 2019 at 11:36:49AM -0300, Jason Gunthorpe wrote:
> > On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
> > > From: Jason Gunthorpe <jgg@mellanox.com>
> > > 
> > > This patch series arised out of discussions with Jerome when looking at the
> > > ODP changes, particularly informed by use after free races we have already
> > > found and fixed in the ODP code (thanks to syzkaller) working with mmu
> > > notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> > 
> > So the last big difference with ODP's flow is how 'range->valid'
> > works.
> > 
> > In ODP this was done using the rwsem umem->umem_rwsem which is
> > obtained for read in invalidate_start and released in invalidate_end.
> > 
> > Then any other threads that wish to only work on a umem which is not
> > undergoing invalidation will obtain the write side of the lock, and
> > within that lock's critical section the virtual address range is known
> > to not be invalidating.
> > 
> > I cannot understand how hmm gets to the same approach. It has
> > range->valid, but it is not locked by anything that I can see, so when
> > we test it in places like hmm_range_fault it seems useless..
> > 
> > Jerome, how does this work?
> > 
> > I have a feeling we should copy the approach from ODP and use an
> > actual lock here.
> 
> range->valid is use as bail early if invalidation is happening in
> hmm_range_fault() to avoid doing useless work. The synchronization
> is explained in the documentation:

That just says the hmm APIs handle locking. I asked how the apis
implement that locking internally.

Are you trying to say that if I do this, hmm will still work completely
correctly?

diff --git a/mm/hmm.c b/mm/hmm.c
index 8396a65710e304..42977744855d26 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -981,8 +981,8 @@ long hmm_range_snapshot(struct hmm_range *range)
 
 	do {
 		/* If range is no longer valid force retry. */
-		if (!range->valid)
-			return -EAGAIN;
+/*		if (!range->valid)
+			return -EAGAIN;*/
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
@@ -1080,10 +1080,10 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 
 	do {
 		/* If range is no longer valid force retry. */
-		if (!range->valid) {
+/*		if (!range->valid) {
 			up_read(&hmm->mm->mmap_sem);
 			return -EAGAIN;
-		}
+		}*/
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
@@ -1134,7 +1134,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 			start = hmm_vma_walk.last;
 
 			/* Keep trying while the range is valid. */
-		} while (ret == -EBUSY && range->valid);
+		} while (ret == -EBUSY /*&& range->valid*/);
 
 		if (ret) {
 			unsigned long i;

