Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id A4E576B0254
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:33:22 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id e127so18113527pfe.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:33:22 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id gi2si4297983pac.105.2016.02.17.13.33.21
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 13:33:21 -0800 (PST)
Subject: Re: [PATCH 33/33] x86, pkeys: execute-only support
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
 <20160212210240.CB4BB5CA@viggo.jf.intel.com>
 <CAGXu5j+L6W17wkKNdheUQQ01bJE4ZXLDiG=5JBaNWju2j9NB2Q@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56C4E720.4050800@sr71.net>
Date: Wed, 17 Feb 2016 13:33:20 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+L6W17wkKNdheUQQ01bJE4ZXLDiG=5JBaNWju2j9NB2Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On 02/17/2016 01:27 PM, Kees Cook wrote:
> Is there a way to detect this feature's availability without userspace
> having to set up a segv handler and attempting to read a
> PROT_EXEC-only region? (i.e. cpu flag for protection keys, or a way to
> check the protection to see if PROT_READ got added automatically,
> etc?)

You can kinda do it with /proc/$pid/(s)maps.  Here's smaps, for instance:

> 00401000-00402000 --xp 00001000 08:14 4897479                            /root/pkeys/pkey-xonly
> Size:                  4 kB
> Rss:                   4 kB
...
> KernelPageSize:        4 kB
> MMUPageSize:           4 kB
> Locked:                0 kB
> ProtectionKey:        15
> VmFlags: ex mr mw me dw 

You can see "--x" and the ProtectionKey itself being nonzero.  That's a
reasonable indication.  There's also the "OSPKE" cpuid bit which only
shows up when the kernel has enabled protection keys.  This is
_separate_ from the bit that says whether the processor support pkeys.

I check them in test code like this:

> static inline void __cpuid(unsigned int *eax, unsigned int *ebx,
>                                 unsigned int *ecx, unsigned int *edx)
> {
>         /* ecx is often an input as well as an output. */
>         asm volatile(
>                 "cpuid;"
>                 : "=a" (*eax),
>                   "=b" (*ebx),
>                   "=c" (*ecx),
>                   "=d" (*edx)
>                 : "0" (*eax), "2" (*ecx));
> }
> 
> /* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx) */
> #define X86_FEATURE_PKU        (1<<3) /* Protection Keys for Userspace */
> #define X86_FEATURE_OSPKE      (1<<4) /* OS Protection Keys Enable */
> 
> static inline int cpu_has_pku(void)
> {
>         unsigned int eax;
>         unsigned int ebx;
>         unsigned int ecx;
>         unsigned int edx;
>         eax = 0x7;
>         ecx = 0x0;
>         __cpuid(&eax, &ebx, &ecx, &edx);
> 
>         if (!(ecx & X86_FEATURE_PKU)) {
>                 dprintf2("cpu does not have PKU\n");
>                 return 0;
>         }
>         if (!(ecx & X86_FEATURE_OSPKE)) {
>                 dprintf2("cpu does not have OSPKE\n");
>                 return 0;
>         }
>         return 1;
> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
