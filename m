Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88F1EC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:41:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 318EE2082C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:41:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="c/H5ji3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 318EE2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABA566B0003; Wed, 12 Jun 2019 07:41:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6A936B0005; Wed, 12 Jun 2019 07:41:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95A4E6B0006; Wed, 12 Jun 2019 07:41:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74AD56B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:41:28 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u129so13470791qkd.12
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:41:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lSxjAlC+uZbBWLnsce9oyecap+o1G1ClcqcyZBLt6wI=;
        b=AUjz4hPz28wHnJjocg8GLQGc+N3kn3tIsTv/K5/bDgJ4eUzXM7EHDohRl+C8L2CVhP
         SsfIAe9ZWw8iLzVI+2H1DQAXwEL+b8/DlC5OLELN5XEEn+1o/X75ELMMGbswzLCYIMmC
         WlZXdr32AsXU3wWQZUxdASy9ZOgBZWiJ1bdkIilYpHjAnV/Hvhj1eizfmqw6R1sp+dKp
         GWMbdGcCz4xhexhQqcFAak/C0Ih/m+i/n2aWU2jM6qvl6V+dg74FHakK+YmHAZ3B/uDG
         rc07v0VCOUJeIdmGPe/6bEuvEj+OaIQUDSP0DzMUgVdG0/WFAYhutfbfzNtOjR3yStWB
         VWDA==
X-Gm-Message-State: APjAAAXH10OXd2MxIPX77AJSxSjBD27JufwV+p3+ULrpuBTYHtSF7epL
	JZcQKZC2apm6a1pt5NKIp93Bn2ZO4f3Ly0xQx31q4P+k8NQE3kGSIjbWPXVcyDOTby429+N1Pf7
	eKuqoGr8tyMdmqCKILJYsbVFn7ZTU14+uZaVNQkt4excDsiCsv+1pi6ikbVzT3rokUQ==
X-Received: by 2002:aed:2a43:: with SMTP id k3mr70650499qtf.301.1560339688219;
        Wed, 12 Jun 2019 04:41:28 -0700 (PDT)
X-Received: by 2002:aed:2a43:: with SMTP id k3mr70650448qtf.301.1560339687635;
        Wed, 12 Jun 2019 04:41:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339687; cv=none;
        d=google.com; s=arc-20160816;
        b=kH4xIdjGrpwUUbdQ0LCUXNQVdnA/pNCsDsTRwLNxMBYeVFtGadMGW+6g+dJ9TDSFck
         zqndWr1Z/pIHUnIXSkx1VsoYJzAgMUy8KaRCCOPXvQxvgCdYgQv4YTQR3p2w0uOStmMx
         j87TLIkTyIqhvgyNmimR4x2tzZ+Gy2WZtp8ZFfndLPMpVATxHWe7xkvE3AbYpOXYGUlS
         8G8Nj+RXPE4ue8KmUknfGZ648g+wORWz4oVVonqUaJPPfI92PHNDtUT0sGgzjEGQT/Zz
         20DwmAzO1n8ShqECyVTUBygiPCAGPDPpmvJOB44hzNUBuAokUK+vaROQeq8V7q5O6hZ8
         D1TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lSxjAlC+uZbBWLnsce9oyecap+o1G1ClcqcyZBLt6wI=;
        b=JYn3x8sCrsLJXo9HslC1qerpaP2UldV3TVkZbnsMmr92Za1bUNPBs0wTo0coK/JA3b
         Fzbtf9av7dsvjp7lWlxP+cBmL/5EqZN1TAXV+e4tomwlWaa2JpmQLUWRcR2CHErzu056
         2X1B7R9VDDx7hUfoPgf8fbZ+rsprxnIjJO0cEn135Uc/K9INgIlozv3xtBfjI3bwGx42
         1UGlcCOBmbGE4ygdxpbxQa8Hyaxe7oa4Fj0AK4sydlaKW3ed6xnGAWUyoJm+qJ9V9BGY
         ehxDfykYs59I/cntxqeN9DNM1EwYzgSub3lnsf0Jsdbn2TwsTS6dBKAiPF38mK6ikozZ
         +BAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="c/H5ji3n";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j34sor21776042qte.42.2019.06.12.04.41.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:41:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="c/H5ji3n";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lSxjAlC+uZbBWLnsce9oyecap+o1G1ClcqcyZBLt6wI=;
        b=c/H5ji3nSCh+gOvUZDZ+S49kTWjjHMkqM5K2HXt6kiI18mXJOv9nYMDgzX8sXa8uuc
         IcCdYbXGtrpY3GhKtGwh+RIXGC+PFMakdA+wusR+N3jiLNgrx4wjM95NSf+r/FPBRTNN
         yd4RlBPaK5CMMzhC7YE89oQF4gmN6FRcGMETb6SbdNYDGHpJjmCsIvQszvUQHLGeEEcf
         QKiBZ/BRdaKFgmw9CAqhzwIQ6vijVznk6tB3bDaJa089FcAOedvmz990jdY7jBdkCUSa
         1Pra7M2WAjRYPtoJQ+g7F+1qbiV5Kg4vguRuA6sY7Djm4wQOECC02VyEL2dpeO3v2WOZ
         am+Q==
X-Google-Smtp-Source: APXvYqyV/onR2nJG+SUqo2rImG4GNtftgkItRoz2K7ZKcS8ciTodUxxiDupnb/jFspB22/5anKiaMA==
X-Received: by 2002:ac8:2b01:: with SMTP id 1mr63205463qtu.177.1560339686428;
        Wed, 12 Jun 2019 04:41:26 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s66sm7743817qkh.17.2019.06.12.04.41.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Jun 2019 04:41:25 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hb1d7-0002GY-4q; Wed, 12 Jun 2019 08:41:25 -0300
Date: Wed, 12 Jun 2019 08:41:25 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 02/11] mm/hmm: Use hmm_mirror not mm as an
 argument for hmm_range_register
Message-ID: <20190612114125.GA3876@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-3-jgg@ziepe.ca>
 <20190608085425.GB32185@infradead.org>
 <20190611194431.GC29375@ziepe.ca>
 <20190612071234.GA20306@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612071234.GA20306@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 12:12:34AM -0700, Christoph Hellwig wrote:
> On Tue, Jun 11, 2019 at 04:44:31PM -0300, Jason Gunthorpe wrote:
> > On Sat, Jun 08, 2019 at 01:54:25AM -0700, Christoph Hellwig wrote:
> > > FYI, I very much disagree with the direction this is moving.
> > > 
> > > struct hmm_mirror literally is a trivial duplication of the
> > > mmu_notifiers.  All these drivers should just use the mmu_notifiers
> > > directly for the mirroring part instead of building a thing wrapper
> > > that adds nothing but helping to manage the lifetime of struct hmm,
> > > which shouldn't exist to start with.
> > 
> > Christoph: What do you think about this sketch below?
> > 
> > It would replace the hmm_range/mirror/etc with a different way to
> > build the same locking scheme using some optional helpers linked to
> > the mmu notifier?
> > 
> > (just a sketch, still needs a lot more thinking)
> 
> I like the idea.  A few nitpicks: Can we avoid having to store the
> mm in struct mmu_notifier? I think we could just easily pass it as a
> parameter to the helpers.

Yes, but I think any driver that needs to use this API will have to
hold the 'struct mm_struct' and the 'struct mmu_notifier' together (ie
ODP does this in ib_ucontext_per_mm), so if we put it in the notifier
then it is trivially available everwhere it is needed, and the
mmu_notifier code takes care of the lifetime for the driver.

> The write lock case of mm_invlock_start_write_and_lock is probably
> worth factoring into separate helper? I can see cases where drivers
> want to just use it directly if they need to force getting the lock
> without the chance of a long wait.

The entire purpose of the invlock is to avoid getting the write lock
on mmap_sem as a fast path - if the driver wishes to use mmap_sem
locking only then it should just do so directly and forget about the
invlock.

Note that this patch is just an API sketch, I haven't fully checked
that the range_start/end are actually always called under mmap_sem,
and I already found that release is not. So there will need to be some
preperatory adjustments before we can use down_write(mmap_sem) as a
locking strategy here.

Thanks,
Jason

