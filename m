Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D01F36B0387
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:02:14 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id j82so60061694oih.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:02:14 -0800 (PST)
Received: from mail-ot0-x243.google.com (mail-ot0-x243.google.com. [2607:f8b0:4003:c0f::243])
        by mx.google.com with ESMTPS id m31si4174503otd.144.2017.02.17.12.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 12:02:14 -0800 (PST)
Received: by mail-ot0-x243.google.com with SMTP id 45so2615169otd.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:02:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com> <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Feb 2017 12:02:13 -0800
Message-ID: <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Feb 17, 2017 at 6:13 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> This patch introduces two new prctl(2) handles to manage maximum virtual
> address available to userspace to map.

So this is my least favorite patch of the whole series, for a couple of reasons:

 (a) adding new code, and mixing it with the mindless TASK_SIZE ->
get_max_addr() conversion.

 (b) what's the point of that whole TASK_SIZE vs get_max_addr() thing?
When use one, when the other?

so I think this patch needs a lot more thought and/or explanation.

Honestly, (a) is a no-brainer, and can be fixed by just splitting the
patch up. But I think (b) is more fundamental.

In particular, I think that get_max_addr() thing is badly defined.
When should you use TASK_SIZE, when should you use TASK_SIZE_MAX, and
when should you use get_max_addr()? I don't find that clear at all,
and I think that needs to be a whole lot more explicit and documented.

I also get he feeling that the whole thing is unnecessary. I'm
wondering if we should just instead say that the whole 47 vs 56-bit
virtual address is _purely_ about "get_unmapped_area()", and nothing
else.

IOW, I'm wondering if we can't just say that

 - if the processor and kernel support 56-bit user address space, then
you can *always* use the whole space

 - but by default, get_unmapped_area() will only return mappings that
fit in the 47 bit address space.

So if you use MAP_FIXED and give an address in the high range, it will
just always work, and the MM will always consider the task size to be
the full address space.

But for the common case where a process does no use MAP_FIXED, the
kernel will never give a high address by default, and you have to do
the process control thing to say "I want those high addresses".

Hmm?

In other words, I'd like to at least start out trying to keep the
differences between the 47-bit and 56-bit models as simple and minimal
as possible. Not make such a big deal out of it.

We already have "arch_get_unmapped_area()" that controls the whole
"what will non-MAP_FIXED mmap allocations return", so I'd hope that
the above kind of semantics could be done without *any* actual
TASK_SIZE changes _anywhere_ in the VM code.

Comments?

      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
