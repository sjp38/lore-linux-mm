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
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD05C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:55:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E91F2083D
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:55:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EFwgZ0LN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E91F2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18D518E0007; Mon, 24 Jun 2019 01:55:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 117B68E0001; Mon, 24 Jun 2019 01:55:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F21658E0007; Mon, 24 Jun 2019 01:55:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFCED8E0001
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:55:17 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id y13so20677540iol.6
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:55:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MB7jsoCN6B+KNrRXEg/uVPgC1Ut8P/kMidprTlNMk78=;
        b=Noisgo7aIvXZXmummDNHdceIAKnvw64OB396wfCXgGn4DoO4DE0GMeyMo1F2beK/IP
         ewpZmshG5HoOHeR0ohJ5k4F+jYkYfq6TwmRXnjaOoeC4N7PCJHNcIqVLrP5r3xNWOqQS
         zKJAmaKVxQjvwEZE9DuPq/2KnnszUuQX5O4TZdppKY1cwncjUindrAEta0KcIcwE6Gd7
         m3KA/FRQ08gqqs1nyNz38Ze8AnKi5WRcFiWckt5sZaMMfxEaMJr9uD+YYz7HztuWwggQ
         rJKnsmSSoocy0zZH9TIjjhgL2P52b4vO4pwTad39x+ESuKO9IHhUNX5W5DKt6leu5xjK
         rLlw==
X-Gm-Message-State: APjAAAVPM2D79z7nNIhPxKyFSBRZbdTSgD47sn8mntopXP1VoNwowdqs
	q4c1vFHDT/5ASrsgrq/l9iCSK80QWIFIg+Y9eKDiTsE81uYawX/2WUJZ70LD7BOlg/uIs+YCrHp
	h41jt8FuZwxX3+GsSlXMWV+jFpMxUrlcmDzRm2Yf3lxYwYn1iksURYHUF5AKHzRWXVQ==
X-Received: by 2002:a6b:90c1:: with SMTP id s184mr79932776iod.244.1561355717631;
        Sun, 23 Jun 2019 22:55:17 -0700 (PDT)
X-Received: by 2002:a6b:90c1:: with SMTP id s184mr79932755iod.244.1561355717107;
        Sun, 23 Jun 2019 22:55:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355717; cv=none;
        d=google.com; s=arc-20160816;
        b=TeckwxKJeYk34PfFD/ZIqaAlP1PJ/ReOz6lBNg5YkUrhcj4TXDCgBTJ9wCu7NM9b/S
         7UkdgX67o426R2fa5jQSiA3wbShOxRBK7RHq6i2S/pDFs72AGF9Vh81h0YARSvqjb9UL
         R+6RhstFvudDvPRgua3HViGvS6xPqBtTibDDWkzDi6ZIgpfQwqDBqwy28ZjWjV1c0VAL
         d1i7cE2v3pktiXATZw79o8g2MuTppqaA998QcY8C0XMrqbyZinnKgWWEXO7Z3vkVwWrT
         zwQ5JudRU1Umst6idPP73pgb5vjHDVBSPG/ge4737uoGtmVEMirE5hn+Xr9ypCj7DSDq
         n+tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MB7jsoCN6B+KNrRXEg/uVPgC1Ut8P/kMidprTlNMk78=;
        b=Nx/+3CiD664npJ2pqcg6i9C4vcOpZIWoDINdN1puDAk9WfxmoARJqTP5tmYzFLMe4i
         eHQPJoVa7ls1Ecnu9IeDHl2pCquRISTUNwxxEMzTmt/5e8nk5N7y7eqL4xAdJE8ivhxO
         cGSSHfCb73jnRGVA/s7V3NW+4R/DpaCuAojl8GgUlslBguXkZDCcmXhL22O06SUBsDkL
         z6cBk/ijN2lprP+J7dKqlVOW5nYGlkKheEywAQhuc9+kg3S2WE2rLi6wHF1MVvk1E6Vf
         pLI9k1F6OPBkL4dInufrh30QZaL4B08/LFhHz7OjCuiAupm/Qe2qraMv2aEL91KHUnqF
         Ypvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EFwgZ0LN;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n1sor6790136ioo.127.2019.06.23.22.55.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 22:55:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EFwgZ0LN;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MB7jsoCN6B+KNrRXEg/uVPgC1Ut8P/kMidprTlNMk78=;
        b=EFwgZ0LNDntIB9LWehZbyrQruz2I2i5yx0XRhfFyt0IEUziPO1LjP8mBVrYgS/Vu9Z
         3gjIK3n7h57pkpzdrk/dSCXz/EwObWtY84KungPUtK9bM3yr4VYX7AzzbHshdmr1bBu3
         crFI7ZCBdRyXZDpjL+o8byiTblqaKFQiPr0OZB3JWH2Gf2DY//slHAWwsnhExYEsq6DV
         8BMytD3TEDXnBtdmlJ6a7AmCemcYqs2zR6a2/X7WKCBcm+a7kloxAnXeyp3E3m9JxtHT
         qTAUwN2PtzmkVwoxt9w3HW2FoDhdzjz5muPo79LXyfx2AK8pUkarOV6nXKrr2zNVcF8k
         otCg==
X-Google-Smtp-Source: APXvYqz21l53EP4/uEWFM2tah2RK5JkPnEImBUKlK56iy9SewaPdxqyxD6QTuB+hGojVTvragBolmaTARvs5BepDyhI=
X-Received: by 2002:a6b:4107:: with SMTP id n7mr7518421ioa.12.1561355716706;
 Sun, 23 Jun 2019 22:55:16 -0700 (PDT)
MIME-Version: 1.0
References: <1561350068-8966-1-git-send-email-kernelfans@gmail.com> <20190624050341.GB30102@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190624050341.GB30102@iweiny-DESK2.sc.intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 24 Jun 2019 13:55:05 +0800
Message-ID: <CAFgQCTvT4HZn6ZOAxUzUOwqv--R4CLTkOC_V=y22Fy1m1thrRA@mail.gmail.com>
Subject: Re: [PATCH] mm/hugetlb: allow gigantic page allocation to migrate
 away smaller huge page
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, 
	Oscar Salvador <osalvador@suse.de>, David Hildenbrand <david@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 1:03 PM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Mon, Jun 24, 2019 at 12:21:08PM +0800, Pingfan Liu wrote:
> > The current pfn_range_valid_gigantic() rejects the pud huge page allocation
> > if there is a pmd huge page inside the candidate range.
> >
> > But pud huge resource is more rare, which should align on 1GB on x86. It is
> > worth to allow migrating away pmd huge page to make room for a pud huge
> > page.
> >
> > The same logic is applied to pgd and pud huge pages.
>
> I'm sorry but I don't quite understand why we should do this.  Is this a bug or
> an optimization?  It sounds like an optimization.
Yes, an optimization. It can help us to success to allocate a 1GB
hugetlb if there is some 2MB hugetlb sit in the candidate range.
Allocation 1GB hugetlb requires more tough condition, not only a
continuous 1GB range, but also aligned on GB. While allocating a 2MB
range is easier.
>
> >
> > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > Cc: Mike Kravetz <mike.kravetz@oracle.com>
> > Cc: Oscar Salvador <osalvador@suse.de>
> > Cc: David Hildenbrand <david@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: linux-kernel@vger.kernel.org
> > ---
> >  mm/hugetlb.c | 8 +++++---
> >  1 file changed, 5 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index ac843d3..02d1978 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1081,7 +1081,11 @@ static bool pfn_range_valid_gigantic(struct zone *z,
> >                       unsigned long start_pfn, unsigned long nr_pages)
> >  {
> >       unsigned long i, end_pfn = start_pfn + nr_pages;
> > -     struct page *page;
> > +     struct page *page = pfn_to_page(start_pfn);
> > +
> > +     if (PageHuge(page))
> > +             if (compound_order(compound_head(page)) >= nr_pages)
>
> I don't think you want compound_order() here.
Yes, your are right.

Thanks,
  Pingfan
>
> Ira
>
> > +                     return false;
> >
> >       for (i = start_pfn; i < end_pfn; i++) {
> >               if (!pfn_valid(i))
> > @@ -1098,8 +1102,6 @@ static bool pfn_range_valid_gigantic(struct zone *z,
> >               if (page_count(page) > 0)
> >                       return false;
> >
> > -             if (PageHuge(page))
> > -                     return false;
> >       }
> >
> >       return true;
> > --
> > 2.7.5
> >

