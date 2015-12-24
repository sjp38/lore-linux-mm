From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV4 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Date: Thu, 24 Dec 2015 22:46:32 +0100
Message-ID: <20151224214632.GF4128@pd.tnic>
References: <cover.1450990481.git.tony.luck@intel.com>
 <a27752f2ac16e47b1a365c5c3cc870bd87ff0366.1450990481.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a27752f2ac16e47b1a365c5c3cc870bd87ff0366.1450990481.git.tony.luck@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org
List-Id: linux-mm.kvack.org

On Tue, Dec 15, 2015 at 05:30:49PM -0800, Tony Luck wrote:
> Using __copy_user_nocache() as inspiration create a memory copy
> routine for use by kernel code with annotations to allow for
> recovery from machine checks.
> 
> Notes:
> 1) We align the source address rather than the destination. This
>    means we never have to deal with a memory read that spans two
>    cache lines ... so we can provide a precise indication of
>    where the error occurred without having to re-execute at
>    a byte-by-byte level to find the exact spot like the original
>    did.
> 2) We 'or' BIT(63) into the return because this is the first
>    in a series of machine check safe functions. Some will copy
>    from user addresses, so may need to indicate an invalid user
>    address instead of a machine check.
> 3) This code doesn't play any cache games. Future functions can
>    use non-temporal loads/stores to meet needs of different callers.
> 4) Provide helpful macros to decode the return value.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/include/asm/string_64.h |   8 +++
>  arch/x86/kernel/x8664_ksyms_64.c |   4 ++
>  arch/x86/lib/memcpy_64.S         | 133 +++++++++++++++++++++++++++++++++++++++
>  3 files changed, 145 insertions(+)

...

> +	lea (%rdx,%rcx,8),%rdx
> +	jmp 100f
> +40:
> +	mov %ecx,%edx
> +100:
> +	sfence
> +	mov %edx,%eax
> +	bts $63,%rax
> +	ret

Huh, bit 63 is still alive?

Didn't we just talk about having different return values depending on
whether a fault or an MCE happened *instead* of setting that bit?

You have two "RET" points in that function, why not return a different
value from each?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
