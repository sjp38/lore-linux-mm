Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 87DC960021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 04:08:06 -0500 (EST)
Received: by ewy10 with SMTP id 10so2043045ewy.10
        for <linux-mm@kvack.org>; Tue, 08 Dec 2009 01:08:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B1DF8D4.2010202@novell.com>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
	 <20091207153552.0fadf335.akpm@linux-foundation.org>
	 <4B1DA06A.1050004@kernel.org> <4B1DF8D4.2010202@novell.com>
Date: Tue, 8 Dec 2009 10:08:01 +0100
Message-ID: <10f740e80912080108s5e145ee8t74a27e44d31966ed@mail.gmail.com>
Subject: Re: [PATCH] m68k: don't alias VMALLOC_END to vmalloc_end
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <teheo@novell.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Roman Zippel <zippel@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 8, 2009 at 07:57, Tejun Heo <teheo@novell.com> wrote:
> On SUN3, m68k defines macro VMALLOC_END as unsigned long variable
> vmalloc_end which is adjusted from mmu_emu_init(). =C2=A0This becomes
> problematic if a local variables vmalloc_end is defined in some
> function (not very unlikely) and VMALLOC_END is used in the function -
> the function thinks its referencing the global VMALLOC_END value but
> would be referencing its own local vmalloc_end variable.
>
> There's no reason VMALLOC_END should be a macro. =C2=A0Just define it as =
an
> unsigned long variable to avoid nasty surprises.
>
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Roman Zippel <zippel@linux-m68k.org>
> ---
> Okay, here it is. =C2=A0Compile tested. =C2=A0Geert, Roman, if you guys d=
on't
> object, I'd like to push it with the rest of percpu changes to Linus.
> What do you think?

Fine for me, except that by convention allcaps is reserved for macros?

>
> Thanks.
>
> =C2=A0arch/m68k/include/asm/pgtable_mm.h | =C2=A0 =C2=A03 +--
> =C2=A0arch/m68k/sun3/mmu_emu.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 =C2=A08 ++++----
> =C2=A02 files changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/arch/m68k/include/asm/pgtable_mm.h b/arch/m68k/include/asm/p=
gtable_mm.h
> index fe60e1a..0ea9f09 100644
> --- a/arch/m68k/include/asm/pgtable_mm.h
> +++ b/arch/m68k/include/asm/pgtable_mm.h
> @@ -83,9 +83,8 @@
> =C2=A0#define VMALLOC_START (((unsigned long) high_memory + VMALLOC_OFFSE=
T) & ~(VMALLOC_OFFSET-1))
> =C2=A0#define VMALLOC_END KMAP_START
> =C2=A0#else
> -extern unsigned long vmalloc_end;
> =C2=A0#define VMALLOC_START 0x0f800000
> -#define VMALLOC_END vmalloc_end
> +extern unsigned long VMALLOC_END;
> =C2=A0#endif /* CONFIG_SUN3 */
>
> =C2=A0/* zero page used for uninitialized stuff */
> diff --git a/arch/m68k/sun3/mmu_emu.c b/arch/m68k/sun3/mmu_emu.c
> index 3cd1939..25e2b14 100644
> --- a/arch/m68k/sun3/mmu_emu.c
> +++ b/arch/m68k/sun3/mmu_emu.c
> @@ -45,8 +45,8 @@
> =C2=A0** Globals
> =C2=A0*/
>
> -unsigned long vmalloc_end;
> -EXPORT_SYMBOL(vmalloc_end);
> +unsigned long VMALLOC_END;
> +EXPORT_SYMBOL(VMALLOC_END);
>
> =C2=A0unsigned long pmeg_vaddr[PMEGS_NUM];
> =C2=A0unsigned char pmeg_alloc[PMEGS_NUM];
> @@ -172,8 +172,8 @@ void mmu_emu_init(unsigned long bootmem_end)
> =C2=A0#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0// the lowest mapping here is the end of our
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0// vmalloc region
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if(!vmalloc_end)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vmalloc_end =3D seg;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (!VMALLOC_END)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 VMALLOC_END =3D seg;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0// mark the segmap alloc'd, and reserve any
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0// of the first 0xbff pages the hardware is
>



--=20
Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
							    -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
