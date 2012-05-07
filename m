Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 10B226B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 15:23:15 -0400 (EDT)
Received: by dadm1 with SMTP id m1so3203309dad.8
        for <linux-mm@kvack.org>; Mon, 07 May 2012 12:23:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1336390672-14421-9-git-send-email-hannes@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
	<1336390672-14421-9-git-send-email-hannes@cmpxchg.org>
Date: Mon, 7 May 2012 12:23:13 -0700
Message-ID: <CAE9FiQU2pJfCTmZjMG7SggjBZUfsnBArhGCxhaKQSZCojwfZPQ@mail.gmail.com>
Subject: Re: [patch 08/10] mm: nobootmem: unify allocation policy of
 (non-)panicking node allocations
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 7, 2012 at 4:37 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> While the panicking node-specific allocation function tries to satisfy
> node+goal, goal, node, anywhere, the non-panicking function still does
> node+goal, goal, anywhere.
>
> Make it simpler: define the panicking version in terms of the
> non-panicking one, like the node-agnostic interface, so they always
> behave the same way apart from how to deal with allocation failure.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0mm/nobootmem.c | =A0106 +++++++++++++++++++++++++++++-----------------=
----------
> =A01 file changed, 54 insertions(+), 52 deletions(-)
>
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index b078ff8..77069bb 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -275,6 +275,57 @@ void * __init __alloc_bootmem(unsigned long size, un=
signed long align,
> =A0 =A0 =A0 =A0return ___alloc_bootmem(size, align, goal, limit);
> =A0}
>
> +static void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long align,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long goal,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long limit)
> +{
> + =A0 =A0 =A0 void *ptr;
> +
> +again:
> + =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(pgdat->node_id, size, ali=
gn,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goal, limit);
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goal, limit);
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 if (goal) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto again;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned lo=
ng size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long align, unsigned long goal)
> +{
> + =A0 =A0 =A0 if (WARN_ON_ONCE(slab_is_available()))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc_node(size, GFP_NOWAIT, pgdat=
->node_id);
> +
> + =A0 =A0 =A0 return ___alloc_bootmem_node_nopanic(pgdat, size, align, go=
al, 0);
> +}
> +
> +void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uns=
igned long align, unsigned long goal,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uns=
igned long limit)
> +{
> + =A0 =A0 =A0 void *ptr;
> +
> + =A0 =A0 =A0 ptr =3D ___alloc_bootmem_node_nopanic(pgdat, size, align, g=
oal, limit);
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", s=
ize);
> + =A0 =A0 =A0 panic("Out of memory");
> + =A0 =A0 =A0 return NULL;
> +}
> +
> =A0/**
> =A0* __alloc_bootmem_node - allocate boot memory from a specific node
> =A0* @pgdat: node to allocate from
> @@ -293,30 +344,10 @@ void * __init __alloc_bootmem(unsigned long size, u=
nsigned long align,
> =A0void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long siz=
e,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsig=
ned long align, unsigned long goal)
> =A0{
> - =A0 =A0 =A0 void *ptr;
> -
> =A0 =A0 =A0 =A0if (WARN_ON_ONCE(slab_is_available()))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return kzalloc_node(size, GFP_NOWAIT, pgda=
t->node_id);
>
> -again:
> - =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(pgdat->node_id, size, ali=
gn,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0goal, -1ULL);
> - =A0 =A0 =A0 if (ptr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> -
> - =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goal, -1ULL);
> - =A0 =A0 =A0 if (ptr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> -
> - =A0 =A0 =A0 if (goal) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto again;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", s=
ize);
> - =A0 =A0 =A0 panic("Out of memory");
> - =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 return ___alloc_bootmem_node(pgdat, size, align, goal, 0);
> =A0}
>
> =A0void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned lon=
g size,
> @@ -347,22 +378,6 @@ void * __init alloc_bootmem_section(unsigned long si=
ze,
> =A0}
> =A0#endif
>
> -void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned lo=
ng size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long align, unsigned long goal)
> -{
> - =A0 =A0 =A0 void *ptr;
> -
> - =A0 =A0 =A0 if (WARN_ON_ONCE(slab_is_available()))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc_node(size, GFP_NOWAIT, pgdat=
->node_id);
> -
> - =A0 =A0 =A0 ptr =3D =A0__alloc_memory_core_early(pgdat->node_id, size, =
align,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0goal, -1ULL);
> - =A0 =A0 =A0 if (ptr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> -
> - =A0 =A0 =A0 return __alloc_bootmem_nopanic(size, align, goal);
> -}
> -
> =A0#ifndef ARCH_LOW_ADDRESS_LIMIT
> =A0#define ARCH_LOW_ADDRESS_LIMIT 0xffffffffUL
> =A0#endif
> @@ -404,22 +419,9 @@ void * __init __alloc_bootmem_low(unsigned long size=
, unsigned long align,
> =A0void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long=
 size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long align, unsigned long goal)
> =A0{
> - =A0 =A0 =A0 void *ptr;
> -
> =A0 =A0 =A0 =A0if (WARN_ON_ONCE(slab_is_available()))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return kzalloc_node(size, GFP_NOWAIT, pgda=
t->node_id);
>
> - =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(pgdat->node_id, size, ali=
gn,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal, ARCH_=
LOW_ADDRESS_LIMIT);
> - =A0 =A0 =A0 if (ptr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> -
> - =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goal, ARCH_LOW_ADDRESS_LIMIT);
> - =A0 =A0 =A0 if (ptr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> -
> - =A0 =A0 =A0 printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", s=
ize);
> - =A0 =A0 =A0 panic("Out of memory");
> - =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 return ___alloc_bootmem_node(pgdat, size, align, goal,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
ARCH_LOW_ADDRESS_LIMIT);
> =A0}
> --

Acked-by: Yinghai Lu <yinghai@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
