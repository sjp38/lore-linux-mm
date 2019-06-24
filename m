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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6A08C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:32:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DDE82083D
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:32:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Dkbiwb35"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DDE82083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 066466B0003; Mon, 24 Jun 2019 01:32:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0179E8E0002; Mon, 24 Jun 2019 01:32:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E206E8E0001; Mon, 24 Jun 2019 01:32:46 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C26A36B0003
	for <Linux-mm@kvack.org>; Mon, 24 Jun 2019 01:32:46 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id f22so20617688ioj.9
        for <Linux-mm@kvack.org>; Sun, 23 Jun 2019 22:32:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/l5qUlzkkXSn8Rj4gRqkwVlRMYz6YfXqXzcoaQu0DB4=;
        b=sXadgOxzSSAo4gCTYblWKIdG4lk6sWy4yv6Bcjt0DIJdue/3Z6fPK+vQZkicEEnXSf
         vw8HkwPNiyR+8bhmJJCWbLWqK2gODJhK6ry9zkSmk92ze27yDwmdytev80WZ2xI/UzeF
         FzaZci/J5v9EMhJL/hUX3jX/RO5+KFnatXWARuqeV/zxLQj5c9JWmeT16/EHF23EBiIX
         +S7/04tVG9G4QfnCdit5qsgWcacKw52wcSu1eUROI9kpReXYsXutiFffRXyTCQs3h5KH
         Ar6H7G/WWoaXWWN9GlsH/43kc1fekn9z8TzxCzbhwTzt5zKRjEbjUs3SsaHX3MuXc+Kz
         7N9w==
X-Gm-Message-State: APjAAAVt0JV1T1wnTg95N+C0IuPJExdO1V5ZJzV+le8Osy5YpAmPKWFI
	CM0VKHQik+0rE81k07dMgQMetrORDljkH200KtBpw0rwHnoLqE+g13HRKFZStZTbP2aMUtR0jhU
	CNQrKbV7arkKMERNMDPCzm+oNobCTFY5cqR1/aScdKY2LhokqsRbKj6RuwVQiN1zKtQ==
X-Received: by 2002:a6b:3e57:: with SMTP id l84mr53181378ioa.164.1561354366552;
        Sun, 23 Jun 2019 22:32:46 -0700 (PDT)
X-Received: by 2002:a6b:3e57:: with SMTP id l84mr53181346ioa.164.1561354365913;
        Sun, 23 Jun 2019 22:32:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561354365; cv=none;
        d=google.com; s=arc-20160816;
        b=DVx7kN8MTXex8hIo09f8LeQP1CJCld0dCIg+Vsi4htXM0CU3L497t3qA3dYYXpXREB
         745XJujyMbyN5ZtBEDirsMeEwfnNg9f5ZjfH2yxZ8KgW+UWXM1vSj2rZP6lmoT9HGtDc
         YwMKaAxOD3wx0NtuogV0pTF+wGAr0bjAWDLMXx1P6suCd5zeqcr4TS7y9DHXJO5NcIt+
         PHkGdOCPs3sHaPM+fV1lPkhL5N3SsIC7rtlCKr2bx/UhokMaxQKyI7Y890vJrZ5U4oKE
         NypLglbMrQXoMNvkZzhvSHAh23pbJ7lAxhPbcG4Vijh6frsfxLyzYPjV6dD5WtgSmgo6
         ViVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/l5qUlzkkXSn8Rj4gRqkwVlRMYz6YfXqXzcoaQu0DB4=;
        b=MD99qvS801srnTx5b/2qWGvDn1WXbDAYAWxNRTjZibY4HjS/2cBtHmjhpp9A2rkpKz
         +f/r1ChK08JSFUfgfmQ31SIlU6pl/WqOqB7dXOFW3Fn5/bTUqXjaCdnZrS81aJ+uRJAp
         rVquMdj01wiiH8XWnUD7AjAduWV8matpel13sU98CNVPp7EpCGHT92PcweblcsJofyl/
         5b6F5PpVawmvupBcl6BE7vadv0VVXj8RniTp/UvZIdp+g7SHlsYBCtUCfZamhFuoXL/W
         mTSC1gMYFVWGYtlPz0kLZwNoxDZ8OV3cNj/DE1ctyKNj4UIX9N67OQTsddXtdplvWACw
         L0+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Dkbiwb35;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h25sor6877913ioh.29.2019.06.23.22.32.45
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 22:32:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Dkbiwb35;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/l5qUlzkkXSn8Rj4gRqkwVlRMYz6YfXqXzcoaQu0DB4=;
        b=Dkbiwb35Z4XCd7jAlpAZCQu5U6vQ2IJMnfRSCFrBUb+0AD++dGclfZL2qAFUVugf9q
         cUnF8CJHMh2e1Y2kwP/3P+4vHjICpw5lRXFrR75FNpAOxz4UyV/NWmUBlx5OX663D6b3
         FpjNyvXxm2+UK741ClSkR+a6xyMg/8mHcFOpRl4CDHUJnY0Pxz5Ywn7fT3+Hf6Nx991+
         WCTtn8lQkJbVEqqQKZXc5VljE/9+bsxN4bJtL5w6NXn54UH/1XSi7bsSKrP9f3QBwPys
         SWb6/JhlZvRJd9GHNzdgugfJ782MbwIJulfvwNr471wDzJpW/sBRYyeAm07BCOosFi9P
         roJw==
X-Google-Smtp-Source: APXvYqzlHl65VPmh6Fpk+kxQ+1lgOSdmQFpOTpFQfFvOCSSDU3U1pIGJZHw/K1MdWEGG1h+GA1/Q71eEsPHo6r3vczg=
X-Received: by 2002:a6b:6f06:: with SMTP id k6mr52432551ioc.32.1561354365683;
 Sun, 23 Jun 2019 22:32:45 -0700 (PDT)
MIME-Version: 1.0
References: <1561349561-8302-1-git-send-email-kernelfans@gmail.com> <20190624044305.GA30102@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190624044305.GA30102@iweiny-DESK2.sc.intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 24 Jun 2019 13:32:34 +0800
Message-ID: <CAFgQCTuMVdrjkiQ5H3xUuME16g-xNUFXtvU1p+=P4-pujXcSAA@mail.gmail.com>
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

On Mon, Jun 24, 2019 at 12:43 PM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Mon, Jun 24, 2019 at 12:12:41PM +0800, Pingfan Liu wrote:
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
> >  mm/gup.c | 19 ++++++++++++-------
> >  1 file changed, 12 insertions(+), 7 deletions(-)
> >
> > diff --git a/mm/gup.c b/mm/gup.c
> > index ddde097..544f5de 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
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
>
> Sorry if I missed this last time.  compound_order() is not correct here.
For thp, prep_transhuge_page()->prep_compound_page()->set_compound_order().
For smaller hugetlb,
prep_new_huge_page()->prep_compound_page()->set_compound_order().
For gigantic page, prep_compound_gigantic_page()->set_compound_order().

Do I miss anything?

Thanks,
  Pingfan
[...]

