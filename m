Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A87EEC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:22:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D3182063F
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:22:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Pf/t4wPN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D3182063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 066B66B000A; Fri, 14 Jun 2019 12:22:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0165F6B000D; Fri, 14 Jun 2019 12:22:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E21F76B000E; Fri, 14 Jun 2019 12:22:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA6386B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:22:41 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id b4so1348791otf.15
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:22:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yUJ36e2jf7ofvUZMfMQksFI5zeohGaN69gBiudrs7ZQ=;
        b=ZVRb53YzM9RNti+LuJHeN8rwMhLKltYIbAOVEsJYz1vxepiBrDrBhV5vG42yKxElvI
         JLKY00TdcUE5ignoWhR/ejMQP2YSfYaxJ2Z4xPjfIpcZyhHBsUNn9Z0wc3PYfHUoP8l4
         5/EEZHGf03/F+GPt5utdIaCNH/W4j8j/Gq/OxVAjO/TYjjqgVOefG6JwIGlkpYu2v4Gf
         AkxbcZaF43RyLODwKxxjPJvywPDOjmD4nqfehBRRaZFNAXFpP7CB7UWM9Fjw6GPb20m0
         oC4ov2u0UqUfUwTY9X/JAVwIQogt+uYyqxTH/eGt31aipYcx3lib+nMSLp3YhP7er42E
         7qQA==
X-Gm-Message-State: APjAAAUGA32wag8kD7YeMdHRZ+nFDio3OE5rv2UwVnaxUUK7+a3NVDBU
	jqL4HWBCOt3GoI+ASdKyHrbBng6f1t+1l3p7vVix7sdSygvhpd/STCbKqgKcFS8gaWMGLF2X3Zh
	4i00erSjpk410cUX0eytk2SnGmPwQ2Y3cXLOZIuZ7oGT+pYESvcruaLmsaCGGwCVvrg==
X-Received: by 2002:a9d:d4e:: with SMTP id 72mr32931063oti.259.1560529361467;
        Fri, 14 Jun 2019 09:22:41 -0700 (PDT)
X-Received: by 2002:a9d:d4e:: with SMTP id 72mr32931014oti.259.1560529360750;
        Fri, 14 Jun 2019 09:22:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560529360; cv=none;
        d=google.com; s=arc-20160816;
        b=UitAZeN7jd91RIKxWgneP6a4ljb4q2F3Dsa68p52EIqcrH1g1C/DW99OK9ef20Uk7z
         kyl8TwepiuyXegZ2G6KsqF0ExSldYvKOvZ+wb0MMjZQ8M7Rd55QAZjTyYNaetsaBCLhF
         9K7xnZb8PSoBdLxmY0iOst4Ac9lOjOeCYo3yeDGjuRUTLlZMTUJx7RV0FxUD+zx8eyR/
         X7UYXwRov4CtHEa9qkAWJGQTbWezHbefXjmNKX49jvDP3rlVkMnDcJfYN+/yN+9sk/7U
         MZYpuuWQioNwNulLl+lmaCrVS7MAQ7wgt60TTfTICZD6R/XtI6Pu4wWISxPLHwkN3r8b
         FB6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yUJ36e2jf7ofvUZMfMQksFI5zeohGaN69gBiudrs7ZQ=;
        b=TIu01umQSTPh5aFZQEbxLhdPsF2oqNucHtU7zUdu9SjQy52iQucEx8w8wNwdnlnte3
         A0SuvoV7Bw8TsD+C6euujSw90itWXv8o+q8RGMMkm/iLD9R0gNneIq9KrbI4dIccIBWz
         2E0c2vVp0oaRGXCros0PqcJhWkypjkCR7wA5NoHdcttekKYk0HJPUIhl3P359ZptAsxA
         O1KJs4FMBkjEz9GtEc/jxOD2W5LvybIHcr8PF0oX4j8bVFQhONPDzQHRcDz7ae+gccnB
         m3MwgZIgToisjaS3aOHZbg5qLjfBVXKXzdHvZQtr1NmlVZjc/aKGtWaEUAJVNCPw1azq
         QPVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="Pf/t4wPN";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t9sor1458905oig.169.2019.06.14.09.22.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 09:22:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="Pf/t4wPN";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yUJ36e2jf7ofvUZMfMQksFI5zeohGaN69gBiudrs7ZQ=;
        b=Pf/t4wPNKlA6LPs6IE0E4wSi22sJptLx7xtCYfgS+hi2uLi+YmXWGVMFVjMqT/pHin
         3Sq0DbM9kLfL1SbB/3kptFxfDPCI+TPgWEYr1ZhJ1oJwIw1v+EoZSCPgFNDZQzVYX4Lr
         2O/D91YQ//vHVGdpuMdDYLmb46Wi1vu3M4Cl1/gLXm9iIRNs/rYYl1SNW6JMGIBBbCri
         wnRV2hN8ILY7xmhQvs3isFMqLWQbSxD7bf5xY4C2+H9Xf8GDcv8serIT2Is1BLLoRgWt
         6qsSSO3IfVb4gyfmVkGjLEjX7GEJQUHc17+vZfFZNZaTqwS8B/FF6UglP68Vf6+nZUOP
         /d3w==
X-Google-Smtp-Source: APXvYqyp2XTEh+/XfnwmiJdtynxT4ccw6FS0jzhQTeNBXLuonzWWAL9Kcvo3Hm8UjH32DPDaYYmWTbDfTj0f+BKN8e0=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr2277796oih.73.1560529360068;
 Fri, 14 Jun 2019 09:22:40 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <20190614153535.GA9900@linux> <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
In-Reply-To: <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Jun 2019 09:22:29 -0700
Message-ID: <CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com>
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

On Fri, Jun 14, 2019 at 9:18 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> On 6/14/19 9:05 PM, Oscar Salvador wrote:
> > On Fri, Jun 14, 2019 at 02:28:40PM +0530, Aneesh Kumar K.V wrote:
> >> Can you check with this change on ppc64.  I haven't reviewed this series yet.
> >> I did limited testing with change . Before merging this I need to go
> >> through the full series again. The vmemmap poplulate on ppc64 needs to
> >> handle two translation mode (hash and radix). With respect to vmemap
> >> hash doesn't setup a translation in the linux page table. Hence we need
> >> to make sure we don't try to setup a mapping for a range which is
> >> arleady convered by an existing mapping.
> >>
> >> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> >> index a4e17a979e45..15c342f0a543 100644
> >> --- a/arch/powerpc/mm/init_64.c
> >> +++ b/arch/powerpc/mm/init_64.c
> >> @@ -88,16 +88,23 @@ static unsigned long __meminit vmemmap_section_start(unsigned long page)
> >>    * which overlaps this vmemmap page is initialised then this page is
> >>    * initialised already.
> >>    */
> >> -static int __meminit vmemmap_populated(unsigned long start, int page_size)
> >> +static bool __meminit vmemmap_populated(unsigned long start, int page_size)
> >>   {
> >>      unsigned long end = start + page_size;
> >>      start = (unsigned long)(pfn_to_page(vmemmap_section_start(start)));
> >>
> >> -    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
> >> -            if (pfn_valid(page_to_pfn((struct page *)start)))
> >> -                    return 1;
> >> +    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page))) {
> >>
> >> -    return 0;
> >> +            struct mem_section *ms;
> >> +            unsigned long pfn = page_to_pfn((struct page *)start);
> >> +
> >> +            if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> >> +                    return 0;
> >
> > I might be missing something, but is this right?
> > Having a section_nr above NR_MEM_SECTIONS is invalid, but if we return 0 here,
> > vmemmap_populate will go on and populate it.
>
> I should drop that completely. We should not hit that condition at all.
> I will send a final patch once I go through the full patch series making
> sure we are not breaking any ppc64 details.
>
> Wondering why we did the below
>
> #if defined(ARCH_SUBSECTION_SHIFT)
> #define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
> #elif defined(PMD_SHIFT)
> #define SUBSECTION_SHIFT (PMD_SHIFT)
> #else
> /*
>   * Memory hotplug enabled platforms avoid this default because they
>   * either define ARCH_SUBSECTION_SHIFT, or PMD_SHIFT is a constant, but
>   * this is kept as a backstop to allow compilation on
>   * !ARCH_ENABLE_MEMORY_HOTPLUG archs.
>   */
> #define SUBSECTION_SHIFT 21
> #endif
>
> why not
>
> #if defined(ARCH_SUBSECTION_SHIFT)
> #define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
> #else
> #define SUBSECTION_SHIFT  SECTION_SHIFT
> #endif
>
> ie, if SUBSECTION is not supported by arch we have one sub-section per
> section?

A couple comments:

The only reason ARCH_SUBSECTION_SHIFT exists is because PMD_SHIFT on
PowerPC was a non-constant value. However, I'm planning to remove the
distinction in the next rev of the patches. Jeff rightly points out
that having a variable subsection size per arch will lead to
situations where persistent memory namespaces are not portable across
archs. So I plan to just make SUBSECTION_SHIFT 21 everywhere.

