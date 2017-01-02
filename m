Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53B8B6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 04:09:56 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xr1so106764466wjb.7
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 01:09:56 -0800 (PST)
Received: from mail-wj0-x244.google.com (mail-wj0-x244.google.com. [2a00:1450:400c:c01::244])
        by mx.google.com with ESMTPS id f186si68822531wmg.74.2017.01.02.01.09.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jan 2017 01:09:55 -0800 (PST)
Received: by mail-wj0-x244.google.com with SMTP id hb5so34622584wjc.2
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 01:09:54 -0800 (PST)
Date: Mon, 2 Jan 2017 12:09:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Message-ID: <20170102090952.GB30735@node.shutemov.name>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <CALCETrV+3rO=CuPjpoU9iKnKiJ2toW6QZAKXEqDW-QJJrX2EgQ@mail.gmail.com>
 <20161227022405.GA8780@node.shutemov.name>
 <CALCETrU2pmAawB1KZWDBA4uMeh0W_YgKGGQchhhx0VgbS-RcnQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrU2pmAawB1KZWDBA4uMeh0W_YgKGGQchhhx0VgbS-RcnQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Dec 26, 2016 at 07:22:03PM -0800, Andy Lutomirski wrote:
> On Mon, Dec 26, 2016 at 6:24 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> > On Mon, Dec 26, 2016 at 06:06:01PM -0800, Andy Lutomirski wrote:
> >> On Mon, Dec 26, 2016 at 5:54 PM, Kirill A. Shutemov
> >> <kirill.shutemov@linux.intel.com> wrote:
> >> > This patch introduces new rlimit resource to manage maximum virtual
> >> > address available to userspace to map.
> >> >
> >> > On x86, 5-level paging enables 56-bit userspace virtual address space.
> >> > Not all user space is ready to handle wide addresses. It's known that
> >> > at least some JIT compilers use high bit in pointers to encode their
> >> > information. It collides with valid pointers with 5-level paging and
> >> > leads to crashes.
> >> >
> >> > The patch aims to address this compatibility issue.
> >> >
> >> > MM would use min(RLIMIT_VADDR, TASK_SIZE) as upper limit of virtual
> >> > address available to map by userspace.
> >> >
> >> > The default hard limit will be RLIM_INFINITY, which basically means that
> >> > TASK_SIZE limits available address space.
> >> >
> >> > The soft limit will also be RLIM_INFINITY everywhere, but the machine
> >> > with 5-level paging enabled. In this case, soft limit would be
> >> > (1UL << 47) - PAGE_SIZE. Ita??s current x86-64 TASK_SIZE_MAX with 4-level
> >> > paging which known to be safe
> >> >
> >> > New rlimit resource would follow usual semantics with regards to
> >> > inheritance: preserved on fork(2) and exec(2). This has potential to
> >> > break application if limits set too wide or too narrow, but this is not
> >> > uncommon for other resources (consider RLIMIT_DATA or RLIMIT_AS).
> >> >
> >> > As with other resources you can set the limit lower than current usage.
> >> > It would affect only future virtual address space allocations.
> >> >
> >> > Use-cases for new rlimit:
> >> >
> >> >   - Bumping the soft limit to RLIM_INFINITY, allows current process all
> >> >     its children to use addresses above 47-bits.
> >> >
> >> >   - Bumping the soft limit to RLIM_INFINITY after fork(2), but before
> >> >     exec(2) allows the child to use addresses above 47-bits.
> >> >
> >> >   - Lowering the hard limit to 47-bits would prevent current process all
> >> >     its children to use addresses above 47-bits, unless a process has
> >> >     CAP_SYS_RESOURCES.
> >> >
> >> >   - Ita??s also can be handy to lower hard or soft limit to arbitrary
> >> >     address. User-mode emulation in QEMU may lower the limit to 32-bit
> >> >     to emulate 32-bit machine on 64-bit host.
> >>
> >> I tend to think that this should be a personality or an ELF flag, not
> >> an rlimit.
> >
> > My plan was to implement ELF flag on top. Basically, ELF flag would mean
> > that we bump soft limit to hard limit on exec.
> >
> >> That way setuid works right.
> >
> > Um.. I probably miss background here.
> >
> 
> If a setuid program depends on the lower limit, then a malicious
> program shouldn't be able to cause it to run with the higher limit.
> The personality code should already get this case right because
> personalities are reset when setuid happens.

It would be nice to have more fine-grained control than binary personality
flag gives. It would cover more use-cases.

Well, we could reset the limit on exec of setuid binary too. That's not
ideal, but...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
