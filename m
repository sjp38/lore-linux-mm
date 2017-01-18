Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3F6E6B0260
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:36:47 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so13327681pgc.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 03:36:47 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0127.outbound.protection.outlook.com. [104.47.0.127])
        by mx.google.com with ESMTPS id v4si7733792pgo.267.2017.01.18.03.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 03:36:46 -0800 (PST)
Subject: Re: [PATCHv2 3/5] x86/mm: fix native mmap() in compat bins and
 vice-versa
References: <20170116123310.22697-1-dsafonov@virtuozzo.com>
 <20170116123310.22697-4-dsafonov@virtuozzo.com>
 <CALCETrXd97biCE4K3V6=kDw8GxjyuDX1a1gr3ir-Pg0=6f-Hng@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <72d16541-17c3-acb6-1d0d-2d6cf0565f35@virtuozzo.com>
Date: Wed, 18 Jan 2017 14:33:26 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrXd97biCE4K3V6=kDw8GxjyuDX1a1gr3ir-Pg0=6f-Hng@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/17/2017 11:29 PM, Andy Lutomirski wrote:
> On Mon, Jan 16, 2017 at 4:33 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> Fix 32-bit compat_sys_mmap() mapping VMA over 4Gb in 64-bit binaries
>> and 64-bit sys_mmap() mapping VMA only under 4Gb in 32-bit binaries.
>> Changed arch_get_unmapped_area{,_topdown}() to recompute mmap_base
>> for those cases and use according high/low limits for vm_unmapped_area()
>> The recomputing of mmap_base may make compat sys_mmap() in 64-bit
>> binaries a little slower than native, which uses already known from exec
>> time mmap_base - but, as it returned buggy address, that case seemed
>> unused previously, so no performance degradation for already used ABI.
>
> This looks plausibly correct but rather weird -- why does this code
> need to distinguish between all four cases (pure 32-bit, pure 64-bit,
> 64-bit mmap layout doing 32-bit call, 32-bit layout doing 64-bit
> call)?

Only by need to know is mm->mmap_base computed initialy for 32-bit
or for 64-bit.

>
>> Can be optimized in future by introducing mmap_compat_{,legacy}_base
>> in mm_struct.
>
> Hmm.  Would it make sense to do it this way from the beginning?

That would, but mm_struct is in generic code, if adding those new bases
is fine, than I'll do that in v3.

It will look somehow like:
: if (in_compat_syscall())
: 	return current->mm->mmap_compat_base;
: else
: 	return current->mm->mmap_base;

>
> If adding an in_32bit_syscall() helper would help, then by all means
> please do so.
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
