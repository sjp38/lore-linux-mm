Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 87C1F6B0253
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 05:28:13 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 128so12288431wmz.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 02:28:13 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id pb8si27406266wjb.141.2016.01.30.02.28.12
        for <linux-mm@kvack.org>;
        Sat, 30 Jan 2016 02:28:12 -0800 (PST)
Date: Sat, 30 Jan 2016 11:28:03 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
Message-ID: <20160130102803.GB15296@pd.tnic>
References: <CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
 <CAPcyv4hAenpeqPsj7Rd0Un_SgDpm+CjqH3EK72ho-=zZFvG7wA@mail.gmail.com>
 <CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
 <CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
 <CA+8MBbLFb1gdhFWeG-3V4=gHd-fHK_n1oJEFCrYiNa8Af6XAng@mail.gmail.com>
 <20160110112635.GC22896@pd.tnic>
 <20160111104425.GA29448@gmail.com>
 <CA+8MBbJpFWdkwC-yvmDFdFuLrchv2-XhPd3fk8A_hqOOyzm5og@mail.gmail.com>
 <20160114043956.GA8496@pd.tnic>
 <CA+8MBbKdH8v=gkTqzxpPRX9-jBEobU9XaEfZh=4cOXDjPE9fBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CA+8MBbKdH8v=gkTqzxpPRX9-jBEobU9XaEfZh=4cOXDjPE9fBA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Fri, Jan 29, 2016 at 04:35:35PM -0800, Tony Luck wrote:
> On Wed, Jan 13, 2016 at 8:39 PM, Borislav Petkov <bp@alien8.de> wrote:
> > On Wed, Jan 13, 2016 at 03:22:58PM -0800, Tony Luck wrote:
> >> Are there some examples of synthetic CPUID bits?
> >
> > X86_FEATURE_ALWAYS is one. The others got renamed into X86_BUG_* ones,
> > the remaining mechanism is the same, though.
> 
> So something like this [gmail will line wrap, but should still be legible]
> 
> Then Dan will be able to use:
> 
>       if (cpu_has(c, X86_FEATURE_MCRECOVERY))
> 
> to decide whether to use the (slightly slower, but recovery capable)
> __mcsafe_copy()
> or just pick the fastest memcpy() instead.

The most optimal way of alternatively calling two functions would be
something like this, IMO:

alternative_call(memcpy, __mcsafe_copy, X86_FEATURE_MCRECOVERY,
		 ASM_OUTPUT2("=a" (mcsafe_ret.trapnr), "=d" (mcsafe_ret.remain)),
		 "D" (dst), "S" (src), "d" (len));

I hope I've not messed up the calling convention but you want the inputs
in %rdi, %rsi, %rdx and the outputs in %rax, %rdx, respectively. Just
check the asm gcc generates and do not trust me :)

The other thing you probably would need to do is create our own
__memcpy() which returns struct mcsafe_ret so that the signatures of
both functions match.

Yeah, it is a bit of jumping through hoops but this way we do a CALL
<func_ptr> directly in asm, without any JMPs or NOPs padding the other
alternatives methods add.

But if you don't care about a small JMP and that is not a hot path, you
could do the simpler:

	if (static_cpu_has(X86_FEATURE_MCRECOVERY))
		return __mcsafe_copy(...);

	return memcpy();

which adds a JMP or a 5-byte NOP depending on the X86_FEATURE_MCRECOVERY
setting.

> diff --git a/arch/x86/include/asm/cpufeature.h
> b/arch/x86/include/asm/cpufeature.h
> index 7ad8c9464297..621e05103633 100644
> --- a/arch/x86/include/asm/cpufeature.h
> +++ b/arch/x86/include/asm/cpufeature.h
> @@ -106,6 +106,7 @@
>  #define X86_FEATURE_APERFMPERF ( 3*32+28) /* APERFMPERF */
>  #define X86_FEATURE_EAGER_FPU  ( 3*32+29) /* "eagerfpu" Non lazy FPU restore */
>  #define X86_FEATURE_NONSTOP_TSC_S3 ( 3*32+30) /* TSC doesn't stop in
> S3 state */
> +#define X86_FEATURE_MCRECOVERY ( 3*32+31) /* cpu has recoverable

Why not write it out?

	X86_FEATURE_MCE_RECOVERY

> machine checks */
> 
>  /* Intel-defined CPU features, CPUID level 0x00000001 (ecx), word 4 */
>  #define X86_FEATURE_XMM3       ( 4*32+ 0) /* "pni" SSE-3 */

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
