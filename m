Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DEF3C468BE
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 14:54:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C81E320840
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 14:54:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="c7Pg+1Vu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C81E320840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 276D56B000D; Sat,  8 Jun 2019 10:54:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2278D6B0010; Sat,  8 Jun 2019 10:54:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 116746B0266; Sat,  8 Jun 2019 10:54:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id D955B6B000D
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 10:54:01 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id b25so2466928otp.12
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 07:54:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Dk+u3XgaNOqXLaO68gyf05VnI7PTjpPeX2V5LZFBkJU=;
        b=Q7EHBrwWjNkxd73XVF1Blq8whP5hTUlMui5PmauIakSJmyVI5PB2zvCSiWqT/wP69Z
         p+pJGDAYiEsVnFyE/8aRwbamC9bkYlY4C5TaXGBt+SBURVNHkuK1wly2sXDIrIyuqWaP
         NQ7SuLAAbMTAHYmV/pNPyPLREGQnVlzs8aS+e0hbtCIlrDe1hg8WNyQPWeTjX5uDxhLq
         DsTuKF4V3pLOq9N6gTSXDVvBMalljzfpAU/iorYDY2/zkod9RHkkg5QVeK29gxobqAXF
         A1TMGxxBt9zIg1i5ggFObEBB/Rd2t05CkPh7IUodl9L9BNaRtvTdwceDaD0HDnFag6Qv
         GUNQ==
X-Gm-Message-State: APjAAAVdx550aCNw36PoD9v3Jm+fMU050mGL0LCqLj0l74UVK0qu25yu
	SZf+XvRi6A/wZlxYkGwmZ/7GFh73XBgd+7sa6T75h0DkQ1p88e4k+3IVtQgflbfyab2HGackHYG
	CTOxNeRaUXlf6AAVVD8xTMpoT9t/Z15Ve6RC3PuJnNJbq5nx0WZMsTUko1odisW9pnw==
X-Received: by 2002:a9d:5907:: with SMTP id t7mr7875296oth.163.1560005641477;
        Sat, 08 Jun 2019 07:54:01 -0700 (PDT)
X-Received: by 2002:a9d:5907:: with SMTP id t7mr7875258oth.163.1560005640672;
        Sat, 08 Jun 2019 07:54:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560005640; cv=none;
        d=google.com; s=arc-20160816;
        b=i4jS+yAGggYnzBAxNNgYWSLRBXL5oh27sY7rQTKE7mJDx8eAZmUJFgEXqIoLdpspss
         jO9sorjfBkqYH/joeY5KlUrUFEW/qmY7YWqanhiEEYzGJNdh9I99Bgka/5zcR6yYIeVW
         Ck9y3DrKCHu3JBsof1c1q7n7b+OCGfpfQcwTzrhHTorBRjXQ8PWPLJM5FIBsFTjBn58R
         bcpuVfzvnVD+raSaCY8AJgdmwowuJ5B4QwzmeGxCkp+7QGIUZDbOXmx7ohNxmO/6PNnE
         B4qGsYfruaYJHEQV6ZKtCkRfF39CO6ry/71wAHmJpZcRYutjz9anIlaLICmRzJo09EVy
         ae9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Dk+u3XgaNOqXLaO68gyf05VnI7PTjpPeX2V5LZFBkJU=;
        b=Z9q5nq7USj9nxqmXlWB7lr1b4Kfwjj6NzYiloboOIabS346aQFXeu55Kx+x+vhnlaI
         EUTptLQus9oKqFIKJdT0xZx8WLQYF9gb1U98wbTKGlBn9yqBNK4IMt9yGm6E4Qdy5ZH6
         r8wiqhVzpug1s+5tFVNK6+BjJ3aOQTkT762H2CONlygt0y/9tGVcpbYv/7+mJ9vyaWb3
         mW6X62zDmJglBER3npz1sqfYK/MR09nQCFtVCTKgOkI2TxPzMnHXcxLztHBo3H2M6ZYC
         Q6/OAStx4m/hOs/keW2WF3y3v84Y/lmmKm/ra2EaCV3spw3NFjobRydbG0crZko1AYAK
         MGNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=c7Pg+1Vu;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m7sor2375692otf.158.2019.06.08.07.54.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Jun 2019 07:54:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=c7Pg+1Vu;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Dk+u3XgaNOqXLaO68gyf05VnI7PTjpPeX2V5LZFBkJU=;
        b=c7Pg+1Vu+CFzwWjTCMqA/7ILEjKHUJlK9K7TIBu56QFBG34LHWLdVkM7tbREx2Ey9p
         TjCdQdfntrBDULEZ7N1HSxQg0s3DwVikz29ifn2VjQqccdLcAJ1KkySuifbxWyME5a7W
         x4fOaxhygkWdkKYvJVh0JgypnwprJM5FHpdLFWTbR4b8W25GIpRqLlOkF/ugyfihZC+8
         c7LrVjq4p2Hw1E72Dp2p511CMIYJdbrwSfhhEtnq2nr9rqDPBQg5MRZOyX6pvij6xYTr
         nGmNhnS25l7cTno9P3Fo7izT+xPDuhI3LIcqoKUC7iNIdx3UljQ5OPalTto1Tp8OepSr
         0zOw==
X-Google-Smtp-Source: APXvYqypLm2j/J6SB8ZKAlfeHzcCYKwyThpmhhnmxpvXXR1jOg6wN0waBPRAcYcxiyvBbMj8vJDm0b8GB8DJsrFdTLI=
X-Received: by 2002:a9d:470d:: with SMTP id a13mr8130580otf.126.1560005639908;
 Sat, 08 Jun 2019 07:53:59 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu-J3-66V7UhH3=AjN4sX7iydHNF7Fd+SMbezaVNrZQmGQ@mail.gmail.com>
 <CAPcyv4g-GNe2vSYTn0a6ivQYxJdS5khE4AJbcxysoGPsTZwswg@mail.gmail.com>
 <CAKv+Gu83QB6x8=LCaAcR0S65WELC-Y+Voxw6LzaVh4FSV3bxYA@mail.gmail.com>
 <CAPcyv4hXBJBMrqoUr4qG5A3CUVgWzWK6bfBX29JnLCKDC7CiGA@mail.gmail.com>
 <CAKv+Gu_ZYpey0dWYebFgCaziyJ-_x+KbCmOegWqFjwC0U-5QaA@mail.gmail.com>
 <CAPcyv4jO5WhRJ-=Nz70Jc0mCHYBJ6NsHjJNk6AerwQXH43oemw@mail.gmail.com>
 <CAPcyv4gzhr57xa2MbR1Jk8EDFw-WLdcw3mJnEX9PeAFwVEZbDA@mail.gmail.com> <CAKv+Gu_OcsWi5DqxOk-j6ovc0CMAZV37Od7zA5Bs4Ng5ATQxAA@mail.gmail.com>
In-Reply-To: <CAKv+Gu_OcsWi5DqxOk-j6ovc0CMAZV37Od7zA5Bs4Ng5ATQxAA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 8 Jun 2019 07:53:49 -0700
Message-ID: <CAPcyv4i_ZaKKT2dHQTuHCWT9HhqCOm4kpy2YdK952GubwqbJDQ@mail.gmail.com>
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

On Sat, Jun 8, 2019 at 12:20 AM Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
>
> On Fri, 7 Jun 2019 at 19:34, Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Fri, Jun 7, 2019 at 8:23 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > On Fri, Jun 7, 2019 at 5:29 AM Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> > [..]
> > > > > #ifdef CONFIG_EFI_APPLICATION_RESERVED
> > > > > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > > > > {
> > > > >         return md->type == EFI_CONVENTIONAL_MEMORY
> > > > >                 && (md->attribute & EFI_MEMORY_SP);
> > > > > }
> > > > > #else
> > > > > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > > > > {
> > > > >         return false;
> > > > > }
> > > > > #endif
> > > >
> > > > I think this policy decision should not live inside the EFI subsystem.
> > > > EFI just gives you the memory map, and mangling that information
> > > > depending on whether you think a certain memory attribute should be
> > > > ignored is the job of the MM subsystem.
> > >
> > > The problem is that we don't have an mm subsystem at the time a
> > > decision needs to be made. The reservation policy needs to be deployed
> > > before even memblock has been initialized in order to keep kernel
> > > allocations out of the reservation. I agree with the sentiment I just
> > > don't see how to practically achieve an optional "System RAM" vs
> > > "Application Reserved" routing decision without an early (before
> > > e820__memblock_setup()) conditional branch.
> >
> > I can at least move it out of include/linux/efi.h and move it to
> > arch/x86/include/asm/efi.h since it is an x86 specific policy decision
> > / implementation for now.
>
> No, that doesn't make sense to me. If it must live in the EFI
> subsystem, I'd prefer it to be in the core code, not in x86 specific
> code, since there is nothing x86 specific about it.

Ok, but it's still not clear to me where you would accept an early
detection of EFI_CONVENTIONAL_MEMORY + EFI_MEMORY_SP and route it away
from the "System RAM" default. Please just recommend a place to land a
conditional branch that translates between the base EFI type +
attribute and E820_RAM and E820_APPLICATION_RESERVED.

> Perhaps a efi=xxx command line option would be in order to influence
> the builtin default, but it can be a followup patch independent of
> this series.

Sure, but I expect the default polarity of the branch is a compile
time option with an efi= override.

