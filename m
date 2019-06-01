Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE6C9C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 04:26:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84E4A27122
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 04:26:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="eULIT2RU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84E4A27122
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E283C6B0008; Sat,  1 Jun 2019 00:26:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD96A6B000A; Sat,  1 Jun 2019 00:26:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9FE06B000C; Sat,  1 Jun 2019 00:26:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id A06786B0008
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 00:26:54 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id x27so5588387ote.6
        for <linux-mm@kvack.org>; Fri, 31 May 2019 21:26:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QNhOzt9mi4QEW/UkqlsD+LhM4aY8Y6V5JqJaEQnQrZQ=;
        b=Qu4q718YIS/8nq6TNi/TkeWm8GpQit6HT8Jz/QK2Ip9T/Ep653hYhPmMJXf8+n+Jxj
         sHZ3jCj8YpG5rK+T6zoVjDvjU4THO88vbLx4i7mSUhZ890N5ran0AD2PQrdjfBuorbzS
         8VNhwh3kWrRROg9awnsDsnf5F6F8wa1bkVDH/ZyuaHcX0E1TSOsRbHkeNKsG8k2mb35R
         0e9h4BX8J9v+jaxEkCpbyHwM4ucP35Oseu6GUB/Xpo9srcb1NY53tqkD7iTe5rrabpq6
         ClLAeQKbpUF4MC1nsJE++UhopjTCqDahReTG0qHJsTuuEUXhHZ1u6/if6diLwVSB3Qvr
         aXxw==
X-Gm-Message-State: APjAAAUYde5byo/cwYV0KnHYoCpsC/waIQEN6JRMYAHvYEuAwkz0rGE2
	mfyaEcm57fLN1Gnase2jjRX9c9IdnQKsMGPNnuG+OXCuQaPZIx3lJs5jV6FCQwWvyDikzS78Hfu
	3ggtGH7x+lYBqwlQVf0bp7rbtrYCFeJuBRvwExIJljgu0TYtU7ru5XPBZwNF8qjaEfQ==
X-Received: by 2002:aca:bb07:: with SMTP id l7mr1117996oif.124.1559363214119;
        Fri, 31 May 2019 21:26:54 -0700 (PDT)
X-Received: by 2002:aca:bb07:: with SMTP id l7mr1117974oif.124.1559363212793;
        Fri, 31 May 2019 21:26:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559363212; cv=none;
        d=google.com; s=arc-20160816;
        b=YFYF690+dRrcWOKdPXpWJwlFOZwDy4Pk11/WaL8XLdhCl82IxWkIzUvCQUk1Jf7q0H
         3GFKNi3f+AVESMJTRjCxJpeebTP+xsRRjOIeBANmbKVmlkg+b1LtxbemylWKQ91kEnUP
         COWyZv8XmcNzH0YJ0gDvUgBO4BLPVTAlm3YJBjfT7x7CanO86ulhuMxeIn2vm45OUiF3
         rVLH1XlQn1iPyLUa/ylazW3ux4tYLPHZjISNwOc7uuAm7dz095QMuT/IvNdbfwvcgbQQ
         3tTQbhw0x13EQNC+gT2dJhc8ySM0FVpOU24mmoRLPu8U9wSihRw6olbBUJqQvP53EQgu
         Ox8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QNhOzt9mi4QEW/UkqlsD+LhM4aY8Y6V5JqJaEQnQrZQ=;
        b=CqX+iLP8M1or2+c7jzsfjZf1R2SbG5R2VVdaaS7We6LHTuFw8jct7luQDSE3J1wtqd
         7VH24aGk4T/+FNzbHd2RkrSB7Ps5+4eN0qgHh50M9o8dk55cWJRDOXdtcI7ARIc+hbHT
         CDfUEikmMYQ4a40NyqLa2PjkkMFKjT4FiSlvmsJgNZjh1obsOyNCZqPj64LZQE+mH4US
         9Ni0Yd+O0B1k++M34fhUUadGR6B7vaoLmJ+TISOki1HykmW20M+RmrLossHBEIygvCpl
         HcXFnNJg2bD3uzONMkOL2f0AOipvOjEXbNRAruGOHtKnhD7SQvhNlMtb/ooD/AcmLdnu
         Xv6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=eULIT2RU;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s130sor3168034oie.27.2019.05.31.21.26.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 21:26:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=eULIT2RU;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QNhOzt9mi4QEW/UkqlsD+LhM4aY8Y6V5JqJaEQnQrZQ=;
        b=eULIT2RUbl0QppQ6H9eCEst+tZtjWGfwdar6IgE+5A7dmFfh1ZeY2XyDRx/oNIhgUO
         GGNsqiKa0xpM3Nr2i9e786mXzhwNl/Xq1eonERgnlCZNWV/tYdtfaWjSgwdr/1tzfk/L
         5DO4m0UXmprTZzmKQs8b0kC5v7kUXidi2LJZrJxpAo3HErjCp/QvGRV6X0RTnBZ34ZKr
         udmUl3O34LWsBSKBasIJfybnTQpG5SpiwAMaozCzfOr3ifgomLjfRfGhu+foVEa36g3o
         TZY+dEmnqWFGw+Wg1ZmxdcQYZRfNnHrzZWhRHxNEjj6tazoyTq109M4x5OzNtB7fQ9aZ
         sgdA==
X-Google-Smtp-Source: APXvYqzaVrB3g+ABIuTUypcECW4eQQb+L1oF8XmOAVSlRCVDBJ3IC+ot8aNdAKsRh5Ex61K+ZnvQLoiDoa1OvrTEoaY=
X-Received: by 2002:aca:6087:: with SMTP id u129mr1104493oib.70.1559363212074;
 Fri, 31 May 2019 21:26:52 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu-J3-66V7UhH3=AjN4sX7iydHNF7Fd+SMbezaVNrZQmGQ@mail.gmail.com>
 <CAPcyv4g-GNe2vSYTn0a6ivQYxJdS5khE4AJbcxysoGPsTZwswg@mail.gmail.com> <CAKv+Gu83QB6x8=LCaAcR0S65WELC-Y+Voxw6LzaVh4FSV3bxYA@mail.gmail.com>
In-Reply-To: <CAKv+Gu83QB6x8=LCaAcR0S65WELC-Y+Voxw6LzaVh4FSV3bxYA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 31 May 2019 21:26:40 -0700
Message-ID: <CAPcyv4hXBJBMrqoUr4qG5A3CUVgWzWK6bfBX29JnLCKDC7CiGA@mail.gmail.com>
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

On Fri, May 31, 2019 at 8:30 AM Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
>
> On Fri, 31 May 2019 at 17:28, Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Fri, May 31, 2019 at 1:30 AM Ard Biesheuvel
> > <ard.biesheuvel@linaro.org> wrote:
> > >
> > > (cc Mike for memblock)
> > >
> > > On Fri, 31 May 2019 at 01:13, Dan Williams <dan.j.williams@intel.com> wrote:
> > > >
> > > > UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
> > > > interpretation of the EFI Memory Types as "reserved for a special
> > > > purpose".
> > > >
> > > > The proposed Linux behavior for specific purpose memory is that it is
> > > > reserved for direct-access (device-dax) by default and not available for
> > > > any kernel usage, not even as an OOM fallback. Later, through udev
> > > > scripts or another init mechanism, these device-dax claimed ranges can
> > > > be reconfigured and hot-added to the available System-RAM with a unique
> > > > node identifier.
> > > >
> > > > This patch introduces 3 new concepts at once given the entanglement
> > > > between early boot enumeration relative to memory that can optionally be
> > > > reserved from the kernel page allocator by default. The new concepts
> > > > are:
> > > >
> > > > - E820_TYPE_SPECIFIC: Upon detecting the EFI_MEMORY_SP attribute on
> > > >   EFI_CONVENTIONAL memory, update the E820 map with this new type. Only
> > > >   perform this classification if the CONFIG_EFI_SPECIFIC_DAX=y policy is
> > > >   enabled, otherwise treat it as typical ram.
> > > >
> > >
> > > OK, so now we have 'special purpose', 'specific' and 'app specific'
> > > [below]. Do they all mean the same thing?
> >
> > I struggled with separating the raw-EFI-type name from the name of the
> > Linux specific policy. Since the reservation behavior is optional I
> > was thinking there should be a distinct Linux kernel name for that
> > policy. I did try to go back and change all occurrences of "special"
> > to "specific" from the RFC to this v2, but seems I missed one.
> >
>
> OK

I'll go ahead and use "application reserved" terminology consistently
throughout the code to distinguish that Linux translation from the raw
"EFI specific purpose" attribute.

>
> > >
> > > > - IORES_DESC_APPLICATION_RESERVED: Add a new I/O resource descriptor for
> > > >   a device driver to search iomem resources for application specific
> > > >   memory. Teach the iomem code to identify such ranges as "Application
> > > >   Reserved".
> > > >
> > > > - MEMBLOCK_APP_SPECIFIC: Given the memory ranges can fallback to the
> > > >   traditional System RAM pool the expectation is that they will have
> > > >   typical SRAT entries. In order to support a policy of device-dax by
> > > >   default with the option to hotplug later, the numa initialization code
> > > >   is taught to avoid marking online MEMBLOCK_APP_SPECIFIC regions.
> > > >
> > >
> > > Can we move the generic memblock changes into a separate patch please?
> >
> > Yeah, that can move to a lead-in patch.
> >
> > [..]
> > > > diff --git a/include/linux/efi.h b/include/linux/efi.h
> > > > index 91368f5ce114..b57b123cbdf9 100644
> > > > --- a/include/linux/efi.h
> > > > +++ b/include/linux/efi.h
> > > > @@ -129,6 +129,19 @@ typedef struct {
> > > >         u64 attribute;
> > > >  } efi_memory_desc_t;
> > > >
> > > > +#ifdef CONFIG_EFI_SPECIFIC_DAX
> > > > +static inline bool is_efi_dax(efi_memory_desc_t *md)
> > > > +{
> > > > +       return md->type == EFI_CONVENTIONAL_MEMORY
> > > > +               && (md->attribute & EFI_MEMORY_SP);
> > > > +}
> > > > +#else
> > > > +static inline bool is_efi_dax(efi_memory_desc_t *md)
> > > > +{
> > > > +       return false;
> > > > +}
> > > > +#endif
> > > > +
> > > >  typedef struct {
> > > >         efi_guid_t guid;
> > > >         u32 headersize;
> > >
> > > I'd prefer it if we could avoid this DAX policy distinction leaking
> > > into the EFI layer.
> > >
> > > IOW, I am fine with having a 'is_efi_sp_memory()' helper here, but
> > > whether that is DAX memory or not should be decided in the DAX layer.
> >
> > Ok, how about is_efi_sp_ram()? Since EFI_MEMORY_SP might be applied to
> > things that aren't EFI_CONVENTIONAL_MEMORY.
>
> Yes, that is fine. As long as the #ifdef lives in the DAX code and not here.

We still need some ifdef in the efi core because that is the central
location to make the policy distinction to identify identify
EFI_CONVENTIONAL_MEMORY differently depending on whether EFI_MEMORY_SP
is present. I agree with you that "dax" should be dropped from the
naming. So how about:

#ifdef CONFIG_EFI_APPLICATION_RESERVED
static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
{
        return md->type == EFI_CONVENTIONAL_MEMORY
                && (md->attribute & EFI_MEMORY_SP);
}
#else
static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
{
        return false;
}
#endif

