Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFAE3C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DEAD2054F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:20:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Fpo0sQeA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DEAD2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15C948E0003; Wed, 26 Jun 2019 05:20:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10D278E0002; Wed, 26 Jun 2019 05:20:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F16428E0003; Wed, 26 Jun 2019 05:20:57 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D205A8E0002
	for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 05:20:57 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id j18so1879796ioj.4
        for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 02:20:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yWLGrl/2egjAr2UjDXCO9Iz9KQ93uoAPVQBnf/rPQpU=;
        b=EOYJx7YEUzLqseUOlm9oqmnDAdxZuZpoP3OJPTdbPRBmZf0keFJXQ5Dc8rGRRUTIjC
         gDHZ7AnZQeh+UJrLCafBs6pEcn/xK+awHE9wd2QS/IRysKCF+m3WCiEWEhBH/BZ4RRCP
         Sd5IzD9PeF63lt9yetvMbEc9ZDjKTuYBxZ5LffOhRigHj08gcfF+/tPfj7ejWhH8ebZG
         kE5Ma4M6TNJDsT9LQp7HhOtzxeBaP7FuJWntkZ+QSH546MmdEElHERur67nUMQKJ3Chg
         hn4TDggJV05JXojjRlMu09I5KliLlT1xrRPfO6sEzi91ceZuY2AowJ2qgFYJ/2t/3wYh
         pU9Q==
X-Gm-Message-State: APjAAAUelhgRltGzlnjZykQetU5cy6BPFojJFMltSNl5+V0fDKB4QMcA
	ZHQKU1ZdWgH2LNdZ1RffWDnliIFK2IAdP4hWDum5KUSH1IwmJZB7JjrfThnC1dfa+HYJgIiuJsz
	TQHVCpXzVPHPjTkyJrk0jkCjWfvA7jRkuJQoEYDFhjFO5Vt2KvpaqcA+muYcPPURaIw==
X-Received: by 2002:a6b:dc17:: with SMTP id s23mr3792461ioc.56.1561540857600;
        Wed, 26 Jun 2019 02:20:57 -0700 (PDT)
X-Received: by 2002:a6b:dc17:: with SMTP id s23mr3792431ioc.56.1561540857096;
        Wed, 26 Jun 2019 02:20:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561540857; cv=none;
        d=google.com; s=arc-20160816;
        b=MMl4UPuQGInG+++bRLG5SxxCQp4uTaVieNisNPEswNKw9kmTHxOKCZ+sTrhJs6wFdR
         0TtyAdOwO28SzvZyXY9HIig4YDayf89pcuMTh2zuupCk/bKqpzPgpzr4pyl4kIhIv9uw
         by8PJp41SSeQniFGgO0aupfY78JAlgNqLtOXClnfZqFUfSOsbJ2A1grfFXNI1uQj0nUp
         0NtLY9AsvkbNZf1b4G3oTOr4CxE9kJmjIO7NGtk5Zyhn9JGkZZ0USJ6bNsbYaSMjqGnW
         Tz2+Go7DQCzdlnr4RSDI3U/VLCpDpcsOxk5qx4e9yZ2iOiEK2FPiMcU+JNxWeWtCOSXx
         MCNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yWLGrl/2egjAr2UjDXCO9Iz9KQ93uoAPVQBnf/rPQpU=;
        b=IcmjQw4kGk7phgegfEcwNLaTwfSGSKB+drzUOkRn4no/IhY+pSQFeP/9jBppXPNqYq
         ++5Yq3DrLn8MthDBnnhHpaHFhbU9koxv9BJgCcCKGPxpVacNHQSClXuQYP4eiAGNJi82
         krsgLKuARjx1NZiE5fI4lu/YwE0+wzHlWl9JEjaEsdluKGkxHKhtq1VC3Y+3ie3o6cdG
         4qY+Nj5+/GavtkN7zlps95pBawn1+oIMFiMhzWKYxPC2WUkpo0LhSU5R9FKg503IiZbA
         6nm+OUOJQycOVUYADXNVZb4LzLXTGZA07it1deojDQB8g/fUNwPQkcngE0tmb7Qktnvw
         gl6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Fpo0sQeA;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a24sor12521199iod.40.2019.06.26.02.20.57
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 02:20:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Fpo0sQeA;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yWLGrl/2egjAr2UjDXCO9Iz9KQ93uoAPVQBnf/rPQpU=;
        b=Fpo0sQeA3/Tgp0c/1mafklMBLg6jSyrxQxe44Ed9S6n7lVvYDoV6L06pna8ZEAMUts
         K8Ixtm2yL/rwJ4iPi3IiPnZip8oHbXYXGNbVK6OkLNtHlqCDku3E8sJT/Mr4jrGyDtxg
         T44cN0rry6IaATkchMQQrmB6MnA7mJmWfPnQoLHmV1QqbUc8TdNkw9/VhKJ1MVv3ElSf
         EXifh0SKHi4+edEQtq0strFRMNchuRQ98XpQxm/WDySH51CVXBZSew8F3GZJ9skiPNTo
         JOcvF6HYHnoUGuGVsjyMkWfclzUoPNJGMla7zXbGutkg/NvJU8+5HMgNu7Fn0Q333oaO
         j2zg==
X-Google-Smtp-Source: APXvYqy6U2utBeNKdNTf32j/0dK1Qo8sVgZz8kHlz7QzVIdIazEytRzIlyZ/6EwmqGioWHrlm9s/W32c0UHdayas8ko=
X-Received: by 2002:a6b:4107:: with SMTP id n7mr3493139ioa.12.1561540856871;
 Wed, 26 Jun 2019 02:20:56 -0700 (PDT)
MIME-Version: 1.0
References: <1561471999-6688-1-git-send-email-kernelfans@gmail.com> <20190625175144.GA13219@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190625175144.GA13219@iweiny-DESK2.sc.intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Wed, 26 Jun 2019 17:20:44 +0800
Message-ID: <CAFgQCTt4SN8EfbqV2ZhK_SEeQOsGFgNW5zTjc7JUkcCNNspuaQ@mail.gmail.com>
Subject: Re: [PATCHv3] mm/gup: speed up check_and_migrate_cma_pages() on huge page
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

On Wed, Jun 26, 2019 at 1:51 AM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Tue, Jun 25, 2019 at 10:13:19PM +0800, Pingfan Liu wrote:
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
> > v2 -> v3: fix page order to size convertion
> >
> >  mm/gup.c | 19 ++++++++++++-------
> >  1 file changed, 12 insertions(+), 7 deletions(-)
> >
> > diff --git a/mm/gup.c b/mm/gup.c
> > index ddde097..03cc1f4 100644
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
> > +                     step = 1 << compound_order(head) - (pages[i] - head);
>
> Check your precedence here.
>
>         step = (1 << compound_order(head)) - (pages[i] - head);
OK.

Thanks,
Pingfan

