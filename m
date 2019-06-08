Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34B1FC2BCA1
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:15:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D511A208C0
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:15:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="bRrQYKB2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D511A208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C7AE6B026C; Fri,  7 Jun 2019 21:15:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 577286B026F; Fri,  7 Jun 2019 21:15:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4669A6B0276; Fri,  7 Jun 2019 21:15:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 221CC6B026C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 21:15:27 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 37so3414936qtc.7
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 18:15:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=h6Z9rr6zGxumR/45vmaME9IJ083vX8f0km+kn2uW+c8=;
        b=dYzcEVTBkiiJDCbRkght2VTIsG4Md/AGKsdOVtUanc7zjiHFR6mkAbc+p1E1EWL/Ox
         gGbliNyr3FbGjk3rP9cPFv8neRxYzb5i28MdXWVn0Y6nAK0G9lzql8Qjl+ubuMzamTKk
         FwknPdu3EGhey9j8vGzuuobpeK/Q0S8l7t0nloIMQdp1lZn6zQnMatTLZbd4XPDu+Noa
         BqTrKfHlj1hLchjdBHJUMtQUqS+WX3ZDamysGeX3CjUpBss4/NKQscX5+gv3ruMOB5MO
         fCMiJgsxmjY02ZaOUp1YVNvVNFCkFU1bEfn5/2RQYKpUHFw2STEvN7z/CnkFwCG+NjMP
         a0pw==
X-Gm-Message-State: APjAAAUBDRdM/SSgo7afdqTZCdpaUKz6a2N7C5B7xsiNLGpPALGepxOW
	vNolpDUjsBkSAG5FH8FYEkAp+sz2J/275gDN4vwHxEvd+LYlKBaIjSpoczw9MoqKgy/U7KRS1FC
	zsKrLUXL97tztz1QiXBopFjmO2P2dD5jJP6l0HvjfayqVXQmmaV3Jcguz5zsQQiqvFQ==
X-Received: by 2002:ac8:2209:: with SMTP id o9mr49236294qto.17.1559956526843;
        Fri, 07 Jun 2019 18:15:26 -0700 (PDT)
X-Received: by 2002:ac8:2209:: with SMTP id o9mr49236247qto.17.1559956526050;
        Fri, 07 Jun 2019 18:15:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559956526; cv=none;
        d=google.com; s=arc-20160816;
        b=ZBA6YfbNMcsNHwBlgCvkLI7nJrJOVaxgrFsHmH695a7DnRQP0m1b3i9+EMm4FcTK0e
         FMT70jC+ObEY84D5c6lePrN00I1SeKCO2ctm0XcwazQtYb2JG9z8AhFVy4vgfHADD2x+
         8qX7fqPVjB3IW7j3DKN1S3R5iX7hnyPghrIKUKpdt4LMLdsseeq+AlyIZRb70/9YHBp+
         lIGbuWPNw/H9BMbTPDniXGtnLutH36nUqD2wBaVWK47H/E6HYJdG+plSZKTTpAeMb+ZK
         1EiIoS6e9VaMj4bpBw/ACYGmkzDGyDhdWHumBansqgFdqhPDnttrNEgS9GnAMZXtIH6Q
         dPqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=h6Z9rr6zGxumR/45vmaME9IJ083vX8f0km+kn2uW+c8=;
        b=N0EXr7xovTUSCkdif1pXRjkG1T2KMfZ0fVHT54/uHqa04Wd/MiCcBX9GI5/gzOoGnm
         4CGHvy0+zZ4LZqXeVjrSuf950P6AB/eFuqy3SbRxLkXUH4biKsRqISlhdmQ9e/azbp2B
         AP8aVYUYz4qeiad46iyyMgQtoWVV1+Mn6xklBMZDLW1S8U6/yCJ9CQqhyDYNHkyheiiU
         UGl37Z0cxWjU3IZHs2/WZ+1UDXQFb6mo92sxbZY64Kue4TgeE9TS6TiBCWz4wkpXtGGE
         rh/CyYUMmcUoiz6Pnmo9EbETWhBDyzrmuoRzBd2YCOXFL4kY3FDdBa0RNPXBQCZVOv3P
         WEoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bRrQYKB2;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c19sor4572877qta.34.2019.06.07.18.15.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 18:15:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bRrQYKB2;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=h6Z9rr6zGxumR/45vmaME9IJ083vX8f0km+kn2uW+c8=;
        b=bRrQYKB2zE6/wWU/OjS2kqvu2AoxAnZ/cCuCgPmbOeWj+HhbWbKLaCaogL0rqmZe0R
         BtruNkxj/Zi/NgK7luDutuRW7H758gt9Eu6yTyut/4xnbnV7w3i473DBuvfoey1s+Ay5
         XmK6BJ9hHcTUZl8lDhdBJ2IGvsrZUQbNiv03egVplE5XTDlTBUMw8lj/AuEbwkeC1oeK
         YAnG/BpSduK8thlJPaUbYi8ZQC2H3u8Rg78tXDXasJ0Kh/NDiNEG3VMZKRfJqN2PpXZr
         jtsX+FFxZSKZrB8lKqNa9CPoPomNmQIdreS92pKoIQ9qgTGc0r+xReuWGWSNMTsCofLP
         CCQA==
X-Google-Smtp-Source: APXvYqxlijcObZVobH5DV858Z4pTZYEKltcFNld56zqPC5gVgwHJRZ7Ay2DmCcFxie8ytW1foI+w9w==
X-Received: by 2002:ac8:2d69:: with SMTP id o38mr35025897qta.169.1559956525671;
        Fri, 07 Jun 2019 18:15:25 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f34sm2160045qta.19.2019.06.07.18.15.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 18:15:25 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZPx6-00023t-KY; Fri, 07 Jun 2019 22:15:24 -0300
Date: Fri, 7 Jun 2019 22:15:24 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: linux-rdma@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 08/11] mm/hmm: Use lockdep instead of comments
Message-ID: <20190608011524.GA7844@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-9-jgg@ziepe.ca>
 <CAFqt6zakL282X2SMh7E9kHDLnT9nW5ifbN2p1OKTXY4gaU=qkA@mail.gmail.com>
 <20190607193955.GT14802@ziepe.ca>
 <CAFqt6zZbQmPq=v9xtgHfc5QCy4Vk8pjWgTOY0+TyFgHmEnWTsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zZbQmPq=v9xtgHfc5QCy4Vk8pjWgTOY0+TyFgHmEnWTsg@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 08, 2019 at 02:32:23AM +0530, Souptick Joarder wrote:
> On Sat, Jun 8, 2019 at 1:09 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Sat, Jun 08, 2019 at 01:03:48AM +0530, Souptick Joarder wrote:
> > > On Thu, May 23, 2019 at 9:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > >
> > > > From: Jason Gunthorpe <jgg@mellanox.com>
> > > >
> > > > So we can check locking at runtime.
> > > >
> > > > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> > > >  mm/hmm.c | 4 ++--
> > > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > >
> > > > diff --git a/mm/hmm.c b/mm/hmm.c
> > > > index 2695925c0c5927..46872306f922bb 100644
> > > > +++ b/mm/hmm.c
> > > > @@ -256,11 +256,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
> > > >   *
> > > >   * To start mirroring a process address space, the device driver must register
> > > >   * an HMM mirror struct.
> > > > - *
> > > > - * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
> > > >   */
> > > >  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
> > > >  {
> > > > +       lockdep_assert_held_exclusive(mm->mmap_sem);
> > > > +
> > >
> > > Gentle query, does the same required in hmm_mirror_unregister() ?
> >
> > No.. The unregistration path does its actual work in the srcu
> > callback, which is in a different context than this function. So any
> > locking held by the caller of unregister will not apply.
> >
> > The hmm_range_free SRCU callback obtains the write side of mmap_sem to
> > protect the same data that the write side above in register is
> > touching, mostly &mm->hmm.
> 
> Looking into https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/tree/?h=hmm,
> unable trace hmm_range_free(). Am I looking into correct tree ?

The cover letter for the v2 posting has a note about the git tree for
this series:

https://github.com/jgunthorpe/linux/tree/hmm

The above rdma.git is only for already applied patches on their way to
Linus. This series is still in review.

Thanks,
Jason

