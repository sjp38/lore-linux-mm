Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA3C6B0263
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:01:04 -0500 (EST)
Received: by igvg19 with SMTP id g19so81175677igv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:01:04 -0800 (PST)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id g131si18864292ioe.128.2015.11.16.11.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 11:01:03 -0800 (PST)
Received: by iofh3 with SMTP id h3so170154729iof.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:01:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151116185519.GE8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
	<1447698757-8762-8-git-send-email-ard.biesheuvel@linaro.org>
	<20151116185519.GE8644@n2100.arm.linux.org.uk>
Date: Mon, 16 Nov 2015 20:01:03 +0100
Message-ID: <CAKv+Gu-P45_S2aHE2Dr=i-2e29-DvmSBR_JWec=JPcZeTMn02Q@mail.gmail.com>
Subject: Re: [PATCH v2 07/12] ARM: split off core mapping logic from create_mapping
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 16 November 2015 at 19:55, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Mon, Nov 16, 2015 at 07:32:32PM +0100, Ard Biesheuvel wrote:
>> In order to be able to reuse the core mapping logic of create_mapping
>> for mapping the UEFI Runtime Services into a private set of page tables,
>> split it off from create_mapping() into a separate function
>> __create_mapping which we will wire up in a subsequent patch.
>
> I'm slightly worried about this.  Generally, these functions setup
> global mappings.  If you're wanting to have a private set of page
> tables for UEFI, and those private page tables contain global
> mappings which are different from the mappings in the kernel's page
> tables, then you need careful break-TLBflush-make handling when
> switching from the kernel's page tables to the private UEFI ones,
> and vice versa.
>
> Has this aspect been considered?
>

Yes. The UEFI mappings are all below 1 GB, and the top kernel end is
reused as we do for ordinary userland page tables. The switch to the
UEFI page tables performs a full TLB flush. What it does not do is
break before make, as far as I can tell, so any pointers regarding how
to implement that would be appreciated (this is implemented in 11/12)

-- 
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
