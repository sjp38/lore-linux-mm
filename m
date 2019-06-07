Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 780AEC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:39:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F6EE20868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:39:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="SAtTDMFw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F6EE20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C906D6B000E; Fri,  7 Jun 2019 15:39:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1A496B0266; Fri,  7 Jun 2019 15:39:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B07A26B0269; Fri,  7 Jun 2019 15:39:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0926B000E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:39:57 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e39so2756114qte.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:39:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=v5PuEzRCYukWCZO7VXmHdZiC17djxNHawIgWZJ3C3rI=;
        b=o15M/1cQVVVO9gd3iyPoREfjdWHjWwzPqaQhQaZX4mOB8sB0F4sqvHSw7sRFvZO5WI
         MPHLLkDDlgDSZuvnQlHihOeNZdbUY5Q8lB+uD7dJA9RG13vml/hW1tO5jCSO1+lFMSof
         bn9vKbjfLpMBmYs4Anod8Pmodce+Q9ocHn9kNtTx4wOL6LnMYmp9ssQXqxC+1+TOE//n
         CrjztHVvl9y7vQ+eFUM/5BWuWLD8nsbCZCpv4vMWki6QXKSqojY4zyuMNqATukC7gQMk
         zXJUWZjKhnZpJ9RlSDbaBmsO96DVn2cWciWyjRxwLw09yhDCy6wqKmedoBVdJohG+nmq
         WOzQ==
X-Gm-Message-State: APjAAAWyNZKA/jABTN4ergY8XEK/a4klG+MM85Fkgq1TLX0d55nuBmtm
	fks0hSo629UJVx3UQGpMJeSJbkwkqq/bl8ltztyQQS1jc22Tr0sqv9QocyyjTK1DC5R+BI3B4zM
	2akZE1rkoIhvP9alotWnqYX5n7JIoGYJHk1CAgmkLG3p4PG5WwrZZ4z/+rhplihp61w==
X-Received: by 2002:a37:7f02:: with SMTP id a2mr46025220qkd.124.1559936397361;
        Fri, 07 Jun 2019 12:39:57 -0700 (PDT)
X-Received: by 2002:a37:7f02:: with SMTP id a2mr46025197qkd.124.1559936396855;
        Fri, 07 Jun 2019 12:39:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559936396; cv=none;
        d=google.com; s=arc-20160816;
        b=WDjvIubxLvHBaJhjaywS5/GoiJAPOZWxY4n+g7tns4sTCAululD/klydR8mkhzWH5k
         OXhj0DZfBEj1HsG291++txOAMZN/B707xhlE5b1I50JvFKVGtH4TJPdaGgUjp7CNBD9A
         +9mqr23TBu+nKHplt8r1oOvFmiZOztQxQtXOBuptuDiwVXhENz6pt4+tn68FHokKSp8n
         gMHzHN2XNJ3bT24wpoOnv6CKA+vjzC7Pc4kmUbIcL08jXl6mKg56SrkvkXzeZ4jwdatI
         UmXm1yYR6fRQbwD9KBuOvK8n9tsBfp5ecpOZ1KPH64K6rLNuBCTGh20ADQWg7CmHM0eb
         S3YQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v5PuEzRCYukWCZO7VXmHdZiC17djxNHawIgWZJ3C3rI=;
        b=lLyGiY/YRp+cp1zOztBb2dr6YGHtOVN0IJ8OSQ4cS9HQrwE+eZvDn9OduNNOpunDMX
         hB5IfQU6MPnd0eaBxih00Ai8hMF9iIKN4la9gFakDEcJHkmqIKjA5VIRrgDelXqCMGlo
         hOYriuZj+OODEkomYRMJsQ4vp8FiQnzIyDcbni+zDCDth3jSYdlcY1sfgm8tVBaC3OT6
         aftDr1oxQp+A49hEzBU1OEoEYmljWohxW4KWi6ZSirfJfeVv80HvR6y/nAP5pKboCjyb
         D2WsfpZmH4bZ/5f6PdUyv82a9Z71OskNJbpQduMHOrIlg44ZfV/dLDmbHlIxeOeHP9Xb
         9uVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=SAtTDMFw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor1674381qka.102.2019.06.07.12.39.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 12:39:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=SAtTDMFw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=v5PuEzRCYukWCZO7VXmHdZiC17djxNHawIgWZJ3C3rI=;
        b=SAtTDMFwUmHIu49ip5MvvV585/FJuArUH6e+7qtqGRge4Po4xGdF9mVWCB0X/LfcDZ
         S8k2EUayAT/XyINgUH3TIe/wXyoHbb9DFckpgvIyY/0/q3Ii0Co5gDrul9aKC4OKk20W
         aHokMp9l9jU2YuHq9oePc3nIazjf1Zzt/8VIYFXOd+z+D8CBo2rWiHRA+Z3w2pAHQgxi
         coNiAQZJYT5BweEOPNk1ChYd4KC/kMJQSqMc53F6JyrSUVaBkqVmwfuh6vyWs++p37xR
         IXPalW63NH2kpn4cw3UD+fCEyK3p1JBU8J3vmnxDsZ2ZdorBeINpEQ7o7qHIwYNDmk1h
         AbrQ==
X-Google-Smtp-Source: APXvYqxGWrYqN4UNN4o5aR4HOkmObWEddG1b3Np+uajVbZa2p3YdBOe1UPksd0tTWtPwZyGUbFZPeg==
X-Received: by 2002:a37:a110:: with SMTP id k16mr25061800qke.97.1559936396611;
        Fri, 07 Jun 2019 12:39:56 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id g5sm1140002qta.77.2019.06.07.12.39.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 12:39:56 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZKiR-0005LL-KT; Fri, 07 Jun 2019 16:39:55 -0300
Date: Fri, 7 Jun 2019 16:39:55 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: linux-rdma@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 08/11] mm/hmm: Use lockdep instead of comments
Message-ID: <20190607193955.GT14802@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-9-jgg@ziepe.ca>
 <CAFqt6zakL282X2SMh7E9kHDLnT9nW5ifbN2p1OKTXY4gaU=qkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zakL282X2SMh7E9kHDLnT9nW5ifbN2p1OKTXY4gaU=qkA@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 08, 2019 at 01:03:48AM +0530, Souptick Joarder wrote:
> On Thu, May 23, 2019 at 9:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > From: Jason Gunthorpe <jgg@mellanox.com>
> >
> > So we can check locking at runtime.
> >
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> >  mm/hmm.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 2695925c0c5927..46872306f922bb 100644
> > +++ b/mm/hmm.c
> > @@ -256,11 +256,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
> >   *
> >   * To start mirroring a process address space, the device driver must register
> >   * an HMM mirror struct.
> > - *
> > - * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
> >   */
> >  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
> >  {
> > +       lockdep_assert_held_exclusive(mm->mmap_sem);
> > +
> 
> Gentle query, does the same required in hmm_mirror_unregister() ?

No.. The unregistration path does its actual work in the srcu
callback, which is in a different context than this function. So any
locking held by the caller of unregister will not apply.

The hmm_range_free SRCU callback obtains the write side of mmap_sem to
protect the same data that the write side above in register is
touching, mostly &mm->hmm.

Jason

