Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57DB7C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:48:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 096B9217F9
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:48:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="FkyVO0/z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 096B9217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9681F6B0003; Fri, 14 Jun 2019 15:48:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 919456B0006; Fri, 14 Jun 2019 15:48:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 806D16B0007; Fri, 14 Jun 2019 15:48:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 559C06B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 15:48:41 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id a198so1299522oii.15
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:48:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=61N/lm8CJKTJGE2ZrsEMbNnmq9p1swuX2Cc2kuVqmK8=;
        b=b23yr2cNUQ7lfn1Z9t2gLhy6DRM7SEoxYtdBv6olzbrcxY/9VMaGp5iHWBNEyzamBu
         rIAvwt9h6QWHqEOres/2/UZkUezabrJkVokBQxh4eNRoNlop6FzGDyNtEKURoyikh569
         4nwTM5JnLeoBEVIIR6EyrefTTV7C3CSa+7Bz9s9WgzmLixNas6DfJDXgqp1JfIu6hjPQ
         2EPpfafXdHV1i0jKy9yuczS9NABDR17jQ2SL9ZSVD1NDqplHgYQMTDZ8yv4kk9TjwqPW
         K8S89dS4/F5DimtyFqP3NJx/McCp17IWh7uL8mIhyN6lg85mEBvNPTLquzpayae+0S7G
         /gzw==
X-Gm-Message-State: APjAAAWRGONW846FQeMQR1fGJ2d/Ny7C7BCc80ux23/+vR+Wo5NCkpl8
	nnXFrx+UwH5RsFn874OtPla+HRoagRlp9xM/x6VVJC8HMpDQDbwYm6Vllu5NB5lGmawFIAqDwYp
	eD0Fd0w9a9mwEd7KHGo1bhRPBzqJCmbhKVqzq//dbE26cfuOi6VXbbNc+2ie8C8vw5Q==
X-Received: by 2002:a9d:151:: with SMTP id 75mr19441342otu.202.1560541720899;
        Fri, 14 Jun 2019 12:48:40 -0700 (PDT)
X-Received: by 2002:a9d:151:: with SMTP id 75mr19441312otu.202.1560541720233;
        Fri, 14 Jun 2019 12:48:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560541720; cv=none;
        d=google.com; s=arc-20160816;
        b=o1Mx84KZeYc6gQZGz99yXCz3lVnh/mjIVnl+QDlLeH/cbrTS4LCjnqplGu+JT863s/
         mshKzPSEV8VLNc/vNAhF+7vjHuv3kp9GHY4Y1EdXQQnbDhAUNJI1fYPhkGXubo82hL0e
         FXSs4Meu32VWGYlkP3O/vhTxNcEDaW9GmSSrg8W+jIdziHFlA8LyqVAVUPM7H2mU1wFb
         TeFo3dtQJjRUdVNNyJQBDtXK59cYyONIkJ+STEGXhkk5HB5vpkU6Q+559v7mvpNufm8u
         D1Imk/ZAjYPvb6FEB2ExBIewHAX395S0IjeYt0o/Ndot4LBksqOLl9VzZ2/wQRGZhySS
         rzCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=61N/lm8CJKTJGE2ZrsEMbNnmq9p1swuX2Cc2kuVqmK8=;
        b=wuCDovoMekZKF/xNheIJWyfipLQsGUy6STkkoVMvNqqQ/1Cm06BhisXGl2NTjIPgfd
         XZbD8vkOTNwkKUXvir6J2JGmUB5wx1ZDBbDkj5Q+R2AZxPCv1QmlbkU5mHkTIaXVmtw+
         EJxC+ovsgG2ngX85nE8HGdiBxwlWtk3LfyOBzwDb9Wr6Ckikx24rXmURqxBfP73cWw68
         nwG1PjirGrmIAesYnnFbcUrmVUv4rl0CLBAFWj8uWWLd52QG+eBMWWezOidFbScxec5k
         R1PX7LaG0MZuHndgWTsruhPkvygRF1Njkh2okQ0V0P2u3Xsz2XbThycyar2QVmPoUPxu
         +omQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="FkyVO0/z";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 64sor1694479oih.55.2019.06.14.12.48.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 12:48:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="FkyVO0/z";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=61N/lm8CJKTJGE2ZrsEMbNnmq9p1swuX2Cc2kuVqmK8=;
        b=FkyVO0/zxJj7vYBynZj+RIa1WrMzTm1kia7hToc7/9jsjNszIC0OOdDSt2e9GHbjRz
         Gv0Bs1rJpU7trCLwdhaf9yMStHmacLc5JnN8JWOSeCMyzLxgW65lshrlwNJvPld7U6Ei
         Zk24vw19PFp4OglBzQE23UfJUaeiv8tF4pTAY2HOyDRl5FLetj2EMGCcz8qCWWyyu/oM
         m2Q1AICd30U3T3NJ5AJyRoK8JudPBoTH11TK4SWuTco7hupEHFBHS8HNeOlhL7+dkNCE
         y1kWeugS2SEaANrIVnohRfowPKks1IAeQN/iQZr2VHAwY1agNYzQG1lvOhM9Cu3R/G/t
         0OcA==
X-Google-Smtp-Source: APXvYqw/kAqgUWUW+2xtCZNhueHvHq1j8kWOltLUnweDmTpt47mRKoU2MLB3pvG8YOS9WHmt2Lp8IhU5Cp+Gcd0Upwc=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr2806919oih.73.1560541719689;
 Fri, 14 Jun 2019 12:48:39 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <1560524365.5154.21.camel@lca.pw> <CAPcyv4jAzMzFjSD22VU9Csw+kgGbf8r=XHbdJYzgL_uH_GVEvw@mail.gmail.com>
 <CAPcyv4hjvBPDYKpp2Gns3-cc2AQ0AVS1nLk-K3fwXeRUvvzQLg@mail.gmail.com> <1560541220.5154.23.camel@lca.pw>
In-Reply-To: <1560541220.5154.23.camel@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Jun 2019 12:48:28 -0700
Message-ID: <CAPcyv4i5iUop_H-Ai4q_hn2-3L6aRuovY44tuV50bp1oZj29TQ@mail.gmail.com>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Qian Cai <cai@lca.pw>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Oscar Salvador <osalvador@suse.de>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 12:40 PM Qian Cai <cai@lca.pw> wrote:
>
> On Fri, 2019-06-14 at 11:57 -0700, Dan Williams wrote:
> > On Fri, Jun 14, 2019 at 11:03 AM Dan Williams <dan.j.williams@intel.com>
> > wrote:
> > >
> > > On Fri, Jun 14, 2019 at 7:59 AM Qian Cai <cai@lca.pw> wrote:
> > > >
> > > > On Fri, 2019-06-14 at 14:28 +0530, Aneesh Kumar K.V wrote:
> > > > > Qian Cai <cai@lca.pw> writes:
> > > > >
> > > > >
> > > > > > 1) offline is busted [1]. It looks like test_pages_in_a_zone() missed
> > > > > > the
> > > > > > same
> > > > > > pfn_section_valid() check.
> > > > > >
> > > > > > 2) powerpc booting is generating endless warnings [2]. In
> > > > > > vmemmap_populated() at
> > > > > > arch/powerpc/mm/init_64.c, I tried to change PAGES_PER_SECTION to
> > > > > > PAGES_PER_SUBSECTION, but it alone seems not enough.
> > > > > >
> > > > >
> > > > > Can you check with this change on ppc64.  I haven't reviewed this series
> > > > > yet.
> > > > > I did limited testing with change . Before merging this I need to go
> > > > > through the full series again. The vmemmap poplulate on ppc64 needs to
> > > > > handle two translation mode (hash and radix). With respect to vmemap
> > > > > hash doesn't setup a translation in the linux page table. Hence we need
> > > > > to make sure we don't try to setup a mapping for a range which is
> > > > > arleady convered by an existing mapping.
> > > >
> > > > It works fine.
> > >
> > > Strange... it would only change behavior if valid_section() is true
> > > when pfn_valid() is not or vice versa. They "should" be identical
> > > because subsection-size == section-size on PowerPC, at least with the
> > > current definition of SUBSECTION_SHIFT. I suspect maybe
> > > free_area_init_nodes() is too late to call subsection_map_init() for
> > > PowerPC.
> >
> > Can you give the attached incremental patch a try? This will break
> > support for doing sub-section hot-add in a section that was only
> > partially populated early at init, but that can be repaired later in
> > the series. First things first, don't regress.
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 874eb22d22e4..520c83aa0fec 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7286,12 +7286,10 @@ void __init free_area_init_nodes(unsigned long
> > *max_zone_pfn)
> >
> >         /* Print out the early node map */
> >         pr_info("Early memory node ranges\n");
> > -       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
> > +       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
> >                 pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
> >                         (u64)start_pfn << PAGE_SHIFT,
> >                         ((u64)end_pfn << PAGE_SHIFT) - 1);
> > -               subsection_map_init(start_pfn, end_pfn - start_pfn);
> > -       }
> >
> >         /* Initialise every node */
> >         mminit_verify_pageflags_layout();
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 0baa2e55cfdd..bca8e6fa72d2 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -533,6 +533,7 @@ static void __init sparse_init_nid(int nid,
> > unsigned long pnum_begin,
> >                 }
> >                 check_usemap_section_nr(nid, usage);
> >                 sparse_init_one_section(__nr_to_section(pnum), pnum,
> > map, usage);
> > +               subsection_map_init(section_nr_to_pfn(pnum),
> > PAGES_PER_SECTION);
> >                 usage = (void *) usage + mem_section_usage_size();
> >         }
> >         sparse_buffer_fini();
>
> It works fine except it starts to trigger slab debugging errors during boot. Not
> sure if it is related yet.

If you want you can give this branch a try if you suspect something
else in -next is triggering the slab warning.

https://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git/log/?h=subsection-v9

It's the original v9 patchset + dependencies backported to v5.2-rc4.

I otherwise don't see how subsections would effect slab caches.

