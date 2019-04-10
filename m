Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41262C10F0E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 02:11:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFD7621741
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 02:11:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="0pg82SOI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFD7621741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D9CB6B0006; Tue,  9 Apr 2019 22:11:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1898F6B0008; Tue,  9 Apr 2019 22:11:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 029556B000A; Tue,  9 Apr 2019 22:11:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id D044C6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 22:11:06 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id q203so871461itb.2
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 19:11:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8B9lCJLeymvncj1USaXc65os0BUeWCHWyugSHvMXZpk=;
        b=nlKVBYKiQdFS9pPtBdyZtMJWRvbcZ97w68nzTtHjMYE77YLdZbLICZ217LOURl7stE
         tqG/LXTQcDy5ttRA+Kv89NkKSmXB+fGTDqUdGEJgX+Xpd6TwMBfeuCkBFeuPxv7LXTxj
         O2tYsOrS9UY7/MNlLZA0acifmkV9LQBYDx5IhNqMMLBzsUH3s5SrMLoPid5GVe9MCls7
         lTYtoybduZ6mBaZWhEPEgFybISBexkbq2lcqvyXRa50SFwhL9tT7iaRW041eLGP84cS9
         lymhStDyvJGNu2hGk8fDVsHEtgJT+uhGbtV4+8UpGwmpBx2l+/IG2CaHHKwielDYDV9w
         6wDA==
X-Gm-Message-State: APjAAAXUfuAhxbuaLtejOi9gfv/ua3aWl3d3RyhH39/bPDEbT9DZyDMz
	yF25/OYOGPxyzttSPPTOxX+mbmQeFlIfQxCEemU6lsIL1oR61iTNAZKplU7YY2N9/JovE8x4xCG
	pN52+K9YflkOrR7pRXivCgy+Z6e9mZPXB2yWyZ2nludDOxMt1rOFV7nfZb9QIOuM=
X-Received: by 2002:a02:9345:: with SMTP id e5mr29070921jah.29.1554862266456;
        Tue, 09 Apr 2019 19:11:06 -0700 (PDT)
X-Received: by 2002:a02:9345:: with SMTP id e5mr29070891jah.29.1554862265610;
        Tue, 09 Apr 2019 19:11:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554862265; cv=none;
        d=google.com; s=arc-20160816;
        b=oa6sIs4Wr/2EojAmOpWVFJ+KFW1hoWc9BJKI5B+InNEXImA9Wmz6RONGxDU/QGvPFl
         IivpWXfgmHWz+eIkZG0pZfZRv5W5nHQGWnlBzAWVFgP+XwCrgluEHks/+YQPzIdmX4j+
         Lkv8MFEev7ELV7rs7SOQRCB6tkKOA6nRyTmKS13JOGZEFEf4DNGcAVn1dX0RJ9gQSJUY
         SKwRLnGRyDwAXdu1iJoiN6YmHgcNadaIqOQTDQhaMzNYW6fcCzTcMSkK4NU/J9s+EirD
         mS7P6pXVfsu+YwKo8va0Ol/raia+6jM+zsuc6g2YiFr9ydY+lJxmt987zscjjafT9TDM
         78tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8B9lCJLeymvncj1USaXc65os0BUeWCHWyugSHvMXZpk=;
        b=Uxil8YnJkyxXw5AH16NaHDAYXB+43vbNookCVuAeAsU0BvWg0R1wOVP+oTw/RX1XfR
         I9DYom5duWdPv91HKwOdlX5dv+klospp0yKZQk95HWVDK5uToIzIJmPJZPs9Lcn1BsBc
         ygt+FXZUp0I0uFDjSeqyUEn0/QGlEDgnkxeZjxUbOFpGbaeUw5hdG8uKFiMFi2a0DQRX
         r0kcPUwtAypx9aqdpMnTV91PL7QvkzaHWUoMjhQsqOQYcb9t5u11SwI4myt6YpZ4Gz4p
         f6aoX1J26jH/xr6lyILsDPqtRgrkFCIbfn7VIG97+GqFNpZd4AUSvwSte7+w6b9Cgszc
         KHrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=0pg82SOI;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z200sor1328995itb.10.2019.04.09.19.11.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 19:11:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=0pg82SOI;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8B9lCJLeymvncj1USaXc65os0BUeWCHWyugSHvMXZpk=;
        b=0pg82SOIoW+W0YyQ5xNEBnjnawiZOHXDiuZNgyjrwjgZQVrzEqerg/C2BIDdLhZsrx
         BfncUG+4tjPZyT9n4MVhPIsZzQ5we0g0OVnYX360flRNGMeDn72PFN1iToOP9GdCUDg0
         G17T6+fhfo1nFUUiTU1MzCp5pnSyUtLBbOeB+vsrj5pXvbjlGzZ0M9a6zeZFNbtNKFBs
         X97KEc9tWuLfrmmbAHImpZuMTZN4cUyDfx5XtG3PQtqK2SZDK/sXcoSYkbd89/NVVLYK
         HVA+Lt/knOIPRU9rX43xJMnm/MkWKzXMJDG/BFCBRY3CghycFuzFgCmEmyV9O9yCW5U6
         askg==
X-Google-Smtp-Source: APXvYqyBAmPBedawt4crdvXhqyaXfSyXYDKADKRRvPMkEuPYFjXBMi1U8GsELuKKDQOczQgHbY1p7WZkDktP5lqZiKM=
X-Received: by 2002:a24:7c52:: with SMTP id a79mr1472650itd.51.1554862264952;
 Tue, 09 Apr 2019 19:11:04 -0700 (PDT)
MIME-Version: 1.0
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440491334.3190322.44013027330479237.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu8ocQGxTAapfjb5WufhL=Qj54LythHcPHsyy+wUnVBnfA@mail.gmail.com>
 <CAPcyv4gUL8j+EaAZ556_NKXLgva++HgPBOeeAUNHN+DAWaewaQ@mail.gmail.com> <CAKv+Gu_M-V-3ahHTj10iyx=eC2pBzFg027NmdBX1x7nXrpqK7g@mail.gmail.com>
In-Reply-To: <CAKv+Gu_M-V-3ahHTj10iyx=eC2pBzFg027NmdBX1x7nXrpqK7g@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 9 Apr 2019 19:10:53 -0700
Message-ID: <CAA9_cmeRqr=b-hmaxA0aLZE98YGS9hF8h8JGGp9K6c_qhLK3AQ@mail.gmail.com>
Subject: Re: [RFC PATCH 1/5] efi: Detect UEFI 2.8 Special Purpose Memory
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, "the arch/x86 maintainers" <x86@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Darren Hart <dvhart@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Andy Shevchenko <andy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 9, 2019 at 10:21 AM Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
>
> On Tue, 9 Apr 2019 at 09:44, Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Fri, Apr 5, 2019 at 9:21 PM Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> > >
> > > Hi Dan,
> > >
> > > On Thu, 4 Apr 2019 at 21:21, Dan Williams <dan.j.williams@intel.com> wrote:
> > > >
> > > > UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
> > > > interpretation of the EFI Memory Types as "reserved for a special
> > > > purpose".
> > > >
> > > > The proposed Linux behavior for special purpose memory is that it is
> > > > reserved for direct-access (device-dax) by default and not available for
> > > > any kernel usage, not even as an OOM fallback. Later, through udev
> > > > scripts or another init mechanism, these device-dax claimed ranges can
> > > > be reconfigured and hot-added to the available System-RAM with a unique
> > > > node identifier.
> > > >
> > > > A follow-on patch integrates parsing of the ACPI HMAT to identify the
> > > > node and sub-range boundaries of EFI_MEMORY_SP designated memory. For
> > > > now, arrange for EFI_MEMORY_SP memory to be reserved.
> > > >
> > > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > > Cc: Ingo Molnar <mingo@redhat.com>
> > > > Cc: Borislav Petkov <bp@alien8.de>
> > > > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > > > Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > > > Cc: Darren Hart <dvhart@infradead.org>
> > > > Cc: Andy Shevchenko <andy@infradead.org>
> > > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > > > ---
> > > >  arch/x86/Kconfig                  |   18 ++++++++++++++++++
> > > >  arch/x86/boot/compressed/eboot.c  |    5 ++++-
> > > >  arch/x86/boot/compressed/kaslr.c  |    2 +-
> > > >  arch/x86/include/asm/e820/types.h |    9 +++++++++
> > > >  arch/x86/kernel/e820.c            |    9 +++++++--
> > > >  arch/x86/platform/efi/efi.c       |   10 +++++++++-
> > > >  include/linux/efi.h               |   14 ++++++++++++++
> > > >  include/linux/ioport.h            |    1 +
> > > >  8 files changed, 63 insertions(+), 5 deletions(-)
> > > >
> > > > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > > > index c1f9b3cf437c..cb9ca27de7a5 100644
> > > > --- a/arch/x86/Kconfig
> > > > +++ b/arch/x86/Kconfig
> > > > @@ -1961,6 +1961,24 @@ config EFI_MIXED
> > > >
> > > >            If unsure, say N.
> > > >
> > > > +config EFI_SPECIAL_MEMORY
> > > > +       bool "EFI Special Purpose Memory Support"
> > > > +       depends on EFI
> > > > +       ---help---
> > > > +         On systems that have mixed performance classes of memory EFI
> > > > +         may indicate special purpose memory with an attribute (See
> > > > +         EFI_MEMORY_SP in UEFI 2.8). A memory range tagged with this
> > > > +         attribute may have unique performance characteristics compared
> > > > +         to the system's general purpose "System RAM" pool. On the
> > > > +         expectation that such memory has application specific usage
> > > > +         answer Y to arrange for the kernel to reserve it for
> > > > +         direct-access (device-dax) by default. The memory range can
> > > > +         later be optionally assigned to the page allocator by system
> > > > +         administrator policy. Say N to have the kernel treat this
> > > > +         memory as general purpose by default.
> > > > +
> > > > +         If unsure, say Y.
> > > > +
> > >
> > > EFI_MEMORY_SP is now part of the UEFI spec proper, so it does not make
> > > sense to make any understanding of it Kconfigurable.
> >
> > No, I think you're misunderstanding what this Kconfig option is trying
> > to achieve.
> >
> > The configuration capability is solely for the default kernel policy.
> > As can already be seen by Christoph's response [1] the thought that
> > the firmware gets more leeway to dictate to Linux memory policy may be
> > objectionable.
> >
> > [1]: https://lore.kernel.org/lkml/20190409121318.GA16955@infradead.org/
> >
> > So the Kconfig option is gating whether the kernel simply ignores the
> > attribute and gives it to the page allocator by default. Anything
> > fancier, like sub-dividing how much is OS managed vs device-dax
> > accessed requires the OS to reserve it all from the page-allocator by
> > default until userspace policy can be applied.
> >
>
> I don't think this policy should dictate whether we pretend that the
> attribute doesn't exist in the first place. We should just wire up the
> bit fully, and only apply this policy at the very end.

The bit is just a policy hint, if the kernel is not implementing any
of the policy why even check for the bit?

>
> > > Instead, what I would prefer is to implement support for EFI_MEMORY_SP
> > > unconditionally (including the ability to identify it in the debug
> > > dump of the memory map etc), in a way that all architectures can use
> > > it. Then, I think we should never treat it as ordinary memory and make
> > > it the firmware's problem not to use the EFI_MEMORY_SP attribute in
> > > cases where it results in undesired behavior in the OS.
> >
> > No, a policy of "never treat it as ordinary memory" confuses the base
> > intent of the attribute which is an optional hint to get the OS to not
> > put immovable / non-critical allocations in what could be a precious
> > resource.
> >
>
> The base intent is to prevent the OS from using memory that is
> co-located with an accelerator for any purpose other than what the
> accelerator needs it for. Having a Kconfigurable policy that may be
> disabled kind of misses the point IMO. I think 'optional hint' doesn't
> quite capture the intent.

That's not my understanding, and an EFI attribute is the wrong
mechanism to meet such a requirement. If this memory is specifically
meant for use with a given accelerator then it had better be marked
reserved and the accelerator driver is then responsible for publishing
the resource to the OS if at all.

You did prompt me to go back and re-read the wording in the spec. It
still seems clear to me that the attribute is an optional hint not a
hard requirement. Whether the OS honors an optional hint is an OS
policy and I fail to see why the OS should bother to detect the bit
without implementing any associated policy.

> > Moreover, the interface for platform firmware to indicate that a
> > memory range should never be treated as ordinary memory is simply the
> > existing "reserved" memory type, not this attribute. That's the
> > mechanism to use when platform firmware knows that a driver is needed
> > for a given mmio resource.
> >
>
> Reserved memory is memory that simply should never touched at all by
> the OS, and on ARM, we take care never to map it anywhere.

That's not a guarantee, at least on x86. Some shipping persistent
memory platforms describe it as reserved and then the ACPI NFIT
further describes what that reserved memory contains and how the OS
can use it. See commit af1996ef59db "ACPI: Change NFIT driver to
insert new resource".

