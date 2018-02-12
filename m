Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5695B6B002A
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 09:51:32 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x188so2452420wmg.2
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:51:32 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id l64si6988665ede.72.2018.02.12.06.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 06:51:27 -0800 (PST)
Date: Mon, 12 Feb 2018 15:51:25 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180212145125.GE16484@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
 <20180211191312.54apu5edk3olsfz3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180211191312.54apu5edk3olsfz3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

Hi Ingo,

On Sun, Feb 11, 2018 at 08:13:12PM +0100, Ingo Molnar wrote:
> Could you please measure the PTI kernel vs. vanilla kernel?

Okay, did that, here is the data. The test machine is a Xeon E5-1620v2,
which is Ivy Bridge based (no PCIE) and has 4C/8T.

I ran the 2 tests you suggested:

	* Test-1: perf stat --null --sync --repeat 10 perf bench sched messaging -g 20

	* Test-2: perf stat --null --sync --repeat 10 perf bench sched messaging -g 20 -t

The tests ran on these kernels:

	* tip-32-pae: current top of tip/x86-tip-for-linus branch,
	              compiled as a 32 bit kernel with PAE
	              (commit b2ac58f90540e39324e7a29a7ad471407ae0bf48)

	* pti-32-pae: Same as above with my patches on-top, as on

		      git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v2

	              compiled as a 32 bit kernel with PAE
		      (commit dbb0074f778b396a11e0c897fef9d0c4583e7ccb)

	* pti-off-64: current top of tip/x86-tip-for-linus branch,
		      compiled as a 64 bit kernel, booted with pti=off
	              (commit b2ac58f90540e39324e7a29a7ad471407ae0bf48)

	* pti-on-64: current top of tip/x86-tip-for-linus branch,
		     compiled as a 64 bit kernel, booted with pti=on
	             (commit b2ac58f90540e39324e7a29a7ad471407ae0bf48)

Results are:
	            | Test-1             | Test-2          
	------------+--------------------+-----------------
	tip-32-pae  | 0.28s (+-0.44%)    | 0.27s (+-2.15%) 
	------------+--------------------+-----------------
	pti-32-pae  | 0.44s (+-0.40%)    | 0.42s (+-0.48%) 
	------------+--------------------+-----------------
	pti-off-64  | 0.24s (+-0.40%)    | 0.25s (+-1.31%) 
	------------+--------------------+-----------------
	pti-on-64   | 0.30s (+-0.47%)    | 0.31s (+-0.95%)

On 32 bit with PTI enabled the test needs 157% (non-threaded) and
156% (threaded) of time compared to the non-PTI baseline.

On 64 bit these numbers are 125% (non-threaded) and 124% (threaded).

The pti-32-pae kernel still used 'rep movsb' in the entry code. I
replaced that with 'rep movsl' and measured again, but overhead is still
around 152%.

I also measured cycles with 'perf record' to see where the additional
time is spent. The report showed around 25% in entry_SYSENTER_32 for
the pti-32-pae kernel. The same report on the tip-32-pae kernel shows
around 2.5% for the same symbol.

The entry_SYSENTER_32 path does no stack-copy on entry (it only
push/pops 8 bytes for the cr3 switch), but one full pt_regs copy on
exit. The exit-path was easy to optimize, I got it to the point where it
only copied 8 bytes to the entry stack (flags and eax).  This way I got
the 'perf report' numbers for entry_SYSENTER_32 down to around 20%, but
the overall numbers for Test-1 and Test-2 are still at around 150% of
the baseline.

So it seems that most of the additional time is actually spent switching
the cr3s.

Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
