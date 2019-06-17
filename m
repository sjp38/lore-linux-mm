Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5923AC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:35:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1334F2084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:35:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="YprNyBwc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1334F2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BC958E0002; Mon, 17 Jun 2019 13:35:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 845338E0001; Mon, 17 Jun 2019 13:35:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E6198E0002; Mon, 17 Jun 2019 13:35:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFC58E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:35:16 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n19so5182751ota.14
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:35:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+m6hj6kR6+t7FFgSRKaK1PbX93Vf69qhd80YwAUvJfY=;
        b=lFvWFq/eoYiH78Sltlb7v6vyxTibmA6Ni6zQ7isuvg/xzPl6rxQp7QWWOxmRGClpCx
         /nBJEyzD+ObV8mCnObdwfSDu7owUEmuF6XGc+z5TXRREdMX1wQPXM+5G5GMPo8kms3Yz
         rDGJO1VrPPy5mGQ2i1yCMZGA7+Z5Z1XG7TeblyjcgUfy+8xSelXvjddr0BWsP6b/+801
         QJs5KNCIN9+/j8pxZ50qatGOSxwvKeeBbFv5QMmEP8kf5pDFhOpAY1AUXF8Z023X7VvA
         Fk3rUdj4Q1G3dtWNCeSYWnCh2QK0bhkx93ULEH/KJwKr5UvHrM8IKi/BKu9AXr8IZg7E
         0Vlw==
X-Gm-Message-State: APjAAAXtAp+CdUTUts1sKg9JsIxUav4hkCKVWtMRpYbhF6SBdBQ+2ugH
	J0PI+vHy8zOJ5V10fKfBvUSr/JsJ8bULIYurKUtnqNaSYOcpGK0r2y7pTxufERpePtSGUF+dqkI
	HGL6YJofpjfOIs6nMgTX0AbKXgSQWsP+5OvtWrSJ8VxTPPCBOzftAAPLogUygD2W1AA==
X-Received: by 2002:a05:6830:1042:: with SMTP id b2mr21854274otp.345.1560792915668;
        Mon, 17 Jun 2019 10:35:15 -0700 (PDT)
X-Received: by 2002:a05:6830:1042:: with SMTP id b2mr21820662otp.345.1560792113315;
        Mon, 17 Jun 2019 10:21:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560792113; cv=none;
        d=google.com; s=arc-20160816;
        b=Fq0NctD5a1uHrJXQKqzUy+7YEx/8wcQaB5mQX7cVuo+lQ5SlsHHxC4EmGEJwjq4oOF
         gDht3XVsugwgaiRTa4GGDZ4Eb3l5xeF74zCPziInX5xG67x507mG7CTXD+a+6NGMtYA2
         HzE+lXmxRDv70qbCkmYIpILvjxQ/s4Mg3FgGA7CURM8zSq4OyQbD58qeTAQjJGoQ3CTF
         vAFeSv+Qg8CEurdyxqb2TZekk21P6MR0Oy1jwH3vcFlH3Snbp49FmaBXFJtkuV+WOxx5
         0X47B71/Btdh5BI1+5jFvaDNyeCAAX+oqqNtgiu9ypFBmx29swqNo4ntcSHsg62/INb5
         9uGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+m6hj6kR6+t7FFgSRKaK1PbX93Vf69qhd80YwAUvJfY=;
        b=JxRVMyj5hEoBNiEIimpx77ebmTrK+5F1A12xuP5NTz52YdkioiXmjFrlQ3ABqVllVL
         nW6QmWLCiDYhElpnOAxlzir7qHSPYag/cSVx90lmnqy21/lkCtZS+cXWnsWzbxc5jN3i
         dmNodt49rBl1y7EDNp/bna1hpVXM6UcT6q3HIsCQOznL5edIe7fOzQd1rhORbx3Eapo7
         +Jma1/PgGT7cJ3MLZvMzFpTGSpG7piMVaOT6cGun7yJpvXBGu/CliZniDQTmVIOdvaWz
         g+JT8qxcjnlro3FBtsIgwshX/LiUkMmQS9fBHSO/exsG9/LQEvhI0bpgTE0dxtGnFs3c
         WmSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YprNyBwc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h67sor4858619oia.130.2019.06.17.10.21.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 10:21:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YprNyBwc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+m6hj6kR6+t7FFgSRKaK1PbX93Vf69qhd80YwAUvJfY=;
        b=YprNyBwcuU7peH69ojyfcOHSG09vpn+WCDMlzGVZX7krGOxzA38q9jGCAuVJ3u8dUl
         ARp0m4eM7XcX/eR8V6wFea0PHqsk2ILlfA4J8C3DcOEQ3mE+O51E01kszOwKzLuws2fF
         6Igv5nh+vDV7XP9ueQ61ixTl17AHI6MdkwZpji/iK30Tn5OzQgi5Xx2TA38yrkdJrsR1
         odxVF85VzukYawtRFMrPqVrmXrKlQ6HrdV+m99XuDdcrRABsCDi421y5SB7YP4Kn0iqZ
         FZRt9w+dmb+eOjEHfy4knKFlViuuM33mdh1Zzdp5EHs3I45SN1TMzM8K80BnPc4E7ZZb
         kqCQ==
X-Google-Smtp-Source: APXvYqwVgRIrtHtXnTOpaGBVuVulNLYZy1sN1k1Po68BpCrKXTxlXWFQxhkbz94oC9uvIpMV9vHTUh/5w12QpAh0JY0=
X-Received: by 2002:aca:1304:: with SMTP id e4mr11244312oii.149.1560792112232;
 Mon, 17 Jun 2019 10:21:52 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <20190614153535.GA9900@linux> <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
 <CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com> <87imt6i3zd.fsf@linux.ibm.com>
In-Reply-To: <87imt6i3zd.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Jun 2019 10:21:40 -0700
Message-ID: <CAPcyv4gKPBuZ_1=YRGpQb0hzgf_-PFdkgTgh1nHS_iAxbJ-MCg@mail.gmail.com>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Oscar Salvador <osalvador@suse.de>, Qian Cai <cai@lca.pw>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jmoyer <jmoyer@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 8:50 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> > On Fri, Jun 14, 2019 at 9:18 AM Aneesh Kumar K.V
> > <aneesh.kumar@linux.ibm.com> wrote:
> >>
> >> On 6/14/19 9:05 PM, Oscar Salvador wrote:
> >> > On Fri, Jun 14, 2019 at 02:28:40PM +0530, Aneesh Kumar K.V wrote:
> >> >> Can you check with this change on ppc64.  I haven't reviewed this series yet.
> >> >> I did limited testing with change . Before merging this I need to go
> >> >> through the full series again. The vmemmap poplulate on ppc64 needs to
> >> >> handle two translation mode (hash and radix). With respect to vmemap
> >> >> hash doesn't setup a translation in the linux page table. Hence we need
> >> >> to make sure we don't try to setup a mapping for a range which is
> >> >> arleady convered by an existing mapping.
> >> >>
> >> >> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> >> >> index a4e17a979e45..15c342f0a543 100644
> >> >> --- a/arch/powerpc/mm/init_64.c
> >> >> +++ b/arch/powerpc/mm/init_64.c
> >> >> @@ -88,16 +88,23 @@ static unsigned long __meminit vmemmap_section_start(unsigned long page)
> >> >>    * which overlaps this vmemmap page is initialised then this page is
> >> >>    * initialised already.
> >> >>    */
> >> >> -static int __meminit vmemmap_populated(unsigned long start, int page_size)
> >> >> +static bool __meminit vmemmap_populated(unsigned long start, int page_size)
> >> >>   {
> >> >>      unsigned long end = start + page_size;
> >> >>      start = (unsigned long)(pfn_to_page(vmemmap_section_start(start)));
> >> >>
> >> >> -    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
> >> >> -            if (pfn_valid(page_to_pfn((struct page *)start)))
> >> >> -                    return 1;
> >> >> +    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page))) {
> >> >>
> >> >> -    return 0;
> >> >> +            struct mem_section *ms;
> >> >> +            unsigned long pfn = page_to_pfn((struct page *)start);
> >> >> +
> >> >> +            if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> >> >> +                    return 0;
> >> >
> >> > I might be missing something, but is this right?
> >> > Having a section_nr above NR_MEM_SECTIONS is invalid, but if we return 0 here,
> >> > vmemmap_populate will go on and populate it.
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
> >>   * Memory hotplug enabled platforms avoid this default because they
> >>   * either define ARCH_SUBSECTION_SHIFT, or PMD_SHIFT is a constant, but
> >>   * this is kept as a backstop to allow compilation on
> >>   * !ARCH_ENABLE_MEMORY_HOTPLUG archs.
> >>   */
> >> #define SUBSECTION_SHIFT 21
> >> #endif
> >>
> >> why not
> >>
> >> #if defined(ARCH_SUBSECTION_SHIFT)
> >> #define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
> >> #else
> >> #define SUBSECTION_SHIFT  SECTION_SHIFT
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
>
> What is the dependency between subsection and pageblock_order? Shouldn't
> subsection size >= pageblock size?
>
> We do have pageblock size drived from HugeTLB size.

The pageblock size is independent of subsection-size. The pageblock
size is a page-allocator concern, subsections only exist for pages
that are never onlined to the page-allocator.

