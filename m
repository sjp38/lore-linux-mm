Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84F22C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:54:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45DB3206BB
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:54:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="MmNiLITB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45DB3206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD7DA6B0285; Thu,  6 Jun 2019 15:54:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D888A6B0286; Thu,  6 Jun 2019 15:54:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C77436B0287; Thu,  6 Jun 2019 15:54:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7B786B0285
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 15:54:06 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s9so3034575qtn.14
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 12:54:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SSrc7aXqKW0QuJBVKpfuDTODYfdscXoCHgxlwk6+Gs8=;
        b=ZAhNI0viFnmI07uVrm7WkEJUFhl9BBSZUQfdmkhnIVbKCgW9ZX8I0QfFiH9XCNU9qv
         sP+YwgOVcrdQOHkYNc1npuSUebRwL6MzW0LimHNTMwxce7jNLWgYVqMcMTlNQUfzQXuN
         vTRadOOHsFTt4YudpeUQSNmj4k1eX44E27pz7oiBVseUKm9B7rNOh9LycDkcb+7W90C/
         R5LDB/UcLb+CUHh5FdngzWWygBoZzXnJtGq9CERvM8N8Fp084ovMW/GtE4UuvW9uWs9G
         la5ggqEu4Ffml5aL3qnbtgyRa248YOgmzNpUybEkYkRsa5p9ZoZ/J4sI1a6jWerF4Ga7
         zSzw==
X-Gm-Message-State: APjAAAUmTVjevLuLLCejMVlghlaMmkKzBBYCQOI4S8/OWGwZSM0+GiAX
	eS4JXIrnwhIBuFVD8sQN56fBcyRnkhfGDF6rNnYN92V/y/pSN5l/eBgIsWQkTW3qgxtqwD4WfBm
	UR4xgDJR3HSZJNZOVXmFr26P8TGhMkQHJFOZ7uJXvIV5B6vl2BNesqAyOHSX747UTMA==
X-Received: by 2002:a37:9207:: with SMTP id u7mr41614348qkd.357.1559850846456;
        Thu, 06 Jun 2019 12:54:06 -0700 (PDT)
X-Received: by 2002:a37:9207:: with SMTP id u7mr41614299qkd.357.1559850845742;
        Thu, 06 Jun 2019 12:54:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559850845; cv=none;
        d=google.com; s=arc-20160816;
        b=y7CEgCIzx8gdKbAiAwinNfGpkH81AL9VBxdxLKu7Jea3x+RYVsgdYnasGC14tyTIrw
         4cRnPy0WgQzZzi/nl1QRW1vUCVdv52jbWx2rGcitLlbHuAsA+by3uguTmNvwCMrz+U6T
         T+Tb075qWRlBFlzu8zyLJ+7eQQM8LFWXVDqmOSt7RR/1LFGuXNH/azkHSFEfNdpp1jir
         XNAVwc6g4ndMxxiKbIO464HNem+U8wGrNPAwPo6Nvi2sUmdk2zgl4SQRqaPG2TN/lUKh
         n8AglqA2pci0QGAV/y5lQtc4+t3piDmpq7SfGjEF+FNcCl/UVAY4s3GMBtddreIqaXU7
         GYXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=SSrc7aXqKW0QuJBVKpfuDTODYfdscXoCHgxlwk6+Gs8=;
        b=jl5spWk+Amp0AU5aOvYj7E5/zFP09+KrTBS92cfsTh84likyCFqh8cd1JHvzbFomm8
         rmduiDdczl930mI+pRDoXkRWpqa7qyUkdp5DdXapTR6GMS8dlWEjlvr1KqOWyoO6+LrD
         HTGXoAeRzIvLKnQeIoEFDi6bTNVdltV6LSvXqdHtBDvHzFcUhdC27Iuqu9dns7wi9K7W
         4WW1OgNom+lWdLqa9Wcd4NesDFBRlpSXtI8Na6QphI6gtR/mS94LKGW11bql5C6PkmIF
         +K2ayJhdT1VfyjvMRCuSJAAYns/QzUhYnBJmzb3Rv9/PtQGXw8uEAUikZs5ZGjJ48MQa
         l+8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=MmNiLITB;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a24sor1550925qkl.129.2019.06.06.12.54.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 12:54:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=MmNiLITB;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=SSrc7aXqKW0QuJBVKpfuDTODYfdscXoCHgxlwk6+Gs8=;
        b=MmNiLITBmV/0RW1V5YR48nwqAGaNFYMwCPw1DQe438JAseKB+llCAlVsguYT7Ggt/q
         0CX4JruFxznxbxnMVXJyUo4g1XcS7xrSEZpfqPBYLCuWTlBlLKt4yVO3ZDnbKj9xixVN
         Y8MKdEPi2ZGinfyw4jHBFTK5a1SWCJ/j5L8sf3tFdJRTJgUsuX90zYINQXtTv1vKaFu5
         YC2yd3qx1u1xZiwC7O3pk+Dw/7KCkmd/rNjOHme9usOljEUlxy5QNfH/yp4q9aG8Vtr/
         z9gHlIV3U2bxfYh+nbBiAFG4NtoBUSfk5r7mAG1vjLv+mOHyaKqe0qUvZmULGerz3uGl
         aQgA==
X-Google-Smtp-Source: APXvYqwsoCS9r5bDKHGpMtuAyxDpKYq6SgA5/VRty3UuLftef6QXg2MNcHvcoacSdpNSzw7K2lDFVg==
X-Received: by 2002:a37:4d41:: with SMTP id a62mr37131848qkb.99.1559850845473;
        Thu, 06 Jun 2019 12:54:05 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id t29sm1077174qtt.42.2019.06.06.12.54.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 12:54:05 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYySa-00082x-K1; Thu, 06 Jun 2019 16:54:04 -0300
Date: Thu, 6 Jun 2019 16:54:04 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>,
	Philip Yang <Philip.Yang@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] mm/hmm: hmm_vma_fault() doesn't always call
 hmm_range_unregister()
Message-ID: <20190606195404.GJ17373@ziepe.ca>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-5-rcampbell@nvidia.com>
 <20190606145018.GA3658@ziepe.ca>
 <45c7f8ae-36b2-60cc-7d1d-d13ddd402d4b@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <45c7f8ae-36b2-60cc-7d1d-d13ddd402d4b@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 12:44:36PM -0700, Ralph Campbell wrote:
> 
> On 6/6/19 7:50 AM, Jason Gunthorpe wrote:
> > On Mon, May 06, 2019 at 04:29:41PM -0700, rcampbell@nvidia.com wrote:
> > > From: Ralph Campbell <rcampbell@nvidia.com>
> > > 
> > > The helper function hmm_vma_fault() calls hmm_range_register() but is
> > > missing a call to hmm_range_unregister() in one of the error paths.
> > > This leads to a reference count leak and ultimately a memory leak on
> > > struct hmm.
> > > 
> > > Always call hmm_range_unregister() if hmm_range_register() succeeded.
> > > 
> > > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > Cc: Ira Weiny <ira.weiny@intel.com>
> > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > Cc: Arnd Bergmann <arnd@arndb.de>
> > > Cc: Balbir Singh <bsingharora@gmail.com>
> > > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > > Cc: Matthew Wilcox <willy@infradead.org>
> > > Cc: Souptick Joarder <jrdr.linux@gmail.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > >   include/linux/hmm.h | 3 ++-
> > >   1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > > index 35a429621e1e..fa0671d67269 100644
> > > +++ b/include/linux/hmm.h
> > > @@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> > >   		return (int)ret;
> > >   	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> > > +		hmm_range_unregister(range);
> > >   		/*
> > >   		 * The mmap_sem was taken by driver we release it here and
> > >   		 * returns -EAGAIN which correspond to mmap_sem have been
> > > @@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> > >   	ret = hmm_range_fault(range, block);
> > >   	if (ret <= 0) {
> > > +		hmm_range_unregister(range);
> > 
> > While this seems to be a clear improvement, it seems there is still a
> > bug in nouveau_svm.c around here as I see it calls hmm_vma_fault() but
> > never calls hmm_range_unregister() for its on stack range - and
> > hmm_vma_fault() still returns with the range registered.
> > 
> > As hmm_vma_fault() is only used by nouveau and is marked as
> > deprecated, I think we need to fix nouveau, either by dropping
> > hmm_range_fault(), or by adding the missing unregister to nouveau in
> > this patch.
> 
> I will send a patch for nouveau to use hmm_range_register() and
> hmm_range_fault() and do some testing with OpenCL.

wow, thanks, I'd like to also really like to send such a thing through
hmm.git - do you know who the nouveau maintainers are so we can
collaborate on patch planning this?

> I can also send a separate patch to then remove hmm_vma_fault()
> but I guess that should be after AMD's changes.

Let us wait to hear back from AMD how they can consume hmm.git - I'd
very much like to get everything done in one kernel cycle!

Regards,
Jason

