Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 145D9C31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:24:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C26F62133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:24:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KnTCmViR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C26F62133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C4F66B0007; Fri, 14 Jun 2019 11:24:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34EAA6B0008; Fri, 14 Jun 2019 11:24:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0966B000A; Fri, 14 Jun 2019 11:24:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id F27346B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:24:30 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c5so3072998iom.18
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:24:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=b5mc7IOtZTIYzG3UEP4sVSXC9GRywSomfDBGG2VeoWI=;
        b=VHSoTpBUUxCjPjzLGVYM8QggBNXjBpkxFy+92nt4vttyc8a3zYaVouMDqhErZP+HdS
         RKToYHOG/szWRPy7gIwxHwKCqqX9Qc18opGVGgtoT4ZnXzl9TkmJ8lvQyywn0aFuR3M1
         JkiQxTaKsdf4kHceEhhR2Zn38zPJdgfKEW87UF4a7Wj1L4/YldHpHSg3R0JYboYolS0q
         PFIBTguW6PygV8iIFnjjfsTUJ8hE4EVbMpszfbj33joILWPrHodpIOGHJSsrx7locKwN
         FvhaMyNt0VJgBKQ2db4phioL8xzZ4EsgyGRhSX+hVC8Hl2UAFnJhdbwk8qNUUg6tH1o1
         TpgA==
X-Gm-Message-State: APjAAAXi2cWakku16zZKzGddoXJk2rRRXQZb27j1l2DG/qKMYcOivoiL
	9WY/Dw0Aqp23L3aENGWUUJVLjn5NBNic2V403COhZ3OG2yhRmsoPq6Hns+m2erTjgGOxBkpi90P
	N6QzezmsG6pMC94iNI25H6+JS4WygoXlAG0uzQOMhTqzhCH2kTsRNtyJpo9TUxrIFQA==
X-Received: by 2002:a02:878a:: with SMTP id t10mr66102004jai.112.1560525870746;
        Fri, 14 Jun 2019 08:24:30 -0700 (PDT)
X-Received: by 2002:a02:878a:: with SMTP id t10mr66101905jai.112.1560525869868;
        Fri, 14 Jun 2019 08:24:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560525869; cv=none;
        d=google.com; s=arc-20160816;
        b=G5r3HelGtXPbkIMkgrPgjlfHm3BML2jOs4ZHtOgJL19+OIp52SmqGll2dzy59No0G4
         C3mQn4f/dB8mCDCl6A8gzakdXAfFZp/QkW7xsJD5zKIZZLz4HeBFM7B61dFnj+BImIFU
         Mx1yiISG+X3C2e6pitVadrAdOp2huYTSbR1m7mXlz/BtbTe6FcubF07AjJ2iWO3F5tU6
         DMdkQly/XrU/5UusPX9A9TvfBXmPy/xqWRAQEnlzEPsnzgEPLpBbpqeudnYizc0Mi2st
         cKK813amzpxEGenep0FC5IwBQnvMOoKznOVYfdtmgk69aloCeV087HOH+gSpiEHBl5as
         dPqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=b5mc7IOtZTIYzG3UEP4sVSXC9GRywSomfDBGG2VeoWI=;
        b=PmfCdJeDz4CW9Vx8ET75NCYrzBlDRxbKgj88H43IwRBCWQf8npqh7CnfeKpy3R1OPZ
         xEqxufgxzRi2aAlXBM2GUl8s9scHSQAeDs/ceeNyqQby5xj6jjXl4+4RO1wKopYC3rSR
         E1dJLESZr2JV4eH8/R35Lg+ecUygv3N2QZDcMpxPDk9T9E/4IqtqA6YzCcSANDF/FlGs
         W+PoenNC/ZwzXSs3IeLl/dkoHZiM3gJjlzvWFwFghWcwE+v29LIb6ZHh5qTsQ9voFBeq
         uFplblRi40ga36DL6y3EQgNosAj+GZyhm8eDdoJgB/rSwbb6daV30mQgTl1+pNnkWQBJ
         J3WQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KnTCmViR;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r29sor2563283iob.25.2019.06.14.08.24.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 08:24:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KnTCmViR;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=b5mc7IOtZTIYzG3UEP4sVSXC9GRywSomfDBGG2VeoWI=;
        b=KnTCmViRin1UgLkXIhzoE2OPV9TlwVESbaXCiEIMM2WNU5h4E9lpY0vF0ycwvoRD/Q
         Rrwmm35gXN74dCUWB8WvT8bjZ/1ewsxImQA28kH0+htgddgjTH8fyQm+OcR4qiFHOVKC
         q+d4bgfBXRRCy0RHBkrGVnD0FIBi8h0vKCMXs+gRBz0RPt+yhpG0JRTbh/iVVJSVHc3q
         N15E8ikRs9oCaIAvlmeDXsA9ylpFj7nVeN/GfY0XCm3Xy+ikuCzkpanl008D2KaUZ7Kr
         USKoXTAsmfArudlWKCx4S/cMNM3n3zPAhznScDp76DDGGOtaTpKvWnayZ6NHG9WOXRJU
         Bpag==
X-Google-Smtp-Source: APXvYqyhiF0X4SUWnydncHY4ZbPZUXB3x2O0g2X6ukqLUOc/rcv424wYEFuaQMTf3N8NzMrlA8XSFaybvWmGRvIe9ks=
X-Received: by 2002:a6b:4107:: with SMTP id n7mr3534566ioa.12.1560525869521;
 Fri, 14 Jun 2019 08:24:29 -0700 (PDT)
MIME-Version: 1.0
References: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
 <1560422702-11403-3-git-send-email-kernelfans@gmail.com> <20190613213915.GE32404@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190613213915.GE32404@iweiny-DESK2.sc.intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 14 Jun 2019 23:24:18 +0800
Message-ID: <CAFgQCTu2voVPA2U90JjUFc116C9iqDDcDZf9UhErE56CgqxccQ@mail.gmail.com>
Subject: Re: [PATCHv4 2/3] mm/gup: fix omission of check on FOLL_LONGTERM in
 gup fast path
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, 
	Mike Rapoport <rppt@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>, 
	Matthew Wilcox <willy@infradead.org>, John Hubbard <jhubbard@nvidia.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	Christoph Hellwig <hch@infradead.org>, Shuah Khan <shuah@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, mike.kravetz@oracle.com, 
	David Rientjes <rientjes@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Cc Mike, David, who is an expert of hugetlb and thp

On Fri, Jun 14, 2019 at 5:37 AM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Thu, Jun 13, 2019 at 06:45:01PM +0800, Pingfan Liu wrote:
> > FOLL_LONGTERM suggests a pin which is going to be given to hardware and
> > can't move. It would truncate CMA permanently and should be excluded.
> >
> > FOLL_LONGTERM has already been checked in the slow path, but not checked in
> > the fast path, which means a possible leak of CMA page to longterm pinned
> > requirement through this crack.
> >
> > Place a check in gup_pte_range() in the fast path.
> >
> > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mike Rapoport <rppt@linux.ibm.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > Cc: Keith Busch <keith.busch@intel.com>
> > Cc: Christoph Hellwig <hch@infradead.org>
> > Cc: Shuah Khan <shuah@kernel.org>
> > Cc: linux-kernel@vger.kernel.org
> > ---
> >  mm/gup.c | 26 ++++++++++++++++++++++++++
> >  1 file changed, 26 insertions(+)
> >
> > diff --git a/mm/gup.c b/mm/gup.c
> > index 766ae54..de1b03f 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -1757,6 +1757,14 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
> >               VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> >               page = pte_page(pte);
> >
> > +             /*
> > +              * FOLL_LONGTERM suggests a pin given to hardware. Prevent it
> > +              * from truncating CMA area
> > +              */
> > +             if (unlikely(flags & FOLL_LONGTERM) &&
> > +                     is_migrate_cma_page(page))
> > +                     goto pte_unmap;
> > +
> >               head = try_get_compound_head(page, 1);
> >               if (!head)
> >                       goto pte_unmap;
> > @@ -1900,6 +1908,12 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
> >               refs++;
> >       } while (addr += PAGE_SIZE, addr != end);
> >
> > +     if (unlikely(flags & FOLL_LONGTERM) &&
> > +             is_migrate_cma_page(page)) {
> > +             *nr -= refs;
> > +             return 0;
> > +     }
> > +
>
> Why can't we place this check before the while loop and skip subtracting the
> page count?
Yes, that will be better.

>
> Can is_migrate_cma_page() operate on any "subpage" of a compound page?
For gigantic page, __alloc_gigantic_page() allocate from
MIGRATE_MOVABLE pageblock. For page order < MAX_ORDER, pages are
allocated from either free_list[MIGRATE_MOVABLE] or
free_list[MIGRATE_CMA]. So all subpage have the same migrate type.

Thanks,
  Pingfan
>
> Here this calls is_magrate_cma_page() on the tail page of the compound page.
>
> I'm not an expert on compound pages nor cma handling so is this ok?
>
> It seems like you need to call is_migrate_cma_page() on each page within the
> while loop?
>
> >       head = try_get_compound_head(pmd_page(orig), refs);
> >       if (!head) {
> >               *nr -= refs;
> > @@ -1941,6 +1955,12 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
> >               refs++;
> >       } while (addr += PAGE_SIZE, addr != end);
> >
> > +     if (unlikely(flags & FOLL_LONGTERM) &&
> > +             is_migrate_cma_page(page)) {
> > +             *nr -= refs;
> > +             return 0;
> > +     }
> > +
>
> Same comment here.
>
> >       head = try_get_compound_head(pud_page(orig), refs);
> >       if (!head) {
> >               *nr -= refs;
> > @@ -1978,6 +1998,12 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
> >               refs++;
> >       } while (addr += PAGE_SIZE, addr != end);
> >
> > +     if (unlikely(flags & FOLL_LONGTERM) &&
> > +             is_migrate_cma_page(page)) {
> > +             *nr -= refs;
> > +             return 0;
> > +     }
> > +
>
> And here.
>
> Ira
>
> >       head = try_get_compound_head(pgd_page(orig), refs);
> >       if (!head) {
> >               *nr -= refs;
> > --
> > 2.7.5
> >

