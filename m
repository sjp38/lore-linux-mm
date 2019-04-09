Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 969C2C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 16:44:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45D5F2133D
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 16:44:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="lrv4gijf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45D5F2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4AFB6B0266; Tue,  9 Apr 2019 12:44:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF9536B0269; Tue,  9 Apr 2019 12:44:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0F5F6B026A; Tue,  9 Apr 2019 12:44:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB046B0266
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 12:44:04 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id w3so10221120otg.11
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 09:44:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/Ilyq20E19xyV6UbqdWCXc0MKpHCaUfLCj4Un3Tvmso=;
        b=FFtz0DZ2f8ZCogilmktV5OIfXFhqNJYGmMn1oKFBkY0O0q+tgSaLxyCEQk/z+IBfcw
         8CZzU1Dw1TN3Z/Li43P55ZA+AAJmI9Q3z04p9cJ/jZgop3dPKSMABskIP3zkt5uf8tgZ
         VO8CdGq6vS3d61vMv1cjHb97wiwmOlqj0FvPWjcaLoOOVgkiC4FbIwdRKmLWj/OcNG59
         PSksQhs6sopJiDe/ML6F9ivTvRqtmmeETDaMSqi8KvDCsd+vwJKhcEbiYrrX/SuoNNO8
         clH0cNx05OgfpXus7h1D0Y73W9epU6B1xdi/QkXiJuE3Y6TYr8mSS1mhzHhU3MdS3BJ7
         GWbQ==
X-Gm-Message-State: APjAAAVQHL5EXd1cEDbUf5yZ/e8/PtlRqh7CMllx/RahhyjfU0TXGvzK
	4GO5fLNwuWcgyTvVf2OHj6ZQAEK1I8pjWiWeT6IekpCqJ6n5oL6Kti8xr8k/5lFCjhokz2fgarj
	mqXh7mJ0Id9vqQ1JKeIolVC3HUZY38jT/MAR1cXuuPZqXUJgeLE8dD5Cj+2YleE5sbQ==
X-Received: by 2002:a9d:7309:: with SMTP id e9mr23041811otk.93.1554828244102;
        Tue, 09 Apr 2019 09:44:04 -0700 (PDT)
X-Received: by 2002:a9d:7309:: with SMTP id e9mr23041765otk.93.1554828243182;
        Tue, 09 Apr 2019 09:44:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554828243; cv=none;
        d=google.com; s=arc-20160816;
        b=GMdAs3XmhCUm0Bj4AIKXQInjNHT3tfJlsQ+CjyQkcT40tkKZEzN9Af6p2gVPh9MHpW
         3KdKVGNq2clTpeNofq2aMmN+Unp7VUsvGvNvaMZ/CoQKKRo70lAQ9pgBOHMgCZgX/2QO
         uYo/LeFvvqeEhaEMxPTyS2xHh9egnS5AHqYPRoDCTvZFNzoAEPJE7Pn61hCUd8oXYuJJ
         CAHcwpMaLsWsTBRe9iW+V6nHhe1GJb+plTFeVaRE6LyWZnlPaoauHNWOiwYPhD89Zqk+
         bEGR2cNc+Rf5oOtUNmAIzidY4iHpL3H37Xk52XNoX9d55FSm3JH8CwNMEMnXKMgSyqQB
         2xyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/Ilyq20E19xyV6UbqdWCXc0MKpHCaUfLCj4Un3Tvmso=;
        b=TLyzmUbJNO5U7jP5JYFoU+ViUj01cAeW37awPZD1w2/Rlzpyk8s1kr+QKc2kHLgipI
         XXLnzJ6TVALWuTQ8GfG7vSSFSIBe9RgZS2UzX9Til+hKBb2B0Y+ZOpwycW6u8dWxvBCW
         nIjbTf7CVq70IjrWVxwkWztGbKXEbRRncnStd/mzbav9JLx3yTbsDYNqAqyeQTfem10K
         oNWwUEE20ipI+bCo2CcPWsYJUMSC4uq+5cDaYsZfrW2ymUe0/BUrqHwQKPm7rZRoCP1y
         Pd8Ck/HWn6KDHBAMF+jDW52LEXpuW9ALY+PzK8zRGO2sF4pCpzBqwwIPPxavhbsgzJCc
         hoRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=lrv4gijf;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y201sor18947612oie.29.2019.04.09.09.44.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 09:44:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=lrv4gijf;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/Ilyq20E19xyV6UbqdWCXc0MKpHCaUfLCj4Un3Tvmso=;
        b=lrv4gijfp8inONCmOta0cZT+rOaqS46kzXxlD7fVm7Dvpf3Yx9BV0vl2saWGilF59Z
         r0JIhV5mKblMk253QdWZYY1tiYj9SMAos6c6FUEEBPBglPmO0bCC/uEl5KDqNr0n9Tgo
         sV9UMZJF9vyRAytOkUGR7XHrfK86Zj5wu6poTg/wItdEzgt2FNAcvZE2xp+WHid1XbKT
         GZYGnWNVNJCvu54jNART4HCe1FWdzhX/+vtUMDqTY12S11FfOjDOjbOc4//48c+iYRmM
         ++Cade6kftVkQ27c80QU3ExuwRPVBr3cVH1UrjunaNBJ56uvCaAxV2ItyXyyVRmRKLXI
         Q9Aw==
X-Google-Smtp-Source: APXvYqxR0l4hgJwOIl2t0dh8FgfnBaGJLiSOysar/muEp50KkXSwWDL6A2Yd+RJSIG/AneDrjksKy2ozyrO6fMV7pNo=
X-Received: by 2002:aca:f581:: with SMTP id t123mr21730459oih.0.1554828242538;
 Tue, 09 Apr 2019 09:44:02 -0700 (PDT)
MIME-Version: 1.0
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440491334.3190322.44013027330479237.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu8ocQGxTAapfjb5WufhL=Qj54LythHcPHsyy+wUnVBnfA@mail.gmail.com>
In-Reply-To: <CAKv+Gu8ocQGxTAapfjb5WufhL=Qj54LythHcPHsyy+wUnVBnfA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 9 Apr 2019 09:43:50 -0700
Message-ID: <CAPcyv4gUL8j+EaAZ556_NKXLgva++HgPBOeeAUNHN+DAWaewaQ@mail.gmail.com>
Subject: Re: [RFC PATCH 1/5] efi: Detect UEFI 2.8 Special Purpose Memory
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, 
	Vishal L Verma <vishal.l.verma@intel.com>, "the arch/x86 maintainers" <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Keith Busch <keith.busch@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 5, 2019 at 9:21 PM Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>
> Hi Dan,
>
> On Thu, 4 Apr 2019 at 21:21, Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
> > interpretation of the EFI Memory Types as "reserved for a special
> > purpose".
> >
> > The proposed Linux behavior for special purpose memory is that it is
> > reserved for direct-access (device-dax) by default and not available for
> > any kernel usage, not even as an OOM fallback. Later, through udev
> > scripts or another init mechanism, these device-dax claimed ranges can
> > be reconfigured and hot-added to the available System-RAM with a unique
> > node identifier.
> >
> > A follow-on patch integrates parsing of the ACPI HMAT to identify the
> > node and sub-range boundaries of EFI_MEMORY_SP designated memory. For
> > now, arrange for EFI_MEMORY_SP memory to be reserved.
> >
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Borislav Petkov <bp@alien8.de>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > Cc: Darren Hart <dvhart@infradead.org>
> > Cc: Andy Shevchenko <andy@infradead.org>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  arch/x86/Kconfig                  |   18 ++++++++++++++++++
> >  arch/x86/boot/compressed/eboot.c  |    5 ++++-
> >  arch/x86/boot/compressed/kaslr.c  |    2 +-
> >  arch/x86/include/asm/e820/types.h |    9 +++++++++
> >  arch/x86/kernel/e820.c            |    9 +++++++--
> >  arch/x86/platform/efi/efi.c       |   10 +++++++++-
> >  include/linux/efi.h               |   14 ++++++++++++++
> >  include/linux/ioport.h            |    1 +
> >  8 files changed, 63 insertions(+), 5 deletions(-)
> >
> > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > index c1f9b3cf437c..cb9ca27de7a5 100644
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -1961,6 +1961,24 @@ config EFI_MIXED
> >
> >            If unsure, say N.
> >
> > +config EFI_SPECIAL_MEMORY
> > +       bool "EFI Special Purpose Memory Support"
> > +       depends on EFI
> > +       ---help---
> > +         On systems that have mixed performance classes of memory EFI
> > +         may indicate special purpose memory with an attribute (See
> > +         EFI_MEMORY_SP in UEFI 2.8). A memory range tagged with this
> > +         attribute may have unique performance characteristics compared
> > +         to the system's general purpose "System RAM" pool. On the
> > +         expectation that such memory has application specific usage
> > +         answer Y to arrange for the kernel to reserve it for
> > +         direct-access (device-dax) by default. The memory range can
> > +         later be optionally assigned to the page allocator by system
> > +         administrator policy. Say N to have the kernel treat this
> > +         memory as general purpose by default.
> > +
> > +         If unsure, say Y.
> > +
>
> EFI_MEMORY_SP is now part of the UEFI spec proper, so it does not make
> sense to make any understanding of it Kconfigurable.

No, I think you're misunderstanding what this Kconfig option is trying
to achieve.

The configuration capability is solely for the default kernel policy.
As can already be seen by Christoph's response [1] the thought that
the firmware gets more leeway to dictate to Linux memory policy may be
objectionable.

[1]: https://lore.kernel.org/lkml/20190409121318.GA16955@infradead.org/

So the Kconfig option is gating whether the kernel simply ignores the
attribute and gives it to the page allocator by default. Anything
fancier, like sub-dividing how much is OS managed vs device-dax
accessed requires the OS to reserve it all from the page-allocator by
default until userspace policy can be applied.

> Instead, what I would prefer is to implement support for EFI_MEMORY_SP
> unconditionally (including the ability to identify it in the debug
> dump of the memory map etc), in a way that all architectures can use
> it. Then, I think we should never treat it as ordinary memory and make
> it the firmware's problem not to use the EFI_MEMORY_SP attribute in
> cases where it results in undesired behavior in the OS.

No, a policy of "never treat it as ordinary memory" confuses the base
intent of the attribute which is an optional hint to get the OS to not
put immovable / non-critical allocations in what could be a precious
resource.

Moreover, the interface for platform firmware to indicate that a
memory range should never be treated as ordinary memory is simply the
existing "reserved" memory type, not this attribute. That's the
mechanism to use when platform firmware knows that a driver is needed
for a given mmio resource.

> Also, sInce there is a generic component and a x86 component, can you
> please split those up?

Sure, can do.

>
> You only cc'ed me on patch #1 this time, but could you please cc me on
> the entire series for v2? Thanks.

Yes, will do, and thanks for taking a look.

