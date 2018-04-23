Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4FBC6B000D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 13:09:21 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id g76so8876067vki.9
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:09:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l65sor6207614vkb.207.2018.04.23.10.09.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 10:09:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1524498460-25530-29-git-send-email-joro@8bytes.org>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org> <1524498460-25530-29-git-send-email-joro@8bytes.org>
From: Kees Cook <keescook@google.com>
Date: Mon, 23 Apr 2018 10:09:19 -0700
Message-ID: <CAGXu5jKYhqvgooq8q-2NoMC_Cqh-SR8J0y0c1x9LteinDfQELQ@mail.gmail.com>
Subject: Re: [PATCH 28/37] x86/mm/pti: Map kernel-text to user-space on 32 bit kernels
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, Anthony Liguori <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Mon, Apr 23, 2018 at 8:47 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Keeping the kernel text mapped with G bit set keeps its
> entries in the TLB across kernel entry/exit and improved the
> performance. The 64 bit x86 kernels already do this when
> there is no PCID, so do this in 32 bit as well since PCID is
> not even supported there.

I think this should keep at least part of the logic as 64-bit since
there are other reasons to turn off the Global flag:

https://lkml.kernel.org/r/20180420222026.D0B4AAC9@viggo.jf.intel.com

-Kees

>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/mm/init_32.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index c893c6a..8299b98 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -956,4 +956,10 @@ void mark_rodata_ro(void)
>         mark_nxdata_nx();
>         if (__supported_pte_mask & _PAGE_NX)
>                 debug_checkwx();
> +
> +       /*
> +        * Do this after all of the manipulation of the
> +        * kernel text page tables are complete.
> +        */
> +       pti_clone_kernel_text();
>  }
> --
> 2.7.4
>



-- 
Kees Cook
Pixel Security
