Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B0E0C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:47:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B66920863
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:47:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JnAr0PRj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B66920863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF0E16B0003; Mon, 25 Mar 2019 12:47:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA0666B0006; Mon, 25 Mar 2019 12:47:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB5CB6B0007; Mon, 25 Mar 2019 12:47:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96A386B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:47:16 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id z123so9101774qka.20
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:47:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aW91dn9nuPfOXD4t7dRzfb0dMVTbNhA56lMZa1MF4+k=;
        b=qYuYWuqwXYoYRs1Zeqs9dGo4xMbw39gTZy+2cAwGTOpGq69ED/GT7Lpov69apRqg66
         UDX8+3zX68dKbFO3dXaKrX4BjnT5YnARkNEpunlua0HuAbiZOkNlTVTi3Fy55C0VmYuZ
         vOJAgzyTeDq0Vw6cCowFPDIPnatKlrczMKX3QiOusRtTtTxWz3k6GUn457pdeyghcKtE
         WWf5VSd0ClLVeJmbda8VayDvZy0ZqBqjxHuiBKqCXe2A14TuJEyuDiux8Sg2N3sWrnIh
         LHOrxulKlu9aaljx2VUlYXUfOVvMk7wkErZSKFTqKj1ODHiKlC0PODE9MO/tpoF51WqI
         njNg==
X-Gm-Message-State: APjAAAW28a8/7tYTIVLLYtdBVP8SNF003XmU78MOzR/W75Qh/iWXUGga
	9RWbtA+MWDUuPuUwmgiXAqTs0KgSFOoMZjss9MOA1rBbV8d1SNGSJhX92KA1ip2FVKNtJBcISUj
	x4eUUQWjmGx8iyOdCtVGlH883rwsz+0e6ZSICd6//urpCH/EsIvmCptD3ZdVy50l9Lg==
X-Received: by 2002:a0c:b0a5:: with SMTP id o34mr18425842qvc.42.1553532436337;
        Mon, 25 Mar 2019 09:47:16 -0700 (PDT)
X-Received: by 2002:a0c:b0a5:: with SMTP id o34mr18425780qvc.42.1553532435695;
        Mon, 25 Mar 2019 09:47:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553532435; cv=none;
        d=google.com; s=arc-20160816;
        b=BG1ySMHVp0jVfXztfp29dHfAf+ew95GMhd9069iq/w9Kt3XKrETFYAptGvMDbTXakF
         XztpVJO19zBYpRjxcv7kmPIfKf1vl9rmdIvOw2EvXOBzFQa4nF1xPEnRIs2i3/xlE5MN
         ckaJxvfR8TaNXrUQI5pVduV1kKE0BMpWIQcBVwdbbhBEGf1zQuy/2G7Gs0jygQuVpIY9
         RgMEvnUma4RsmsnyoY9QPCKve92tqjFYx7O6DtQVTCWBPiDsxrwI9cDetN7FhjRLyIRW
         fUBYmoiyA4IpPHVC+cuMluBFfrUVluI7WCSr3hlVrHD8RKfRjuTGpogdDShGrW4kJmuz
         3CtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aW91dn9nuPfOXD4t7dRzfb0dMVTbNhA56lMZa1MF4+k=;
        b=La9keTry484ZxDNqlaFSYSv5pHwvKDWcWL9x0PlMBE4AGuO+cLTFaQoGNUnpMNOWMg
         xUYmgS0hF3TwH6/eSO8TZ76QGsYjYULMQnVBHHRx+lTxJ6Gx01RtSKCUb2+sYIQGGObO
         LUpMK2oJcIkXiyhuEAJbjCiXDvXvtOX08aBmzAPEcejMUwqxAdWKHbUByRyr+ZFrp7ND
         SV1IUgtAyHs/WOQvyaAktTtnU8nAKvVcogjMMCG8gi04B7L179NZLao8QrXp8jLBbNV3
         5qFYJ5iSWIQtbGdc5bg2F0KF4zlukNBCMepREB7yVizQLr/chlcRUhgXJtvuQx3SDTl5
         NgcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JnAr0PRj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v20sor17763006qtj.31.2019.03.25.09.47.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 09:47:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JnAr0PRj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=aW91dn9nuPfOXD4t7dRzfb0dMVTbNhA56lMZa1MF4+k=;
        b=JnAr0PRjqUbU63OKfPbizP+KqQ3+NBp3Hl9xEGo+e0G3nrDd2HGKgCPDVvAtgDDGgq
         2KqoA2jx2HYsmwe0GjaGFLziEseA4OyTXFW2tSuxSlIej8IyT2qvfN0dQbNRQisxqgjv
         YyjWs4or4Fb+acXC3N1tVR1kd3hrkJmWqdorNYmhoaj/k41Isg08w6zsZvRJANzGWc/A
         EJ647jSN/xbRcwr26WHD7ybePy8t3s7A4gLWDx47XPWQwWwNd0vcZuvCEmzRsRVkB2ae
         vIuQxoFE06doqkYM87BYQF+Q/Y/tCVL0HxbvDGkDI49yextuAdRbm4bB0Z5jwF0TR+zK
         Xgkw==
X-Google-Smtp-Source: APXvYqzOo9mFR4RSXVRCnnLwhZ0gTiLUKzXoKvrAWJbTVN22MCNVY7LjLthjFhx1EBSjcGadXts77A==
X-Received: by 2002:aed:3562:: with SMTP id b31mr22334515qte.154.1553532435230;
        Mon, 25 Mar 2019 09:47:15 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id u18sm9956618qka.25.2019.03.25.09.47.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Mar 2019 09:47:14 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1h8Skj-0005QU-Qs; Mon, 25 Mar 2019 13:47:13 -0300
Date: Mon, 25 Mar 2019 13:47:13 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: [RESEND 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
Message-ID: <20190325164713.GC9949@ziepe.ca>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190317183438.2057-5-ira.weiny@intel.com>
 <CAA9_cmcx-Bqo=CFuSj7Xcap3e5uaAot2reL2T74C47Ut6_KtQw@mail.gmail.com>
 <20190325084225.GC16366@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325084225.GC16366@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 01:42:26AM -0700, Ira Weiny wrote:
> On Fri, Mar 22, 2019 at 03:12:55PM -0700, Dan Williams wrote:
> > On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:
> > >
> > > From: Ira Weiny <ira.weiny@intel.com>
> > >
> > > DAX pages were previously unprotected from longterm pins when users
> > > called get_user_pages_fast().
> > >
> > > Use the new FOLL_LONGTERM flag to check for DEVMAP pages and fall
> > > back to regular GUP processing if a DEVMAP page is encountered.
> > >
> > > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > >  mm/gup.c | 29 +++++++++++++++++++++++++----
> > >  1 file changed, 25 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/mm/gup.c b/mm/gup.c
> > > index 0684a9536207..173db0c44678 100644
> > > +++ b/mm/gup.c
> > > @@ -1600,6 +1600,9 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
> > >                         goto pte_unmap;
> > >
> > >                 if (pte_devmap(pte)) {
> > > +                       if (unlikely(flags & FOLL_LONGTERM))
> > > +                               goto pte_unmap;
> > > +
> > >                         pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
> > >                         if (unlikely(!pgmap)) {
> > >                                 undo_dev_pagemap(nr, nr_start, pages);
> > > @@ -1739,8 +1742,11 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
> > >         if (!pmd_access_permitted(orig, flags & FOLL_WRITE))
> > >                 return 0;
> > >
> > > -       if (pmd_devmap(orig))
> > > +       if (pmd_devmap(orig)) {
> > > +               if (unlikely(flags & FOLL_LONGTERM))
> > > +                       return 0;
> > >                 return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
> > > +       }
> > >
> > >         refs = 0;
> > >         page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> > > @@ -1777,8 +1783,11 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
> > >         if (!pud_access_permitted(orig, flags & FOLL_WRITE))
> > >                 return 0;
> > >
> > > -       if (pud_devmap(orig))
> > > +       if (pud_devmap(orig)) {
> > > +               if (unlikely(flags & FOLL_LONGTERM))
> > > +                       return 0;
> > >                 return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr);
> > > +       }
> > >
> > >         refs = 0;
> > >         page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> > > @@ -2066,8 +2075,20 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
> > >                 start += nr << PAGE_SHIFT;
> > >                 pages += nr;
> > >
> > > -               ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
> > > -                                             gup_flags);
> > > +               if (gup_flags & FOLL_LONGTERM) {
> > > +                       down_read(&current->mm->mmap_sem);
> > > +                       ret = __gup_longterm_locked(current, current->mm,
> > > +                                                   start, nr_pages - nr,
> > > +                                                   pages, NULL, gup_flags);
> > > +                       up_read(&current->mm->mmap_sem);
> > > +               } else {
> > > +                       /*
> > > +                        * retain FAULT_FOLL_ALLOW_RETRY optimization if
> > > +                        * possible
> > > +                        */
> > > +                       ret = get_user_pages_unlocked(start, nr_pages - nr,
> > > +                                                     pages, gup_flags);
> > 
> > I couldn't immediately grok why this path needs to branch on
> > FOLL_LONGTERM? Won't get_user_pages_unlocked(..., FOLL_LONGTERM) do
> > the right thing?
> 
> Unfortunately holding the lock is required to support FOLL_LONGTERM (to check
> the VMAs) but we don't want to hold the lock to be optimal (specifically allow
> FAULT_FOLL_ALLOW_RETRY).  So I'm maintaining the optimization for *_fast users
> who do not specify FOLL_LONGTERM.
> 
> Another way to do this would have been to define __gup_longterm_unlocked with
> the above logic, but that seemed overkill at this point.

get_user_pages_unlocked() is an exported symbol, shouldn't it work
with the FOLL_LONGTERM flag?

I think it should even though we have no user..

Otherwise the GUP API just gets more confusing.

Jason

