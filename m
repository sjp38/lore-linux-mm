Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 312596B0260
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:29:50 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id j94so95245235uad.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:29:50 -0800 (PST)
Received: from mail-vk0-x22d.google.com (mail-vk0-x22d.google.com. [2607:f8b0:400c:c05::22d])
        by mx.google.com with ESMTPS id u47si6962023uaf.158.2017.01.17.12.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 12:29:49 -0800 (PST)
Received: by mail-vk0-x22d.google.com with SMTP id k127so54698573vke.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:29:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170116123310.22697-4-dsafonov@virtuozzo.com>
References: <20170116123310.22697-1-dsafonov@virtuozzo.com> <20170116123310.22697-4-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 17 Jan 2017 12:29:28 -0800
Message-ID: <CALCETrXd97biCE4K3V6=kDw8GxjyuDX1a1gr3ir-Pg0=6f-Hng@mail.gmail.com>
Subject: Re: [PATCHv2 3/5] x86/mm: fix native mmap() in compat bins and vice-versa
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 16, 2017 at 4:33 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Fix 32-bit compat_sys_mmap() mapping VMA over 4Gb in 64-bit binaries
> and 64-bit sys_mmap() mapping VMA only under 4Gb in 32-bit binaries.
> Changed arch_get_unmapped_area{,_topdown}() to recompute mmap_base
> for those cases and use according high/low limits for vm_unmapped_area()
> The recomputing of mmap_base may make compat sys_mmap() in 64-bit
> binaries a little slower than native, which uses already known from exec
> time mmap_base - but, as it returned buggy address, that case seemed
> unused previously, so no performance degradation for already used ABI.

This looks plausibly correct but rather weird -- why does this code
need to distinguish between all four cases (pure 32-bit, pure 64-bit,
64-bit mmap layout doing 32-bit call, 32-bit layout doing 64-bit
call)?

> Can be optimized in future by introducing mmap_compat_{,legacy}_base
> in mm_struct.

Hmm.  Would it make sense to do it this way from the beginning?

If adding an in_32bit_syscall() helper would help, then by all means
please do so.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
