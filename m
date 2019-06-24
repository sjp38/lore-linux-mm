Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD70FC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:34:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 689092083D
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:34:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZUFFpEiZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 689092083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C4E36B0003; Mon, 24 Jun 2019 01:34:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1758E8E0002; Mon, 24 Jun 2019 01:34:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0642A8E0001; Mon, 24 Jun 2019 01:34:14 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA00C6B0003
	for <Linux-mm@kvack.org>; Mon, 24 Jun 2019 01:34:13 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id y13so20619521iol.6
        for <Linux-mm@kvack.org>; Sun, 23 Jun 2019 22:34:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=O2cgsn++49XRi6aE7UftxVDux3g2be02ob/0XO5leII=;
        b=QDRw1IWTEHhiSVBQmdqIgbwzUk3xzd9bkrpDumpeJD1ar8hNZv7kxINGqv+nWaY0lY
         q/huKgYSkJl9O09d8xwVHsixq2Qr/9RXCpqELxDGIyK01KZWaBqL2GERsoE4e3nOSiwb
         5SWvnitsWCzPrDSVgcZTUbRB/pkjvfDSEEJhK3XHLdHvRZJcsmRzXPzFzEzGyHre4c6M
         vUHsYBYKr+XzzHdHi2SGaZDu0FZqlhegGwSuB4lxu/QlerF3jVYg7AI3qL9HnZi8rHkf
         yOzOiebl8g4o1m8Wzdn5r7Xg+jROLWLZR9Jk5pCpet9E4YB+G4HmJ7Iob0+byjEhq6KI
         v42g==
X-Gm-Message-State: APjAAAXTN/986vjYuNmU+DAn+qDoBzDOZhVNBj8UI+SIimEhVZYwtUg/
	32B0RD7CC+IsteaKtq7nioScdsldLR9dx0v5s8s/C/R3lq4ZzfWNOKBfG79HeMpuBjlPyrAlq6D
	vSvRR96IjyIODNPsUZi92pbD7+0yKURMKGd+kGt8b4zSWu3shuH5eR14wbjgHpgmpCQ==
X-Received: by 2002:a6b:e203:: with SMTP id z3mr4059997ioc.23.1561354453642;
        Sun, 23 Jun 2019 22:34:13 -0700 (PDT)
X-Received: by 2002:a6b:e203:: with SMTP id z3mr4059967ioc.23.1561354453081;
        Sun, 23 Jun 2019 22:34:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561354453; cv=none;
        d=google.com; s=arc-20160816;
        b=MgtDItnGch/GSQ0uxHx9ZVF91bCCOm6CryKDU1xZ1+7Ko7PV8Lkb4T60vzTn7WTiL8
         Do7MasqEMzLwYnD1bjmBglIJyYuKn1f0TQYCtN5NH/EjIBWngrKMhrXsWdOD33VEVL9/
         5N5Mr32qXocIBAr/JzndlKbtiA+33dgm7w4lmx2gY1x6dnzDrB3mW5kVLO/q8vMXok5c
         Kvi3uhOCBfbq8UJMVdhzuowOSMAx0k1R7q3ZPfSdUty5qZjDAV76d40CvTDUa2htbGjO
         DxuTt/l3eNkM58D1h40IjBH0GGofZJSKaJPdA6bFUdPj08XHkiOIo73Cg81H4W4TRlw0
         tfyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=O2cgsn++49XRi6aE7UftxVDux3g2be02ob/0XO5leII=;
        b=d2WqmhfIJdtyYaExKlY5DtNU64KVxuYv4E3LOC/kGAen8++a/tOBwZjL9bznHhBpwX
         00XHwdRdIQBeRQH0Ps3p2DRly30dW0pRD8ZGTm4/dZ8Wwc217NhuhkX/GXgUN2zkusyM
         z1PeoI3QAmbvgCd0Xro9PWxQ45ZEUvsyEFxTrqb8e34A3akxjOcjqAnOZP88B73pky6r
         pr6C2K/6JWnFdKm0oOIWb855KRHxapCdCTuK2DOMU+feMld5QkffFxNAi/6dERMBnid9
         oX2eT3NPUEDa0kZwRr54dMseDBwtbFShieTjDeP6m0MMhhhXPv9AFRwBSamcJLwTJRR5
         x0sA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZUFFpEiZ;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15sor7229528iol.1.2019.06.23.22.34.13
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 22:34:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZUFFpEiZ;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=O2cgsn++49XRi6aE7UftxVDux3g2be02ob/0XO5leII=;
        b=ZUFFpEiZaiVkP2DAtpPpJdLBcrNKA9cH3iGexIP4qVSiH3s6Ph/+nWoAXjtSgV9qiW
         S/MqeWZ9lJiuxTnnse2zwppjjSxvd3MZ5gaEkBq0Tx7sdpZTHNvhXGyGkbivSn5EM3sV
         PmjzgK+pPR5F9iFCIgp57SC3UeZnajMu3j+oSl9qBRl/CRWKRfBHD1/X7yZzlo+xRHiS
         NQfxE8K9kmG+aXIWTyCV5fT596GsAP1qtw0aA8yQxmRpz62O3/dGBaIaPU2UkltRgLps
         9zHkuW3F1UTYS/SwcLCPFPZ0RyJSsAscHyqm7+EpI5MgrgH1QWjEaNtValTV8+BsywOp
         EO/Q==
X-Google-Smtp-Source: APXvYqynPgam6/QO7kIucj+Eumv9i5hEjlNV7F+IsO6RFskEeRxPzshmmWIaqYh3bloHYgPhntoq1CMNEHeCCrXrmCY=
X-Received: by 2002:a02:a384:: with SMTP id y4mr124692536jak.77.1561354452881;
 Sun, 23 Jun 2019 22:34:12 -0700 (PDT)
MIME-Version: 1.0
References: <1561349561-8302-1-git-send-email-kernelfans@gmail.com>
 <20190624044305.GA30102@iweiny-DESK2.sc.intel.com> <CAFgQCTuMVdrjkiQ5H3xUuME16g-xNUFXtvU1p+=P4-pujXcSAA@mail.gmail.com>
In-Reply-To: <CAFgQCTuMVdrjkiQ5H3xUuME16g-xNUFXtvU1p+=P4-pujXcSAA@mail.gmail.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 24 Jun 2019 13:34:01 +0800
Message-ID: <CAFgQCTshH=FsJbdf49wD=fgJzvbEqzEW--F3oon1aLc64r=u7w@mail.gmail.com>
Subject: Re: [PATCHv2] mm/gup: speed up check_and_migrate_cma_pages() on huge page
To: Ira Weiny <ira.weiny@intel.com>
Cc: Linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, 
	Mike Rapoport <rppt@linux.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Thomas Gleixner <tglx@linutronix.de>, John Hubbard <jhubbard@nvidia.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Christoph Hellwig <hch@lst.de>, 
	Keith Busch <keith.busch@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, 
	LKML <Linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 1:32 PM Pingfan Liu <kernelfans@gmail.com> wrote:
>
> On Mon, Jun 24, 2019 at 12:43 PM Ira Weiny <ira.weiny@intel.com> wrote:
> >
> > On Mon, Jun 24, 2019 at 12:12:41PM +0800, Pingfan Liu wrote:
> > > Both hugetlb and thp locate on the same migration type of pageblock, since
> > > they are allocated from a free_list[]. Based on this fact, it is enough to
> > > check on a single subpage to decide the migration type of the whole huge
> > > page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> > > similar on other archs.
> > >
> > > Furthermore, when executing isolate_huge_page(), it avoid taking global
> > > hugetlb_lock many times, and meanless remove/add to the local link list
> > > cma_page_list.
> > >
> > > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Ira Weiny <ira.weiny@intel.com>
> > > Cc: Mike Rapoport <rppt@linux.ibm.com>
> > > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > > Cc: Christoph Hellwig <hch@lst.de>
> > > Cc: Keith Busch <keith.busch@intel.com>
> > > Cc: Mike Kravetz <mike.kravetz@oracle.com>
> > > Cc: Linux-kernel@vger.kernel.org
> > > ---
> > >  mm/gup.c | 19 ++++++++++++-------
> > >  1 file changed, 12 insertions(+), 7 deletions(-)
> > >
> > > diff --git a/mm/gup.c b/mm/gup.c
> > > index ddde097..544f5de 100644
> > > --- a/mm/gup.c
> > > +++ b/mm/gup.c
> > > @@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
> > >       LIST_HEAD(cma_page_list);
> > >
> > >  check_again:
> > > -     for (i = 0; i < nr_pages; i++) {
> > > +     for (i = 0; i < nr_pages;) {
> > > +
> > > +             struct page *head = compound_head(pages[i]);
> > > +             long step = 1;
> > > +
> > > +             if (PageCompound(head))
> > > +                     step = compound_order(head) - (pages[i] - head);
> >
> > Sorry if I missed this last time.  compound_order() is not correct here.
> For thp, prep_transhuge_page()->prep_compound_page()->set_compound_order().
> For smaller hugetlb,
> prep_new_huge_page()->prep_compound_page()->set_compound_order().
> For gigantic page, prep_compound_gigantic_page()->set_compound_order().
>
> Do I miss anything?
>
Oh, got it. It should be 1<<compound_order(head)
> Thanks,
>   Pingfan
> [...]

