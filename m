Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 739E6C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 01:21:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1234822CE5
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 01:21:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qi4Uh0to"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1234822CE5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F3386B0003; Sun, 23 Jun 2019 21:21:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A3758E0002; Sun, 23 Jun 2019 21:21:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36A138E0001; Sun, 23 Jun 2019 21:21:21 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 169826B0003
	for <Linux-mm@kvack.org>; Sun, 23 Jun 2019 21:21:21 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id y13so19987225iol.6
        for <Linux-mm@kvack.org>; Sun, 23 Jun 2019 18:21:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=b+MLzYEoEduR8Q+ofY+9DSCWoJU/Fb/z+zF7Y0bwVTI=;
        b=jIb+9J+pYsm2YR5LBJeM1YQQ+0/0uIKxKX3QbVuvU3ghL4++MbNb0cXl11YSmY0Pww
         f6O5XE55vXtoSLmT7UrPuKOrdikTxx/iLXuB+dKpfL5DCa869sxCP7xCrM/Z38X91+Ra
         VlTgU+h2mN9u/fl9L2OH1ZfeE/eM8oceWFPodopo4VbySHM6S92y7iixDHeHjCEdsu7/
         66ZY2uEZRBnSsZH5JT1kxeFiFEaSiU+aCfW8cDgZXHjG4BC9E9aOxF5RQBeji14DKu6n
         3SeAowLr3wEGeu/0JyfpVBzhihq4fnKY58v8YRoaKieiJ8y/N9zRn2q5NeUpUtoU1pop
         O0fw==
X-Gm-Message-State: APjAAAUFKEDaV+UCKp1P9uwDIs95S7aZS3dl/IjWk7dkycM+R2xompuX
	fmyX1gqaXHDW0InoRfSvkmhmsig3IJn2z2obMkHR++m3UK4KTL6/xzkl8tfGPlnNaWh2iYIIj2T
	32m1QUp0zpLQE/aLnmRDq6QELI4GaXhcHMvKETf/G4j3lqefx8I6gMA13uP0inIKJzQ==
X-Received: by 2002:a02:a384:: with SMTP id y4mr123812584jak.77.1561339280829;
        Sun, 23 Jun 2019 18:21:20 -0700 (PDT)
X-Received: by 2002:a02:a384:: with SMTP id y4mr123812538jak.77.1561339280098;
        Sun, 23 Jun 2019 18:21:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561339280; cv=none;
        d=google.com; s=arc-20160816;
        b=eHhoyyXExiPcDu8yzyI1XcRTo7LnNpYIEt4t6iNWbKJD/Nhc4LQuhpYaGVuvQLLIcd
         +uUxw1VAja4auHVLqVWee0dUnz4dI5AU5qeQAPOf+WQ1QCU9VKkLfl8/fR2wmrkbYhu+
         TLFTXvCOwiBNqSj7O3yZKiFQYYHo0f6FXbjAiEJEV9/pyj6tpa0AVmCRGNc1Ek8gTIll
         hkZvw68ychAZoZs7HaA92UFOOHzaNkOKjq3fRBUlOIQ9EbzHfjWRHuTwVJB3JjQr1Tme
         xv2OjjwazfgF4z+9q6fQ1NDHiA7VQiCZKbr8fsMLpfSW6clWhNDGJdmMU83X9xqGwQ4C
         TLvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=b+MLzYEoEduR8Q+ofY+9DSCWoJU/Fb/z+zF7Y0bwVTI=;
        b=nAdlK/VmPw84TuRJL8Btrso+m7jNH1bIdVNdYj1ovOPCyXVemnEF/XC9TO2lBDki/z
         x23+tjgKw81WlT/dvzR9BR5VOv02iY6OgSZe2g7NaI5eBktiPbPX5TKeZoHxDr3vBCff
         EvIXSzL8CYnYCcY7sXFY+oqd/l+apnu6YM9C+szBJR9UN4pBgxwNEXaUhE8ABZmZeUQq
         XqnPmPZifPCjJuAORJkyysmhiG7bh2tF7rleQGDzjDF5GQbeu5IBik09ZOzajP82uRdK
         KDPCnA/+WJn0aiVrwIvxmoFjw2AxTF9Xjidmh+DToik+24dNVeOxI/6ERB/W/FeDsNBa
         PGjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qi4Uh0to;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor6560543iog.65.2019.06.23.18.21.19
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 18:21:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qi4Uh0to;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=b+MLzYEoEduR8Q+ofY+9DSCWoJU/Fb/z+zF7Y0bwVTI=;
        b=Qi4Uh0togE92l73msdpzeDUQYoLAyZbb6tYJqdSYxXXbCbuKYbIrOFew4kw1bAfb6k
         2d1A6Hsd9u2fJFbrs5TT5PAgHVkgKCRCKhE+DNc8NO7z5Ri+niBjt845zb3lruTCh9id
         uXToEifUf1p2SVDBJovQyBWllp+Y8V2ZMXca6QVxXMWTYO3beoTBtFqqHi0NGApE/RHg
         bshvgR9AJsc+zf1NdfI1cIEL2879R+1CA17sPwjJw6ZS4Zz3AYLcD3UjlKzyt1fcsmH0
         nMH/bmFil0zmY8bvMreCMOQCD6WM26TKyaSR61R324NacVQS/+A63xWa5rqFJNsmU9R+
         tqww==
X-Google-Smtp-Source: APXvYqwlrTd7zZ+8C5LG65dPmV1E9CKsY7yiH4Q4qh+AomfR8v3cv/tfgFHaNCcDqrgpU1DtrOjGGbkR19Vqdm4kFkE=
X-Received: by 2002:a6b:5106:: with SMTP id f6mr8398579iob.15.1561339279746;
 Sun, 23 Jun 2019 18:21:19 -0700 (PDT)
MIME-Version: 1.0
References: <1561112116-23072-1-git-send-email-kernelfans@gmail.com> <20190621181349.GA21680@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190621181349.GA21680@iweiny-DESK2.sc.intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 24 Jun 2019 09:21:07 +0800
Message-ID: <CAFgQCTt2M3NVD5Xmip3YX=eYM_wJn9mWLjZq8z-jXuvT5q-naQ@mail.gmail.com>
Subject: Re: [PATCH] mm/gup: speed up check_and_migrate_cma_pages() on huge page
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

On Sat, Jun 22, 2019 at 2:13 AM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Fri, Jun 21, 2019 at 06:15:16PM +0800, Pingfan Liu wrote:
> > Both hugetlb and thp locate on the same migration type of pageblock, since
> > they are allocated from a free_list[]. Based on this fact, it is enough to
> > check on a single subpage to decide the migration type of the whole huge
> > page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> > similar on other archs.
> >
> > Furthermore, when executing isolate_huge_page(), it avoid taking global
> > hugetlb_lock many times, and meanless remove/add to the local link list
> > cma_page_list.
> >
> > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: Mike Rapoport <rppt@linux.ibm.com>
> > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: Keith Busch <keith.busch@intel.com>
> > Cc: Mike Kravetz <mike.kravetz@oracle.com>
> > Cc: Linux-kernel@vger.kernel.org
> > ---
> >  mm/gup.c | 13 +++++++++----
> >  1 file changed, 9 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/gup.c b/mm/gup.c
> > index ddde097..2eecb16 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -1342,16 +1342,19 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
> >       LIST_HEAD(cma_page_list);
> >
> >  check_again:
> > -     for (i = 0; i < nr_pages; i++) {
> > +     for (i = 0; i < nr_pages;) {
> > +
> > +             struct page *head = compound_head(pages[i]);
> > +             long step = 1;
> > +
> > +             if (PageCompound(head))
> > +                     step = compound_order(head) - (pages[i] - head);
> >               /*
> >                * If we get a page from the CMA zone, since we are going to
> >                * be pinning these entries, we might as well move them out
> >                * of the CMA zone if possible.
> >                */
> >               if (is_migrate_cma_page(pages[i])) {
>
> I like this but I think for consistency I would change this pages[i] to be
> head.  Even though it is not required.
Yes, agree. Thank you for your good suggestion.

Regards,
  Pingfan
>
> Ira
>
> > -
> > -                     struct page *head = compound_head(pages[i]);
> > -
> >                       if (PageHuge(head)) {
> >                               isolate_huge_page(head, &cma_page_list);
> >                       } else {
> > @@ -1369,6 +1372,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
> >                               }
> >                       }
> >               }
> > +
> > +             i += step;
> >       }
> >
> >       if (!list_empty(&cma_page_list)) {
> > --
> > 2.7.5
> >

