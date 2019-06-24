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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92761C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 06:10:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A5D820663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 06:10:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QaG2tg0Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A5D820663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5A928E0002; Mon, 24 Jun 2019 02:10:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C085B8E0001; Mon, 24 Jun 2019 02:10:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF6BD8E0002; Mon, 24 Jun 2019 02:10:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91E558E0001
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 02:10:14 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s83so20686284iod.13
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 23:10:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4j6NnH/rtjW7YqPJZlJgQIQOVFVwz7hkEl28tcCpX/c=;
        b=V3sXkwt+LyAzFzMv4MsBhYjkhUukamDgwvmtpwxE//y5O82pkk50VFvLLy6IXgMKXi
         hB/8E84bmrGFqc3yLiOFTBqX/VZupX0hKo4+LvtkIpCyMaN1c0D8naf4/YHfqp4mDAfn
         iXflWosKs0DPccfEjEn4F1ZUZPw+qEDqovM5SiVHnBLVSI0sUJlccr6FC89PY5c4cyT7
         7N99W8sylmt2oVOVd1VlkmH2oQnQytavfo/hN6OPrekVnWhKYirgzNbcuNewn6KpJ7Pg
         nyySpNu3gzoUWI5ggw56zf6rpguSRoc4IO1FJa1mjIlXSgp0nPTUrk32kFfqQcndhgmh
         2LYQ==
X-Gm-Message-State: APjAAAUaBxpGlb8v7u5EXOi8zpbjjsLe1CKceluy9Z3a5jv7m3f5SyeL
	GAoQhseHxdjot2wwnY1wfRyFtQ7nSiHMq1EhGkwN8EIvrdEiXAzUlm/7AglJ4vRuTd9tVnKuem/
	MAZ8cRH0uzbLNGj7OiKbcJrp9jY4DC6wrKfR9/FIihXz3ZohKKrf0m6gODP147MIFnw==
X-Received: by 2002:a02:aa0d:: with SMTP id r13mr22220778jam.129.1561356614354;
        Sun, 23 Jun 2019 23:10:14 -0700 (PDT)
X-Received: by 2002:a02:aa0d:: with SMTP id r13mr22220717jam.129.1561356613591;
        Sun, 23 Jun 2019 23:10:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561356613; cv=none;
        d=google.com; s=arc-20160816;
        b=ENSoUvhIxworW+rMm0nfp3iNcO0N8vj8t7LqKeJOBHWt9nZ6pWqa8U6KIGztJuUSAH
         aYdp+6V+5K4itCJIP8FsnGLM3eaupuM1Ez/W0tsondauc/UqB2PZBbU0+vQfljX53XGU
         L6IUquYzmocVOLpdKmnLUZxC2BD4+ztvu30Ut04uFsFZWhfCtmwkOAHaKP/xqd5ZStaf
         ag9OECDH1Q72AShauRSkrWzigvvz7sLMGy0rSCKJRzXKDGkvQR90xyanA0vIH3clMxTo
         x0IuMjAKUBANvvEO/CX5Zvz3Ewmo8/HY47qWL29wQRHXjHkJta5rR4hmoc7A5AGMvcsS
         G6RQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4j6NnH/rtjW7YqPJZlJgQIQOVFVwz7hkEl28tcCpX/c=;
        b=fkPX2L94S2DvX/5sMiKDOaFTrSBHOZBGCG5fYIjvFfKT57snNZIi0/GIQd2Cb+SdS+
         VfevfgBuXogpuBT7OaldxfSiy7mEkWp1ZpUnG22bL9JGsRMFQ7stqmwOeHAKZniR3PXY
         0AQgq1OnSblMT6Tfqe+kiSKU8+V3dV6caLHUCYmmmbsyfbFF7Mx4InWTdkx1wn2YOPfy
         QGbsZWttXhLoa7ZQQSf2NXxn8lhKWE1rbsgCrWnVst3muXiWGb1guPQxX3/9VOYagAH/
         QoGvoEp6ugnF5ZRE3LTs7p+BGfV84MtDm85ybeiPlWr7tvuIo0af0atcsCs434x7Rnb3
         jjqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QaG2tg0Y;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d124sor7053194iof.41.2019.06.23.23.10.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 23:10:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QaG2tg0Y;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4j6NnH/rtjW7YqPJZlJgQIQOVFVwz7hkEl28tcCpX/c=;
        b=QaG2tg0YYgd5+P5YRlDvLPsQpP7pDaSmqOTCFDcG7/rcTc53ymw2VqKN97slpnV64h
         Z0qRqTGndfOy26HG/tWXys9SYkoqbC/kD6scoZi8KsC2l3+OsH6QsMKNsERmRMR0PDlM
         NCls1WOiUY+TnzK1tWtORWC0o/KQlxMxSoR4va5E58FzkSBpUkmE8HWQZ0/Zb3ZcfTSn
         mSaid68PFqvYlQA3Fnblkgdug64w3pgL4eb3n3Di+vyEQM9/Ab7C/9Jip9LxDovl67NG
         S5t16MOLFqYUMTdA5h1HYzdKbBrk8BRvQa+OW1Z8gIH+DIPrutdgXyVI2/6HHWDy+kos
         tJSg==
X-Google-Smtp-Source: APXvYqz4l/aitSGXlKJujrJxoiu8kzosNa/t0hrpf2ai9RzW0CH9f/kJvMBczKvXomO4NEdlo8XLXdUnhSubabN7hoI=
X-Received: by 2002:a02:a384:: with SMTP id y4mr124829515jak.77.1561356613275;
 Sun, 23 Jun 2019 23:10:13 -0700 (PDT)
MIME-Version: 1.0
References: <1561350068-8966-1-git-send-email-kernelfans@gmail.com> <216a335d-f7c6-26ad-2ac1-427c8a73ca2f@arm.com>
In-Reply-To: <216a335d-f7c6-26ad-2ac1-427c8a73ca2f@arm.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 24 Jun 2019 14:10:02 +0800
Message-ID: <CAFgQCTs14R5P7RpCTMwLCMJrGgPzbTGp4tvxCJA0kFgD8_y==g@mail.gmail.com>
Subject: Re: [PATCH] mm/hugetlb: allow gigantic page allocation to migrate
 away smaller huge page
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, 
	Oscar Salvador <osalvador@suse.de>, David Hildenbrand <david@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 1:16 PM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
>
>
> On 06/24/2019 09:51 AM, Pingfan Liu wrote:
> > The current pfn_range_valid_gigantic() rejects the pud huge page allocation
> > if there is a pmd huge page inside the candidate range.
> >
> > But pud huge resource is more rare, which should align on 1GB on x86. It is
> > worth to allow migrating away pmd huge page to make room for a pud huge
> > page.
> >
> > The same logic is applied to pgd and pud huge pages.
>
> The huge page in the range can either be a THP or HugeTLB and migrating them has
> different costs and chances of success. THP migration will involve splitting if
> THP migration is not enabled and all related TLB related costs. Are you sure
> that a PUD HugeTLB allocation really should go through these ? Is there any
PUD hugetlb has already driven out PMD thp in current. This patch just
want to make PUD hugetlb survives PMD hugetlb.

> guarantee that after migration of multiple PMD sized THP/HugeTLB pages on the
> given range, the allocation request for PUD will succeed ?
The migration is complicated, but as my understanding, if there is no
gup pin in the range and there is enough memory including swap, then
it will success.
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
> >
>
> So except in the case where there is a bigger huge page in the range this will
> attempt migrating everything on the way. As mentioned before if it all this is
> a good idea, it needs to differentiate between HugeTLB and THP and also take
> into account costs of migrations and chance of subsequence allocation attempt
> into account.
Sorry, but I think this logic is only for hugetlb. The caller
alloc_gigantic_page() is only used inside mm/hugetlb.c, not by
huge_memory.c.

Thanks,
  Pingfan

