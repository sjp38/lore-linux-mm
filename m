Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7251E6B0009
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 04:28:40 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id r20so1479217lfr.4
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 01:28:40 -0800 (PST)
Received: from shrek.podlesie.net (shrek-3s.podlesie.net. [2a00:13a0:3010::1])
        by mx.google.com with ESMTP id v9si1748525ljb.392.2018.01.26.01.28.37
        for <linux-mm@kvack.org>;
        Fri, 26 Jan 2018 01:28:38 -0800 (PST)
Date: Fri, 26 Jan 2018 10:28:36 +0100
From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180126092836.GA11003@shrek.podlesie.net>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <20180124185800.GA11515@shrek.podlesie.net>
 <67E8EB67-EB60-441E-BDFB-521F3D431400@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <67E8EB67-EB60-441E-BDFB-521F3D431400@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Jan 25, 2018 at 02:09:40PM -0800, Nadav Amit wrote:
> The PoC apparently does not work with 3GB of memory or more on 32-bit. Does
> you setup has more? Can you try the attack while setting max_addr=1G ?

No, I tested on:

Pentium M (Dothan): 1.5 GB RAM, PAE for NX, 2GB/2GB split

CONFIG_NOHIGHMEM=y
CONFIG_VMSPLIT_2G=y
CONFIG_PAGE_OFFSET=0x80000000
CONFIG_X86_PAE=y

and

Xeon (Pentium 4): 2 GB RAM, no PAE, 1.75GB/2.25GB split
CONFIG_NOHIGHMEM=y
CONFIG_VMSPLIT_2G_OPT=y
CONFIG_PAGE_OFFSET=0x78000000


Now I'm testing with standard settings on
Pentium M: 1.5 GB RAM, no PAE, 3GB/1GB split, ~890 MB RAM available

CONFIG_NOHIGHMEM=y
CONFIG_PAGE_OFFSET=0xc0000000
CONFIG_X86_PAE=n

and it still does not work.

reliability from https://github.com/IAIK/meltdown reports 0.38%
(1/256 = 0.39%, "true" random), and other libkdump tools does not work.

https://github.com/paboldin/meltdown-exploit (on linux_proc_banner
symbol) reports:
cached = 46, uncached = 515, threshold 153
read c0897020 = ff   (score=0/1000)
read c0897021 = ff   (score=0/1000)
read c0897022 = ff   (score=0/1000)
read c0897023 = ff   (score=0/1000)
read c0897024 = ff   (score=0/1000)
NOT VULNERABLE

and my exploit with:

	for (i = 0; i < 256; i++) {
		unsigned char *px = p + (i << 12);

		t = rdtsc();
		readb(px);
		t = rdtsc() - t;
		if (t < 100)
			printf("%02x %lld\n", i, t);
	}

loop returns only "00 45". When I change the exploit code (now based
on paboldin code to be sure) to:

	movzx (%[addr]), %%eax
	movl $0xaa, %%eax
	shl $12, %%eax
	movzx (%[target], %%eax), %%eax

I always get "0xaa 51", so the CPU is speculatively executing the second
load with (0xaa << 12) in eax, and without the movl instruction, eax seems
to be always 0. I even tried to remove the shift:

	movzx (%[addr]), %%eax
	movzx (%[target], %%eax), %%eax

and I've been reading known value (from /dev/mem, for instance 0x20),
I've modified target array offset, and the CPU is still touching "wrong"
cacheline, eax == 0 instead of 0x20. I've also tested movl instead
of movzx (with and 0xff).


On Core 2 Quad in 64-bit mode everything works as expected, vulnerable
to Meltdown (I did not test it in 32-bit mode). I don't have any Core
"1" to test.

On that Pentium M syscall slowdown caused by PTI is huge, 7.5 times slower
(7 times compared to patched kernel with disabled PTI), on Skylake with
PCID the same trivial benchmark is "only" 3.5 times slower (and 5.2
times slower without PCID).

Krzysiek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
