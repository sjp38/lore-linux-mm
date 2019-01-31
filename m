Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A164AC282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:06:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51F612087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:06:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51F612087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFA008E0002; Thu, 31 Jan 2019 06:06:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD0D58E0001; Thu, 31 Jan 2019 06:06:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C982B8E0002; Thu, 31 Jan 2019 06:06:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82D9E8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:06:58 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v2so2122024plg.6
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:06:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=B4PsHezRzbQTLM37MNR4kCXhA4fHEy1DZXXcjl0U99c=;
        b=oNZphCJC4bkKBbThtCdXVlet6nzzON/rIY5sCD+nIYXR/96JRExQ7CV6gPcEu8uaEX
         KsqFCzyq78GHKCJz9MPOzcCmlGmQ3JonBgW5Moo3VYf70OyCiDGjLD3SwAY7zqf2vjFQ
         HN3pxym+nvkCnL7a/US/tHJP/HfN+WbTV4pis2vF6GK3zzSyJL1Kw40QTJgHT4wSmr7A
         qJUmtwNBUAzHriu3WaFkI/9aOLQX6/r6MUeZauAh7UiyfvlI7wgz9aT4cnAQAv6rmqAl
         SgU1jxuRayznqhPD12wKnOTEiqdJdVRPr5F6SkORA5j8kXLf+pCJvZaIozAIEparuzdy
         Z6IA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukenMIkt5U2zwUsTMtKckdlweLMs59q0Tz3b7Fht3EoyyrJAdQNd
	MTIRCa7oqo7FiT3gPNBwU/igNcWekEUstUyq8MItQTLmETU5PJ0N6++OaCRVpk0ekyw+3wa3BA+
	UnR6Ufa6OJLAvLfTs3IqLRF0DUkmgxxfwCqJNzeTBL12YbIrCcE1tBrlbeae2L6t7yA==
X-Received: by 2002:a62:5003:: with SMTP id e3mr35460750pfb.23.1548932818153;
        Thu, 31 Jan 2019 03:06:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6ua1dU97mkNvS+pDP4LRWH/PiL5ZKUkbv58PibXpQx4yYdanx2+NoSorL42XWDiQ2Xulsm
X-Received: by 2002:a62:5003:: with SMTP id e3mr35460694pfb.23.1548932817280;
        Thu, 31 Jan 2019 03:06:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548932817; cv=none;
        d=google.com; s=arc-20160816;
        b=T6MuFESh+QNPyaZN06FjbI7+JrTpdsmgoGnwnOYqquwGCEA0teb1tisenRtIRF9pnb
         vHMrQXIg+H+AczOqShpyuzGIp0s833JW7ymlp9KukvW0UmsLLPYvlCV44G8JJFeTPyFA
         O4xVf9b/7QTIaPBRcPdgF3nY6IvJIF44ZMjnq0TdTvqhRApxAv9TJDBjU4BJjaWAVJPj
         elf59baA2fVMFToz53gNKkPT10DrfK6PPYeYYJuOHEpX8WNv3mdwzKdyVSllMIA9R8Df
         xX4UMTbFD3TLWRM59EbU45jmm+Sli9JjiaU220EXfbOzMq3fEaUVmpag76AK3kiMUSpC
         vPFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=B4PsHezRzbQTLM37MNR4kCXhA4fHEy1DZXXcjl0U99c=;
        b=O5tLhKJPmmFkDkZJPM1Uqmf0yP5Vo2fpQD63nXf2UwFlPoGnwPqnQB0QNmQiiEWres
         fFCejtia4+KGkKa1ThWphh1vorLcStmRf+cDdKKojUHkDrJMDLUwQ/xnNpqky/TUnVXU
         odLjopE9a/5R/DK4roeyjr4Zw5hzDIA65MzRHrghAH0enwuVDcIBGrFdxtrV/YL9Q6L6
         yH3viPmye4APjc3ur49lFKKCvPffHN4jp5K2HOEp0hz6YLTW+MXaxS0RvjtsTnRo1Buy
         DYQb5K4ao136sNSq8wcQhp1bXYzbWgJ1s7ro9Hu+U/+kId6TTto72zWAOlMmmvf7+75q
         EcZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m30si4354420pff.158.2019.01.31.03.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 03:06:57 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0VB0vxY071644
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:06:56 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qbxm93ub6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:06:56 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 31 Jan 2019 11:06:53 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 11:06:44 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0VB6hb544302338
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 11:06:43 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 77784A4055;
	Thu, 31 Jan 2019 11:06:43 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 05551A4057;
	Thu, 31 Jan 2019 11:06:41 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 31 Jan 2019 11:06:40 +0000 (GMT)
Date: Thu, 31 Jan 2019 13:06:39 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz,
        Rik van Riel <riel@surriel.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com,
        Peter Zijlstra <peterz@infradead.org>,
        Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com,
        iamjoonsoo.kim@lge.com, treding@nvidia.com,
        Kees Cook <keescook@chromium.org>,
        Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de,
        hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie,
        oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com,
        Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
        Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org,
        linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org,
        linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org,
        iommu@lists.linux-foundation.org, linux-media@vger.kernel.org
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
 <20190131083842.GE28876@rapoport-lnx>
 <CAFqt6zbG089qCYBoZ8HCHPaRm+Yi=gHNboxy9y_qw9eVpSFjag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zbG089qCYBoZ8HCHPaRm+Yi=gHNboxy9y_qw9eVpSFjag@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19013111-0020-0000-0000-0000030F465E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013111-0021-0000-0000-000021604905
Message-Id: <20190131110638.GK28876@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 03:43:39PM +0530, Souptick Joarder wrote:
> On Thu, Jan 31, 2019 at 2:09 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > On Thu, Jan 31, 2019 at 08:38:12AM +0530, Souptick Joarder wrote:
> > > Previouly drivers have their own way of mapping range of
> > > kernel pages/memory into user vma and this was done by
> > > invoking vm_insert_page() within a loop.
> > >
> > > As this pattern is common across different drivers, it can
> > > be generalized by creating new functions and use it across
> > > the drivers.
> > >
> > > vm_insert_range() is the API which could be used to mapped
> > > kernel memory/pages in drivers which has considered vm_pgoff
> > >
> > > vm_insert_range_buggy() is the API which could be used to map
> > > range of kernel memory/pages in drivers which has not considered
> > > vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
> > >
> > > We _could_ then at a later "fix" these drivers which are using
> > > vm_insert_range_buggy() to behave according to the normal vm_pgoff
> > > offsetting simply by removing the _buggy suffix on the function
> > > name and if that causes regressions, it gives us an easy way to revert.
> > >
> > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > > Suggested-by: Russell King <linux@armlinux.org.uk>
> > > Suggested-by: Matthew Wilcox <willy@infradead.org>
> > > ---
> > >  include/linux/mm.h |  4 +++
> > >  mm/memory.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
> > >  mm/nommu.c         | 14 ++++++++++
> > >  3 files changed, 99 insertions(+)
> > >
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index 80bb640..25752b0 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -2565,6 +2565,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
> > >  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
> > >                       unsigned long pfn, unsigned long size, pgprot_t);
> > >  int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
> > > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > > +                             unsigned long num);
> > > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > > +                             unsigned long num);
> > >  vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> > >                       unsigned long pfn);
> > >  vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index e11ca9d..0a4bf57 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -1520,6 +1520,87 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
> > >  }
> > >  EXPORT_SYMBOL(vm_insert_page);
> > >
> > > +/**
> > > + * __vm_insert_range - insert range of kernel pages into user vma
> > > + * @vma: user vma to map to
> > > + * @pages: pointer to array of source kernel pages
> > > + * @num: number of pages in page array
> > > + * @offset: user's requested vm_pgoff
> > > + *
> > > + * This allows drivers to insert range of kernel pages they've allocated
> > > + * into a user vma.
> > > + *
> > > + * If we fail to insert any page into the vma, the function will return
> > > + * immediately leaving any previously inserted pages present.  Callers
> > > + * from the mmap handler may immediately return the error as their caller
> > > + * will destroy the vma, removing any successfully inserted pages. Other
> > > + * callers should make their own arrangements for calling unmap_region().
> > > + *
> > > + * Context: Process context.
> > > + * Return: 0 on success and error code otherwise.
> > > + */
> > > +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > > +                             unsigned long num, unsigned long offset)
> > > +{
> > > +     unsigned long count = vma_pages(vma);
> > > +     unsigned long uaddr = vma->vm_start;
> > > +     int ret, i;
> > > +
> > > +     /* Fail if the user requested offset is beyond the end of the object */
> > > +     if (offset > num)
> > > +             return -ENXIO;
> > > +
> > > +     /* Fail if the user requested size exceeds available object size */
> > > +     if (count > num - offset)
> > > +             return -ENXIO;
> > > +
> > > +     for (i = 0; i < count; i++) {
> > > +             ret = vm_insert_page(vma, uaddr, pages[offset + i]);
> > > +             if (ret < 0)
> > > +                     return ret;
> > > +             uaddr += PAGE_SIZE;
> > > +     }
> > > +
> > > +     return 0;
> > > +}
> > > +
> > > +/**
> > > + * vm_insert_range - insert range of kernel pages starts with non zero offset
> > > + * @vma: user vma to map to
> > > + * @pages: pointer to array of source kernel pages
> > > + * @num: number of pages in page array
> > > + *
> > > + * Maps an object consisting of `num' `pages', catering for the user's
> > > + * requested vm_pgoff
> > > + *
> >
> > The elaborate description you've added to __vm_insert_range() is better put
> > here, as this is the "public" function.
> 
> Ok, will add it in v3. Which means __vm_insert_range() still needs a short
> description ?

It won't hurt ;-)

> >
> > > + * Context: Process context. Called by mmap handlers.
> > > + * Return: 0 on success and error code otherwise.
> > > + */
> > > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > > +                             unsigned long num)
> > > +{
> > > +     return __vm_insert_range(vma, pages, num, vma->vm_pgoff);
> > > +}
> > > +EXPORT_SYMBOL(vm_insert_range);
> > > +
> > > +/**
> > > + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> > > + * @vma: user vma to map to
> > > + * @pages: pointer to array of source kernel pages
> > > + * @num: number of pages in page array
> > > + *
> > > + * Maps a set of pages, always starting at page[0]
> >
> > Here I'd add something like:
> >
> > Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to
> > 0. This function is intended for the drivers that did not consider
> > @vm_pgoff.
> 
> Ok.
> 
> >
> > > vm_insert_range_buggy() is the API which could be used to map
> > > range of kernel memory/pages in drivers which has not considered
> > > vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
> >
> > > + *
> > > + * Context: Process context. Called by mmap handlers.
> > > + * Return: 0 on success and error code otherwise.
> > > + */
> > > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > > +                             unsigned long num)
> > > +{
> > > +     return __vm_insert_range(vma, pages, num, 0);
> > > +}
> > > +EXPORT_SYMBOL(vm_insert_range_buggy);
> > > +
> > >  static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> > >                       pfn_t pfn, pgprot_t prot, bool mkwrite)
> > >  {
> > > diff --git a/mm/nommu.c b/mm/nommu.c
> > > index 749276b..21d101e 100644
> > > --- a/mm/nommu.c
> > > +++ b/mm/nommu.c
> > > @@ -473,6 +473,20 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
> > >  }
> > >  EXPORT_SYMBOL(vm_insert_page);
> > >
> > > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > > +                     unsigned long num)
> > > +{
> > > +     return -EINVAL;
> > > +}
> > > +EXPORT_SYMBOL(vm_insert_range);
> > > +
> > > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > > +                             unsigned long num)
> > > +{
> > > +     return -EINVAL;
> > > +}
> > > +EXPORT_SYMBOL(vm_insert_range_buggy);
> > > +
> > >  /*
> > >   *  sys_brk() for the most part doesn't need the global kernel
> > >   *  lock, except when an application is doing something nasty
> > > --
> > > 1.9.1
> > >
> >
> > --
> > Sincerely yours,
> > Mike.
> >
> 

-- 
Sincerely yours,
Mike.

