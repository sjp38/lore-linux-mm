Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F7A2C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 19:07:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D28B520717
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 19:07:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="OLrB/QI7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D28B520717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F5F76B026A; Wed,  5 Jun 2019 15:07:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A76C6B026B; Wed,  5 Jun 2019 15:07:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86E976B026C; Wed,  5 Jun 2019 15:07:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 598796B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 15:07:02 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id b64so750302otc.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 12:07:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FlGX/Q/ed4YLpiHihy7wKZjWbXQYUcrLzGq5do+X348=;
        b=cwUImzkeQg8Cv4ypCX5OZI3uYlT0qo/HPBBglpi3evYtbSL6pfhWtC1x4TeW2vckf6
         wBCQXGTSItJsbWoCoOPD5ijcMJV68imo+q9kiCmMYM++UzahxKOHd8fThEaUZwKKZcb+
         44R1U/gj005RG5X40HwdKZAp9jpEt3jeG1J/G5xjL1HR0jein1hQDkv4JO7uiww/rfnF
         TzP5iuY295kBg3g4OLUZKotdD7f5+fIZa4VYS2YQzoAE+WM1tCiPKaj6TRMz9J1omwWD
         fnEOhKbl8kVfQXBx/yk3Vh4TXwWt/yA2Jd+r8YZ1/5H29QqgWKCm5132zsczXwDSSKKa
         Ctzw==
X-Gm-Message-State: APjAAAUB7OT9SKXjED8eIazLbk5B8pPPnuUPymr2SP5fxT8GPzTTE+HZ
	0uYaJ0Zslq2Zs1/391ZjltfD38ocdb7cCpjug7+qNB4pebtJxwZEE3xfWRfvqffGJLbDAF+z7/2
	HsPr9Gw1szMz0aJ6qKFgetFD9tsuMyOJYHNFf8wAU4RHo7bfOygBE26sMw1ELYAfjZA==
X-Received: by 2002:aca:4343:: with SMTP id q64mr9369339oia.82.1559761621899;
        Wed, 05 Jun 2019 12:07:01 -0700 (PDT)
X-Received: by 2002:aca:4343:: with SMTP id q64mr9369270oia.82.1559761620885;
        Wed, 05 Jun 2019 12:07:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559761620; cv=none;
        d=google.com; s=arc-20160816;
        b=obGbc9rOzSU7CG8tVSyqFeBzbvGugL+h6oLt91tlpRlb9L4o7ZO3mSmRAHpWdzySlx
         Za87jh0B2VyHja6JAORBltmAEvaCHhXw//nPshdfc5g50zA6TLEvD1ys5QOGjykP6G4v
         aa0ap/c9vCN8SasDHEymx9eHpevWgwfdaVziflJL8qU61AZkbq3Gb1JUa5OymJNQ0YtP
         ou4NxL6yiCydtX+R3HPu4dBMsYlyI9OkzMgQdaKbTos/1kNa3bKEnRh5X3pIW0eJNoLo
         iyHGiuYNMyDYlEVs5BNxj7wCPcGji/EGZ5JIvoxey3q/Dmaiy1cO4XQJR+3SgRKeYWFe
         flnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FlGX/Q/ed4YLpiHihy7wKZjWbXQYUcrLzGq5do+X348=;
        b=yW2iNL0xqLxPfPRjRWPi6lynzwWMn2ar07s6gND2tOt51G1o8IAAxuThy+HY7Qcwux
         BAnTuqtUAk7JEGiQo/oyU0TUJ6CqDSIHZDEoj9FUsYZhdkXXnl/zyL4ctwEg15pJ3BBD
         6sdZhCNbSbIkgswWdZJKAo2fxpcdPBnxrg9/USuEbTZejdzBbk74qob8btxR3cgLdBlR
         t8f+I5POe1TwRZ/ANcQFBXCBo0SJnG+oPXDBUREDwmUM+cl+uHrWNGZvE60b2IeD/0Ub
         2KDz3AocQ2u5zy5nb9TTLl25+vEdWBouTs9ytaafsOSvK71kDosnGsYDvnbc/69NK6MC
         m3bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="OLrB/QI7";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y1sor2862085otk.117.2019.06.05.12.07.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 12:07:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="OLrB/QI7";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FlGX/Q/ed4YLpiHihy7wKZjWbXQYUcrLzGq5do+X348=;
        b=OLrB/QI7SOZkBoOCJvJu/oZedSJQS+6e3vcQQioJRsL2HLS3UXE0MF5JJ48ujYCrRX
         bpQ26cFMyEZ7PkMmokOgMIfekwWGfuv95Lo22jjqwCYNgzLyN1QIk0rMRi5bGjt8Gp5R
         qRJzS9WVdVCONuYpJM6xmY/eXFoyS1RX02M4Bo+LBmAVGMQuGyN/NlLluu3prOipzIom
         dvlHWW1dhIOlidBLrhzBx5/WpnE4OSyFKbwkwnhxvE4PXqgDoRMTcwsmcS78BxKZ+ayM
         ZcQxNzhm81hrnTIiDhtByguCDXFJr7dt5iOqQJ4GKBUKG+jLpE8qsDxia/YxvotytVs1
         ch4A==
X-Google-Smtp-Source: APXvYqzgVMKh9g4W1mu1XQOvy1kR0wNgwQKf4iqlSH2P2xmTbIEaH9QIde+dosL04I1rFqIv0WxNp1FKT990IzXVl+0=
X-Received: by 2002:a9d:7248:: with SMTP id a8mr10453669otk.363.1559761620354;
 Wed, 05 Jun 2019 12:07:00 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190603054159.GA5747@rapoport-lnx>
In-Reply-To: <20190603054159.GA5747@rapoport-lnx>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 5 Jun 2019 12:06:49 -0700
Message-ID: <CAPcyv4gAWUPoRK2o-FkpqMbB4559q4O-Fx7niT1vppoRC1VyWA@mail.gmail.com>
Subject: Re: [PATCH v2 4/8] x86, efi: Reserve UEFI 2.8 Specific Purpose Memory
 for dax
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-efi <linux-efi@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, 
	Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	kbuild test robot <lkp@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 2, 2019 at 10:42 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Hi Dan,
>
> On Thu, May 30, 2019 at 03:59:43PM -0700, Dan Williams wrote:
> > UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
> > interpretation of the EFI Memory Types as "reserved for a special
> > purpose".
> >
> > The proposed Linux behavior for specific purpose memory is that it is
> > reserved for direct-access (device-dax) by default and not available for
> > any kernel usage, not even as an OOM fallback. Later, through udev
> > scripts or another init mechanism, these device-dax claimed ranges can
> > be reconfigured and hot-added to the available System-RAM with a unique
> > node identifier.
> >
> > This patch introduces 3 new concepts at once given the entanglement
> > between early boot enumeration relative to memory that can optionally be
> > reserved from the kernel page allocator by default. The new concepts
> > are:
> >
> > - E820_TYPE_SPECIFIC: Upon detecting the EFI_MEMORY_SP attribute on
> >   EFI_CONVENTIONAL memory, update the E820 map with this new type. Only
> >   perform this classification if the CONFIG_EFI_SPECIFIC_DAX=y policy is
> >   enabled, otherwise treat it as typical ram.
> >
> > - IORES_DESC_APPLICATION_RESERVED: Add a new I/O resource descriptor for
> >   a device driver to search iomem resources for application specific
> >   memory. Teach the iomem code to identify such ranges as "Application
> >   Reserved".
> >
> > - MEMBLOCK_APP_SPECIFIC: Given the memory ranges can fallback to the
> >   traditional System RAM pool the expectation is that they will have
> >   typical SRAT entries. In order to support a policy of device-dax by
> >   default with the option to hotplug later, the numa initialization code
> >   is taught to avoid marking online MEMBLOCK_APP_SPECIFIC regions.
>
> I'd appreciate a more elaborate description how this flag is going to be
> used.

This flag is only there to communicate to the numa code what ranges of
"conventional memory" should be skipped for onlining and reserved for
device-dax to consume. However, now that I say that out loud I realize
I might be able to get away with just using a plain entry
memblock.reserved. I'll take a look.

>
> > A follow-on change integrates parsing of the ACPI HMAT to identify the
> > node and sub-range boundaries of EFI_MEMORY_SP designated memory. For
> > now, just identify and reserve memory of this type.
> >
> > Cc: <x86@kernel.org>
> > Cc: Borislav Petkov <bp@alien8.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: Darren Hart <dvhart@infradead.org>
> > Cc: Andy Shevchenko <andy@infradead.org>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > Reported-by: kbuild test robot <lkp@intel.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  arch/x86/Kconfig                  |   20 ++++++++++++++++++++
> >  arch/x86/boot/compressed/eboot.c  |    5 ++++-
> >  arch/x86/boot/compressed/kaslr.c  |    2 +-
> >  arch/x86/include/asm/e820/types.h |    9 +++++++++
> >  arch/x86/kernel/e820.c            |    9 +++++++--
> >  arch/x86/kernel/setup.c           |    1 +
> >  arch/x86/platform/efi/efi.c       |   37 +++++++++++++++++++++++++++++++++----
> >  drivers/acpi/numa.c               |   15 ++++++++++++++-
> >  include/linux/efi.h               |   14 ++++++++++++++
> >  include/linux/ioport.h            |    1 +
> >  include/linux/memblock.h          |    7 +++++++
> >  mm/memblock.c                     |    4 ++++
> >  12 files changed, 115 insertions(+), 9 deletions(-)
>
> ...
>
> > diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> > index 08a5f4a131f5..ddde1c7b1f9a 100644
> > --- a/arch/x86/kernel/setup.c
> > +++ b/arch/x86/kernel/setup.c
> > @@ -1109,6 +1109,7 @@ void __init setup_arch(char **cmdline_p)
> >
> >       if (efi_enabled(EFI_MEMMAP)) {
> >               efi_fake_memmap();
> > +             efi_find_app_specific();
> >               efi_find_mirror();
> >               efi_esrt_init();
> >
> > diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
> > index e1cb01a22fa8..899f1305c77a 100644
> > --- a/arch/x86/platform/efi/efi.c
> > +++ b/arch/x86/platform/efi/efi.c
> > @@ -123,10 +123,15 @@ void __init efi_find_mirror(void)
> >   * more than the max 128 entries that can fit in the e820 legacy
> >   * (zeropage) memory map.
> >   */
> > +enum add_efi_mode {
> > +     ADD_EFI_ALL,
> > +     ADD_EFI_APP_SPECIFIC,
> > +};
> >
> > -static void __init do_add_efi_memmap(void)
> > +static void __init do_add_efi_memmap(enum add_efi_mode mode)
> >  {
> >       efi_memory_desc_t *md;
> > +     int add = 0;
> >
> >       for_each_efi_memory_desc(md) {
> >               unsigned long long start = md->phys_addr;
> > @@ -139,7 +144,9 @@ static void __init do_add_efi_memmap(void)
> >               case EFI_BOOT_SERVICES_CODE:
> >               case EFI_BOOT_SERVICES_DATA:
> >               case EFI_CONVENTIONAL_MEMORY:
> > -                     if (md->attribute & EFI_MEMORY_WB)
> > +                     if (is_efi_dax(md))
> > +                             e820_type = E820_TYPE_SPECIFIC;
> > +                     else if (md->attribute & EFI_MEMORY_WB)
> >                               e820_type = E820_TYPE_RAM;
> >                       else
> >                               e820_type = E820_TYPE_RESERVED;
> > @@ -165,9 +172,24 @@ static void __init do_add_efi_memmap(void)
> >                       e820_type = E820_TYPE_RESERVED;
> >                       break;
> >               }
> > +
> > +             if (e820_type == E820_TYPE_SPECIFIC) {
> > +                     memblock_remove(start, size);
> > +                     memblock_add_range(&memblock.reserved, start, size,
> > +                                     MAX_NUMNODES, MEMBLOCK_APP_SPECIFIC);
>
> Why cannot this happen at e820__memblock_setup()?
> Then memblock_remove() call should not be required as nothing will
> memblock_add() the region.

It's only required given the relative call order of efi_fake_memmap()
and the desire to be able to specify EFI_MEMORY_SP on the kernel
command line if the platform BIOS neglects to do it. efi_fake_memmap()
currently occurs after e820__memblock_setup() and my initial attempts
to flip the order resulted in boot failures so there is a subtle
dependency on that order I have not identified.

[..]
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 6bbad46f4d2c..654fecb52ba5 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -982,6 +982,10 @@ static bool should_skip_region(struct memblock_region *m, int nid, int flags)
> >       if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
> >               return true;
> >
> > +     /* if we want specific memory skip non-specific memory regions */
> > +     if ((flags & MEMBLOCK_APP_SPECIFIC) && !memblock_is_app_specific(m))
> > +             return true;
> > +
>
> With this the MEMBLOCK_APP_SPECIFIC won't be skipped for traversals that
> don't set memblock_flags explicitly. Is this the intention?

Yeah as per above it turns out the only real need is to identify it as
reserved, so the flag can likely go away altogether.

