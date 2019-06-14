Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5DDBC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:36:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 685782133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:36:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="xQp7xtj3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 685782133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E65A16B000A; Fri, 14 Jun 2019 12:36:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E15FC6B000C; Fri, 14 Jun 2019 12:36:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDE4E6B000E; Fri, 14 Jun 2019 12:36:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id A44186B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:36:45 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a21so1357058otk.17
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:36:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EvAQexBEPL7nJ/QjTH44i3lQXyubE+6SE92rMt2TZnA=;
        b=JdjiwJqGnuwFyeROEFamtsfUz5cSa/3TsDBW+LCHNA21vAnDlfnowMucW0NLFacEPV
         iRhwgzphK7nH56O0f8nAiELaovYoK69ZM5exmy63BQRvtTHMF9/JNXLvN7f8smR3iY9l
         u1Ced4vKzp7CWKFwr1lbjisCNUDx+rEIxEvj9lnaERkceSTvgswmOP1TvRkk+g7lVBIV
         EKge/rfOire4NJI+2VAeG6uiDH+F6HgvS+CJ3UntMgW2QELDejSuGTkKiXlSbP9dGQwi
         TBqxIfbELbTOfhZdkhhgTh8gU2KKsVyz2fYkc3uBFIlXIFPU/tmHlHCVbAVyODDrBlR6
         AwBQ==
X-Gm-Message-State: APjAAAU83PgWFnCrnVhVyRjNVGRH0IczHnJAur8zf2H4dIuieV5S0JWL
	3k2dJdwGF6s9AKCfDc+kfKYNarA4D36YWnbruAMkqlTNedC5UPW73743thsunNk49VrE7mQP7rB
	qgtg6+vm9WcPN/yJ8sOwya28A5IsEjq/aECh1VRuNRdWC+GtXQNcn807HTzwKLrJ/uQ==
X-Received: by 2002:a9d:66d0:: with SMTP id t16mr11878429otm.153.1560530205374;
        Fri, 14 Jun 2019 09:36:45 -0700 (PDT)
X-Received: by 2002:a9d:66d0:: with SMTP id t16mr11878377otm.153.1560530204603;
        Fri, 14 Jun 2019 09:36:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560530204; cv=none;
        d=google.com; s=arc-20160816;
        b=VNJKc9QBP10rM53X2dLDOYdVxPw5MnBrSRWga225grbtu+uFHZ+hqeyVmYbpwdb69s
         Pw5DSoao1Yl3NzvhMpbe+jqpGAkHDequxizXvZ0EkZg2rbvu0NFYwSqL+4erJjmpnLxa
         MsWV4npjZoIvT3Gb8aNDvqbjdp9OH4nuZ5fmA7aRoELs7bO/qUIV8JLg++i4Se1Jkjg/
         vXpTZ6tS80RCny+ohd4vE+Cr/n8yIOG0U8+Rfk4mfwqUyuWLezWu2aS2VZ+2HZOn2xmq
         BDa1k/5Jq8JlrxvpVRI+0a6aALH7nrlV+DHPpX688hD3DhtPk4I7llg9qb+s/rW08jry
         RO9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EvAQexBEPL7nJ/QjTH44i3lQXyubE+6SE92rMt2TZnA=;
        b=vmAL6UHp8KvaWHsYXzx9esaB/m34OgiLVn01ZI6Re1OtBKa9OD6DzHEhfZ6dT+k/tv
         km1EsQ002Kv8CP7IlKqwBO8YmmhEZ7gqWcLLmpfU7XAZP5XDoF7M1qEqn7+nEGw28CF3
         c4iGJXkGtS6YuuIzctnRwB0uQtxGyHGp4MDm7voqC3YJJMdeAlxtUOg3OEAEm+NQllrA
         HBk4+lYAUlAjbVmbYYC1xkB6/fzRW5A7jCrCoJXkMqK6ulkKbFfsAlQqx7iHO5kKimLQ
         xH7Mt9/UnDcEBFFxh3sAZvFPJmRnVfdrLCAtx+pzvwNwl+x6/It0bZwRAa8iVZWX3Bf/
         4YZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=xQp7xtj3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n132sor1393610oih.112.2019.06.14.09.36.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 09:36:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=xQp7xtj3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EvAQexBEPL7nJ/QjTH44i3lQXyubE+6SE92rMt2TZnA=;
        b=xQp7xtj36pghq2SegeVzV1Nb6Jx+8KWpSM1bivXSZruRDpGMoWRWchUkI0VOEoENxP
         XrHss5QzoD3JdjLKm/7fhMkySRU7ZKwukK//Icf268cwemrp8asrCuCmjX4Icr7gPuyX
         Q4RK0eY8EPnZdU8cWgEV/iGcuJKS6Ht5Yewp3ICmMddmKbsxCODaQZXWIFRjevkOZqeQ
         p2CCFO0UtUlJPR13efKardTCBubi+djaxfZjklcwiNhGsemJilUwKnqh4jff1ZLVr89Y
         I+5zddT/p6HMYozKqgwPkpeoH94ISqHDOGgnAKs+m9EoB/jWQAxr2nSwWuUfIq+6gQ32
         e8pQ==
X-Google-Smtp-Source: APXvYqyAFp/NcVwACgsoLfr51WnLFz4lRqOTM95kLcsTY/9X3NmHQmV8Cv5Yzn+oZgNE9ZWsnZXvHNBd8sB4Zn7N3lU=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr2315505oih.73.1560530204171;
 Fri, 14 Jun 2019 09:36:44 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <20190614153535.GA9900@linux> <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
 <CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com> <24fcb721-5d50-2c34-f44b-69281c8dd760@linux.ibm.com>
In-Reply-To: <24fcb721-5d50-2c34-f44b-69281c8dd760@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Jun 2019 09:36:33 -0700
Message-ID: <CAPcyv4ixq6aRQLdiMAUzQ-eDoA-hGbJQ6+_-K-nZzhXX70m1+g@mail.gmail.com>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Oscar Salvador <osalvador@suse.de>, Qian Cai <cai@lca.pw>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jmoyer <jmoyer@redhat.com>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 9:26 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> On 6/14/19 9:52 PM, Dan Williams wrote:
> > On Fri, Jun 14, 2019 at 9:18 AM Aneesh Kumar K.V
> > <aneesh.kumar@linux.ibm.com> wrote:
> >>
> >> On 6/14/19 9:05 PM, Oscar Salvador wrote:
> >>> On Fri, Jun 14, 2019 at 02:28:40PM +0530, Aneesh Kumar K.V wrote:
> >>>> Can you check with this change on ppc64.  I haven't reviewed this series yet.
> >>>> I did limited testing with change . Before merging this I need to go
> >>>> through the full series again. The vmemmap poplulate on ppc64 needs to
> >>>> handle two translation mode (hash and radix). With respect to vmemap
> >>>> hash doesn't setup a translation in the linux page table. Hence we need
> >>>> to make sure we don't try to setup a mapping for a range which is
> >>>> arleady convered by an existing mapping.
> >>>>
> >>>> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> >>>> index a4e17a979e45..15c342f0a543 100644
> >>>> --- a/arch/powerpc/mm/init_64.c
> >>>> +++ b/arch/powerpc/mm/init_64.c
> >>>> @@ -88,16 +88,23 @@ static unsigned long __meminit vmemmap_section_start(unsigned long page)
> >>>>     * which overlaps this vmemmap page is initialised then this page is
> >>>>     * initialised already.
> >>>>     */
> >>>> -static int __meminit vmemmap_populated(unsigned long start, int page_size)
> >>>> +static bool __meminit vmemmap_populated(unsigned long start, int page_size)
> >>>>    {
> >>>>       unsigned long end = start + page_size;
> >>>>       start = (unsigned long)(pfn_to_page(vmemmap_section_start(start)));
> >>>>
> >>>> -    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
> >>>> -            if (pfn_valid(page_to_pfn((struct page *)start)))
> >>>> -                    return 1;
> >>>> +    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page))) {
> >>>>
> >>>> -    return 0;
> >>>> +            struct mem_section *ms;
> >>>> +            unsigned long pfn = page_to_pfn((struct page *)start);
> >>>> +
> >>>> +            if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> >>>> +                    return 0;
> >>>
> >>> I might be missing something, but is this right?
> >>> Having a section_nr above NR_MEM_SECTIONS is invalid, but if we return 0 here,
> >>> vmemmap_populate will go on and populate it.
> >>
> >> I should drop that completely. We should not hit that condition at all.
> >> I will send a final patch once I go through the full patch series making
> >> sure we are not breaking any ppc64 details.
> >>
> >> Wondering why we did the below
> >>
> >> #if defined(ARCH_SUBSECTION_SHIFT)
> >> #define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
> >> #elif defined(PMD_SHIFT)
> >> #define SUBSECTION_SHIFT (PMD_SHIFT)
> >> #else
> >> /*
> >>    * Memory hotplug enabled platforms avoid this default because they
> >>    * either define ARCH_SUBSECTION_SHIFT, or PMD_SHIFT is a constant, but
> >>    * this is kept as a backstop to allow compilation on
> >>    * !ARCH_ENABLE_MEMORY_HOTPLUG archs.
> >>    */
> >> #define SUBSECTION_SHIFT 21
> >> #endif
> >>
> >> why not
> >>
> >> #if defined(ARCH_SUBSECTION_SHIFT)
> >> #define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
> >> #else
> >> #define SUBSECTION_SHIFT  SECTION_SHIFT
>
> That should be SECTION_SIZE_SHIFT
>
> >> #endif
> >>
> >> ie, if SUBSECTION is not supported by arch we have one sub-section per
> >> section?
> >
> > A couple comments:
> >
> > The only reason ARCH_SUBSECTION_SHIFT exists is because PMD_SHIFT on
> > PowerPC was a non-constant value. However, I'm planning to remove the
> > distinction in the next rev of the patches. Jeff rightly points out
> > that having a variable subsection size per arch will lead to
> > situations where persistent memory namespaces are not portable across
> > archs. So I plan to just make SUBSECTION_SHIFT 21 everywhere.
> >
>
>
> persistent memory namespaces are not portable across archs because they
> have PAGE_SIZE dependency.

We can fix that by reserving mem_map capacity assuming the smallest
PAGE_SIZE across archs.

> Then we have dependencies like the page size
> with which we map the vmemmap area.

How does that lead to cross-arch incompatibility? Even on a single
arch the vmemmap area will be mapped with 2MB pages for 128MB aligned
spans of pmem address space and 4K pages for subsections.

> Why not let the arch
> arch decide the SUBSECTION_SHIFT and default to one subsection per
> section if arch is not enabled to work with subsection.

Because that keeps the implementation from ever reaching a point where
a namespace might be able to be moved from one arch to another. If we
can squash these arch differences then we can have a common tool to
initialize namespaces outside of the kernel. The one wrinkle is
device-dax that wants to enforce the mapping size, but I think we can
have a module-option compatibility override for that case for the
admin to say "yes, I know this namespace is defined for 2MB x86 pages,
but I want to force enable it with 64K pages on PowerPC"

