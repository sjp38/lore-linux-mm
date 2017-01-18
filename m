Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A657F6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:43:16 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id a194so14573856oib.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 03:43:16 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20095.outbound.protection.outlook.com. [40.107.2.95])
        by mx.google.com with ESMTPS id o204si2990178oif.190.2017.01.18.03.43.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 03:43:15 -0800 (PST)
Subject: Re: [PATCHv2 4/5] x86/mm: for MAP_32BIT check in_compat_syscall()
 instead TIF_ADDR32
References: <20170116123310.22697-1-dsafonov@virtuozzo.com>
 <20170116123310.22697-5-dsafonov@virtuozzo.com>
 <CALCETrWXCr_nYMb41JSgVSAmMYkkkkDfWtLfQhh7S5Enz8YJCA@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <09f45e26-951a-ac10-0749-1bce8639cfbd@virtuozzo.com>
Date: Wed, 18 Jan 2017 14:39:54 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrWXCr_nYMb41JSgVSAmMYkkkkDfWtLfQhh7S5Enz8YJCA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/17/2017 11:30 PM, Andy Lutomirski wrote:
> On Mon, Jan 16, 2017 at 4:33 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> At this momet, logic in arch_get_unmapped_area{,_topdown} for mmaps with
>> MAP_32BIT flag checks TIF_ADDR32 which means:
>> o if 32-bit ELF changes mode to 64-bit on x86_64 and then tries to
>>   mmap() with MAP_32BIT it'll result in addr over 4Gb (as default is
>>   top-down allocation)
>> o if 64-bit ELF changes mode to 32-bit and tries mmap() with MAP_32BIT,
>>   it'll allocate only memory in 1GB space: [0x40000000, 0x80000000).
>>
>> Fix it by handeling MAP_32BIT in 64-bit syscalls only.
>> As a little bonus it'll make thread flag a little less used.
>
> Seems like an improvement.  Also, jeez, the mmap code is complicated.

Yes, but it's intentionally 4 of 5 by the reason, that it'll broke
the second case:

 >> o if 64-bit ELF changes mode to 32-bit and tries mmap() with MAP_32BIT,
 >>   it'll allocate only memory in 1GB space: [0x40000000, 0x80000000).

if the first 3 patches has not applied earlier.
(because it'll allocate not in 1Gb space, but in 64-bit whole space,
above 4Gb).
So, this should go only after fixing compat mmap in 64-bit binaries,
which is done in prev 3 patches.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
