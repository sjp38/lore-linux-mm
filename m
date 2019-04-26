Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A646C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:36:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67B7B206E0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:36:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67B7B206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05F726B000A; Fri, 26 Apr 2019 04:36:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00CB46B000C; Fri, 26 Apr 2019 04:36:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEFB56B000D; Fri, 26 Apr 2019 04:36:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB056B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 04:36:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o3so1153968edr.6
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:36:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1BdYGx4Gm0y5xvYhP5up8QXVzzwG2qa3NJwpUjBYwv4=;
        b=KEqGOLcYpFs0NLSHhPrNX0jcZAA78oyICTWFGB8/7TieHMWazWTEHfhnCJjF68VWw3
         yNxYqdmPugrXK0+Z5NR68g1C83gcIW5op9EnE/DDKLgUY9YyDdKTj1oq04kkLgDq3NWB
         TfK0CtW9QsgkttrnNdXh9OUxAcKwr8Du327xAr/6odXJZX1+fMqE8SPA8fKZIIGWC19q
         ABwMDb+ilsTjyT9NDO67D8QJvI6c4JUW6Il8akmqkKIPmrb7xSuBKJY+jAkhxrdZcLHx
         qqBuINX45xienB5vFIcttD4fXmjYkrFiYHe3AenuC9nAEkvbwXcfjghBMOjnB9qWkWJf
         vSJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVo3F1wJzRnTwbjvlzBQsVVr7IyKPSofYqTg/pxY1jK4s9uVVmS
	wG6t2w5BLjDBR2aXfKqS6GqG+7XLuWMTvaGtmNix0FmTwVTRRMmG14UZgfwlsX0gYkB65NsLu3Y
	xTP51/HcoNaWvvpHLtgdzD9emn+yD70GhzGBx83h/rbDp/kQtQVKZfcMP8GZJFB3YHQ==
X-Received: by 2002:a50:c905:: with SMTP id o5mr28000297edh.252.1556267817060;
        Fri, 26 Apr 2019 01:36:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjtUe25XYuAVBj8beU6BNiUGDeL+tCLxgcl1po5/eZobJjUCZdyVgRPlXu1CKqgEDOrvIF
X-Received: by 2002:a50:c905:: with SMTP id o5mr28000257edh.252.1556267816180;
        Fri, 26 Apr 2019 01:36:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556267816; cv=none;
        d=google.com; s=arc-20160816;
        b=T15ITJ/gjd18Y60moq39xPQs1w8HRrafMheCzcqboEyHkH1NREqDFLEWhhmTM7xN3A
         uKbFjt3rstrNHCCUcMWOcnY1NUE1w7INLle8zidcN1eyorOheR8heUn4hupwCJYtYIBx
         Lt0uDcWqLSnnKcA03Ob+ZqPZGmIwRD3Rnyz+OPNhZ1+dIr4JFFmFkZtcpgC1cmfTB4Ne
         rWGCxneHGgVkjDEkTMVs2E6HUPVmUizd93NVB8zNAlCkyDwHivtgByHSuQnKSoujV/o5
         SZ5W8JCzkrFLtnL538lhqG/wbiYVvOBvNRg4ph6Pxz6i3SqB9uG5DKJ22Apae+jfNDkg
         ZuaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1BdYGx4Gm0y5xvYhP5up8QXVzzwG2qa3NJwpUjBYwv4=;
        b=fb/4KZ8A1MzqLSesP5xX1SyNDkz9A/zz76WoZPbP9SLaScLb5XvSKdqZDe8s5mGRwo
         mI5Tt45FcD4B1VtSSjgDbxj1H8iFS9ZNTqFNo8H0tTT4b651eSEDHP5efYVMx9Sk9XG0
         oiMTpP1QYr1HnoYsSmLpjQiSBt6fZg9XcONnoTbfLDYUmRBrM6v/IWGSi1xCxqObUgwf
         zRN7LDQCaAEbBQ8XxE0inmsyldQLCJD7Z9a2oXyGxF8eetIRKOD1AAtKJ4F5pQsiK5oJ
         w3dg9FSo7rVgh+EKodsWnZU/Xlabv507TYDAO6iM4iNC0nQ5mbua0kHD0hSCAS4bXbgY
         SI2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si105184ejq.25.2019.04.26.01.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 01:36:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 76901AF35;
	Fri, 26 Apr 2019 08:36:54 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id F01381E3618; Fri, 26 Apr 2019 10:36:53 +0200 (CEST)
Date: Fri, 26 Apr 2019 10:36:53 +0200
From: Jan Kara <jack@suse.cz>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux MM <linux-mm@kvack.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	stable <stable@vger.kernel.org>,
	Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by
 insert_pfn_pmd()
Message-ID: <20190426083653.GB11637@quack2.suse.cz>
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com>
 <20190424173833.GE19031@bombadil.infradead.org>
 <CAPcyv4gLGUa69svQnwjvruALZ0ChqUJZHQJ1Mt_Cjr1Jh_6vbQ@mail.gmail.com>
 <20190425073149.GA21215@quack2.suse.cz>
 <CAPcyv4iYMP4NWxa08zTdRxtc4UcbFFOCwbMZijB0bc2WcawggQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iYMP4NWxa08zTdRxtc4UcbFFOCwbMZijB0bc2WcawggQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 17:33:04, Dan Williams wrote:
> On Thu, Apr 25, 2019 at 12:32 AM Jan Kara <jack@suse.cz> wrote:
> >
> > On Wed 24-04-19 11:13:48, Dan Williams wrote:
> > > On Wed, Apr 24, 2019 at 10:38 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > >
> > > > On Wed, Apr 24, 2019 at 10:13:15AM -0700, Dan Williams wrote:
> > > > > I think unaligned addresses have always been passed to
> > > > > vmf_insert_pfn_pmd(), but nothing cared until this patch. I *think*
> > > > > the only change needed is the following, thoughts?
> > > > >
> > > > > diff --git a/fs/dax.c b/fs/dax.c
> > > > > index ca0671d55aa6..82aee9a87efa 100644
> > > > > --- a/fs/dax.c
> > > > > +++ b/fs/dax.c
> > > > > @@ -1560,7 +1560,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct
> > > > > vm_fault *vmf, pfn_t *pfnp,
> > > > >                 }
> > > > >
> > > > >                 trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
> > > > > -               result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
> > > > > +               result = vmf_insert_pfn_pmd(vma, pmd_addr, vmf->pmd, pfn,
> > > > >                                             write);
> > > >
> > > > We also call vmf_insert_pfn_pmd() in dax_insert_pfn_mkwrite() -- does
> > > > that need to change too?
> > >
> > > It wasn't clear to me that it was a problem. I think that one already
> > > happens to be pmd-aligned.
> >
> > Why would it need to be? The address is taken from vmf->address and that's
> > set up in __handle_mm_fault() like .address = address & PAGE_MASK. So I
> > don't see anything forcing PMD alignment of the virtual address...
> 
> True. So now I'm wondering if the masking should be done internal to
> the routine. Given it's prefixed vmf_ it seems to imply the api is
> prepared to take raw 'struct vm_fault' parameters. I think I'll go
> that route unless someone sees a reason to require the caller to
> handle this responsibility.

Yeah, that sounds good to me. Thanks for fixing this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

