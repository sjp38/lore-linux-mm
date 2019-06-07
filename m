Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD2BDC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:29:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B565208E3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:29:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="l4nQx5bF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B565208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4ABA66B000C; Fri,  7 Jun 2019 08:29:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45D9A6B000E; Fri,  7 Jun 2019 08:29:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34B616B0266; Fri,  7 Jun 2019 08:29:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1896A6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 08:29:27 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id j18so1539978ioj.4
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 05:29:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZAvCebdzLCcSo6NRDYnZ6+WboqvZJ6BWkvuu4gNcNRU=;
        b=Ko2+C6atPBeeLidRpyTgy4cEyoT5JZEAUpWk3eQ6n8fEngKYqRqgITSizt8o++/pwM
         VlFYgBpqTbyuIwK2H+RlMo8jrvuafii0W02oWhY2z81/HPvyi/xZyCef12ioVEvZ0wZ2
         6ghhaTJlLQS8yz5XgosTGvP3yCMUyH4YAPxHfbExoF6eO12DFO6O9zMhYT9qA7V3oxRf
         axVK58iqwFKv1S4PwGcCtMuk66/iXh+UjhL49ZwLAnlPgdscJFKhxc9/EzlzNpLDP7qJ
         V6NoCq2muyaGtzjq+lx8VFIsoxbPxHkUJSQ5V6YFH/jXT0PQlcQSg58n7b1egDXj4pbz
         7HVA==
X-Gm-Message-State: APjAAAVVTvK/Vkn64q9CfdL2/Ka1N8M0RogaCSb1tJWhlZP4kJE1rl5G
	J2xbgimyzlqUkODEtxPge5kNlJtrvWk4zEpxglu/IYiU/uHi4lNgkPYkxib3kXBGgHSAj26UZ5t
	npf930zr+ZT0Zqbcq0guARpdCTJfyKiCQMFaUttx+sqWfo090UDChEy3XP/QhuVc8GA==
X-Received: by 2002:a24:c7c7:: with SMTP id t190mr3587353itg.159.1559910566795;
        Fri, 07 Jun 2019 05:29:26 -0700 (PDT)
X-Received: by 2002:a24:c7c7:: with SMTP id t190mr3587292itg.159.1559910565758;
        Fri, 07 Jun 2019 05:29:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559910565; cv=none;
        d=google.com; s=arc-20160816;
        b=e7CQkSOHSGawE564MnYnVGSqsWaI9CDjwIewOFMkgoO/xMdxfK4YpiQDM4j0Kw0cq3
         eI6PYYPP5x/Lc9JlVvLP0SPfdl7DT9tCfkO5avEcoHa/GLPeYu4yQNZ0jb2vhCMSwcqm
         Hhcn5E1KDCL5MyTqrDXX5QKOhH3z7rhUGU695UrLaz94f1xY4jvkis6vIxWqG/CZWhyE
         6ouKdjWXVWa+M9RTQ1So/XoomhXysZS36A1Zv8yP4qUtGnHyc9uMxEAieeoMBFTFOLgK
         w4aBVJBflnWTGo+pcI/YWPAVlB84/A8x4todsOFBvjaaHScl1Co38thq2NQn03iQDUEh
         ZCSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZAvCebdzLCcSo6NRDYnZ6+WboqvZJ6BWkvuu4gNcNRU=;
        b=kVDoBsDoseX6ztDdh0Dtk2lmfGlMmFEeUtD7jRLEHKAJhtGqOjktA6QDjtvQLoUQOO
         Vyv00OOucuoXqvOVC4nVb/GalF0cB7TOVdStH1EsYwr9A/XRp6aZmecFnFSS/a/4uCxJ
         YJ/autrU99Wy/J+3TdfOXjnVJpyZHxMJBOzCZQ36vmlbX4SZhUEfOJ+kfev1ZflnA5VH
         gZws0gRR6+MP9YH43CkI9qDNE70OwBjbZt0J+/TNltYdvW8yb0iCfZHFXM9DLAK6C1J3
         cENMDGDfvFg8kD5MR4sC8EBIdmja3F2L3YxLKSq99FWS4D7UKxkOG8ef9TptwPUjS5ZL
         L8Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=l4nQx5bF;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16sor1053885ioj.130.2019.06.07.05.29.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 05:29:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=l4nQx5bF;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZAvCebdzLCcSo6NRDYnZ6+WboqvZJ6BWkvuu4gNcNRU=;
        b=l4nQx5bFXnCKwqIlYU0J3gLgZ0wR2UHkkyD80ob8NWqEzmyQRyDonYA1xejed7SD7I
         kl8UJmHVctl7fGkgf+4DP5y24neUBNA+zxlxJY3S4HVfsZwYCbLpbC5X/rnEuTmx0XXh
         TM3xqj2bbhQ5K2+gr7mtqkPtJTeLrCTJIkyzfvXg394Cl7G+Ji9ZKHSnA1ZN2SUSoI8i
         uwU2sOnfICyeKhaZfC07P/kXjxtmj4uZ0679dcT9GHa3muXEwPVuvI4jtVZZhHeErlrd
         8nBJksrkmuE8GCa9e4sgJfJqjQV2LI1VOgH3RQx135gNWHZBHKd/iVGw+7oY5dE1Bxte
         Coew==
X-Google-Smtp-Source: APXvYqwpgjUncM9YwGMeAEjGhHkH4kygINBHDj2ErQa4lBEYa0dUkEHo5JqszczMdAM7yNXhdyvGEegvK6pJJXoP2q8=
X-Received: by 2002:a5d:9402:: with SMTP id v2mr15677145ion.128.1559910565141;
 Fri, 07 Jun 2019 05:29:25 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu-J3-66V7UhH3=AjN4sX7iydHNF7Fd+SMbezaVNrZQmGQ@mail.gmail.com>
 <CAPcyv4g-GNe2vSYTn0a6ivQYxJdS5khE4AJbcxysoGPsTZwswg@mail.gmail.com>
 <CAKv+Gu83QB6x8=LCaAcR0S65WELC-Y+Voxw6LzaVh4FSV3bxYA@mail.gmail.com> <CAPcyv4hXBJBMrqoUr4qG5A3CUVgWzWK6bfBX29JnLCKDC7CiGA@mail.gmail.com>
In-Reply-To: <CAPcyv4hXBJBMrqoUr4qG5A3CUVgWzWK6bfBX29JnLCKDC7CiGA@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 7 Jun 2019 14:29:12 +0200
Message-ID: <CAKv+Gu_ZYpey0dWYebFgCaziyJ-_x+KbCmOegWqFjwC0U-5QaA@mail.gmail.com>
Subject: Re: [PATCH v2 4/8] x86, efi: Reserve UEFI 2.8 Specific Purpose Memory
 for dax
To: Dan Williams <dan.j.williams@intel.com>
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

On Sat, 1 Jun 2019 at 06:26, Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Fri, May 31, 2019 at 8:30 AM Ard Biesheuvel
> <ard.biesheuvel@linaro.org> wrote:
> >
> > On Fri, 31 May 2019 at 17:28, Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > On Fri, May 31, 2019 at 1:30 AM Ard Biesheuvel
> > > <ard.biesheuvel@linaro.org> wrote:
> > > >
> > > > (cc Mike for memblock)
> > > >
> > > > On Fri, 31 May 2019 at 01:13, Dan Williams <dan.j.williams@intel.com> wrote:
> > > > >
> > > > > UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
> > > > > interpretation of the EFI Memory Types as "reserved for a special
> > > > > purpose".
> > > > >
> > > > > The proposed Linux behavior for specific purpose memory is that it is
> > > > > reserved for direct-access (device-dax) by default and not available for
> > > > > any kernel usage, not even as an OOM fallback. Later, through udev
> > > > > scripts or another init mechanism, these device-dax claimed ranges can
> > > > > be reconfigured and hot-added to the available System-RAM with a unique
> > > > > node identifier.
> > > > >
> > > > > This patch introduces 3 new concepts at once given the entanglement
> > > > > between early boot enumeration relative to memory that can optionally be
> > > > > reserved from the kernel page allocator by default. The new concepts
> > > > > are:
> > > > >
> > > > > - E820_TYPE_SPECIFIC: Upon detecting the EFI_MEMORY_SP attribute on
> > > > >   EFI_CONVENTIONAL memory, update the E820 map with this new type. Only
> > > > >   perform this classification if the CONFIG_EFI_SPECIFIC_DAX=y policy is
> > > > >   enabled, otherwise treat it as typical ram.
> > > > >
> > > >
> > > > OK, so now we have 'special purpose', 'specific' and 'app specific'
> > > > [below]. Do they all mean the same thing?
> > >
> > > I struggled with separating the raw-EFI-type name from the name of the
> > > Linux specific policy. Since the reservation behavior is optional I
> > > was thinking there should be a distinct Linux kernel name for that
> > > policy. I did try to go back and change all occurrences of "special"
> > > to "specific" from the RFC to this v2, but seems I missed one.
> > >
> >
> > OK
>
> I'll go ahead and use "application reserved" terminology consistently
> throughout the code to distinguish that Linux translation from the raw
> "EFI specific purpose" attribute.
>

OK

> >
> > > >
> > > > > - IORES_DESC_APPLICATION_RESERVED: Add a new I/O resource descriptor for
> > > > >   a device driver to search iomem resources for application specific
> > > > >   memory. Teach the iomem code to identify such ranges as "Application
> > > > >   Reserved".
> > > > >
> > > > > - MEMBLOCK_APP_SPECIFIC: Given the memory ranges can fallback to the
> > > > >   traditional System RAM pool the expectation is that they will have
> > > > >   typical SRAT entries. In order to support a policy of device-dax by
> > > > >   default with the option to hotplug later, the numa initialization code
> > > > >   is taught to avoid marking online MEMBLOCK_APP_SPECIFIC regions.
> > > > >
> > > >
> > > > Can we move the generic memblock changes into a separate patch please?
> > >
> > > Yeah, that can move to a lead-in patch.
> > >
> > > [..]
> > > > > diff --git a/include/linux/efi.h b/include/linux/efi.h
> > > > > index 91368f5ce114..b57b123cbdf9 100644
> > > > > --- a/include/linux/efi.h
> > > > > +++ b/include/linux/efi.h
> > > > > @@ -129,6 +129,19 @@ typedef struct {
> > > > >         u64 attribute;
> > > > >  } efi_memory_desc_t;
> > > > >
> > > > > +#ifdef CONFIG_EFI_SPECIFIC_DAX
> > > > > +static inline bool is_efi_dax(efi_memory_desc_t *md)
> > > > > +{
> > > > > +       return md->type == EFI_CONVENTIONAL_MEMORY
> > > > > +               && (md->attribute & EFI_MEMORY_SP);
> > > > > +}
> > > > > +#else
> > > > > +static inline bool is_efi_dax(efi_memory_desc_t *md)
> > > > > +{
> > > > > +       return false;
> > > > > +}
> > > > > +#endif
> > > > > +
> > > > >  typedef struct {
> > > > >         efi_guid_t guid;
> > > > >         u32 headersize;
> > > >
> > > > I'd prefer it if we could avoid this DAX policy distinction leaking
> > > > into the EFI layer.
> > > >
> > > > IOW, I am fine with having a 'is_efi_sp_memory()' helper here, but
> > > > whether that is DAX memory or not should be decided in the DAX layer.
> > >
> > > Ok, how about is_efi_sp_ram()? Since EFI_MEMORY_SP might be applied to
> > > things that aren't EFI_CONVENTIONAL_MEMORY.
> >
> > Yes, that is fine. As long as the #ifdef lives in the DAX code and not here.
>
> We still need some ifdef in the efi core because that is the central
> location to make the policy distinction to identify identify
> EFI_CONVENTIONAL_MEMORY differently depending on whether EFI_MEMORY_SP
> is present. I agree with you that "dax" should be dropped from the
> naming. So how about:
>
> #ifdef CONFIG_EFI_APPLICATION_RESERVED
> static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> {
>         return md->type == EFI_CONVENTIONAL_MEMORY
>                 && (md->attribute & EFI_MEMORY_SP);
> }
> #else
> static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> {
>         return false;
> }
> #endif

I think this policy decision should not live inside the EFI subsystem.
EFI just gives you the memory map, and mangling that information
depending on whether you think a certain memory attribute should be
ignored is the job of the MM subsystem.

