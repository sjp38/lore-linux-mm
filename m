Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A8DFC4403DA
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:31:45 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i38so2600346iod.10
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:31:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 192sor1627399its.90.2017.10.31.16.31.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 16:31:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031223156.B967E819@viggo.jf.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223156.B967E819@viggo.jf.intel.com>
From: Kees Cook <keescook@google.com>
Date: Tue, 31 Oct 2017 16:31:43 -0700
Message-ID: <CAGXu5jK=OiZ0mf1DsEaEmdFT+u+v3JHW6OcS=bCc=tx6XW93BA@mail.gmail.com>
Subject: Re: [PATCH 05/23] x86, mm: document X86_CR4_PGE toggling behavior
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, x86@kernel.org

On Tue, Oct 31, 2017 at 3:31 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> The comment says it all here.  The problem here is that the
> X86_CR4_PGE bit affects all PCIDs in a way that is totally
> obscure.
>
> This makes it easier for someone to find if grepping for PCID-
> related stuff and documents the hardware behavior that we are
> depending on.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: x86@kernel.org
> ---
>
>  b/arch/x86/include/asm/tlbflush.h |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff -puN arch/x86/include/asm/tlbflush.h~kaiser-prep-document-cr4-pge-behavior arch/x86/include/asm/tlbflush.h
> --- a/arch/x86/include/asm/tlbflush.h~kaiser-prep-document-cr4-pge-behavior     2017-10-31 15:03:50.479119470 -0700
> +++ b/arch/x86/include/asm/tlbflush.h   2017-10-31 15:03:50.482119612 -0700
> @@ -258,9 +258,11 @@ static inline void __native_flush_tlb_gl
>         WARN_ON_ONCE(!(cr4 & X86_CR4_PGE));
>         /*
>          * Architecturally, any _change_ to X86_CR4_PGE will fully flush the
> -        * TLB of all entries including all entries in all PCIDs and all
> -        * global pages.  Make sure that we _change_ the bit, regardless of
> +        * all entries.  Make sure that we _change_ the bit, regardless of

nit: "... flush the all entries." Drop "the" in the line above?

>          * whether we had X86_CR4_PGE set in the first place.
> +        *
> +        * Note that just toggling PGE *also* flushes all entries from all
> +        * PCIDs, regardless of the state of X86_CR4_PCIDE.
>          */
>         native_write_cr4(cr4 ^ X86_CR4_PGE);
>         /* Put original CR3 value back: */

pre-existing nit: s/CR3/CR4/

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
