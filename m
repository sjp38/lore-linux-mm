From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 02/30] x86, tlb: make CR4-based TLB flushes more robust
Date: Thu, 9 Nov 2017 11:48:13 +0100
Message-ID: <20171109104813.h67cts3mmr5zh4kd@pd.tnic>
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194649.61C7A485@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171108194649.61C7A485@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave.hansen@linux.intel.com>, luto@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org
List-Id: linux-mm.kvack.org

On Wed, Nov 08, 2017 at 11:46:49AM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Our CR4-based TLB flush currently requries global pages to be
> supported *and* enabled.  But, the hardware only needs for them to
> be supported.
> 
> Make the code more robust by alllowing the initial state of
> X86_CR4_PGE to be on *or* off.  In addition, if we get called in
> an unepected state (X86_CR4_PGE=0), issue a warning.  Having
> X86_CR4_PGE=0 is certainly unexpected and we should not ignore
> it if encountered.
> 
> This essentially gives us the best of both worlds: we get a TLB
> flush no matter what, and we get a warning if we got called in
> an unexpected way (X86_CR4_PGE=0).

Commit message could use a spell checker.

> The XOR change was suggested by Kirill Shutemov.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Cc: Richard Fellner <richard.fellner@student.tugraz.at>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: x86@kernel.org
> ---
> 
>  b/arch/x86/include/asm/tlbflush.h |   17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> diff -puN arch/x86/include/asm/tlbflush.h~kaiser-prep-make-cr4-writes-tolerate-clear-pge arch/x86/include/asm/tlbflush.h
> --- a/arch/x86/include/asm/tlbflush.h~kaiser-prep-make-cr4-writes-tolerate-clear-pge	2017-11-08 10:45:26.461681402 -0800
> +++ b/arch/x86/include/asm/tlbflush.h	2017-11-08 10:45:26.464681402 -0800
> @@ -250,9 +250,20 @@ static inline void __native_flush_tlb_gl
>  	unsigned long cr4;
>  
>  	cr4 = this_cpu_read(cpu_tlbstate.cr4);
> -	/* clear PGE */
> -	native_write_cr4(cr4 & ~X86_CR4_PGE);
> -	/* write old PGE again and flush TLBs */

<---- newline here.

> +	/*
> +	 * This function is only called on systems that support X86_CR4_PGE
> +	 * and where always set X86_CR4_PGE.  Warn if we are called without

"... and where X86_CR4_PGE is normally always set."

> +	 * PGE set.
> +	 */
> +	WARN_ON_ONCE(!(cr4 & X86_CR4_PGE));

<---- newline here.

> +	/*
> +	 * Architecturally, any _change_ to X86_CR4_PGE will fully flush the
> +	 * TLB of all entries including all entries in all PCIDs and all
> +	 * global pages.  Make sure that we _change_ the bit, regardless of
> +	 * whether we had X86_CR4_PGE set in the first place.

							    ... or not."

> +	 */
> +	native_write_cr4(cr4 ^ X86_CR4_PGE);


<---- newline here.

> +	/* Put original CR4 value back: */
>  	native_write_cr4(cr4);
>  }

Btw, Andy, we read the CR4 shadow in that function but we don't update
it. Why?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
