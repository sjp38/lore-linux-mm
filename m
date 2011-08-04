Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CD09F6B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 02:10:40 -0400 (EDT)
Received: by vwm42 with SMTP id 42so1599446vwm.14
        for <linux-mm@kvack.org>; Wed, 03 Aug 2011 23:10:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-2-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-3-git-send-email-lliubbo@gmail.com>
Date: Thu, 4 Aug 2011 09:10:39 +0300
Message-ID: <CAOJsxLGRmR1RNEOrTjtU_y+6mPF0S+Lh5uZyyoKGZ1w0DLEYqQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] sparse: using kzalloc to clean up code
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, namhyung@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu, Aug 4, 2011 at 6:09 AM, Bob Liu <lliubbo@gmail.com> wrote:
> This patch using kzalloc to clean up sparse_index_alloc() and
> __GFP_ZERO to clean up __kmalloc_section_memmap().
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
> =A0mm/sparse.c | =A0 24 +++++++-----------------
> =A01 files changed, 7 insertions(+), 17 deletions(-)
>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 858e1df..9596635 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -65,15 +65,12 @@ static struct mem_section noinline __init_refok *spar=
se_index_alloc(int nid)
>
> =A0 =A0 =A0 =A0if (slab_is_available()) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (node_state(nid, N_HIGH_MEMORY))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 section =3D kmalloc_node(ar=
ray_size, GFP_KERNEL, nid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 section =3D kzalloc_node(ar=
ray_size, GFP_KERNEL, nid);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 section =3D kmalloc(array_s=
ize, GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 section =3D kzalloc(array_s=
ize, GFP_KERNEL);
> =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0section =3D alloc_bootmem_node(NODE_DATA(n=
id), array_size);
>
> - =A0 =A0 =A0 if (section)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(section, 0, array_size);
> -

You now broke the alloc_bootmem_node() path.

> =A0 =A0 =A0 =A0return section;
> =A0}
>
> @@ -636,19 +633,12 @@ static struct page *__kmalloc_section_memmap(unsign=
ed long nr_pages)
> =A0 =A0 =A0 =A0struct page *page, *ret;
> =A0 =A0 =A0 =A0unsigned long memmap_size =3D sizeof(struct page) * nr_pag=
es;
>
> - =A0 =A0 =A0 page =3D alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(mem=
map_size));
> + =A0 =A0 =A0 page =3D alloc_pages(GFP_KERNEL|__GFP_NOWARN|__GFP_ZERO,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 get_order(memmap_size));
> =A0 =A0 =A0 =A0if (page)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto got_map_page;
> -
> - =A0 =A0 =A0 ret =3D vmalloc(memmap_size);
> - =A0 =A0 =A0 if (ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto got_map_ptr;
> -
> - =A0 =A0 =A0 return NULL;
> -got_map_page:
> - =A0 =A0 =A0 ret =3D (struct page *)pfn_to_kaddr(page_to_pfn(page));
> -got_map_ptr:
> - =A0 =A0 =A0 memset(ret, 0, memmap_size);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D (struct page *)pfn_to_kaddr(page_to=
_pfn(page));
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D vzalloc(memmap_size);
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
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
