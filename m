Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06DD46B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 05:51:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so30802371pgc.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 02:51:27 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r1si33280586pfd.81.2016.12.09.02.51.26
        for <linux-mm@kvack.org>;
        Fri, 09 Dec 2016 02:51:26 -0800 (PST)
Date: Fri, 9 Dec 2016 10:51:20 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC, PATCHv1 00/28] 5-level paging
Message-ID: <20161209105120.GA3705@e104818-lin.cambridge.arm.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161209050130.GC2595@gmail.com>
 <13962749.Q2mLWEctkQ@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <13962749.Q2mLWEctkQ@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, maxim.kuvyrkov@linaro.org, Will Deacon <will.deacon@arm.com>, broonie@kernel.org, schwidefsky@de.ibm.com

On Fri, Dec 09, 2016 at 11:24:12AM +0100, Arnd Bergmann wrote:
> On Friday, December 9, 2016 6:01:30 AM CET Ingo Molnar wrote:
> > >   - Handle opt-in wider address space for userspace.
> > > 
> > >     Not all userspace is ready to handle addresses wider than current
> > >     47-bits. At least some JIT compiler make use of upper bits to encode
> > >     their info.
> > > 
> > >     We need to have an interface to opt-in wider addresses from userspace
> > >     to avoid regressions.
> > > 
> > >     For now, I've included testing-only patch which bumps TASK_SIZE to
> > >     56-bits. This can be handy for testing to see what breaks if we max-out
> > >     size of virtual address space.
> > 
> > So this is just a detail - but it sounds a bit limiting to me to provide an 'opt 
> > in' flag for something that will work just fine on the vast majority of 64-bit 
> > software.
> > 
> > Please make this an opt out compatibility flag instead: similar to how we handle 
> > address space layout limitations/quirks ABI details, such as ADDR_LIMIT_32BIT, 
> > ADDR_LIMIT_3GB, ADDR_COMPAT_LAYOUT, READ_IMPLIES_EXEC, etc.
> 
> We've had a similar discussion about JIT software on ARM64, which has a wide
> range of supported page table layouts and some software wants to limit that
> to a specific number.
> 
> I don't remember the outcome of that discussion, but I'm adding a few people
> to Cc that might remember.

The arm64 kernel supports several user VA space configurations (though
commonly 39 and 48-bit) and has had these from the initial port. We
realised that certain JITs (e.g.
https://bugzilla.mozilla.org/show_bug.cgi?id=1143022) and IIRC LLVM
assume a 47-bit user VA but AFAICT, most have been fixed.

ARMv8.1 also supports 52-bit VA (though only with 64K pages and we
haven't added support for it yet). However, it's likely that if we make
a 52-bit TASK_SIZE this the default, we will break some user
assumptions. While arguably that's not necessarily ABI, if user relies
on a 47 or 48-bit VA the kernel shouldn't break it. So I'm strongly
inclined to make the 52-bit TASK_SIZE an opt-in on arm64.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
