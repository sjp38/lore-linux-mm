Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1ED066B0243
	for <linux-mm@kvack.org>; Mon, 10 May 2010 19:59:56 -0400 (EDT)
Received: by pxi12 with SMTP id 12so147450pxi.14
        for <linux-mm@kvack.org>; Mon, 10 May 2010 16:59:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
Date: Mon, 10 May 2010 16:59:53 -0700
Message-ID: <AANLkTinOVSpCXdkkcCHMdN-HWsImE7_Gcbgg5plnNMss@mail.gmail.com>
Subject: Re: [PATCH 19/25] lmb: Add array resizing support
From: Yinghai Lu <yhlu.kernel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, May 10, 2010 at 2:38 AM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> When one of the array gets full, we resize it. After much thinking and
> a few iterations of that code, I went back to on-demand resizing using
> the (new) internal lmb_find_base() function, which is pretty much what
> Yinghai initially proposed, though there some differences in the details.
>
> To work this relies on the default alloc limit being set sensibly by
> the architecture.
>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> =A0lib/lmb.c | =A0 93 +++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++++-
> =A01 files changed, 92 insertions(+), 1 deletions(-)
>
> diff --git a/lib/lmb.c b/lib/lmb.c
> index 4977888..2602683 100644
> --- a/lib/lmb.c
> +++ b/lib/lmb.c
> @@ -11,6 +11,7 @@
> =A0*/
>
> =A0#include <linux/kernel.h>
> +#include <linux/slab.h>
> =A0#include <linux/init.h>
> =A0#include <linux/bitops.h>
> =A0#include <linux/poison.h>
> @@ -24,6 +25,17 @@ static struct lmb_region lmb_reserved_init_regions[INI=
T_LMB_REGIONS + 1];
>
> =A0#define LMB_ERROR =A0 =A0 =A0(~(phys_addr_t)0)
>
> +/* inline so we don't get a warning when pr_debug is compiled out */
> +static inline const char *lmb_type_name(struct lmb_type *type)
> +{
> + =A0 =A0 =A0 if (type =3D=3D &lmb.memory)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return "memory";
> + =A0 =A0 =A0 else if (type =3D=3D &lmb.reserved)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return "reserved";
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return "unknown";
> +}
> +
> =A0/*
> =A0* Address comparison utilities
> =A0*/
> @@ -156,6 +168,73 @@ static void lmb_coalesce_regions(struct lmb_type *ty=
pe,
> =A0 =A0 =A0 =A0lmb_remove_region(type, r2);
> =A0}
>
> +/* Defined below but needed now */
> +static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys=
_addr_t size);
> +
> +static int lmb_double_array(struct lmb_type *type)
> +{
> + =A0 =A0 =A0 struct lmb_region *new_array, *old_array;
> + =A0 =A0 =A0 phys_addr_t old_size, new_size, addr;
> + =A0 =A0 =A0 int use_slab =3D slab_is_available();
> +
> + =A0 =A0 =A0 pr_debug("lmb: %s array full, doubling...", lmb_type_name(t=
ype));
> +
> + =A0 =A0 =A0 /* Calculate new doubled size */
> + =A0 =A0 =A0 old_size =3D type->max * sizeof(struct lmb_region);
> + =A0 =A0 =A0 new_size =3D old_size << 1;
> +
> + =A0 =A0 =A0 /* Try to find some space for it.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* WARNING: We assume that either slab_is_available() and=
 we use it or
> + =A0 =A0 =A0 =A0* we use LMB for allocations. That means that this is un=
safe to use
> + =A0 =A0 =A0 =A0* when bootmem is currently active (unless bootmem itsel=
f is implemented
> + =A0 =A0 =A0 =A0* on top of LMB which isn't the case yet)
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* This should however not be an issue for now, as we cur=
rently only
> + =A0 =A0 =A0 =A0* call into LMB while it's still active, or much later w=
hen slab is
> + =A0 =A0 =A0 =A0* active for memory hotplug operations
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (use_slab) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_array =3D kmalloc(new_size, GFP_KERNEL)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D new_array =3D=3D NULL ? LMB_ERROR =
: __pa(new_array);
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D lmb_find_base(new_size, sizeof(phy=
s_addr_t), LMB_ALLOC_ACCESSIBLE);
> + =A0 =A0 =A0 if (addr =3D=3D LMB_ERROR) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("lmb: Failed to double %s array from=
 %ld to %ld entries !\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lmb_type_name(type), type->m=
ax, type->max * 2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 new_array =3D __va(addr);
> +
> + =A0 =A0 =A0 /* Found space, we now need to move the array over before
> + =A0 =A0 =A0 =A0* we add the reserved region since it may be our reserve=
d
> + =A0 =A0 =A0 =A0* array itself that is full.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 memcpy(new_array, type->regions, old_size);
> + =A0 =A0 =A0 memset(new_array + type->max, 0, old_size);
> + =A0 =A0 =A0 old_array =3D type->regions;
> + =A0 =A0 =A0 type->regions =3D new_array;
> + =A0 =A0 =A0 type->max <<=3D 1;
> +
> + =A0 =A0 =A0 /* If we use SLAB that's it, we are done */
> + =A0 =A0 =A0 if (use_slab)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 /* Add the new reserved region now. Should not fail ! */
> + =A0 =A0 =A0 BUG_ON(lmb_add_region(&lmb.reserved, addr, new_size) < 0);
> +
> + =A0 =A0 =A0 /* If the array wasn't our static init one, then free it. W=
e only do
> + =A0 =A0 =A0 =A0* that before SLAB is available as later on, we don't kn=
ow whether
> + =A0 =A0 =A0 =A0* to use kfree or free_bootmem_pages(). Shouldn't be a b=
ig deal
> + =A0 =A0 =A0 =A0* anyways
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (old_array !=3D lmb_memory_init_regions &&
> + =A0 =A0 =A0 =A0 =A0 old_array !=3D lmb_reserved_init_regions)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lmb_free(__pa(old_array), old_size);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static long lmb_add_region(struct lmb_type *type, phys_addr_t base, ph=
ys_addr_t size)
> =A0{
> =A0 =A0 =A0 =A0unsigned long coalesced =3D 0;
> @@ -196,7 +275,11 @@ static long lmb_add_region(struct lmb_type *type, ph=
ys_addr_t base, phys_addr_t
>
> =A0 =A0 =A0 =A0if (coalesced)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return coalesced;
> - =A0 =A0 =A0 if (type->cnt >=3D type->max)
> +
> + =A0 =A0 =A0 /* If we are out of space, we fail. It's too late to resize=
 the array
> + =A0 =A0 =A0 =A0* but then this shouldn't have happened in the first pla=
ce.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (WARN_ON(type->cnt >=3D type->max))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;
>
> =A0 =A0 =A0 =A0/* Couldn't coalesce the LMB, so add it to the sorted tabl=
e. */
> @@ -217,6 +300,14 @@ static long lmb_add_region(struct lmb_type *type, ph=
ys_addr_t base, phys_addr_t
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0type->cnt++;
>
> + =A0 =A0 =A0 /* The array is full ? Try to resize it. If that fails, we =
undo
> + =A0 =A0 =A0 =A0* our allocation and return an error
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (type->cnt =3D=3D type->max && lmb_double_array(type)) {

you need to pass base, base+size with lmb_double_array()

otherwise when you are using lmb_reserve(base, size), double_array()
array could have chance to get
new buffer that is overlapped with [base, base + size).

to keep it simple, should check_double_array() after lmb_reserve,
lmb_add, lmb_free (yes, that need it too).
that was suggested by Michael Ellerman.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
