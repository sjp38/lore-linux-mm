Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C354B6B0072
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 18:05:13 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7128735pbb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 15:05:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339794567-17784-1-git-send-email-greg.pearson@hp.com>
References: <1339794567-17784-1-git-send-email-greg.pearson@hp.com>
Date: Fri, 15 Jun 2012 15:05:12 -0700
Message-ID: <CAE9FiQWh9bjBQZEbEp=Wti=qNJVR2G-CuEa8bC3TtfN5hSWKxg@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: fix overlapping allocation when doubling
 reserved array
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Pearson <greg.pearson@hp.com>
Cc: tj@kernel.org, hpa@linux.intel.com, akpm@linux-foundation.org, shangw@linux.vnet.ibm.com, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 15, 2012 at 2:09 PM, Greg Pearson <greg.pearson@hp.com> wrote:
> The __alloc_memory_core_early() routine will ask memblock for a range
> of memory then try to reserve it. If the reserved region array lacks
> space for the new range, memblock_double_array() is called to allocate
> more space for the array. If memblock is used to allocate memory for
> the new array it can end up using a range that overlaps with the range
> originally allocated in __alloc_memory_core_early(), leading to possible
> data corruption.
>
> With this patch memblock_double_array() now calls memblock_find_in_range(=
)
> with a narrowed candidate range so any memory allocated will not overlap
> with the original range that was being reserved. The range is narrowed by
> passing in the starting address of the previously allocated range as the
> end of the candidate range. Since memblock_find_in_range_node() looks for
> a free range by walking the free memory list in reverse order (highest
> memory address to lowest address) this change should not unnecessarily
> exclude chunks of memory that could otherwise be used to satisfy the
> request.

old early_res version have exclude_start/exclude_end.

>
> Signed-off-by: Greg Pearson <greg.pearson@hp.com>
> ---
> =A0mm/memblock.c | =A0 11 +++++++----
> =A01 files changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 952123e..599519c 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -184,7 +184,8 @@ static void __init_memblock memblock_remove_region(st=
ruct memblock_type *type, u
> =A0 =A0 =A0 =A0}
> =A0}
>
> -static int __init_memblock memblock_double_array(struct memblock_type *t=
ype)
> +static int __init_memblock memblock_double_array(struct memblock_type *t=
ype,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 phys_addr_t skip_base)

could pass phys_addr_t exclude_base, phys_addr_t execlude_end

> =A0{
> =A0 =A0 =A0 =A0struct memblock_region *new_array, *old_array;
> =A0 =A0 =A0 =A0phys_addr_t old_size, new_size, addr;
> @@ -222,7 +223,8 @@ static int __init_memblock memblock_double_array(stru=
ct memblock_type *type)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new_array =3D kmalloc(new_size, GFP_KERNEL=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0addr =3D new_array ? __pa(new_array) : 0;
> =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D memblock_find_in_range(0, MEMBLOCK=
_ALLOC_ACCESSIBLE, new_size, sizeof(phys_addr_t));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D memblock_find_in_range(0, skip_bas=
e,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_size, s=
izeof(phys_addr_t));

could try to search [exclude_end, MEMBLOCK_ALLOC_ACCESSIBLE) at first.
then try [0, execlude_start).

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
