Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6350EC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:57:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22DB1207E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QNjqqGcb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22DB1207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B92316B026E; Fri,  7 Jun 2019 16:57:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1D086B026F; Fri,  7 Jun 2019 16:57:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BC4D6B0270; Fri,  7 Jun 2019 16:57:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 319B46B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:57:22 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id v188so744517lfa.20
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:57:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Tny04mc/baghyNAFbwqZ/oFPlAWsvuYVsFUjkQqS22Q=;
        b=OCtnaYbrCgV+SqiWxkLfFXe7kvpBVAG+YfBE4Pk41ZP7cE5ldFlBIcLQA72SYif/lR
         famLFZR/HLP9kQNyWbaKQEsuP4y2DH9Z9Cmguc8nm2YH+t1krjElEHLodGLuW1jbmDE2
         yvomqinkRFP9HaAoVY8oQgO9+PZtEyV94wp+FyR3qoZvUyaqbhRX06vVa73wdjqYoFyn
         d+4T0TFqxfQp/C1SdfM6VztRZ6Bo/rfxCK06ztAsIVSF2wdIXTjkNTbawCXTHxGJx7mF
         Ghjy5D6k8kxxokQ3isYA444UmsRtzT/GucYr8dC6a/WsOUbJKySJeorF1u7OlP4MeHry
         f6lw==
X-Gm-Message-State: APjAAAVON1BWH/Vp/Cr090Y35tE/8hsLs2AxhyabQlCk5wjzy2HpCxCi
	2grJIcnAT9aNvMMe5mhmp82hNN+kbvHHnEiv/WGSDU2mvfK7w7EM5FA0/o/FI1eMRWp07xsBsJF
	ga1T55dcIT6C+8Xprh1Yiem7av+MgYGG3HKHazscWezXT58J588EWKSXLBmC+J0PAYw==
X-Received: by 2002:ac2:5b0c:: with SMTP id v12mr13924405lfn.184.1559941041414;
        Fri, 07 Jun 2019 13:57:21 -0700 (PDT)
X-Received: by 2002:ac2:5b0c:: with SMTP id v12mr13924363lfn.184.1559941040209;
        Fri, 07 Jun 2019 13:57:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559941040; cv=none;
        d=google.com; s=arc-20160816;
        b=ZI0KRJn9ALQa5noY3QC3MnNDFarK1+tQaTuoOsKW1kfO7r2RFQt/pZ4qGqUOxKzluS
         EHIWZJudygKfKW3gMyI8oIrR+8Zpxz4khOjk7tqmTpDFvisB3KwJCalTtm8Rk0B79Ie7
         /fJBZ+4yDpo3j5GxWIIKvMTq62fjCVXVZg6LILle1GdRpC4+/99mGlb7UgBgKqTmqHJr
         xhz4ZLidf1m98gl6ebxZtxFjUcsqpU66I6zPJxW5fZGaT12IBE1PidLRAhlEfeeq8Vix
         OliZcAA5E8DQyAcv4aLBvZLf4leYw4UVRlEIgFx9CtwxkrTvZzfeVP7lF8wbDAktO0Df
         IBSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Tny04mc/baghyNAFbwqZ/oFPlAWsvuYVsFUjkQqS22Q=;
        b=zkGCCBz7taUcyZp1wuXG9lM0GdDNwF5hBz84Gdd7Y0IKmyd9Fv5AngsP1AGKuhkfRU
         7NTzuF8piKPBPh6nllFrpUGXqUCO7Rn7oCPU5+GoZaG/77bovWlSe2B4xM0YtGhLq1ZB
         BnIkFeiL6JFy0TYMNDPgC7yl5K1Pgvt0gSZ77OS0302MMmZPSd0RnJETTRhVfe83Hdlt
         +bSD4maAsme+6UKrZ1S7gilgRsr8ZJNkv4sp+QG48zv1os2CtDhQWZ92ddB9EUaPzKUC
         zME+wV0BqQSpG/gBhmZJtd5DIVHesKFPboIu8hzccUsu96a9oGgvSl6j8sbtn8ihqKcQ
         OiVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QNjqqGcb;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t20sor214947lfl.17.2019.06.07.13.57.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 13:57:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QNjqqGcb;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Tny04mc/baghyNAFbwqZ/oFPlAWsvuYVsFUjkQqS22Q=;
        b=QNjqqGcbdGS6ZZ8Py7DrJaDT7cFcTNRm3NFiWdMD9IiJe7FR81nCaS4ldYhjYQaa3x
         pDZ5dtaQh4VtXRU/M4vMtz6V86TMfvWqfIOv3+xQ1BS3Pi/OO8O34PrdybxezwGLFnCA
         796+BWV1HccLI+fGw5gqheajIrNxGca1f6Uv38w0SnJb21LsBYtuvkgZh+7P53Wem6Jj
         v1LkfYLNkunt2AZr9uAea0s8kIG7tfsuyXHc6LOsqr0UjKu/sKW1okPNjSls4KDZ0RxL
         AyfSU2pULwfpv2onwyxRS9I+M50aNUxdHUI7kSVEx7UEAZ1INmBowgvS78Dnkqo8S+cx
         zMQw==
X-Google-Smtp-Source: APXvYqxZe1mVzQxPGczygMJ7Uvjoz9hw+fjkiPEv98As/XW3kebMuog/DbkAruQO2q5Tc4hMSjsxYVTQBupk3BZEUnY=
X-Received: by 2002:ac2:4ac5:: with SMTP id m5mr4395351lfp.95.1559941039830;
 Fri, 07 Jun 2019 13:57:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190523153436.19102-1-jgg@ziepe.ca> <20190523153436.19102-9-jgg@ziepe.ca>
 <CAFqt6zakL282X2SMh7E9kHDLnT9nW5ifbN2p1OKTXY4gaU=qkA@mail.gmail.com> <20190607193955.GT14802@ziepe.ca>
In-Reply-To: <20190607193955.GT14802@ziepe.ca>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Jun 2019 02:32:23 +0530
Message-ID: <CAFqt6zZbQmPq=v9xtgHfc5QCy4Vk8pjWgTOY0+TyFgHmEnWTsg@mail.gmail.com>
Subject: Re: [RFC PATCH 08/11] mm/hmm: Use lockdep instead of comments
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 8, 2019 at 1:09 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Sat, Jun 08, 2019 at 01:03:48AM +0530, Souptick Joarder wrote:
> > On Thu, May 23, 2019 at 9:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > >
> > > From: Jason Gunthorpe <jgg@mellanox.com>
> > >
> > > So we can check locking at runtime.
> > >
> > > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> > >  mm/hmm.c | 4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/mm/hmm.c b/mm/hmm.c
> > > index 2695925c0c5927..46872306f922bb 100644
> > > +++ b/mm/hmm.c
> > > @@ -256,11 +256,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
> > >   *
> > >   * To start mirroring a process address space, the device driver must register
> > >   * an HMM mirror struct.
> > > - *
> > > - * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
> > >   */
> > >  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
> > >  {
> > > +       lockdep_assert_held_exclusive(mm->mmap_sem);
> > > +
> >
> > Gentle query, does the same required in hmm_mirror_unregister() ?
>
> No.. The unregistration path does its actual work in the srcu
> callback, which is in a different context than this function. So any
> locking held by the caller of unregister will not apply.
>
> The hmm_range_free SRCU callback obtains the write side of mmap_sem to
> protect the same data that the write side above in register is
> touching, mostly &mm->hmm.

Looking into https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/tree/?h=hmm,
unable trace hmm_range_free(). Am I looking into correct tree ?

