Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B32E9C04AAA
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 00:22:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6400E2081C
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 00:22:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="vCaTJVpf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6400E2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFA536B0003; Fri,  3 May 2019 20:22:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DABAE6B0006; Fri,  3 May 2019 20:22:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C74946B0007; Fri,  3 May 2019 20:22:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3AE6B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 20:22:36 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id q15so3501296otl.8
        for <linux-mm@kvack.org>; Fri, 03 May 2019 17:22:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=P2GLzP+mIPWDKsZ2J8CpfXaoOt0+K7Q0KkqhqHG4CQc=;
        b=pwzi3OPL1KNwfKNv0VV925H6fK5PFiSgDgZI7wP1ipKNEWxy3KM3E6bgv998D809S4
         xqpXtecLpqGM6hV4p3076mBs7A1++7S6wDN68Q6qosUBMToTLL4Stxg2ecuu06yQK6JO
         G7+Z6Zov8hayZjGfYvM21uR5gi+wTc7wBqA6mBhGaitGkzPH7hHXguw4odqoUnlWZwOw
         efIK47aqvXbcVOIAb8ebnBz0+wsDoLKz/2lch5eEAAcfhcB2eD+ckzrGLgVJR3nBaV3e
         oa2DMyuZDq+4cIe7o/ogahcbyD+LrACJ3iedo42At7MY4/r8QYLssJCK+CcbfwnADawR
         JS1g==
X-Gm-Message-State: APjAAAXUO7yjIu3CPPhLh7qQ8c1KkJMNuSGmSYkGn+BFb4YB7PdfYzR0
	WLkz+Jkzp5lnvyIDG8HB6MQtf8SJKc6kb+UqkGwulldlVm1XOHHedP/fzCCk6uXmU2xdwNVhbXa
	AyXgbYQjklxv9onykSfJBrtbztyKcjGq/ehGm55s5/eC3mw9TuRe8a+rUNfTDg+cd7w==
X-Received: by 2002:a9d:3621:: with SMTP id w30mr8379222otb.98.1556929356218;
        Fri, 03 May 2019 17:22:36 -0700 (PDT)
X-Received: by 2002:a9d:3621:: with SMTP id w30mr8379190otb.98.1556929355226;
        Fri, 03 May 2019 17:22:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556929355; cv=none;
        d=google.com; s=arc-20160816;
        b=lkVHPRi2HawPbmrpEvN7K+Y0yXbE1fkYLTRxjrKCbVlXkX/HD3d1tzD9DQN72FVoq1
         NJh19Qt0EPnt19ywpbGcG8thSuqTkk2muF3xKTJma29MrtNR4f60SvtCZOoPI8+P6ZqF
         84/ZHkSK/jtk8Z4LME4euEA9/yPXEO4WUAASzQZUezrOIv6BjDRLuyJ3bpfeoEpNUa58
         y8GMzVqAkWUI8gu5qTy4+rnGEUvmVkC5njYtR8eGGIz7GtDNjHCzf3WF+7V0yWvhIfAX
         PKx57HZ1UBFgN7XJu//XSjRSZjuapkaLCvY5zKw9z3YPg2c/jNUnv2TX2onpBG6TECe3
         s69g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=P2GLzP+mIPWDKsZ2J8CpfXaoOt0+K7Q0KkqhqHG4CQc=;
        b=LVxXPGlB0+cNYHUoOKEK6VIvqrl12unRygLtzEgYXkR0NavQRBISfXkcx0T7Mgd4bk
         tIVjILMRDMwlb7RTNERFl0gTPnurSl1eiv2P6LNNmFvPXRk68em2zJOsdepjcWA0EISF
         Fy3oOMgUhyqbzrpo5+fR9Dvox7MOCQ/IDXQkb3MaLA/5JADl/67+P8RmwjuKjC2uxN8c
         SNIcBSFa2Ell81Xdl7y9+VnOqXk47N45p2Y3ZgFisTX1RqHrIleHo/ZvlgNIRDDvyRE/
         KnhjEzcsOycurSLm9omftnazFNunbv5vJcyAf/IMrwD5iZv99KQy4sXB83tfPZ1GV7hh
         b8+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=vCaTJVpf;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k17sor1817543otl.54.2019.05.03.17.22.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 May 2019 17:22:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=vCaTJVpf;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=P2GLzP+mIPWDKsZ2J8CpfXaoOt0+K7Q0KkqhqHG4CQc=;
        b=vCaTJVpfuYZulF2lvGYTlcwKbV4bHIuldvUdxOqs+uH+ZWUG8MHCqU5LYRU4Ii5WsS
         PDEi1Bnr5u7uVLSxwEHBcH9FcPgYoz9Zrqra3zoo3B3CV5rf1+xPBXBNtymFu8jTtI2b
         4t2wu2eKaV7ho3Zf63LxX2I8ETXX16rERV2zGWVqTQO/gyE/IpH1gehvfpn1PuaZ9XQ2
         nmeLDeeeVTfbVR8/sYJ645rjgSmbfdxHU+oB6gDOf5ZuLEJW+SGhXPmQQNsK5GI6X0Ln
         ByAdVXtAjKqekszhk+thuc6BqPOtKacnBhw35lG5RNxfap33IOANS8l1kbF1doUDWmMd
         3bmA==
X-Google-Smtp-Source: APXvYqxdVipoa5z31EifFG5ifrC68H+QnObLfr0ceemkguKFFrj+suFsJQfhR6Tx4LZgszvoXiMNhHCc5XuKsKhoJxk=
X-Received: by 2002:a9d:5cc1:: with SMTP id r1mr6880612oti.229.1556929354326;
 Fri, 03 May 2019 17:22:34 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634075.2015392.3371070426600230054.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190501232517.crbmgcuk7u4gvujr@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAPcyv4hxy86gWN3ncTQmHi8DT31k8YzsweMfGHgCh=sORMQQcg@mail.gmail.com>
In-Reply-To: <CAPcyv4hxy86gWN3ncTQmHi8DT31k8YzsweMfGHgCh=sORMQQcg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 3 May 2019 17:22:23 -0700
Message-ID: <CAPcyv4hAh-Joe3Pt0r5CPSaWpZ4YoNF2jNDcvbMF2fsQm7Hetg@mail.gmail.com>
Subject: Re: [PATCH v6 01/12] mm/sparsemem: Introduce struct mem_section_usage
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 1, 2019 at 11:07 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Wed, May 1, 2019 at 4:25 PM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
> >
> > On 19-04-17 11:39:00, Dan Williams wrote:
> > > Towards enabling memory hotplug to track partial population of a
> > > section, introduce 'struct mem_section_usage'.
> > >
> > > A pointer to a 'struct mem_section_usage' instance replaces the existing
> > > pointer to a 'pageblock_flags' bitmap. Effectively it adds one more
> > > 'unsigned long' beyond the 'pageblock_flags' (usemap) allocation to
> > > house a new 'map_active' bitmap.  The new bitmap enables the memory
> > > hot{plug,remove} implementation to act on incremental sub-divisions of a
> > > section.
> > >
> > > The primary motivation for this functionality is to support platforms
> > > that mix "System RAM" and "Persistent Memory" within a single section,
> > > or multiple PMEM ranges with different mapping lifetimes within a single
> > > section. The section restriction for hotplug has caused an ongoing saga
> > > of hacks and bugs for devm_memremap_pages() users.
> > >
> > > Beyond the fixups to teach existing paths how to retrieve the 'usemap'
> > > from a section, and updates to usemap allocation path, there are no
> > > expected behavior changes.
> > >
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Vlastimil Babka <vbabka@suse.cz>
> > > Cc: Logan Gunthorpe <logang@deltatee.com>
> > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > > ---
> > >  include/linux/mmzone.h |   23 ++++++++++++--
> > >  mm/memory_hotplug.c    |   18 ++++++-----
> > >  mm/page_alloc.c        |    2 +
> > >  mm/sparse.c            |   81 ++++++++++++++++++++++++------------------------
> > >  4 files changed, 71 insertions(+), 53 deletions(-)
> > >
> > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > index 70394cabaf4e..f0bbd85dc19a 100644
> > > --- a/include/linux/mmzone.h
> > > +++ b/include/linux/mmzone.h
> > > @@ -1160,6 +1160,19 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
> > >  #define SECTION_ALIGN_UP(pfn)        (((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
> > >  #define SECTION_ALIGN_DOWN(pfn)      ((pfn) & PAGE_SECTION_MASK)
> > >
> > > +#define SECTION_ACTIVE_SIZE ((1UL << SECTION_SIZE_BITS) / BITS_PER_LONG)
> > > +#define SECTION_ACTIVE_MASK (~(SECTION_ACTIVE_SIZE - 1))
> > > +
> > > +struct mem_section_usage {
> > > +     /*
> > > +      * SECTION_ACTIVE_SIZE portions of the section that are populated in
> > > +      * the memmap
> > > +      */
> > > +     unsigned long map_active;
> >
> > I think this should be proportional to section_size / subsection_size.
> > For example, on intel section size = 128M, and subsection is 2M, so
> > 64bits work nicely. But, on arm64 section size if 1G, so subsection is
> > 16M.
> >
> > On the other hand 16M is already much better than what we have: with 1G
> > section size and 2M pmem alignment we guaranteed to loose 1022M. And
> > with 16M subsection it is only 14M.
>
> I'm ok with it being 16M for now unless it causes a problem in
> practice, i.e. something like the minimum hardware mapping alignment
> for physical memory being less than 16M.

On second thought, arbitrary differences across architectures is a bit
sad. The most common nvdimm namespace alignment granularity is
PMD_SIZE, so perhaps the default sub-section size should try to match
that default.

