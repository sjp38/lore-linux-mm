Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F0D1C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A1112085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:07:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="j2Qp3PZj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A1112085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 620286B0005; Thu,  2 May 2019 02:07:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CF966B0006; Thu,  2 May 2019 02:07:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4993E6B0007; Thu,  2 May 2019 02:07:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D04F6B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:07:35 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id o13so606711otk.12
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:07:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+eUa2WBJtTifEb3RkGF9DZb4oB8mFlPtN9ka+3YCHXQ=;
        b=qbU5qF+lThpQ8+YJX8TSI3ViLqnbewSon9JfzEe6t5poS92U30dsMlhltYFUaXYn7f
         Eq7QXf0qbHDyV1dUU9bAdrhZIFzH2B4Hcj0jhsDx6F2A2j4Bq+R44/qD6JqTKvx+n0FP
         qj8K5Drkhv9Fb2BdSFI9Tj8Rc/J2HP5rYY55i5I7TzFtC5QJvdcRGF2uIj0aVSR8l/ya
         ZfuBTzqqcZXwDcuKRZHkk28RBQKBuBgL6a7lMZMq/Fx08O1p16/2jsSQwfSDHzg5lVx7
         O7uwh+BZZuL9j2mmpXxpRT6tI4NKNNNXjOlaxWWhRgFhLetOl5scLbQdZR6X1ciajnk4
         A6FQ==
X-Gm-Message-State: APjAAAVEVuVse4uCyQgCjEcwKS9gN64rtic0f8kajWqfeNmp4HPx13L+
	E+JaEV6I/MJVqybHHftZowd7Cd0jwPk10HF9lu0eWHSBhLjLr/BBfpjGhFkyEBXUBrdk6D4Q9Fi
	Jiuapg2/QEWPFVaXAIoS2HXXaWz55hwEdB4zY2KXcs4mWjjSRO8gZcZEw+oiWdi3zWQ==
X-Received: by 2002:a05:6830:8e:: with SMTP id a14mr1375929oto.260.1556777254750;
        Wed, 01 May 2019 23:07:34 -0700 (PDT)
X-Received: by 2002:a05:6830:8e:: with SMTP id a14mr1375882oto.260.1556777253542;
        Wed, 01 May 2019 23:07:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777253; cv=none;
        d=google.com; s=arc-20160816;
        b=VFzrl0VwnrKL+gvogS8u0sqd66ui4gzYXAIFjgvS+ogSwwq2ACTfkHeDaEstPfIvQ4
         a/uBaQKs3keQ7e/Ql2lBbw3wlV2b/Kf0okEIbb4F7FSxmngM1lcfyZB72hTwWNdJuS4y
         PbE1a/JCVafNkQ1/nlt9IFZ9cGC3vUP+iPcmUD8VAPdFXgSjR26qFaqd/I+ky+NZufQi
         MQLrwnk40DecTRadkqXeL6TOxNL2FjiUIU9rsKedrulYw04hhLyDyCiGyiURg4J5qVKh
         9DB81DY/rPLgX9ozMutlQuveJu5CBmFleX6KBlJ6OjcNHKmGah+yAmP/QmzLMr6ji9ZQ
         obJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+eUa2WBJtTifEb3RkGF9DZb4oB8mFlPtN9ka+3YCHXQ=;
        b=dpBwE63hISsunkWaaGUtiZiuv2K17+KxmV3f6u/Vq+4s5YaikBAZU8LeBSAdzdPqK5
         /5/zq1yLsNypKZ5XtX7Yt0re2HGs2jCUj7tpE50ZXqL8ivSnzS5mNJdjpPTKAH3tFap4
         P3NUG/79F4Vy/YacSYnHn5uJIoEpbWe0bq7WajWWTTB8DjJ5EzZvl5/4pTAF7UMrU2M9
         ooDd3QoCz1AXbJT9xV7dRmOfnGI5ybfVW19LcJGhOOOzLd6EFUXTvC5twIVItWqZxnMq
         LvDM0fe/gKJ9OXaUMO2mUCWaKUUokkHH0ZMqOBrtF3FP6vDjv9s7muDnki4I3iLAPmXh
         A9dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=j2Qp3PZj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4sor19162787otc.127.2019.05.01.23.07.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 23:07:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=j2Qp3PZj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+eUa2WBJtTifEb3RkGF9DZb4oB8mFlPtN9ka+3YCHXQ=;
        b=j2Qp3PZj0gAuSV09rXDWyVVdTgNPHV1NuRFvruWgIdSKimbJnOwIGC0fYBy5B5qoHJ
         Rrn1Db9TkutnPaxiErVY866vskShinsDhpr6Q1ojWBBuL55Bdt2rtZfuofkk6TzuXaYc
         fHoPj3YHxRK09nnIprBPHa76pyDTPTBXY4iusLJB1qS5eHRaqbZIhiiejETqGTj4LIQW
         AUQk+uBMSEzTJARjaMzAY1wHxa0JIuuyQCvwlwqKS0DPwQ+s4eEbB4H+z2MEe2H3bDFZ
         mjkGIfFMLLHa/uKpBIQLuDLN98DrEZL+dCtIfDZ8MQaPIRagyD/tOcYYTrfo8Uc7dgO7
         yOHQ==
X-Google-Smtp-Source: APXvYqyuasNHY2N4vYwpauHssWwpKgShtN9TAkBJGZaP4i4nxgI12gknIizrWWjBcJs5E5SwLyuWyjQNMx423OzBves=
X-Received: by 2002:a9d:19ed:: with SMTP id k100mr1396693otk.214.1556777252755;
 Wed, 01 May 2019 23:07:32 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634075.2015392.3371070426600230054.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190501232517.crbmgcuk7u4gvujr@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
In-Reply-To: <20190501232517.crbmgcuk7u4gvujr@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 1 May 2019 23:07:21 -0700
Message-ID: <CAPcyv4hxy86gWN3ncTQmHi8DT31k8YzsweMfGHgCh=sORMQQcg@mail.gmail.com>
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

On Wed, May 1, 2019 at 4:25 PM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
>
> On 19-04-17 11:39:00, Dan Williams wrote:
> > Towards enabling memory hotplug to track partial population of a
> > section, introduce 'struct mem_section_usage'.
> >
> > A pointer to a 'struct mem_section_usage' instance replaces the existing
> > pointer to a 'pageblock_flags' bitmap. Effectively it adds one more
> > 'unsigned long' beyond the 'pageblock_flags' (usemap) allocation to
> > house a new 'map_active' bitmap.  The new bitmap enables the memory
> > hot{plug,remove} implementation to act on incremental sub-divisions of a
> > section.
> >
> > The primary motivation for this functionality is to support platforms
> > that mix "System RAM" and "Persistent Memory" within a single section,
> > or multiple PMEM ranges with different mapping lifetimes within a single
> > section. The section restriction for hotplug has caused an ongoing saga
> > of hacks and bugs for devm_memremap_pages() users.
> >
> > Beyond the fixups to teach existing paths how to retrieve the 'usemap'
> > from a section, and updates to usemap allocation path, there are no
> > expected behavior changes.
> >
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  include/linux/mmzone.h |   23 ++++++++++++--
> >  mm/memory_hotplug.c    |   18 ++++++-----
> >  mm/page_alloc.c        |    2 +
> >  mm/sparse.c            |   81 ++++++++++++++++++++++++------------------------
> >  4 files changed, 71 insertions(+), 53 deletions(-)
> >
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 70394cabaf4e..f0bbd85dc19a 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -1160,6 +1160,19 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
> >  #define SECTION_ALIGN_UP(pfn)        (((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
> >  #define SECTION_ALIGN_DOWN(pfn)      ((pfn) & PAGE_SECTION_MASK)
> >
> > +#define SECTION_ACTIVE_SIZE ((1UL << SECTION_SIZE_BITS) / BITS_PER_LONG)
> > +#define SECTION_ACTIVE_MASK (~(SECTION_ACTIVE_SIZE - 1))
> > +
> > +struct mem_section_usage {
> > +     /*
> > +      * SECTION_ACTIVE_SIZE portions of the section that are populated in
> > +      * the memmap
> > +      */
> > +     unsigned long map_active;
>
> I think this should be proportional to section_size / subsection_size.
> For example, on intel section size = 128M, and subsection is 2M, so
> 64bits work nicely. But, on arm64 section size if 1G, so subsection is
> 16M.
>
> On the other hand 16M is already much better than what we have: with 1G
> section size and 2M pmem alignment we guaranteed to loose 1022M. And
> with 16M subsection it is only 14M.

I'm ok with it being 16M for now unless it causes a problem in
practice, i.e. something like the minimum hardware mapping alignment
for physical memory being less than 16M.

