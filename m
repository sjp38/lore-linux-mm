Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DE2186B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 23:38:52 -0400 (EDT)
Received: by iwn40 with SMTP id 40so683891iwn.1
        for <linux-mm@kvack.org>; Sun, 11 Apr 2010 20:38:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1270900173-10695-2-git-send-email-lliubbo@gmail.com>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
	 <1270900173-10695-2-git-send-email-lliubbo@gmail.com>
Date: Mon, 12 Apr 2010 12:38:50 +0900
Message-ID: <x2y28c262361004112038p8699872ay700ebf967cd11907@mail.gmail.com>
Subject: Re: [PATCH] add alloc_pages_exact_node()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Hi, Bob.

On Sat, Apr 10, 2010 at 8:49 PM, Bob Liu <lliubbo@gmail.com> wrote:
> Add alloc_pages_exact_node() to allocate pages from exact
> node.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
> =C2=A0arch/powerpc/platforms/cell/ras.c | =C2=A0 =C2=A04 ++--
> =C2=A0include/linux/gfp.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | =C2=A0 =C2=A07 +++++++
> =C2=A0mm/mempolicy.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0mm/migrate.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A03 +--
> =C2=A04 files changed, 11 insertions(+), 5 deletions(-)
>
> diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/c=
ell/ras.c
> index 6d32594..93a5afd 100644
> --- a/arch/powerpc/platforms/cell/ras.c
> +++ b/arch/powerpc/platforms/cell/ras.c
> @@ -123,8 +123,8 @@ static int __init cbe_ptcal_enable_on_node(int nid, i=
nt order)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0area->nid =3D nid;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0area->order =3D order;
> - =C2=A0 =C2=A0 =C2=A0 area->pages =3D alloc_pages_from_valid_node(area->=
nid,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 GFP_KERNEL | GFP_THISNODE, area->order);
> + =C2=A0 =C2=A0 =C2=A0 area->pages =3D alloc_pages_exact_node(area->nid, =
GFP_KERNEL,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 area->order);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!area->pages) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNIN=
G "%s: no page on node %d\n",
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index c94f2ed..70cf2ae 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -296,6 +296,13 @@ static inline struct page *alloc_pages_from_valid_no=
de(int nid, gfp_t gfp_mask,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return __alloc_pages(gfp_mask, order, node_zon=
elist(nid, gfp_mask));
> =C2=A0}
>
> +static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mas=
k,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 unsigned int order)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return alloc_pages_from_valid_node(nid, gfp_mask |=
 GFP_THISNODE,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 order);
> +}
> +
> =C2=A0#ifdef CONFIG_NUMA
> =C2=A0extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned or=
der);
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 6838cd8..08f40a2 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -842,7 +842,7 @@ static void migrate_page_add(struct page *page, struc=
t list_head *pagelist,
>
> =C2=A0static struct page *new_node_page(struct page *page, unsigned long =
node, int **x)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 return alloc_pages_from_valid_node(node, GFP_HIGHU=
SER_MOVABLE, 0);
> + =C2=A0 =C2=A0 =C2=A0 return alloc_pages_exact_node(node, GFP_HIGHUSER_M=
OVABLE, 0);
> =C2=A0}

It's behavior change. Please, write down why you want to change
behavior in log.
Although I knew it, you need to explain it for others and git log,

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
