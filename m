Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id E25536B007B
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 04:38:08 -0400 (EDT)
Received: by yhr47 with SMTP id 47so5684210yhr.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 01:38:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1338880312-17561-1-git-send-email-minchan@kernel.org>
References: <1338880312-17561-1-git-send-email-minchan@kernel.org>
Date: Tue, 19 Jun 2012 17:38:07 +0900
Message-ID: <CAEwNFnBAC1OKCA3MnT0VHX+y9gfLDPhCO-=SVD_-sVipoAX4ag@mail.gmail.com>
Subject: Re: [PATCH] [RESEND] arm: limit memblock base address for early_pte_alloc
From: Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@arm.linux.org.uk>
Cc: Nicolas Pitre <nico@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Jongsung Kim <neidhard.kim@lge.com>, Chanho Min <chanho.min@lge.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Resend.

Could you please see this problem?

Thanks.

On Tue, Jun 5, 2012 at 4:11 PM, Minchan Kim <minchan@kernel.org> wrote:
> If we do arm_memblock_steal with a page which is not aligned with section=
 size,
> panic can happen during boot by page fault in map_lowmem.
>
> Detail:
>
> 1) mdesc->reserve can steal a page which is allocated at 0x1ffff000 by me=
mblock
> =C2=A0 which prefers tail pages of regions.
> 2) map_lowmem maps 0x00000000 - 0x1fe00000
> 3) map_lowmem try to map 0x1fe00000 but it's not aligned by section due t=
o 1.
> 4) calling alloc_init_pte allocates a new page for new pte by memblock_al=
loc
> 5) allocated memory for pte is 0x1fffe000 -> it's not mapped yet.
> 6) memset(ptr, 0, sz) in early_alloc_aligned got PANICed!
>
> This patch fix it by limiting memblock to mapped memory range.
>
> Reported-by: Jongsung Kim <neidhard.kim@lge.com>
> Suggested-by: Chanho Min <chanho.min@lge.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> =C2=A0arch/arm/mm/mmu.c | =C2=A0 37 ++++++++++++++++++++++---------------
> =C2=A01 file changed, 22 insertions(+), 15 deletions(-)
>
> diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
> index e5dad60..a15aafe 100644
> --- a/arch/arm/mm/mmu.c
> +++ b/arch/arm/mm/mmu.c
> @@ -594,7 +594,7 @@ static void __init alloc_init_pte(pmd_t *pmd, unsigne=
d long addr,
>
> =C2=A0static void __init alloc_init_section(pud_t *pud, unsigned long add=
r,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long en=
d, phys_addr_t phys,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct mem_ty=
pe *type)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct mem_ty=
pe *type, bool lowmem)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pmd_t *pmd =3D pmd_offset(pud, addr);
>
> @@ -619,6 +619,8 @@ static void __init alloc_init_section(pud_t *pud, uns=
igned long addr,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0flush_pmd_entry(p)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (lowmem)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 memblock_set_current_limit(__pa(addr));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * No need to loop=
; pte's aren't interested in the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * individual L1 e=
ntries.
> @@ -628,14 +630,15 @@ static void __init alloc_init_section(pud_t *pud, u=
nsigned long addr,
> =C2=A0}
>
> =C2=A0static void __init alloc_init_pud(pgd_t *pgd, unsigned long addr,
> - =C2=A0 =C2=A0 =C2=A0 unsigned long end, unsigned long phys, const struc=
t mem_type *type)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long end, unsigned long phys,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct mem_type *type, bool lowmem=
)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pud_t *pud =3D pud_offset(pgd, addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long next;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0do {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0next =3D pud_addr_=
end(addr, end);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 alloc_init_section(pud=
, addr, next, phys, type);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 alloc_init_section(pud=
, addr, next, phys, type, lowmem);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0phys +=3D next - a=
ddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} while (pud++, addr =3D next, addr !=3D end);
> =C2=A0}
> @@ -702,14 +705,7 @@ static void __init create_36bit_mapping(struct map_d=
esc *md,
> =C2=A0}
> =C2=A0#endif /* !CONFIG_ARM_LPAE */
>
> -/*
> - * Create the page directory entries and any necessary
> - * page tables for the mapping specified by `md'. =C2=A0We
> - * are able to cope here with varying sizes and address
> - * offsets, and we take full advantage of sections and
> - * supersections.
> - */
> -static void __init create_mapping(struct map_desc *md)
> +static inline void __create_mapping(struct map_desc *md, bool lowmem)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long addr, length, end;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0phys_addr_t phys;
> @@ -759,7 +755,7 @@ static void __init create_mapping(struct map_desc *md=
)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0do {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long next=
 =3D pgd_addr_end(addr, end);
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 alloc_init_pud(pgd, ad=
dr, next, phys, type);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 alloc_init_pud(pgd, ad=
dr, next, phys, type, lowmem);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0phys +=3D next - a=
ddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0addr =3D next;
> @@ -767,6 +763,18 @@ static void __init create_mapping(struct map_desc *m=
d)
> =C2=A0}
>
> =C2=A0/*
> + * Create the page directory entries and any necessary
> + * page tables for the mapping specified by `md'. =C2=A0We
> + * are able to cope here with varying sizes and address
> + * offsets, and we take full advantage of sections and
> + * supersections.
> + */
> +static void __init create_mapping(struct map_desc *md)
> +{
> + =C2=A0 =C2=A0 =C2=A0 __create_mapping(md, false);
> +}
> +
> +/*
> =C2=A0* Create the architecture specific mappings
> =C2=A0*/
> =C2=A0void __init iotable_init(struct map_desc *io_desc, int nr)
> @@ -1111,7 +1119,7 @@ static void __init map_lowmem(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0map.length =3D end=
 - start;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0map.type =3D MT_ME=
MORY;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 create_mapping(&map);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __create_mapping(&map,=
 true);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0}
>
> @@ -1123,11 +1131,10 @@ void __init paging_init(struct machine_desc *mdes=
c)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0void *zero_page;
>
> - =C2=A0 =C2=A0 =C2=A0 memblock_set_current_limit(arm_lowmem_limit);
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0build_mem_type_table();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0prepare_page_table();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0map_lowmem();
> + =C2=A0 =C2=A0 =C2=A0 memblock_set_current_limit(arm_lowmem_limit);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dma_contiguous_remap();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0devicemaps_init(mdesc);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0kmap_init();
> --
> 1.7.9.5
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
