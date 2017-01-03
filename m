Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 349786B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 11:05:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so79914176wmw.0
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 08:05:02 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id rz16si77847305wjb.93.2017.01.03.08.05.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 08:05:00 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id m203so87237748wma.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 08:05:00 -0800 (PST)
Date: Tue, 3 Jan 2017 19:04:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Message-ID: <20170103160457.GB17319@node.shutemov.name>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <2736959.3MfCab47fD@wuerfel>
 <CALCETrV_qejd-Ozqo4vTqz=LuukMUPeQ7EVUQbfTxs_xNbO3oQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrV_qejd-Ozqo4vTqz=LuukMUPeQ7EVUQbfTxs_xNbO3oQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On Mon, Jan 02, 2017 at 10:08:28PM -0800, Andy Lutomirski wrote:
> On Mon, Jan 2, 2017 at 12:44 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Tuesday, December 27, 2016 4:54:13 AM CET Kirill A. Shutemov wrote:
> >> As with other resources you can set the limit lower than current usage.
> >> It would affect only future virtual address space allocations.
> 
> I still don't buy all these use cases:
> 
> >>
> >> Use-cases for new rlimit:
> >>
> >>   - Bumping the soft limit to RLIM_INFINITY, allows current process all
> >>     its children to use addresses above 47-bits.
> 
> OK, I get this, but only as a workaround for programs that make
> assumptions about the address space and don't use some mechanism (to
> be designed?) to work correctly in spite of a larger address space.

I guess you've misread the case. It's opt-in for large adrress space, not
other way around.

I believe 47-bit VA by default is right way to go to make the transition
without breaking userspace.

> >>   - Bumping the soft limit to RLIM_INFINITY after fork(2), but before
> >>     exec(2) allows the child to use addresses above 47-bits.
> 
> Ditto.
> 
> >>
> >>   - Lowering the hard limit to 47-bits would prevent current process all
> >>     its children to use addresses above 47-bits, unless a process has
> >>     CAP_SYS_RESOURCES.
> 
> I've tried and I can't imagine any reason to do this.

That's just if something went wrong and we want to stop an application
from use addresses above 47-bit.

> >>   - Ita??s also can be handy to lower hard or soft limit to arbitrary
> >>     address. User-mode emulation in QEMU may lower the limit to 32-bit
> >>     to emulate 32-bit machine on 64-bit host.
> 
> I don't understand.  QEMU user-mode emulation intercepts all syscalls.
> What QEMU would *actually* want is a way to say "allocate me some
> memory with the high N bits clear".  mmap-via-int80 on x86 should be
> fixed to do this, but a new syscall with an explicit parameter would
> work, as would a prctl changing the current limit.

Look at mess in mmap_find_vma(). QEmu has to guess where is free virtual
memory. That's unnessesary complex.

prctl would work for this too. new-mmap would *not*: there are more ways
to allocate vitual address space: shmat(), mremap(). Changing all of them
just for this is stupid.

> >>
> >> TODO:
> >>   - port to non-x86;
> >>
> >> Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >> Cc: linux-api@vger.kernel.org
> >
> > This seems to nicely address the same problem on arm64, which has
> > run into the same issue due to the various page table formats
> > that can currently be chosen at compile time.
> 
> On further reflection, I think this has very little to do with paging
> formats except insofar as paging formats make us notice the problem.
> The issue is that user code wants to be able to assume an upper limit
> on an address, and it gets an upper limit right now that depends on
> architecture due to paging formats.  But someone really might want to
> write a *portable* 64-bit program that allocates memory with the high
> 16 bits clear.  So let's add such a mechanism directly.
> 
> As a thought experiment, what if x86_64 simply never allocated "high"
> (above 2^47-1) addresses unless a new mmap-with-explicit-limit syscall
> were used?  Old glibc would continue working.  Old VMs would work.
> New programs that want to use ginormous mappings would have to use the
> new syscall.  This would be totally stateless and would have no issues
> with CRIU.

Except, we need more than mmap as I mentioned.

And what about stack? I'm not sure that everybody would be happy with
stack in the middle of address space.

> If necessary, we could also have a prctl that changes a
> "personality-like" limit that is in effect when the old mmap was used.
> I say "personality-like" because it would reset under exactly the same
> conditions that personality resets itself.
> 
> Thoughts?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
