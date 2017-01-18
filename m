Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02A196B0260
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:30:01 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id w107so5211154ota.6
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 03:30:00 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20105.outbound.protection.outlook.com. [40.107.2.105])
        by mx.google.com with ESMTPS id n206si789502oia.25.2017.01.18.03.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 03:30:00 -0800 (PST)
Subject: Re: [PATCHv2 2/5] x86/mm: introduce mmap_{,legacy}_base
References: <20170116123310.22697-1-dsafonov@virtuozzo.com>
 <20170116123310.22697-3-dsafonov@virtuozzo.com>
 <CALCETrUHLpsrB0M3rkrxw8R=6Dto5gFz+enP=W3C6WPDTa36GA@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <69eecbfb-9d39-9c72-7ec3-68fdbea45245@virtuozzo.com>
Date: Wed, 18 Jan 2017 14:26:37 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrUHLpsrB0M3rkrxw8R=6Dto5gFz+enP=W3C6WPDTa36GA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/17/2017 11:27 PM, Andy Lutomirski wrote:
> On Mon, Jan 16, 2017 at 4:33 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> In the following patch they will be used to compute:
>> - mmap_base in compat sys_mmap() in native 64-bit binary
>> and vice-versa
>> - mmap_base for native sys_mmap() in compat x32/ia32-bit binary.
>
> I may be wrong here, but I suspect that you're repeating something
> that I consider to be a mistake that's all over the x86 code.
> Specifically, you're distinguishing "native" from "compat" instead of
> "32-bit" from "64-bit".  If you did the latter, then you wouldn't need
> the "native" case to work differently on 32-bit kernels vs 64-bit
> kernels, I think.  Would making this change make your code simpler?
>
> The x86 signal code is the worst offender IMO.

Yes, I also don't like to differ them especially by TIF_ADDR32 flag.
I did distinguishing for the reason that I needed to know for which
task 64/32-bit was computed mm->mmap_base.
Otherwise I could introduce mm->mmap_compat_base and don't differ
tasks by TIF_ADDR32 flag - only by in_compat_syscall(), but that
would change mm_struct generic code (adding a field to mm).
So, I thought it may have more opposition to add a field to mm
in generic code and fixed it here, in x86.

>
> --Andy
>

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
