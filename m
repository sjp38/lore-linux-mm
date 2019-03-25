Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7223FC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:43:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3996020863
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:43:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3996020863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C30826B0003; Mon, 25 Mar 2019 12:43:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDFB46B0006; Mon, 25 Mar 2019 12:43:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A80B06B0007; Mon, 25 Mar 2019 12:43:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63C606B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:43:50 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 73so9834756pga.18
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:43:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Pa6nZS3K5nnS9y06L6oLI0n+uD+p/+Diqto8nrQGBog=;
        b=sU8x3C994NfdrlZFJcedVEh5/QomuT+G1NXz9ggmlqGbJSmqa/zN0iog08Qdw7Gj8n
         lFoADfi0BDgjYhbLXo6v5qBE1wliLI0GIn3J8Z7y9LjUdepXHHCPyfWTYDQvzqBZoVb+
         m6nkcNc+RtSPLrw84PdaXS+bMvLMTeUAzu+amPnEhtDOP3R/Rcto/OSt+Tg3jOKWOIiU
         G7ZsoerFFn3Z1olQZMV7Ek3xxzXbkT26B1KSDak31/OuP2Zk3qcDRUFYOqP7qQBUEDBp
         4t/DdcUdITeXWIX7zeboo5+U09YQITE77N9uweezNaHlRXSeZQPZMuHLnib5Y/WpwgXM
         xrCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX17cRhXiVeUvXWsssx6x4Jf0bYvKzjC8RbvCIpNBaKuridGpwM
	3zfvbsTvew6SbAVTAT7PWSESS91RvlSlgYP8od+t00gHAS1HmAEObEpbNGEOkAHwKypFejcleo8
	01K7Ld7Zki8k+L3VYAU5AGdLjF7FDAxBT6dkrFhG4hPD6SWdR3+OXvUs34I9rD+1h3A==
X-Received: by 2002:a17:902:690a:: with SMTP id j10mr26497593plk.103.1553532230032;
        Mon, 25 Mar 2019 09:43:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIBnElVcgwmyd9MfZRmMErdBK6Rm5j6lgVwera0+10uVP/2/VhtuiQsXLw/WGiIqVwvK08
X-Received: by 2002:a17:902:690a:: with SMTP id j10mr26497532plk.103.1553532229235;
        Mon, 25 Mar 2019 09:43:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553532229; cv=none;
        d=google.com; s=arc-20160816;
        b=DEWK+Xh6R/g/dulicPaOxoifo8WhbPCgBxCCAg1bLUjCVZ+eF383QEyWFG0qPx27kW
         kMq4J0LRPUUIpSUtgv/k1PcjvEs8MqU840MGWVd3G4qtxSDE5Q+m+Y1K8YQHtmPxwwji
         w30wQympONblbwd0nek1yZwgs2NARM+P1vgjtA4YNLzyKWceW44bDZnkJFhsUoC7OC7M
         IoBPfOFAHfEHvBtormzr3+/yc3YYzGsxKFflkx9kJtJ1mtmnqnAgTMbjdE5USzTdzCTr
         vXdMjstSd6A1hXSSGpxPpR/ajAtlkDc/77j/pIufyyJJgG+wTLL3VML+r4HlKH4108hl
         FUsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Pa6nZS3K5nnS9y06L6oLI0n+uD+p/+Diqto8nrQGBog=;
        b=yhwgPHqtXzdp07vMuOzRdTrEfclPTh3DET50FNb0NY1ABBQWsA9TeMG5/6qr8Cki3P
         +vsWMfTJhkdftxdjhpLoYJKNih2skY3S7OKdbUXruUWQSMB6TtTK1MOPmMz5birhrikY
         xlCBJYz3FyN/T7kNIIhwx8RXuahkxa1o0l+34hL2OvUZkmdTRdgXchmrPpMrtPVLwIv/
         xChWNpoyWka1KHaN6lcx8cveHFPwCHrgx5l0swP423QUVSJESClRRwJKjgaNpIXDOsNO
         jcru5ELc5E+Oah6UL5EPeepJuxcYCRNsiwi6nAmYovFsJ2pjbclbTJw9vMuGuWTDtgIR
         7kIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r17si9787270pgm.52.2019.03.25.09.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 09:43:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 09:43:40 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,269,1549958400"; 
   d="scan'208";a="143686285"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 25 Mar 2019 09:43:37 -0700
Date: Mon, 25 Mar 2019 01:42:26 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
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
Message-ID: <20190325084225.GC16366@iweiny-DESK2.sc.intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190317183438.2057-5-ira.weiny@intel.com>
 <CAA9_cmcx-Bqo=CFuSj7Xcap3e5uaAot2reL2T74C47Ut6_KtQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmcx-Bqo=CFuSj7Xcap3e5uaAot2reL2T74C47Ut6_KtQw@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 03:12:55PM -0700, Dan Williams wrote:
> On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:
> >
> > From: Ira Weiny <ira.weiny@intel.com>
> >
> > DAX pages were previously unprotected from longterm pins when users
> > called get_user_pages_fast().
> >
> > Use the new FOLL_LONGTERM flag to check for DEVMAP pages and fall
> > back to regular GUP processing if a DEVMAP page is encountered.
> >
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > ---
> >  mm/gup.c | 29 +++++++++++++++++++++++++----
> >  1 file changed, 25 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/gup.c b/mm/gup.c
> > index 0684a9536207..173db0c44678 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -1600,6 +1600,9 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
> >                         goto pte_unmap;
> >
> >                 if (pte_devmap(pte)) {
> > +                       if (unlikely(flags & FOLL_LONGTERM))
> > +                               goto pte_unmap;
> > +
> >                         pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
> >                         if (unlikely(!pgmap)) {
> >                                 undo_dev_pagemap(nr, nr_start, pages);
> > @@ -1739,8 +1742,11 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
> >         if (!pmd_access_permitted(orig, flags & FOLL_WRITE))
> >                 return 0;
> >
> > -       if (pmd_devmap(orig))
> > +       if (pmd_devmap(orig)) {
> > +               if (unlikely(flags & FOLL_LONGTERM))
> > +                       return 0;
> >                 return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
> > +       }
> >
> >         refs = 0;
> >         page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> > @@ -1777,8 +1783,11 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
> >         if (!pud_access_permitted(orig, flags & FOLL_WRITE))
> >                 return 0;
> >
> > -       if (pud_devmap(orig))
> > +       if (pud_devmap(orig)) {
> > +               if (unlikely(flags & FOLL_LONGTERM))
> > +                       return 0;
> >                 return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr);
> > +       }
> >
> >         refs = 0;
> >         page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> > @@ -2066,8 +2075,20 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
> >                 start += nr << PAGE_SHIFT;
> >                 pages += nr;
> >
> > -               ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
> > -                                             gup_flags);
> > +               if (gup_flags & FOLL_LONGTERM) {
> > +                       down_read(&current->mm->mmap_sem);
> > +                       ret = __gup_longterm_locked(current, current->mm,
> > +                                                   start, nr_pages - nr,
> > +                                                   pages, NULL, gup_flags);
> > +                       up_read(&current->mm->mmap_sem);
> > +               } else {
> > +                       /*
> > +                        * retain FAULT_FOLL_ALLOW_RETRY optimization if
> > +                        * possible
> > +                        */
> > +                       ret = get_user_pages_unlocked(start, nr_pages - nr,
> > +                                                     pages, gup_flags);
> 
> I couldn't immediately grok why this path needs to branch on
> FOLL_LONGTERM? Won't get_user_pages_unlocked(..., FOLL_LONGTERM) do
> the right thing?

Unfortunately holding the lock is required to support FOLL_LONGTERM (to check
the VMAs) but we don't want to hold the lock to be optimal (specifically allow
FAULT_FOLL_ALLOW_RETRY).  So I'm maintaining the optimization for *_fast users
who do not specify FOLL_LONGTERM.

Another way to do this would have been to define __gup_longterm_unlocked with
the above logic, but that seemed overkill at this point.

Ira

