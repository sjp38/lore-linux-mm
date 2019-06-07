Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EF5EC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F11A62089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:24:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="byzmTdhe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F11A62089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D3766B0007; Fri,  7 Jun 2019 11:24:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7830F6B000C; Fri,  7 Jun 2019 11:24:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 698E86B000E; Fri,  7 Jun 2019 11:24:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4111C6B0007
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 11:24:08 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x27so1082096ote.6
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 08:24:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=tejEOI/tX7FNKVM+CoLTw76zsOlMQPJj4RVZ/MPUAHI=;
        b=h4ZMpVR8M77N0h9qJnQlH4H5u9QNdsKN+OSoFwDr01oH9HDlxFSazq9CUK3NBEgfwH
         HLoMxoxS1z4ekDol1fSBi6LTTUBC5YPFhBGu5jWCd4iysCcqEV1wMdxe3WdaKDLp86DU
         /EqUEeK/luoxW4exPLGlPx5OKtpCm+p8RAKlAesSqIz3oZqBqnGSFzyh30T7KTA7zHwf
         fR8dDeCslNl6gdB1xuYN32h8sjMdOctjTEB1vugjSF7CozAlyTY28cZcO64q9qIF+VOX
         uhzrocTwgtySEKYoG5Q2hQlYdT2tLDzIcylbMuumlBVWH1huYgVRQrRRuO+vYZGHWV4z
         Jhvw==
X-Gm-Message-State: APjAAAUYvDtqSyltAbFIkqHRjynWpVkNeUljNBGkKFUOo/jBgqp5dKhR
	pb4+uGqd+xnEyhI5lfj/waviA0eEbH6q4wV3aNSzE5sSLmmh7zE3oAPby7a+LgNRHZLCgFoSapM
	7NMYZmIxiZSQwqmN2g4N5GYoTCopGzNj7v6+yENa2QhbcF7RgeSIRE4rRS5aV7MfbPQ==
X-Received: by 2002:aca:ecc1:: with SMTP id k184mr4231742oih.82.1559921047702;
        Fri, 07 Jun 2019 08:24:07 -0700 (PDT)
X-Received: by 2002:aca:ecc1:: with SMTP id k184mr4231692oih.82.1559921046444;
        Fri, 07 Jun 2019 08:24:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559921046; cv=none;
        d=google.com; s=arc-20160816;
        b=xbb2vYQu2pYZ/fCDqGjtyZUwtRi5oGsEkYCj2FFyjnRPBqwqm80kt04ddRoXgQuxcs
         Ni40q7ozTvT0uZpBzhWG9kDHet9vK5m243H1+khGX59hquNNGNG45I1wYfDlRuST7ej6
         pjlJcluKT5ZtL4jm1I0PFTzwYLDLef8O0e+5MB/+yg3BQq8ULaUAKAA65uTEWDaps1ZC
         iMRsN6JSesN8M7dWbGWjnxW3zdQDEoYFQR2l0KCG5tKAH8zcjt63+kvUsXIB2B5Nbek6
         7qQMZPRnGMjLwo3haUWKUYleiIKgRLFay7PrZm54vUFuzHKF39chZuRQyYa/G5tgwfg+
         YIVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=tejEOI/tX7FNKVM+CoLTw76zsOlMQPJj4RVZ/MPUAHI=;
        b=0IAe5XTqi6UPU61BghIhDSVZjb7kDf45FIwD79saXP8OG8CA9SOKk/6yyqF9hvZCH1
         apUAdOHKNNeV40MYOmlU8C7fF9b4reMqgeWxasRxCy9mbNCxhkkYLAxhCMsfPPNj7D1Y
         mwCsPPmTZqxqWnx8DDNh2uP6ykzpgg8gmw8UvRXMF0QcYf65qVl8DEdzUI8ucdOs2R0g
         eV/IjEIVrepS6tYGheYKSvIIqzO5PkI6I73DVnTSN6LpnYNqc0RS57bJIPARV9xOSKN6
         chxVOqKvn7y+WGYWj5gwVumoUKHrDKMjgtumaGTnrkt+y9YMm0Bk2ibawIule2gr3G78
         Lvcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=byzmTdhe;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y130sor835135oiy.120.2019.06.07.08.24.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 08:24:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=byzmTdhe;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=tejEOI/tX7FNKVM+CoLTw76zsOlMQPJj4RVZ/MPUAHI=;
        b=byzmTdhe8GPLUJgF0izWUXQDBFk0FnSAv+KzTH9y220f/yor1a8c1S0UgUJfr1olT1
         4HMvM9c6eIg/UwcX5CW0gHcyFmwGyWqJ78nn2zK9d8U7DF3i/bMrCOkbG1KL+Bwryxpb
         TRgHArzPRXy31t2OxCMXBGANR9pMgb5FSauN5yKWnbvHNvrf0BLAXbLEArJ0SFxY0bz7
         fKC0k/D2UYErX4LaV8Jf2NTFs6Fww8mJKTWcKsRpDb0f+iQbNopvtdmds8fnoyFO+qvv
         GJbZRkYpQy7c+Q8HSAvvMK23E0ElkbLXCVNYkKPRHdKZPWNJBtB8dhhVTVaL/Xu0v8Lg
         qYQw==
X-Google-Smtp-Source: APXvYqwMUyeo9bVoYx3l1KR9n9bzeoG7oZcFvmWmrWd7uYQgk+B7crHCKrTdgByt1XX6EYGWhaAUrFTB1MJMD+sJIss=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr4310345oii.0.1559921045671;
 Fri, 07 Jun 2019 08:24:05 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu-J3-66V7UhH3=AjN4sX7iydHNF7Fd+SMbezaVNrZQmGQ@mail.gmail.com>
 <CAPcyv4g-GNe2vSYTn0a6ivQYxJdS5khE4AJbcxysoGPsTZwswg@mail.gmail.com>
 <CAKv+Gu83QB6x8=LCaAcR0S65WELC-Y+Voxw6LzaVh4FSV3bxYA@mail.gmail.com>
 <CAPcyv4hXBJBMrqoUr4qG5A3CUVgWzWK6bfBX29JnLCKDC7CiGA@mail.gmail.com> <CAKv+Gu_ZYpey0dWYebFgCaziyJ-_x+KbCmOegWqFjwC0U-5QaA@mail.gmail.com>
In-Reply-To: <CAKv+Gu_ZYpey0dWYebFgCaziyJ-_x+KbCmOegWqFjwC0U-5QaA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 7 Jun 2019 08:23:54 -0700
Message-ID: <CAPcyv4jO5WhRJ-=Nz70Jc0mCHYBJ6NsHjJNk6AerwQXH43oemw@mail.gmail.com>
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

On Fri, Jun 7, 2019 at 5:29 AM Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>
> On Sat, 1 Jun 2019 at 06:26, Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Fri, May 31, 2019 at 8:30 AM Ard Biesheuvel
> > <ard.biesheuvel@linaro.org> wrote:
> > >
> > > On Fri, 31 May 2019 at 17:28, Dan Williams <dan.j.williams@intel.com> wrote:
> > > >
> > > > On Fri, May 31, 2019 at 1:30 AM Ard Biesheuvel
> > > > <ard.biesheuvel@linaro.org> wrote:
> > > > >
> > > > > (cc Mike for memblock)
> > > > >
> > > > > On Fri, 31 May 2019 at 01:13, Dan Williams <dan.j.williams@intel.com> wrote:
> > > > > >
> > > > > > UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
> > > > > > interpretation of the EFI Memory Types as "reserved for a special
> > > > > > purpose".
> > > > > >
> > > > > > The proposed Linux behavior for specific purpose memory is that it is
> > > > > > reserved for direct-access (device-dax) by default and not available for
> > > > > > any kernel usage, not even as an OOM fallback. Later, through udev
> > > > > > scripts or another init mechanism, these device-dax claimed ranges can
> > > > > > be reconfigured and hot-added to the available System-RAM with a unique
> > > > > > node identifier.
> > > > > >
> > > > > > This patch introduces 3 new concepts at once given the entanglement
> > > > > > between early boot enumeration relative to memory that can optionally be
> > > > > > reserved from the kernel page allocator by default. The new concepts
> > > > > > are:
> > > > > >
> > > > > > - E820_TYPE_SPECIFIC: Upon detecting the EFI_MEMORY_SP attribute on
> > > > > >   EFI_CONVENTIONAL memory, update the E820 map with this new type. Only
> > > > > >   perform this classification if the CONFIG_EFI_SPECIFIC_DAX=y policy is
> > > > > >   enabled, otherwise treat it as typical ram.
> > > > > >
> > > > >
> > > > > OK, so now we have 'special purpose', 'specific' and 'app specific'
> > > > > [below]. Do they all mean the same thing?
> > > >
> > > > I struggled with separating the raw-EFI-type name from the name of the
> > > > Linux specific policy. Since the reservation behavior is optional I
> > > > was thinking there should be a distinct Linux kernel name for that
> > > > policy. I did try to go back and change all occurrences of "special"
> > > > to "specific" from the RFC to this v2, but seems I missed one.
> > > >
> > >
> > > OK
> >
> > I'll go ahead and use "application reserved" terminology consistently
> > throughout the code to distinguish that Linux translation from the raw
> > "EFI specific purpose" attribute.
> >
>
> OK
>
> > >
> > > > >
> > > > > > - IORES_DESC_APPLICATION_RESERVED: Add a new I/O resource descriptor for
> > > > > >   a device driver to search iomem resources for application specific
> > > > > >   memory. Teach the iomem code to identify such ranges as "Application
> > > > > >   Reserved".
> > > > > >
> > > > > > - MEMBLOCK_APP_SPECIFIC: Given the memory ranges can fallback to the
> > > > > >   traditional System RAM pool the expectation is that they will have
> > > > > >   typical SRAT entries. In order to support a policy of device-dax by
> > > > > >   default with the option to hotplug later, the numa initialization code
> > > > > >   is taught to avoid marking online MEMBLOCK_APP_SPECIFIC regions.
> > > > > >
> > > > >
> > > > > Can we move the generic memblock changes into a separate patch please?
> > > >
> > > > Yeah, that can move to a lead-in patch.
> > > >
> > > > [..]
> > > > > > diff --git a/include/linux/efi.h b/include/linux/efi.h
> > > > > > index 91368f5ce114..b57b123cbdf9 100644
> > > > > > --- a/include/linux/efi.h
> > > > > > +++ b/include/linux/efi.h
> > > > > > @@ -129,6 +129,19 @@ typedef struct {
> > > > > >         u64 attribute;
> > > > > >  } efi_memory_desc_t;
> > > > > >
> > > > > > +#ifdef CONFIG_EFI_SPECIFIC_DAX
> > > > > > +static inline bool is_efi_dax(efi_memory_desc_t *md)
> > > > > > +{
> > > > > > +       return md->type == EFI_CONVENTIONAL_MEMORY
> > > > > > +               && (md->attribute & EFI_MEMORY_SP);
> > > > > > +}
> > > > > > +#else
> > > > > > +static inline bool is_efi_dax(efi_memory_desc_t *md)
> > > > > > +{
> > > > > > +       return false;
> > > > > > +}
> > > > > > +#endif
> > > > > > +
> > > > > >  typedef struct {
> > > > > >         efi_guid_t guid;
> > > > > >         u32 headersize;
> > > > >
> > > > > I'd prefer it if we could avoid this DAX policy distinction leaking
> > > > > into the EFI layer.
> > > > >
> > > > > IOW, I am fine with having a 'is_efi_sp_memory()' helper here, but
> > > > > whether that is DAX memory or not should be decided in the DAX layer.
> > > >
> > > > Ok, how about is_efi_sp_ram()? Since EFI_MEMORY_SP might be applied to
> > > > things that aren't EFI_CONVENTIONAL_MEMORY.
> > >
> > > Yes, that is fine. As long as the #ifdef lives in the DAX code and not here.
> >
> > We still need some ifdef in the efi core because that is the central
> > location to make the policy distinction to identify identify
> > EFI_CONVENTIONAL_MEMORY differently depending on whether EFI_MEMORY_SP
> > is present. I agree with you that "dax" should be dropped from the
> > naming. So how about:
> >
> > #ifdef CONFIG_EFI_APPLICATION_RESERVED
> > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > {
> >         return md->type == EFI_CONVENTIONAL_MEMORY
> >                 && (md->attribute & EFI_MEMORY_SP);
> > }
> > #else
> > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > {
> >         return false;
> > }
> > #endif
>
> I think this policy decision should not live inside the EFI subsystem.
> EFI just gives you the memory map, and mangling that information
> depending on whether you think a certain memory attribute should be
> ignored is the job of the MM subsystem.

The problem is that we don't have an mm subsystem at the time a
decision needs to be made. The reservation policy needs to be deployed
before even memblock has been initialized in order to keep kernel
allocations out of the reservation. I agree with the sentiment I just
don't see how to practically achieve an optional "System RAM" vs
"Application Reserved" routing decision without an early (before
e820__memblock_setup()) conditional branch.

