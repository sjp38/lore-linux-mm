Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0196B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 07:33:44 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id s136so8118932oie.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 04:33:44 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 3si771432oil.205.2018.01.16.04.33.42
        for <linux-mm@kvack.org>;
        Tue, 16 Jan 2018 04:33:42 -0800 (PST)
Date: Tue, 16 Jan 2018 12:33:34 +0000
From: Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH 33/38] arm64: Implement thread_struct whitelist for
 hardened usercopy
Message-ID: <20180116123332.GX22781@e103592.cambridge.arm.com>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
 <1515636190-24061-34-git-send-email-keescook@chromium.org>
 <20180115122458.GI12608@e103592.cambridge.arm.com>
 <CAGXu5jLHb3BQ9U7g6suoVZwVeETiXiCRbxsprpLNiFxcjcWk1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jLHb3BQ9U7g6suoVZwVeETiXiCRbxsprpLNiFxcjcWk1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Christian Borntraeger <borntraeger@de.ibm.com>, Laura Abbott <labbott@redhat.com>, David Windsor <dave@nullcore.net>, Marc Zyngier <Marc.Zyngier@arm.com>, Dave Kleikamp <dave.kleikamp@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Luis de Bethencourt <luisbg@kernel.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matthew Garrett <mjg59@google.com>, James Morse <James.Morse@arm.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Christoffer Dall <christoffer.dall@linaro.org>

On Mon, Jan 15, 2018 at 12:06:17PM -0800, Kees Cook wrote:
> On Mon, Jan 15, 2018 at 4:24 AM, Dave P Martin <Dave.Martin@arm.com> wrote:
> > On Thu, Jan 11, 2018 at 02:03:05AM +0000, Kees Cook wrote:
> >> This whitelists the FPU register state portion of the thread_struct for
> >> copying to userspace, instead of the default entire structure.
> >>
> >> Cc: Catalin Marinas <catalin.marinas@arm.com>
> >> Cc: Will Deacon <will.deacon@arm.com>
> >> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> >> Cc: Ingo Molnar <mingo@kernel.org>
> >> Cc: James Morse <james.morse@arm.com>
> >> Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
> >> Cc: Dave Martin <Dave.Martin@arm.com>
> >> Cc: zijun_hu <zijun_hu@htc.com>
> >> Cc: linux-arm-kernel@lists.infradead.org
> >> Signed-off-by: Kees Cook <keescook@chromium.org>
> >> ---
> >>  arch/arm64/Kconfig                 | 1 +
> >>  arch/arm64/include/asm/processor.h | 8 ++++++++
> >>  2 files changed, 9 insertions(+)
> >>
> >> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> >> index a93339f5178f..c84477e6a884 100644
> >> --- a/arch/arm64/Kconfig
> >> +++ b/arch/arm64/Kconfig
> >> @@ -90,6 +90,7 @@ config ARM64
> >>       select HAVE_ARCH_MMAP_RND_BITS
> >>       select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
> >>       select HAVE_ARCH_SECCOMP_FILTER
> >> +     select HAVE_ARCH_THREAD_STRUCT_WHITELIST
> >>       select HAVE_ARCH_TRACEHOOK
> >>       select HAVE_ARCH_TRANSPARENT_HUGEPAGE
> >>       select HAVE_ARCH_VMAP_STACK
> >> diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
> >> index 023cacb946c3..e58a5864ec89 100644
> >> --- a/arch/arm64/include/asm/processor.h
> >> +++ b/arch/arm64/include/asm/processor.h
> >> @@ -113,6 +113,14 @@ struct thread_struct {
> >>       struct debug_info       debug;          /* debugging */
> >>  };
> >>
> >> +/* Whitelist the fpsimd_state for copying to userspace. */
> >> +static inline void arch_thread_struct_whitelist(unsigned long *offset,
> >> +                                             unsigned long *size)
> >> +{
> >> +     *offset = offsetof(struct thread_struct, fpsimd_state);
> >> +     *size = sizeof(struct fpsimd_state);
> >
> > This should be fpsimd_state.user_fpsimd (fpsimd_state.cpu is important
> > for correctly context switching and not supposed to be user-accessible.
> > A user copy that encompasses that is definitely a bug).
> 
> So, I actually spent some more time looking at this due to the
> comments from rmk on arm32, and I don't think any whitelist is needed
> here at all. (i.e. it can be *offset = *size = 0) This is because all
> the usercopying I could find uses static sizes or bounce buffers, both
> of which bypass the dynamic-size hardened usercopy checks.

Why do static sizes bypass these checks?  Just for efficiency?

> I've been running some arm64 builds now with this change, and I
> haven't tripped over any problems yet...

Sounds fair enough for now.

I haven't ruled out getting rid of the bounce buffers for FPSIMD
copy-in/out.  They add stack and runtime overhead, and don't seem
to bring benefits.

Bounce buffers enable copies to succeed or fail atomically, rather
than being half-done and then faulting.  This feels cleaner, but
In practice this doesn't seem to matter in real situations.

For SVE there are no bounce buffers, because the register data
can be unreasonably large (at least in theory).

Cheers
---Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
