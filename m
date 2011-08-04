Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9036B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 02:13:13 -0400 (EDT)
Received: by vwm42 with SMTP id 42so1600872vwm.14
        for <linux-mm@kvack.org>; Wed, 03 Aug 2011 23:13:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1312427390-20005-4-git-send-email-lliubbo@gmail.com>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-2-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-3-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-4-git-send-email-lliubbo@gmail.com>
Date: Thu, 4 Aug 2011 09:13:10 +0300
Message-ID: <CAOJsxLFzMDj69wzq5i29OGxDpGG0GZ0ux7KKpWwA_5E-np-VeA@mail.gmail.com>
Subject: Re: [PATCH 4/4] percpu: rename pcpu_mem_alloc to pcpu_mem_zalloc
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, namhyung@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu, Aug 4, 2011 at 6:09 AM, Bob Liu <lliubbo@gmail.com> wrote:
> Currently pcpu_mem_alloc() is implemented always return zeroed memory.
> So rename it to make user like pcpu_get_pages_and_bitmap() know don't rei=
nit it.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

> ---
> =A0mm/percpu-vm.c | =A0 =A05 ++---
> =A0mm/percpu.c =A0 =A0| =A0 17 +++++++++--------
> =A02 files changed, 11 insertions(+), 11 deletions(-)
>
> diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
> index ea53496..29e3730 100644
> --- a/mm/percpu-vm.c
> +++ b/mm/percpu-vm.c
> @@ -50,14 +50,13 @@ static struct page **pcpu_get_pages_and_bitmap(struct=
 pcpu_chunk *chunk,
>
> =A0 =A0 =A0 =A0if (!pages || !bitmap) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (may_alloc && !pages)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages =3D pcpu_mem_alloc(pa=
ges_size);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages =3D pcpu_mem_zalloc(p=
ages_size);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (may_alloc && !bitmap)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bitmap =3D pcpu_mem_alloc(b=
itmap_size);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bitmap =3D pcpu_mem_zalloc(=
bitmap_size);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!pages || !bitmap)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 memset(pages, 0, pages_size);
> =A0 =A0 =A0 =A0bitmap_copy(bitmap, chunk->populated, pcpu_unit_pages);
>
> =A0 =A0 =A0 =A0*bitmapp =3D bitmap;
> diff --git a/mm/percpu.c b/mm/percpu.c
> index bf80e55..28c37a2 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -273,11 +273,11 @@ static void __maybe_unused pcpu_next_pop(struct pcp=
u_chunk *chunk,
> =A0 =A0 =A0 =A0 =A0 =A0 (rs) =3D (re) + 1, pcpu_next_pop((chunk), &(rs), =
&(re), (end)))
>
> =A0/**
> - * pcpu_mem_alloc - allocate memory
> + * pcpu_mem_zalloc - allocate memory
> =A0* @size: bytes to allocate
> =A0*
> =A0* Allocate @size bytes. =A0If @size is smaller than PAGE_SIZE,
> - * kzalloc() is used; otherwise, vmalloc() is used. =A0The returned
> + * kzalloc() is used; otherwise, vzalloc() is used. =A0The returned
> =A0* memory is always zeroed.
> =A0*
> =A0* CONTEXT:
> @@ -286,7 +286,7 @@ static void __maybe_unused pcpu_next_pop(struct pcpu_=
chunk *chunk,
> =A0* RETURNS:
> =A0* Pointer to the allocated area on success, NULL on failure.
> =A0*/
> -static void *pcpu_mem_alloc(size_t size)
> +static void *pcpu_mem_zalloc(size_t size)
> =A0{
> =A0 =A0 =A0 =A0if (WARN_ON_ONCE(!slab_is_available()))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> @@ -302,7 +302,7 @@ static void *pcpu_mem_alloc(size_t size)
> =A0* @ptr: memory to free
> =A0* @size: size of the area
> =A0*
> - * Free @ptr. =A0@ptr should have been allocated using pcpu_mem_alloc().
> + * Free @ptr. =A0@ptr should have been allocated using pcpu_mem_zalloc()=
.
> =A0*/
> =A0static void pcpu_mem_free(void *ptr, size_t size)
> =A0{
> @@ -384,7 +384,7 @@ static int pcpu_extend_area_map(struct pcpu_chunk *ch=
unk, int new_alloc)
> =A0 =A0 =A0 =A0size_t old_size =3D 0, new_size =3D new_alloc * sizeof(new=
[0]);
> =A0 =A0 =A0 =A0unsigned long flags;
>
> - =A0 =A0 =A0 new =3D pcpu_mem_alloc(new_size);
> + =A0 =A0 =A0 new =3D pcpu_mem_zalloc(new_size);
> =A0 =A0 =A0 =A0if (!new)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> @@ -604,11 +604,12 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
> =A0{
> =A0 =A0 =A0 =A0struct pcpu_chunk *chunk;
>
> - =A0 =A0 =A0 chunk =3D pcpu_mem_alloc(pcpu_chunk_struct_size);
> + =A0 =A0 =A0 chunk =3D pcpu_mem_zalloc(pcpu_chunk_struct_size);
> =A0 =A0 =A0 =A0if (!chunk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
> - =A0 =A0 =A0 chunk->map =3D pcpu_mem_alloc(PCPU_DFL_MAP_ALLOC * sizeof(c=
hunk->map[0]));
> + =A0 =A0 =A0 chunk->map =3D pcpu_mem_zalloc(PCPU_DFL_MAP_ALLOC *
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 sizeof(chunk->map[0]));
> =A0 =A0 =A0 =A0if (!chunk->map) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(chunk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> @@ -1889,7 +1890,7 @@ void __init percpu_init_late(void)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUILD_BUG_ON(size > PAGE_SIZE);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 map =3D pcpu_mem_alloc(size);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 map =3D pcpu_mem_zalloc(size);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!map);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_irqsave(&pcpu_lock, flags);
> --
> 1.6.3.3
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
