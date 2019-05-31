Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF4A5C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 15:28:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A15A26B88
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 15:28:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="XIVyr9YG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A15A26B88
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2658B6B0274; Fri, 31 May 2019 11:28:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 215C46B0278; Fri, 31 May 2019 11:28:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1045B6B027A; Fri, 31 May 2019 11:28:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id D35F76B0274
	for <linux-mm@kvack.org>; Fri, 31 May 2019 11:28:35 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id l63so3627707oia.7
        for <linux-mm@kvack.org>; Fri, 31 May 2019 08:28:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=b9VU1ThXRX1owmBXLf1YRTdum6FS+CeP7p64pXwOkS8=;
        b=QXWjsTwCbflT0jhJZp/Jt6uUyMz/sGPcZ7WrnW0u49YrJ98BI/KtivnzllDDcTy3/B
         PSoKOmtqAJpTifpatFizKrMHtxgh+0926UKGEigxxLTraYlk856b3oIHzR9Gf78X7f3j
         qzfdz1eTuu11TMzR9uDZdEIHODabLzb7UwrAkytOGdKElCVPGJvTxl9zU1FtYEjWJ43j
         B6hqugK7K8jfQ3xB7BpOFEffA7MopFYourCnfbotgX4AJDwqKlZLkLrtS75xQnADUfQf
         AruzZpTpbg6qSjbh+liIsueIPtWaGCAn5bZv2N6HEx7rPvQC4q4Bu8mZ9vi+1NwO1hQH
         pwLw==
X-Gm-Message-State: APjAAAXTeMqrfveVnhbFMOaigeQlinGVolY3dbY0hGLaLUt39a0FwMgS
	4D9wnUBgEcS6m/19sZo69HcqThmVEGCnjaA+Ibza8x+acfczjJTQdwM32+j+L5wFJPPphM92RZ1
	8mjZZTMIu1K4fg1JfaLfJbw2SMbZR/NCm1lOkaCnZWNFKtVvZr06BusVH86vjbyxbrA==
X-Received: by 2002:a9d:d23:: with SMTP id 32mr2210553oti.174.1559316515541;
        Fri, 31 May 2019 08:28:35 -0700 (PDT)
X-Received: by 2002:a9d:d23:: with SMTP id 32mr2210506oti.174.1559316514675;
        Fri, 31 May 2019 08:28:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559316514; cv=none;
        d=google.com; s=arc-20160816;
        b=LHEXuj4Sw2X1A24lWnuyGmFiRlbRBg1+HUxiFAnH3zr6JR8OM6Awx4RONLg+Rdt7i0
         rqpk2UCY4jHjh0vczWK0YRqnM2gR1IOCE2+hLO4tVGX9el8JePdjXzF0c4ew9djKjjoG
         Qk8xlMGwzcsR+oteFCvytHzXZRt6EeoTicNNSHV1UctapOz7giM4TRL4yUvO49Sn0Hwv
         FYcA+RfrHhyGnz8utQKFYx6XDBZkdXtdMTvbzwaIgotZfUTUTWB8D4Azw7DYzPURIely
         glQW022HKdj7/GEbTibVcWsFLap9Y/IUQT+1w+SVqxPhJqRbk7p6oS3MEFoLSScOob/i
         TKmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=b9VU1ThXRX1owmBXLf1YRTdum6FS+CeP7p64pXwOkS8=;
        b=GyP/B5Kg5jEuEZweBwQef91Ko3EPxOEr7OJcX9NfiSl9h8cgTIeyqdaPHj4Bggu7Zj
         t5kyKjBV3MjbPI5VCePJ9pJvpAGaNMjUreTG3YtUHAIY0Z87UaG6p9aq+ZgiVgc8A+4i
         HGysR0lOpB0qZctq+MDiVPXikwfLZ1pL0WCF7/IF37fm372dmmX55f5O/1J0VNt+QetB
         P1nwvEwViSyK7dwfF5tIC43t0+Wr6ol9pgCMminq+wGA+i+C/BL0XdlV0qVDryvu8s2P
         epOThQNwFxqXud8/+tFriyNgsngBK5YDz5/M8mxbSblx5MLGgmDsMYZku+S1RGNEfWfj
         u6yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=XIVyr9YG;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q82sor872835oif.161.2019.05.31.08.28.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 08:28:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=XIVyr9YG;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=b9VU1ThXRX1owmBXLf1YRTdum6FS+CeP7p64pXwOkS8=;
        b=XIVyr9YGPbDuCLeXxxYbVHOG05ctX7hT5HQsP6nJa1j1DnKaasZz5JB/RK6lDSpx+c
         HzfmGWxWYWzMnEbBdfQQMvYVCEFWGl/60vfUVApHkfZB3ZcxcXr2uDikIZEu8remlQTX
         ftwGSjmXObo5h3R/pVFyxxIharRZXdgiTzIXVwSkHaaoMvrQ+jrSlPXBr9pUz82jFrQl
         vWR78tkx85FB7kfi8ds326K/U/oggOsmavXYa7FO1quTWH0e6v5aUWbaehnliUADmxfH
         S0jV6S1DZIMs06nuxz6DrfT88NultFFHDaCNLKDiF7b31aCK/AUuV0AuXv0XrCNxPnLx
         mzuA==
X-Google-Smtp-Source: APXvYqy30mw0sLftLrl/aUtPyWC+IDu0mVJfVClUdLCKR5NDk2l1hNOYNXFLrWvyRqIfX8K1tYPXy7QBcir0mZrwRQY=
X-Received: by 2002:aca:6087:: with SMTP id u129mr6243189oib.70.1559316514205;
 Fri, 31 May 2019 08:28:34 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu-J3-66V7UhH3=AjN4sX7iydHNF7Fd+SMbezaVNrZQmGQ@mail.gmail.com>
In-Reply-To: <CAKv+Gu-J3-66V7UhH3=AjN4sX7iydHNF7Fd+SMbezaVNrZQmGQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 31 May 2019 08:28:22 -0700
Message-ID: <CAPcyv4g-GNe2vSYTn0a6ivQYxJdS5khE4AJbcxysoGPsTZwswg@mail.gmail.com>
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

On Fri, May 31, 2019 at 1:30 AM Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
>
> (cc Mike for memblock)
>
> On Fri, 31 May 2019 at 01:13, Dan Williams <dan.j.williams@intel.com> wrote:
> >
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
>
> OK, so now we have 'special purpose', 'specific' and 'app specific'
> [below]. Do they all mean the same thing?

I struggled with separating the raw-EFI-type name from the name of the
Linux specific policy. Since the reservation behavior is optional I
was thinking there should be a distinct Linux kernel name for that
policy. I did try to go back and change all occurrences of "special"
to "specific" from the RFC to this v2, but seems I missed one.

>
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
> >
>
> Can we move the generic memblock changes into a separate patch please?

Yeah, that can move to a lead-in patch.

[..]
> > diff --git a/include/linux/efi.h b/include/linux/efi.h
> > index 91368f5ce114..b57b123cbdf9 100644
> > --- a/include/linux/efi.h
> > +++ b/include/linux/efi.h
> > @@ -129,6 +129,19 @@ typedef struct {
> >         u64 attribute;
> >  } efi_memory_desc_t;
> >
> > +#ifdef CONFIG_EFI_SPECIFIC_DAX
> > +static inline bool is_efi_dax(efi_memory_desc_t *md)
> > +{
> > +       return md->type == EFI_CONVENTIONAL_MEMORY
> > +               && (md->attribute & EFI_MEMORY_SP);
> > +}
> > +#else
> > +static inline bool is_efi_dax(efi_memory_desc_t *md)
> > +{
> > +       return false;
> > +}
> > +#endif
> > +
> >  typedef struct {
> >         efi_guid_t guid;
> >         u32 headersize;
>
> I'd prefer it if we could avoid this DAX policy distinction leaking
> into the EFI layer.
>
> IOW, I am fine with having a 'is_efi_sp_memory()' helper here, but
> whether that is DAX memory or not should be decided in the DAX layer.

Ok, how about is_efi_sp_ram()? Since EFI_MEMORY_SP might be applied to
things that aren't EFI_CONVENTIONAL_MEMORY.

