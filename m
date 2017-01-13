Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 793BD6B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 15:11:07 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id g49so45829238qta.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 12:11:07 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id c6si9139059qtb.169.2017.01.13.12.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 12:11:06 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id a20so8634386qkc.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 12:11:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170102083500.GA30735@node.shutemov.name>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <CALCETrV+3rO=CuPjpoU9iKnKiJ2toW6QZAKXEqDW-QJJrX2EgQ@mail.gmail.com>
 <20161227022405.GA8780@node.shutemov.name> <3a168403-26f7-ac8d-3086-848178be6005@redhat.com>
 <CALCETrVHf-JJGqFoX_kmx2qyLdj78SDUfbvD+VPsSpPfDbYk1Q@mail.gmail.com> <20170102083500.GA30735@node.shutemov.name>
From: "H.J. Lu" <hjl.tools@gmail.com>
Date: Fri, 13 Jan 2017 12:11:05 -0800
Message-ID: <CAMe9rOqRyL7eEmGSkXh9nbVPk_V8cKOuNbdwPA9Dcq=e07G7Ng@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andy Lutomirski <luto@amacapital.net>, Carlos O'Donell <carlos@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Jan 2, 2017 at 12:35 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Fri, Dec 30, 2016 at 06:08:27PM -0800, Andy Lutomirski wrote:
>> On Wed, Dec 28, 2016 at 6:53 PM, Carlos O'Donell <carlos@redhat.com> wro=
te:
>> > On 12/26/2016 09:24 PM, Kirill A. Shutemov wrote:
>> >> On Mon, Dec 26, 2016 at 06:06:01PM -0800, Andy Lutomirski wrote:
>> >>> On Mon, Dec 26, 2016 at 5:54 PM, Kirill A. Shutemov
>> >>> <kirill.shutemov@linux.intel.com> wrote:
>> >>>> This patch introduces new rlimit resource to manage maximum virtual
>> >>>> address available to userspace to map.
>> >>>>
>> >>>> On x86, 5-level paging enables 56-bit userspace virtual address spa=
ce.
>> >>>> Not all user space is ready to handle wide addresses. It's known th=
at
>> >>>> at least some JIT compilers use high bit in pointers to encode thei=
r
>> >>>> information. It collides with valid pointers with 5-level paging an=
d
>> >>>> leads to crashes.
>> >>>>
>> >>>> The patch aims to address this compatibility issue.
>> >>>>
>> >>>> MM would use min(RLIMIT_VADDR, TASK_SIZE) as upper limit of virtual
>> >>>> address available to map by userspace.
>> >>>>
>> >>>> The default hard limit will be RLIM_INFINITY, which basically means=
 that
>> >>>> TASK_SIZE limits available address space.
>> >>>>
>> >>>> The soft limit will also be RLIM_INFINITY everywhere, but the machi=
ne
>> >>>> with 5-level paging enabled. In this case, soft limit would be
>> >>>> (1UL << 47) - PAGE_SIZE. It=E2=80=99s current x86-64 TASK_SIZE_MAX =
with 4-level
>> >>>> paging which known to be safe
>> >>>>
>> >>>> New rlimit resource would follow usual semantics with regards to
>> >>>> inheritance: preserved on fork(2) and exec(2). This has potential t=
o
>> >>>> break application if limits set too wide or too narrow, but this is=
 not
>> >>>> uncommon for other resources (consider RLIMIT_DATA or RLIMIT_AS).
>> >>>>
>> >>>> As with other resources you can set the limit lower than current us=
age.
>> >>>> It would affect only future virtual address space allocations.
>> >>>>
>> >>>> Use-cases for new rlimit:
>> >>>>
>> >>>>   - Bumping the soft limit to RLIM_INFINITY, allows current process=
 all
>> >>>>     its children to use addresses above 47-bits.
>> >>>>
>> >>>>   - Bumping the soft limit to RLIM_INFINITY after fork(2), but befo=
re
>> >>>>     exec(2) allows the child to use addresses above 47-bits.
>> >>>>
>> >>>>   - Lowering the hard limit to 47-bits would prevent current proces=
s all
>> >>>>     its children to use addresses above 47-bits, unless a process h=
as
>> >>>>     CAP_SYS_RESOURCES.
>> >>>>
>> >>>>   - It=E2=80=99s also can be handy to lower hard or soft limit to a=
rbitrary
>> >>>>     address. User-mode emulation in QEMU may lower the limit to 32-=
bit
>> >>>>     to emulate 32-bit machine on 64-bit host.
>> >>>
>> >>> I tend to think that this should be a personality or an ELF flag, no=
t
>> >>> an rlimit.
>> >>
>> >> My plan was to implement ELF flag on top. Basically, ELF flag would m=
ean
>> >> that we bump soft limit to hard limit on exec.
>> >
>> > Could you clarify what you mean by an "ELF flag?"
>>
>> Some way to mark a binary as supporting a larger address space.  I
>> don't have a precise solution in mind, but an ELF note might be a good
>> way to go here.
>
> + H.J.
>
> There's discussion of proposal of "Program Properties"[1]. It seems fits
> the purpose.
>
> [1] https://sourceware.org/ml/gnu-gabi/2016-q4/msg00000.html
>
> --
>  Kirill A. Shutemov

There is another proposal:

https://fedoraproject.org/wiki/Toolchain/Watermark#Markup_for_ELF_objects

which covers much more than mine.

--=20
H.J.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
