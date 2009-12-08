Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 99F9660021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 04:11:52 -0500 (EST)
Received: by ewy10 with SMTP id 10so2046121ewy.10
        for <linux-mm@kvack.org>; Tue, 08 Dec 2009 01:11:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091207153552.0fadf335.akpm@linux-foundation.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
	 <20091207153552.0fadf335.akpm@linux-foundation.org>
Date: Tue, 8 Dec 2009 10:11:49 +0100
Message-ID: <10f740e80912080111l57b0562doebedb1f878592105@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, tj@kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 8, 2009 at 00:35, Andrew Morton <akpm@linux-foundation.org> wro=
te:
> (cc linux-ia64)
>
> On Mon, 07 Dec 2009 16:24:03 +0000
> "Jan Beulich" <JBeulich@novell.com> wrote:
>
>> At least on ia64 vmalloc_end is a global variable that VMALLOC_END
>> expands to. Hence having a local variable named vmalloc_end and
>> initialized from VMALLOC_END won't work on such platforms. Rename
>> these variables, and for consistency also rename vmalloc_start.
>>
>
> erk. =C2=A0So does 2.6.32's vmalloc() actually work correctly on ia64?
>
> Perhaps vmalloc_end wasn't a well chosen name for an arch-specific
> global variable.
>
> arch/m68k/include/asm/pgtable_mm.h does the same thing. =C2=A0Did it brea=
k too?

Rename to m68k_vmalloc_{end,start}?

Hmm, sounds better than introducing allcaps variables...

>
>> ---
>> =C2=A0mm/vmalloc.c | =C2=A0 16 ++++++++--------
>> =C2=A01 file changed, 8 insertions(+), 8 deletions(-)
>>
>> --- linux-2.6.32/mm/vmalloc.c
>> +++ 2.6.32-dont-use-vmalloc_end/mm/vmalloc.c
>> @@ -2060,13 +2060,13 @@ static unsigned long pvm_determine_end(s
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vmap_a=
rea **pprev,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long=
 align)
>> =C2=A0{
>> - =C2=A0 =C2=A0 const unsigned long vmalloc_end =3D VMALLOC_END & ~(alig=
n - 1);
>> + =C2=A0 =C2=A0 const unsigned long end =3D VMALLOC_END & ~(align - 1);
>> =C2=A0 =C2=A0 =C2=A0 unsigned long addr;
>>
>> =C2=A0 =C2=A0 =C2=A0 if (*pnext)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr =3D min((*pnext)->va_st=
art & ~(align - 1), vmalloc_end);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr =3D min((*pnext)->va_st=
art & ~(align - 1), end);
>> =C2=A0 =C2=A0 =C2=A0 else
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr =3D vmalloc_end;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr =3D end;
>>
>> =C2=A0 =C2=A0 =C2=A0 while (*pprev && (*pprev)->va_end > addr) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *pnext =3D *pprev;
>> @@ -2105,8 +2105,8 @@ struct vm_struct **pcpu_get_vm_areas(con
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const size_t *sizes,=
 int nr_vms,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t align, gfp_t =
gfp_mask)
>> =C2=A0{
>> - =C2=A0 =C2=A0 const unsigned long vmalloc_start =3D ALIGN(VMALLOC_STAR=
T, align);
>> - =C2=A0 =C2=A0 const unsigned long vmalloc_end =3D VMALLOC_END & ~(alig=
n - 1);
>> + =C2=A0 =C2=A0 const unsigned long vstart =3D ALIGN(VMALLOC_START, alig=
n);
>> + =C2=A0 =C2=A0 const unsigned long vend =3D VMALLOC_END & ~(align - 1);
>> =C2=A0 =C2=A0 =C2=A0 struct vmap_area **vas, *prev, *next;
>> =C2=A0 =C2=A0 =C2=A0 struct vm_struct **vms;
>> =C2=A0 =C2=A0 =C2=A0 int area, area2, last_area, term_area;
>> @@ -2142,7 +2142,7 @@ struct vm_struct **pcpu_get_vm_areas(con
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 last_end =3D offsets[last_area] + sizes[last_area];
>>
>> - =C2=A0 =C2=A0 if (vmalloc_end - vmalloc_start < last_end) {
>> + =C2=A0 =C2=A0 if (vend - vstart < last_end) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 WARN_ON(true);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;
>> =C2=A0 =C2=A0 =C2=A0 }
>> @@ -2167,7 +2167,7 @@ retry:
>> =C2=A0 =C2=A0 =C2=A0 end =3D start + sizes[area];
>>
>> =C2=A0 =C2=A0 =C2=A0 if (!pvm_find_next_prev(vmap_area_pcpu_hole, &next,=
 &prev)) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 base =3D vmalloc_end - last_=
end;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 base =3D vend - last_end;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto found;
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 base =3D pvm_determine_end(&next, &prev, align) - e=
nd;
>> @@ -2180,7 +2180,7 @@ retry:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* base might have=
 underflowed, add last_end before
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* comparing.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (base + last_end < vmallo=
c_start + last_end) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (base + last_end < vstart=
 + last_end) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_unlock(&vmap_area_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (!purged) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 purge_vmap_area_lazy();
>>
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
