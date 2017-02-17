Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC1C6B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:12:53 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id x12so31232396uax.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:12:53 -0800 (PST)
Received: from mail-ua0-x230.google.com (mail-ua0-x230.google.com. [2607:f8b0:400c:c08::230])
        by mx.google.com with ESMTPS id j17si1134172uaf.188.2017.02.17.12.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 12:12:52 -0800 (PST)
Received: by mail-ua0-x230.google.com with SMTP id k3so1374849uak.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:12:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com> <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 17 Feb 2017 12:12:31 -0800
Message-ID: <CALCETrW6YBxZw0NJGHe92dy7qfHqRHNr0VqTKV=O4j9r8hcSew@mail.gmail.com>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Feb 17, 2017 at 12:02 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Feb 17, 2017 at 6:13 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
>> This patch introduces two new prctl(2) handles to manage maximum virtual
>> address available to userspace to map.
>
> So this is my least favorite patch of the whole series, for a couple of reasons:
>
>  (a) adding new code, and mixing it with the mindless TASK_SIZE ->
> get_max_addr() conversion.
>
>  (b) what's the point of that whole TASK_SIZE vs get_max_addr() thing?
> When use one, when the other?
>
> so I think this patch needs a lot more thought and/or explanation.
>
> Honestly, (a) is a no-brainer, and can be fixed by just splitting the
> patch up. But I think (b) is more fundamental.
>
> In particular, I think that get_max_addr() thing is badly defined.
> When should you use TASK_SIZE, when should you use TASK_SIZE_MAX, and
> when should you use get_max_addr()? I don't find that clear at all,
> and I think that needs to be a whole lot more explicit and documented.
>
> I also get he feeling that the whole thing is unnecessary. I'm
> wondering if we should just instead say that the whole 47 vs 56-bit
> virtual address is _purely_ about "get_unmapped_area()", and nothing
> else.
>
> IOW, I'm wondering if we can't just say that
>
>  - if the processor and kernel support 56-bit user address space, then
> you can *always* use the whole space
>
>  - but by default, get_unmapped_area() will only return mappings that
> fit in the 47 bit address space.
>
> So if you use MAP_FIXED and give an address in the high range, it will
> just always work, and the MM will always consider the task size to be
> the full address space.

At the very least, I'd want to see
MAP_FIXED_BUT_DONT_BLOODY_UNMAP_ANYTHING.  I *hate* the current
interface.

>
> But for the common case where a process does no use MAP_FIXED, the
> kernel will never give a high address by default, and you have to do
> the process control thing to say "I want those high addresses".
>
> Hmm?

How about MAP_LIMIT where the address passed in is interpreted as an
upper bound instead of a fixed address?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
