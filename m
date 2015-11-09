Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE976B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 14:39:56 -0500 (EST)
Received: by ykdv3 with SMTP id v3so194363058ykd.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 11:39:55 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p66si4700332ywc.74.2015.11.09.11.39.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 11:39:54 -0800 (PST)
Subject: Re: [PATCH v4 RESEND 4/11] x86/asm: Fix pud/pmd interfaces to handle
 large PAT bit
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
 <1442514264-12475-5-git-send-email-toshi.kani@hpe.com>
 <5640E08F.5020206@oracle.com> <1447096601.21443.15.camel@hpe.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <5640F673.8070400@oracle.com>
Date: Mon, 9 Nov 2015 14:39:31 -0500
MIME-Version: 1.0
In-Reply-To: <1447096601.21443.15.camel@hpe.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com

On 11/09/2015 02:16 PM, Toshi Kani wrote:
> On Mon, 2015-11-09 at 13:06 -0500, Boris Ostrovsky wrote:
>> On 09/17/2015 02:24 PM, Toshi Kani wrote:
>>> Now that we have pud/pmd mask interfaces, which handle pfn & flags
>>> mask properly for the large PAT bit.
>>>
>>> Fix pud/pmd pfn & flags interfaces by replacing PTE_PFN_MASK and
>>> PTE_FLAGS_MASK with the pud/pmd mask interfaces.
>>>
>>> Suggested-by: Juergen Gross <jgross@suse.com>
>>> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
>>> Cc: Juergen Gross <jgross@suse.com>
>>> Cc: Konrad Wilk <konrad.wilk@oracle.com>
>>> Cc: Thomas Gleixner <tglx@linutronix.de>
>>> Cc: H. Peter Anvin <hpa@zytor.com>
>>> Cc: Ingo Molnar <mingo@redhat.com>
>>> Cc: Borislav Petkov <bp@alien8.de>
>>> ---
>>>    arch/x86/include/asm/pgtable.h       |   14 ++++++++------
>>>    arch/x86/include/asm/pgtable_types.h |    4 ++--
>>>    2 files changed, 10 insertions(+), 8 deletions(-)
>>>
>>
>> Looks like this commit is causing this splat for 32-bit kernels. I am
>> attaching my config file, just in case.
> Thanks for the report!  I'd like to reproduce the issue since I am not sure how
> this change caused it...
>
> I tried to build a kernel with the attached config file, and got the following
> error.  Not sure what I am missing.
>
> ----
> $ make -j24 ARCH=i386
>     :
>    LD      drivers/built-in.o
>    LINK    vmlinux
> ./.config: line 44: $'\r': command not found

I wonder whether my email client added ^Ms to the file that I send. It 
shouldn't have.

> Makefile:929: recipe for target 'vmlinux' failed
> make: *** [vmlinux] Error 127
> ----
>
> Do you have steps to reproduce the issue?  Or do you see it during boot-time?

This always happens just after system has booted, it may still be going 
over init scripts. I am booting with ramdisk, don't know whether it has 
anything to do with this problem.

FWIW, it looks like pmd_pfn_mask() inline is causing this. Reverting it 
alone makes this crash go away.


-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
