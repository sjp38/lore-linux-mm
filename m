Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id E46336B0038
	for <linux-mm@kvack.org>; Sat, 12 Sep 2015 06:42:00 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so82388336wic.0
        for <linux-mm@kvack.org>; Sat, 12 Sep 2015 03:42:00 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id y3si5708074wjy.116.2015.09.12.03.41.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Sep 2015 03:41:59 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so89129563wic.0
        for <linux-mm@kvack.org>; Sat, 12 Sep 2015 03:41:58 -0700 (PDT)
Date: Sat, 12 Sep 2015 11:41:57 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v2 3/3] x86, efi: Add "efi_fake_mem_mirror" boot option
Message-ID: <20150912104157.GB2796@codeblueprint.co.uk>
References: <1440609031-14695-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440609097-14836-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <CAKv+Gu88nxLQk5R2SGo0pnDA0VyTBvZT6oxLV-Uwc3=3wqjSaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu88nxLQk5R2SGo0pnDA0VyTBvZT6oxLV-Uwc3=3wqjSaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, Tony Luck <tony.luck@intel.com>, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 09 Sep, at 04:16:09PM, Ard Biesheuvel wrote:
> 
> Hello Taku,
> 
> To be honest, I think that the naming of this feature is poorly
> chosen. The UEFI spec gets it right by using 'MORE_RELIABLE'. Since
> one way to implement more reliable memory ranges is mirroring, the
> implementation detail of that has leaked into the generic naming,
> which is confusing. Not your fault though, just something I wanted to
> highlight.
 
Care to suggest an alternative option? efi_fake_mem_more_reliable ?

Maybe we should go further than this current design and generalise
things to allow an EFI_MEMORY_ATTRIBUTE value to be specified for
these memory ranges that supplements the ones actually provided by the
firmware?

Something like,

  efi_fake_mem=2G@4G:0x10000,2G@0x10a0000000:0x10000

Where 0x10000 is the EFI_MEMORY_MORE_RELIABLE attribute bit.

That would seem incredibly useful for testing the kernel side of the
EFI_PROPERTIES_TABLE changes, i.e. you wouldn't need support in the
firmware and could just "mock-up" an EFI memory map with EFI_MEMORY_XP
for the data regions (code regions and EFI_MEMORY_RO are a little
trickier as I understand it, because they may also contain data).

> So first of all, could you please update the example so that it only
> shows a single more reliable region (or two but of different sizes)?
> It took me a while to figure out that those 2 GB regions are not
> mirrors of each other in any way, they are simply two separate regions
> that are marked as more reliable than the remaining memory.
> 
> I do wonder if this functionality belongs in the kernel, though. I see
> how it could be useful, and you can keep it as a local hack, but
> generally, the firmware (OVMF?) is a better way to play around with
> code like this, I think?
 
I (partially) disagree. Using real life memory maps has its
advantages, since different layouts exercise the code in different
ways, and I'd really like to see this used on beefy machines with
multiple GB/TB or RAM. It also allows performance measurements to be
taken with bare metal accuracy. Plus there's precedent in the kernel
for creating fake memory/topology objects, e.g. see numa=fake.

Not everyone who touches the EFI memory mirror code is going to want
(or be able) to run firmware with EFI_MEMORY_MORE_RELIABLE support.

Having said that, I'd love to also see EFI_MEMORY_MORE_RELIABLE
support in OVMF! I think both options make sense for different
reasons.

-- 
Matt Fleming, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
