Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39A1CC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 17:34:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC4C720868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 17:34:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="TiqYN4ZI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC4C720868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 945956B0006; Fri,  7 Jun 2019 13:34:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F6706B0007; Fri,  7 Jun 2019 13:34:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BD3F6B000C; Fri,  7 Jun 2019 13:34:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 510816B0006
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 13:34:50 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id y81so822364oig.19
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 10:34:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PQDn4Bg8QjtLfMA6U30U1R3x+u2Sc8pJdpkvrhwxItg=;
        b=J3BXJhDmJs9yTAkQ1QP7+gjBvIenDCpmXL8gOsbswpLZSX8ZFuFCEOiiO0YYwqlLfa
         RHk7ZsKOmSy2tlKqBFLM7wbsT0RZ4hONfRcnixB9PaGS2h5q5aaD1fGrHLgSLAQ/wwGI
         sYzl5oSHxG5PX4dBO1GFxXOHQwNzqW6euatkSPVWjqj8aaoNf0s5mkFdD3pkUpBshMH+
         GOM1T0P4OIiL/ysny9V2udaa+sGZRnYZZIRd9l+C5dDQoWfgy7akcshgQ26XejwGe9JS
         UOT8FPM3+gYUy8rhzvlftlc8RIqpfiYo3RrbkjCv4gioF4A9xSFmFWSSUcsk1waHUA6t
         aeRQ==
X-Gm-Message-State: APjAAAUTU3C6z+wTMuiBhINsTSL3CuQP8gcBFfZhS+H5XbtsNYO+vPG3
	FtmH0sYEODFCioK9lO7P3LHrPI/76Y/ueELYsyrO6G7cJe9/GUByRWB6Dg0cyD50Rfzf7BFKBVe
	xo9n/bKuvi12NFaxLy1r1iMKVEIUcNYshL/QdXnfYJUBd8Gd0QDOyYfVrgdpGCSG6CA==
X-Received: by 2002:aca:1004:: with SMTP id 4mr4243817oiq.14.1559928889915;
        Fri, 07 Jun 2019 10:34:49 -0700 (PDT)
X-Received: by 2002:aca:1004:: with SMTP id 4mr4243761oiq.14.1559928888485;
        Fri, 07 Jun 2019 10:34:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559928888; cv=none;
        d=google.com; s=arc-20160816;
        b=UdSabCTO5xuFQPcFfKSsmXJEoV554ZdkxXEpkBCTCI3hZC6w/zin/nKB1155lC/hA6
         DMwJDIMkrlnqBPY/WXKIEM+w+s5ZeJ+K5IPzVentSxQAtoiz+Apy43GnAehqmYzh4Dng
         n8hyeRgwkD2VFF2y7fN9uTlVtfEU9cGzAVQyEtvjlS39BmG8m1rwgRWyHz/a93nsJMvI
         8X2+VHCl7XWqNMG72UmqcsHOXS9wGL+jHGiAeUjJ4IwCi+ddRIgJazzACyL5wIkPosyI
         1SVQe9hKrQ4leqQUm73eqeBuvUcNEJc1bjRYI7sS5rt3KC+ZEjlRHFDP77FIy3kl/gld
         xO1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PQDn4Bg8QjtLfMA6U30U1R3x+u2Sc8pJdpkvrhwxItg=;
        b=b4BKyG1g4JVYUbjCFX/bvC05ARr0vl13AbNrji19NpKm4M/sUkx7urON9RoahyRkey
         da0g8dC7hn7bemJCkZDdLFbwwlWqNrzRyTcrJ83XBDn7jvbegrzpv5o+aZnf5cmIkQ9Q
         hj2MgveF7D36GgdANiMtKz25mfNYl5PgtIisz2tKgqDIIK+RrL7l2K+xYnue7fFiDoeM
         PhsHAtbHOpj+PFP/9kOCSiGccVTRbLstmydH6RRsKkTJ0FCLngQTKOKhBuqp/x9Aed+l
         rBiFUxVNjkP9salnruH/8s023agzZBTIGC0hhfMvD8302tujUvZgrf6CgkWYdXEcbD8i
         a3pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=TiqYN4ZI;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j66sor993873oia.126.2019.06.07.10.34.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 10:34:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=TiqYN4ZI;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PQDn4Bg8QjtLfMA6U30U1R3x+u2Sc8pJdpkvrhwxItg=;
        b=TiqYN4ZIeJIcZdyH76CPw/HVLGladFFX1TaVyA8d+bt91TPBoOj+Wl/qYIgyST2If0
         5Q53pA2tQdlIrIXAbCxchjf9ns3sci6CtmdDvUYrvO+YD3Ve5aaBvSMa9VMxmPhN4j3W
         Tn6nVuiG9Y78xQgJXKnl+5bg5ke1pBLB1GlQupAgv6HIX0F0U/aM7XPLV9VOXad4g4Lf
         LMgAgdHX6fzBlIhsSuKFqXCYO1qbZHMxYrPREEUVIDtZdlVAsMCCpwK3xKS/Lk71Awcd
         0pVr2y0nBr1ueHaxoR1TDFfUyDNALDL/sX3kpjnRhqFMhc9LDiPs7+I3miDoeZpWxW9D
         0NOg==
X-Google-Smtp-Source: APXvYqwxRH9b7zfmNokXa/MJtvxICynfiQZqc9XkLddgj7G1h1cazph56bWLcewkRjUHU4E05igOxqptPTcARwRwv5E=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr1785826oih.73.1559928887822;
 Fri, 07 Jun 2019 10:34:47 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu-J3-66V7UhH3=AjN4sX7iydHNF7Fd+SMbezaVNrZQmGQ@mail.gmail.com>
 <CAPcyv4g-GNe2vSYTn0a6ivQYxJdS5khE4AJbcxysoGPsTZwswg@mail.gmail.com>
 <CAKv+Gu83QB6x8=LCaAcR0S65WELC-Y+Voxw6LzaVh4FSV3bxYA@mail.gmail.com>
 <CAPcyv4hXBJBMrqoUr4qG5A3CUVgWzWK6bfBX29JnLCKDC7CiGA@mail.gmail.com>
 <CAKv+Gu_ZYpey0dWYebFgCaziyJ-_x+KbCmOegWqFjwC0U-5QaA@mail.gmail.com> <CAPcyv4jO5WhRJ-=Nz70Jc0mCHYBJ6NsHjJNk6AerwQXH43oemw@mail.gmail.com>
In-Reply-To: <CAPcyv4jO5WhRJ-=Nz70Jc0mCHYBJ6NsHjJNk6AerwQXH43oemw@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 7 Jun 2019 10:34:36 -0700
Message-ID: <CAPcyv4gzhr57xa2MbR1Jk8EDFw-WLdcw3mJnEX9PeAFwVEZbDA@mail.gmail.com>
Subject: Re: [PATCH v2 4/8] x86, efi: Reserve UEFI 2.8 Specific Purpose Memory
 for dax
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, linux-efi <linux-efi@vger.kernel.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@redhat.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Darren Hart <dvhart@infradead.org>, 
	Andy Shevchenko <andy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	kbuild test robot <lkp@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 7, 2019 at 8:23 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Fri, Jun 7, 2019 at 5:29 AM Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
[..]
> > > #ifdef CONFIG_EFI_APPLICATION_RESERVED
> > > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > > {
> > >         return md->type == EFI_CONVENTIONAL_MEMORY
> > >                 && (md->attribute & EFI_MEMORY_SP);
> > > }
> > > #else
> > > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > > {
> > >         return false;
> > > }
> > > #endif
> >
> > I think this policy decision should not live inside the EFI subsystem.
> > EFI just gives you the memory map, and mangling that information
> > depending on whether you think a certain memory attribute should be
> > ignored is the job of the MM subsystem.
>
> The problem is that we don't have an mm subsystem at the time a
> decision needs to be made. The reservation policy needs to be deployed
> before even memblock has been initialized in order to keep kernel
> allocations out of the reservation. I agree with the sentiment I just
> don't see how to practically achieve an optional "System RAM" vs
> "Application Reserved" routing decision without an early (before
> e820__memblock_setup()) conditional branch.

I can at least move it out of include/linux/efi.h and move it to
arch/x86/include/asm/efi.h since it is an x86 specific policy decision
/ implementation for now.

