Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 771026B0038
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 13:27:45 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 96so300679551uaq.7
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:27:45 -0800 (PST)
Received: from mail-ua0-x236.google.com (mail-ua0-x236.google.com. [2607:f8b0:400c:c08::236])
        by mx.google.com with ESMTPS id f204si17408138vkd.14.2017.01.03.10.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 10:27:43 -0800 (PST)
Received: by mail-ua0-x236.google.com with SMTP id 34so290245939uac.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:27:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170103160457.GB17319@node.shutemov.name>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <2736959.3MfCab47fD@wuerfel> <CALCETrV_qejd-Ozqo4vTqz=LuukMUPeQ7EVUQbfTxs_xNbO3oQ@mail.gmail.com>
 <20170103160457.GB17319@node.shutemov.name>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 3 Jan 2017 10:27:22 -0800
Message-ID: <CALCETrW3=SsQeC-gWOVqwTtg022+gHei=xfUc2ei3kkX0CACpg@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On Tue, Jan 3, 2017 at 8:04 AM, Kirill A. Shutemov <kirill@shutemov.name> w=
rote:
> On Mon, Jan 02, 2017 at 10:08:28PM -0800, Andy Lutomirski wrote:
>> On Mon, Jan 2, 2017 at 12:44 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> > On Tuesday, December 27, 2016 4:54:13 AM CET Kirill A. Shutemov wrote:
>> >> As with other resources you can set the limit lower than current usag=
e.
>> >> It would affect only future virtual address space allocations.
>>
>> I still don't buy all these use cases:
>>
>> >>
>> >> Use-cases for new rlimit:
>> >>
>> >>   - Bumping the soft limit to RLIM_INFINITY, allows current process a=
ll
>> >>     its children to use addresses above 47-bits.
>>
>> OK, I get this, but only as a workaround for programs that make
>> assumptions about the address space and don't use some mechanism (to
>> be designed?) to work correctly in spite of a larger address space.
>
> I guess you've misread the case. It's opt-in for large adrress space, not
> other way around.
>
> I believe 47-bit VA by default is right way to go to make the transition
> without breaking userspace.

What I meant was: setting the rlimit to anything other than -1ULL is a
workaround, but otherwise I agree.  This still makes little sense if
set by PAM or other conventional rlimit tools.

>> >>
>> >>   - Lowering the hard limit to 47-bits would prevent current process =
all
>> >>     its children to use addresses above 47-bits, unless a process has
>> >>     CAP_SYS_RESOURCES.
>>
>> I've tried and I can't imagine any reason to do this.
>
> That's just if something went wrong and we want to stop an application
> from use addresses above 47-bit.

But CAP_SYS_RESOURCES still makes no sense in this context.

>
>> >>   - It=E2=80=99s also can be handy to lower hard or soft limit to arb=
itrary
>> >>     address. User-mode emulation in QEMU may lower the limit to 32-bi=
t
>> >>     to emulate 32-bit machine on 64-bit host.
>>
>> I don't understand.  QEMU user-mode emulation intercepts all syscalls.
>> What QEMU would *actually* want is a way to say "allocate me some
>> memory with the high N bits clear".  mmap-via-int80 on x86 should be
>> fixed to do this, but a new syscall with an explicit parameter would
>> work, as would a prctl changing the current limit.
>
> Look at mess in mmap_find_vma(). QEmu has to guess where is free virtual
> memory. That's unnessesary complex.
>
> prctl would work for this too. new-mmap would *not*: there are more ways
> to allocate vitual address space: shmat(), mremap(). Changing all of them
> just for this is stupid.

Fair enough.

Except that mmap-via-int80, shmat-via-int80, etc should still work (if
I understand what qemu needs correctly), as would the prctl.

>
>> >>
>> >> TODO:
>> >>   - port to non-x86;
>> >>
>> >> Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.inte=
l.com>
>> >> Cc: linux-api@vger.kernel.org
>> >
>> > This seems to nicely address the same problem on arm64, which has
>> > run into the same issue due to the various page table formats
>> > that can currently be chosen at compile time.
>>
>> On further reflection, I think this has very little to do with paging
>> formats except insofar as paging formats make us notice the problem.
>> The issue is that user code wants to be able to assume an upper limit
>> on an address, and it gets an upper limit right now that depends on
>> architecture due to paging formats.  But someone really might want to
>> write a *portable* 64-bit program that allocates memory with the high
>> 16 bits clear.  So let's add such a mechanism directly.
>>
>> As a thought experiment, what if x86_64 simply never allocated "high"
>> (above 2^47-1) addresses unless a new mmap-with-explicit-limit syscall
>> were used?  Old glibc would continue working.  Old VMs would work.
>> New programs that want to use ginormous mappings would have to use the
>> new syscall.  This would be totally stateless and would have no issues
>> with CRIU.
>
> Except, we need more than mmap as I mentioned.
>
> And what about stack? I'm not sure that everybody would be happy with
> stack in the middle of address space.

I would, personally.  I think that, for very large address spaces, we
should allocate a large block of stack and get rid of the "stack grows
down forever" legacy idea.  Then we would never need to worry about
the stack eventually hitting some other allocation.  And 2^57 bytes is
hilariously large for a default stack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
