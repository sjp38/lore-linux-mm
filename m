Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FE96C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:25:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4424324AEC
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:25:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FUMxlDW8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4424324AEC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D56806B026A; Tue,  4 Jun 2019 03:25:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D07696B026B; Tue,  4 Jun 2019 03:25:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF5146B026D; Tue,  4 Jun 2019 03:25:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A1D746B026A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:25:06 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id i133so15831461ioa.11
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:25:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/1V/guL5iAuFPzWbu/J5qn2zrr3eBIKvgYB5FT90pHk=;
        b=cC+Al8ErvSHXTuyFtWjIcroH5G67RYUuTXcBM+hnFJLbzXhQQvG8CLsXfrpFSFJBji
         gWVJHG10vzBa0dGctDJPg3cDKH0UR3BLBybKKNmj30SX25MuBMBhhfWkvqSNtmqKC2Lr
         dsrePYHOdlsnAirptULO5cCYdGUsBEclZt9K6iVCnC3nChvAbbKk/RMbcaGYXet9UgeC
         4ro7ZTwJq3GcqRoWWspIlPyB8a3DHT/ibzZ4pcHfMHe2AK/W3ipsmSciEjIbBpwB2xKm
         2B4DBKk7Nl77hfvtisRoMS3QPB4WyvWLcXtF+LmtThRz+D+rc3yIqkYR+FRbGAyiRGqk
         7R8A==
X-Gm-Message-State: APjAAAWm2kcEiKzYT0fz751BlxzBJST1iup+OaLHg3wrgFiUGoRGbd+G
	G/0Qq6v1UEMF76lTOiLDUQ/lUncVcQH1t7pgC4g2m4qEDe3dTqV6CjN+nFUtc4OF+0bx8sTjy31
	JVt+cRkj+olRqfg6IMqk5GhArdj81Mx1zbl9GevICJ0d0wyCqYYVZi8Hk/PMg1ayyAg==
X-Received: by 2002:a24:4cc1:: with SMTP id a184mr12623536itb.134.1559633106445;
        Tue, 04 Jun 2019 00:25:06 -0700 (PDT)
X-Received: by 2002:a24:4cc1:: with SMTP id a184mr12623510itb.134.1559633105891;
        Tue, 04 Jun 2019 00:25:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559633105; cv=none;
        d=google.com; s=arc-20160816;
        b=018JPDNKnmt6jmIDphoXRITvkkceM/oWNRnFHqf/bVGYEGILbzOvxIWlxtav0MJbQY
         rV89ND5+djN/3UUkzM3XWH/g/adDrCd9veufNN68/9xtEm5cEUFBo7KfJ6v7QB7UF68n
         ftYgsi/qI7QuCOx2z6kitVZv7Nyp93L+wFfY+nKVRUH9CxEl3E3hJ3Y2WAxIyuscijxM
         DqQ4eEGhANuRX5EK0Xrcz4wz4Shj+qSuZxFm+xtpBM6nz1LNUNMuV5n3+tn1T/3UptYR
         CJ6PXlGnRpBIeQJqHoDM31zeOVqKbOfh4WbvC7weW3eXwPKZistPR2eaufUje6RNBNXr
         twQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/1V/guL5iAuFPzWbu/J5qn2zrr3eBIKvgYB5FT90pHk=;
        b=PnA5R9sN3GC4XJ8Z2yaVDOpNEEZWZOsj5GrsiPsFQRMoNr67unww5C88DmqN9I5wUl
         SMPke31Duh5+87NBU0t0I/uWgyti05YhV0WiJVjdMC5QfPBtyvtCFwbyPbMdMSvJE8S1
         i0ZBZh7SjyT/6tLzyW6FFCBmidFtG5C+3sO58UsTfymKYs3zmjSYwzNHfFtEgYi1vH7S
         Om+GD9IK8w8/tRL24L1yenQPJ4XcqKtCMUDtsDU9mr83+0EVNPZz1FZy6xDAfU0qLVnz
         gqrx0ZY5ku0WX1DbzV5q4/T+hmzeBX/1WW+N3y3C1Man/yEXSNF8PUmUEnY/nmmKZ0Xv
         V7JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FUMxlDW8;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t6sor2071175iof.76.2019.06.04.00.25.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 00:25:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FUMxlDW8;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/1V/guL5iAuFPzWbu/J5qn2zrr3eBIKvgYB5FT90pHk=;
        b=FUMxlDW8cb4jgkfWiO5VPMAL16GJ8wbtKN8sWb6IyMltJRS7oag9E+ZyEmy7EMM1Pf
         TRJrWvzLM48XnFw9C/Ve1YK1Ro502Vv7oyMbW8RlUfZagKdCnYHjyOseCduxGZn5BlMG
         MfXtVkAiWKnumHu+WM7xisNiDuJTu9/JtxA+nW5XR3m6FI/upiv26yfqFmYUEZiwr0cd
         NdiYtm/gYxshs3FPpMY+lT6/UmdfBcT63nBFiD3qDJuJ10ZP1yTeBtBKHtDXGjLEdywN
         KKMKVgwJ6xs0CllzBenJWsa+SMtOjpJH3W08ON3VLUy9r9PLIUkfxznEkQ19wKB6qG9Q
         4Muw==
X-Google-Smtp-Source: APXvYqxP8lQ9qPiM5mHYH7yiqijauzm9S16RYrWR8flgxA2r9BGMRJA+HbMZnSkg9/qdZabc+Iq1s0o59ucjrdD/Eto=
X-Received: by 2002:a6b:5106:: with SMTP id f6mr8539654iob.15.1559633105620;
 Tue, 04 Jun 2019 00:25:05 -0700 (PDT)
MIME-Version: 1.0
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <20190603164206.GB29719@infradead.org> <20190603235610.GB29018@iweiny-DESK2.sc.intel.com>
 <20190604070808.GA28858@infradead.org>
In-Reply-To: <20190604070808.GA28858@infradead.org>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 4 Jun 2019 15:24:54 +0800
Message-ID: <CAFgQCTtXQtL0DQdqQCUEKMjDYB-AFA0SsJsvcbhqUtNbiCu1Eg@mail.gmail.com>
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: Christoph Hellwig <hch@infradead.org>
Cc: Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	John Hubbard <jhubbard@nvidia.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Keith Busch <keith.busch@intel.com>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 3:08 PM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Mon, Jun 03, 2019 at 04:56:10PM -0700, Ira Weiny wrote:
> > On Mon, Jun 03, 2019 at 09:42:06AM -0700, Christoph Hellwig wrote:
> > > > +#if defined(CONFIG_CMA)
> > >
> > > You can just use #ifdef here.
> > >
> > > > +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
> > > > + struct page **pages)
> > >
> > > Please use two instead of one tab to indent the continuing line of
> > > a function declaration.
> > >
> > > > +{
> > > > + if (unlikely(gup_flags & FOLL_LONGTERM)) {
> > >
> > > IMHO it would be a little nicer if we could move this into the caller.
> >
> > FWIW we already had this discussion and thought it better to put this here.
> >
> > https://lkml.org/lkml/2019/5/30/1565
>
> I don't see any discussion like this.  FYI, this is what I mean,
> code might be easier than words:
>
>
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097cf9e4..62d770b18e2c 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2197,6 +2197,27 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
>         return ret;
>  }
>
> +#ifdef CONFIG_CMA
> +static int reject_cma_pages(struct page **pages, int nr_pinned)
> +{
> +       int i = 0;
> +
> +       for (i = 0; i < nr_pinned; i++)
> +               if (is_migrate_cma_page(pages[i])) {
> +                       put_user_pages(pages + i, nr_pinned - i);
> +                       return i;
> +               }
> +       }
> +
> +       return nr_pinned;
> +}
> +#else
> +static inline int reject_cma_pages(struct page **pages, int nr_pinned)
> +{
> +       return nr_pinned;
> +}
> +#endif /* CONFIG_CMA */
> +
>  /**
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:     starting user address
> @@ -2237,6 +2258,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>                 ret = nr;
>         }
>
> +       if (nr && unlikely(gup_flags & FOLL_LONGTERM))
> +               nr = reject_cma_pages(pages, nr);
> +
Yeah. Looks better to keep reject_cma_pages() away from gup flags.

>         if (nr < nr_pages) {
>                 /* Try to get the remaining pages with get_user_pages */
>                 start += nr << PAGE_SHIFT;

