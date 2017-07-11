Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF19D6B051B
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:07:20 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 6so146357oik.11
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:07:20 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 71si173171oik.162.2017.07.11.08.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 08:07:20 -0700 (PDT)
Received: from mail-vk0-f41.google.com (mail-vk0-f41.google.com [209.85.213.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4751A22C9B
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:07:19 +0000 (UTC)
Received: by mail-vk0-f41.google.com with SMTP id r125so1580298vkf.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:07:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170711103548.mkv5w7dd5gpdenne@node.shutemov.name>
References: <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com>
 <bc95be68-8c68-2a45-c530-acbc6c90a231@virtuozzo.com> <20170710123346.7y3jnftqgpingim3@node.shutemov.name>
 <CACT4Y+aRbC7_wvDv8ahH_JwY6P6SFoLg-kdwWHJx5j1stX_P_w@mail.gmail.com>
 <20170710141713.7aox3edx6o7lrrie@node.shutemov.name> <03A6D7ED-300C-4431-9EB5-67C7A3EA4A2E@amacapital.net>
 <20170710184704.realchrhzpblqqlk@node.shutemov.name> <CALCETrVJQ_u-agPm8fFHAW1UJY=VLowdbM+gXyjFCb586r0V3g@mail.gmail.com>
 <20170710212403.7ycczkhhki3vrgac@node.shutemov.name> <CALCETrW6pWzpdf1MVx_ytaYYuVGBsF7R+JowEsKqd3i=vCwJ_w@mail.gmail.com>
 <20170711103548.mkv5w7dd5gpdenne@node.shutemov.name>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 11 Jul 2017 08:06:57 -0700
Message-ID: <CALCETrVpNUq3-zEu1Q1O77N8r4kv4kFdefXp7XEs3Hpf-JPAjg@mail.gmail.com>
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andy Lutomirski <luto@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On Tue, Jul 11, 2017 at 3:35 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Mon, Jul 10, 2017 at 05:30:38PM -0700, Andy Lutomirski wrote:
>> On Mon, Jul 10, 2017 at 2:24 PM, Kirill A. Shutemov
>> <kirill@shutemov.name> wrote:
>> > On Mon, Jul 10, 2017 at 01:07:13PM -0700, Andy Lutomirski wrote:
>> >> Can you give the disassembly of the backtrace lines?  Blaming the
>> >> .endr doesn't make much sense to me.
>> >
>> > I don't have backtrace. It's before printk() is functional. I only see
>> > triple fault and reboot.
>> >
>> > I had to rely on qemu tracing and gdb.
>>
>> Can you ask GDB or objtool to disassemble around those addresses?  Can
>> you also attach the big dump that QEMU throws out that shows register
>> state?  In particular, CR2, CR3, and CR4 could be useful.
>
> The last three execptions:
>
> check_exception old: 0xffffffff new 0xe, cr2: 0xffffffff7ffffff8, rip: 0xffffffff84bb3036
> RAX=00000000ffffffff RBX=ffffffff800000d8 RCX=ffffffff84be4021 RDX=dffffc0000000000
> RSI=0000000000000006 RDI=ffffffff84c57000 RBP=ffffffff800000c8 RSP=ffffffff80000000

So RSP was 0xffffffff80000000, a push happened, and we tried to write
to 0xffffffff7ffffff8, which failed.

> check_exception old: 0xe new 0xe, cr2: 0xffffffff7ffffff8, rip: 0xffffffff84bb3141
> RAX=00000000ffffffff RBX=ffffffff800000d8 RCX=ffffffff84be4021 RDX=dffffc0000000000
> RSI=0000000000000006 RDI=ffffffff84c57000 RBP=ffffffff800000c8 RSP=ffffffff80000000

And #PF doesn't use IST, so it double-faulted.

Either the stack isn't mapped in the page tables, RSP is corrupt, or
there's a genuine stack overflow here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
