Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2C08A6B0259
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:38:06 -0500 (EST)
Received: by igvg19 with SMTP id g19so28518196igv.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:38:06 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id b17si132737ioj.89.2015.11.27.01.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 01:38:05 -0800 (PST)
Received: by iouu10 with SMTP id u10so111030681iou.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:38:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151126104711.GH2765@codeblueprint.co.uk>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
	<1448269593-20758-14-git-send-email-ard.biesheuvel@linaro.org>
	<20151126104711.GH2765@codeblueprint.co.uk>
Date: Fri, 27 Nov 2015 10:38:05 +0100
Message-ID: <CAKv+Gu_RC5qG=BGPSEf=j7AV4SbjXELjBxmcboj1oVs-Dn87qw@mail.gmail.com>
Subject: Re: [PATCH v3 13/13] ARM: add UEFI stub support
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Leif Lindholm <leif.lindholm@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Kuleshov <kuleshovmail@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ryan Harkin <ryan.harkin@linaro.org>, Grant Likely <grant.likely@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>

On 26 November 2015 at 11:47, Matt Fleming <matt@codeblueprint.co.uk> wrote:
> On Mon, 23 Nov, at 10:06:33AM, Ard Biesheuvel wrote:
>> From: Roy Franz <roy.franz@linaro.org>
>>
>> This patch adds EFI stub support for the ARM Linux kernel.
>>
>> The EFI stub operates similarly to the x86 and arm64 stubs: it is a
>> shim between the EFI firmware and the normal zImage entry point, and
>> sets up the environment that the zImage is expecting. This includes
>> optionally loading the initrd and device tree from the system partition
>> based on the kernel command line.
>>
>> Signed-off-by: Roy Franz <roy.franz@linaro.org>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> ---
>>  arch/arm/Kconfig                          |  19 +++
>>  arch/arm/boot/compressed/Makefile         |   4 +-
>>  arch/arm/boot/compressed/efi-header.S     | 130 ++++++++++++++++++++
>>  arch/arm/boot/compressed/head.S           |  54 +++++++-
>>  arch/arm/boot/compressed/vmlinux.lds.S    |   7 ++
>>  arch/arm/include/asm/efi.h                |  23 ++++
>>  drivers/firmware/efi/libstub/Makefile     |   9 ++
>>  drivers/firmware/efi/libstub/arm-stub.c   |   4 +-
>>  drivers/firmware/efi/libstub/arm32-stub.c |  85 +++++++++++++
>>  9 files changed, 331 insertions(+), 4 deletions(-)
>
> [...]
>
>> +
>> +     /*
>> +      * Relocate the zImage, if required. ARM doesn't have a
>> +      * preferred address, so we set it to 0, as we want to allocate
>> +      * as low in memory as possible.
>> +      */
>> +     *image_size = image->image_size;
>> +     status = efi_relocate_kernel(sys_table, image_addr, *image_size,
>> +                                  *image_size, 0, 0);
>> +     if (status != EFI_SUCCESS) {
>> +             pr_efi_err(sys_table, "Failed to relocate kernel.\n");
>> +             efi_free(sys_table, *reserve_size, *reserve_addr);
>> +             *reserve_size = 0;
>> +             return status;
>> +     }
>
> If efi_relocate_kernel() successfully allocates memory at address 0x0,
> is that going to cause issues with NULL pointer checking?

Actually, it is the reservation done a bit earlier that could
potentially end up at 0x0, and the [compressed] kernel is always at
least 32 MB up in memory, so that it can be decompressed as close to
the base of DRAM as possible.

As far as I can tell, efi_free() deals correctly with allocations at
address 0x0, and that is the only dealing we have with the
reservation. So I don't think there is an issue here.

-- 
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
