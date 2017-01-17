Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86DD86B0261
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:31:08 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id f2so95050865uaf.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:31:08 -0800 (PST)
Received: from mail-vk0-x234.google.com (mail-vk0-x234.google.com. [2607:f8b0:400c:c05::234])
        by mx.google.com with ESMTPS id l82si6961404vke.180.2017.01.17.12.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 12:31:07 -0800 (PST)
Received: by mail-vk0-x234.google.com with SMTP id k127so54720997vke.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:31:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170116123310.22697-5-dsafonov@virtuozzo.com>
References: <20170116123310.22697-1-dsafonov@virtuozzo.com> <20170116123310.22697-5-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 17 Jan 2017 12:30:47 -0800
Message-ID: <CALCETrWXCr_nYMb41JSgVSAmMYkkkkDfWtLfQhh7S5Enz8YJCA@mail.gmail.com>
Subject: Re: [PATCHv2 4/5] x86/mm: for MAP_32BIT check in_compat_syscall()
 instead TIF_ADDR32
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 16, 2017 at 4:33 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> At this momet, logic in arch_get_unmapped_area{,_topdown} for mmaps with
> MAP_32BIT flag checks TIF_ADDR32 which means:
> o if 32-bit ELF changes mode to 64-bit on x86_64 and then tries to
>   mmap() with MAP_32BIT it'll result in addr over 4Gb (as default is
>   top-down allocation)
> o if 64-bit ELF changes mode to 32-bit and tries mmap() with MAP_32BIT,
>   it'll allocate only memory in 1GB space: [0x40000000, 0x80000000).
>
> Fix it by handeling MAP_32BIT in 64-bit syscalls only.
> As a little bonus it'll make thread flag a little less used.

Seems like an improvement.  Also, jeez, the mmap code is complicated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
