Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D332C48BD3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 23:01:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 522B120663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 23:01:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 522B120663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0AE96B0005; Mon, 24 Jun 2019 19:01:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBBD28E0003; Mon, 24 Jun 2019 19:01:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B82FC8E0002; Mon, 24 Jun 2019 19:01:26 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81A386B0005
	for <Linux-mm@kvack.org>; Mon, 24 Jun 2019 19:01:26 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y7so10492595pfy.9
        for <Linux-mm@kvack.org>; Mon, 24 Jun 2019 16:01:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lmlJmIoIJYQ/ZKptcn9cFYZEh4juh3us7RvKQficfpo=;
        b=XTzEiusKsfyBgWYrgdS04r786sMIqOEiV3YL6XFyJNyttKylWL801O93N/r3guVcQO
         hh1pd0j+HNwsvLMwXnuYjnTefiNQ4Blw0EBUrp0KNn53mYkI9gIwHZUBba6oAJZhNOWx
         zkZVtZoasgju2EVowsK3WmniQMzBiLSS5klDSEKJzcSfBF/DCJwdpnfMgMyREiYk0/hx
         R9/7tQMoSCMGWtb9chc1Z349EQwrdSJouTJU/xVMp5CNvLoaIPC/HGRmngPPN72kv5Hp
         KL/LMEGGp4bEirBB7BuomutrEKG0m5tQDqRNc0gGrYBfeJAeD77A3oA0+xTdSyeYvDe+
         d6Nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVswtJaHIggpkDwqFwCqly70wJmH9V/GZBFEaxSweKsDJamCBFX
	3XkqZ2TTWXfFHtD60yxVu15t/BmC9l434PWyjYdwhcnl+tJr7Pfkn+UGi5ccCWRLwB3M1FaOmOv
	TddJk1xH4Nj3Pi3y88NBjb6fLE8lNGiF1V85j0jd4ipFYLAKAN9z5wA9nVnf42Dd99w==
X-Received: by 2002:a17:90a:ac0e:: with SMTP id o14mr27955021pjq.142.1561417286155;
        Mon, 24 Jun 2019 16:01:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtVERtzuhUfUMzQVPAHhy9n/cgd+Tbe0ReGZ08epAYz6g1/GUHjJcmyiJV1Ripe5jDGG8G
X-Received: by 2002:a17:90a:ac0e:: with SMTP id o14mr27954943pjq.142.1561417285400;
        Mon, 24 Jun 2019 16:01:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561417285; cv=none;
        d=google.com; s=arc-20160816;
        b=kE3cwVj0UGfRqWaBNs7H+UO9WreAmjMlcInpBNlI1gwRv0FdBNUrnSqFa4xQnICedk
         5CyXUUfdUnYIjS9HFPbaPuflq4JTcvFg28g+DxU14y5ZrwehmbIQdkYXPldcL5lHteNV
         PUEzu9+GP0T8PqGeljH5nOp6hOy9J98mwt1vAhfMI8uGqmXBtGY2KeqUJ4fhjDvQfcgp
         prupQoOR5SzwMiCKmmJvtnRsIlVA9TxPuP93wmL7lE3nUpDdjVN2eENjQkez0GToyFjr
         42Hcekv0oQ19mnClY5SsCRS2/VVAYcI/Cbom0iCmmxqNk2ffpic9POfjGY9yvFnbHDTg
         EaSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lmlJmIoIJYQ/ZKptcn9cFYZEh4juh3us7RvKQficfpo=;
        b=z7eOp0pb4SHF5mXg3Bgn+ySJ24XEP3qJlwzp9887gDLXfNXWUXvuTsrC5HGFOclpSR
         g+PljXzd1+oUlRdTKy/gMqDF0EKTXHbG/ij5Pa4XdWlHc5thR+6Pa5g4TBGxRK9SABQo
         87DvYpZOlTSKyc39cC9fkWEsh/pLm4S3SR6QyQ2PhgKAlkygCRyuKGbypqN0I35HoTtW
         VCjIMfox+0FxU5f4FgJG6bQbpKcDmkJWYefibYTR+SwTx9RZMw+KavOw1gFRk+4qxFLF
         Be4YOppmZCTFnJoSI7x6+Zsf606G0+lclQ3saUmrReYA1QOUSf36b1GzAVGodhEb6DSP
         geTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b41si11456651pla.409.2019.06.24.16.01.25
        for <Linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 16:01:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jun 2019 16:01:24 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,413,1557212400"; 
   d="scan'208";a="163454969"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 24 Jun 2019 16:01:24 -0700
Date: Mon, 24 Jun 2019 16:01:24 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Christoph Hellwig <hch@lst.de>, Keith Busch <keith.busch@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	LKML <Linux-kernel@vger.kernel.org>
Subject: Re: [PATCHv2] mm/gup: speed up check_and_migrate_cma_pages() on huge
 page
Message-ID: <20190624230123.GA24567@iweiny-DESK2.sc.intel.com>
References: <1561349561-8302-1-git-send-email-kernelfans@gmail.com>
 <20190624044305.GA30102@iweiny-DESK2.sc.intel.com>
 <CAFgQCTuMVdrjkiQ5H3xUuME16g-xNUFXtvU1p+=P4-pujXcSAA@mail.gmail.com>
 <CAFgQCTshH=FsJbdf49wD=fgJzvbEqzEW--F3oon1aLc64r=u7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTshH=FsJbdf49wD=fgJzvbEqzEW--F3oon1aLc64r=u7w@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 01:34:01PM +0800, Pingfan Liu wrote:
> On Mon, Jun 24, 2019 at 1:32 PM Pingfan Liu <kernelfans@gmail.com> wrote:
> >
> > On Mon, Jun 24, 2019 at 12:43 PM Ira Weiny <ira.weiny@intel.com> wrote:
> > >
> > > On Mon, Jun 24, 2019 at 12:12:41PM +0800, Pingfan Liu wrote:
> > > > Both hugetlb and thp locate on the same migration type of pageblock, since
> > > > they are allocated from a free_list[]. Based on this fact, it is enough to
> > > > check on a single subpage to decide the migration type of the whole huge
> > > > page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> > > > similar on other archs.
> > > >
> > > > Furthermore, when executing isolate_huge_page(), it avoid taking global
> > > > hugetlb_lock many times, and meanless remove/add to the local link list
> > > > cma_page_list.
> > > >
> > > > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > Cc: Ira Weiny <ira.weiny@intel.com>
> > > > Cc: Mike Rapoport <rppt@linux.ibm.com>
> > > > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > > Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > > > Cc: Christoph Hellwig <hch@lst.de>
> > > > Cc: Keith Busch <keith.busch@intel.com>
> > > > Cc: Mike Kravetz <mike.kravetz@oracle.com>
> > > > Cc: Linux-kernel@vger.kernel.org
> > > > ---
> > > >  mm/gup.c | 19 ++++++++++++-------
> > > >  1 file changed, 12 insertions(+), 7 deletions(-)
> > > >
> > > > diff --git a/mm/gup.c b/mm/gup.c
> > > > index ddde097..544f5de 100644
> > > > --- a/mm/gup.c
> > > > +++ b/mm/gup.c
> > > > @@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
> > > >       LIST_HEAD(cma_page_list);
> > > >
> > > >  check_again:
> > > > -     for (i = 0; i < nr_pages; i++) {
> > > > +     for (i = 0; i < nr_pages;) {
> > > > +
> > > > +             struct page *head = compound_head(pages[i]);
> > > > +             long step = 1;
> > > > +
> > > > +             if (PageCompound(head))
> > > > +                     step = compound_order(head) - (pages[i] - head);
> > >
> > > Sorry if I missed this last time.  compound_order() is not correct here.
> > For thp, prep_transhuge_page()->prep_compound_page()->set_compound_order().
> > For smaller hugetlb,
> > prep_new_huge_page()->prep_compound_page()->set_compound_order().
> > For gigantic page, prep_compound_gigantic_page()->set_compound_order().
> >
> > Do I miss anything?
> >
> Oh, got it. It should be 1<<compound_order(head)

Yea.

Ira

> > Thanks,
> >   Pingfan
> > [...]

