Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id E103190001B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 10:17:06 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id l10so4480614eei.2
        for <linux-mm@kvack.org>; Thu, 13 Jun 2013 07:17:05 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [Part3 PATCH v2 1/4] bootmem, mem-hotplug: Register local pagetable pages with LOCAL_NODE_DATA when freeing bootmem.
In-Reply-To: <1371128636-9027-2-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com> <1371128636-9027-2-git-send-email-tangchen@cn.fujitsu.com>
Date: Thu, 13 Jun 2013 16:16:58 +0200
Message-ID: <xa1tli6ef63p.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 13 2013, Tang Chen wrote:
> As Yinghai suggested, even if a node is movable node, which has only
> ZONE_MOVABLE, pagetables should be put in the local node.
>
> In memory hot-remove logic, it offlines all pages first, and then
> removes pagetables. But the local pagetable pages cannot be offlined
> because they are used by kernel.
>
> So we should skip this kind of pages in offline procedure. But first
> of all, we need to mark them.
>
> This patch marks local node data pages in the same way as we mark the
> SECTION_INFO and MIX_SECTION_INFO data pages. We introduce a new type
> of bootmem: LOCAL_NODE_DATA. And use page->lru.next to mark this type
> of memory.
>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>  arch/x86/mm/init_64.c          |    2 +
>  include/linux/memblock.h       |   22 +++++++++++++++++
>  include/linux/memory_hotplug.h |   13 ++++++++-
>  mm/memblock.c                  |   52 ++++++++++++++++++++++++++++++++++=
++++++
>  mm/memory_hotplug.c            |   26 ++++++++++++++++++++
>  5 files changed, 113 insertions(+), 2 deletions(-)
>
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index bb00c46..25de304 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1053,6 +1053,8 @@ static void __init register_page_bootmem_info(void)
>=20=20
>  	for_each_online_node(i)
>  		register_page_bootmem_info_node(NODE_DATA(i));
> +
> +	register_page_bootmem_local_node();
>  #endif
>  }
>=20=20
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index a85ced9..8a38eef 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -131,6 +131,28 @@ void __next_free_mem_range_rev(u64 *idx, int nid, ph=
ys_addr_t *out_start,
>  	     i !=3D (u64)ULLONG_MAX;					\
>  	     __next_free_mem_range_rev(&i, nid, p_start, p_end, p_nid))
>=20=20
> +void __next_local_node_mem_range(int *idx, int nid, phys_addr_t *out_sta=
rt,
> +				 phys_addr_t *out_end, int *out_nid);

Why not make it return int?

> +
> +/**
> + * for_each_local_node_mem_range - iterate memblock areas storing local =
node
> + *                                 data
> + * @i: int used as loop variable
> + * @nid: node selector, %MAX_NUMNODES for all nodes
> + * @p_start: ptr to phys_addr_t for start address of the range, can be %=
NULL
> + * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
> + * @p_nid: ptr to int for nid of the range, can be %NULL
> + *
> + * Walks over memblock areas storing local node data. Since all the loca=
l node
> + * areas will be reserved by memblock, this iterator will only iterate
> + * memblock.reserve. Available as soon as memblock is initialized.
> + */
> +#define for_each_local_node_mem_range(i, nid, p_start, p_end, p_nid)	   =
 \
> +	for (i =3D -1,							    \
> +	     __next_local_node_mem_range(&i, nid, p_start, p_end, p_nid);   \
> +	     i !=3D -1;							    \
> +	     __next_local_node_mem_range(&i, nid, p_start, p_end, p_nid))
> +

If __next_local_node_mem_range() returned int, this would be easier:

+#define for_each_local_node_mem_range(i, nid, p_start, p_end, p_nid)	     =
 \
+	for (i =3D -1;
+	     (i =3D __next_local_node_mem_range(i, nid, p_start, p_end, p_nid)) !=
=3D -1; )

>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  int memblock_set_node(phys_addr_t base, phys_addr_t size, int nid);
>=20=20
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
> index 0b21e54..c0c4107 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h

> +/**
> + * __next_local_node_mem_range - next function for
> + *                               for_each_local_node_mem_range()
> + * @idx: pointer to int loop variable
> + * @nid: node selector, %MAX_NUMNODES for all nodes
> + * @out_start: ptr to phys_addr_t for start address of the range, can be=
 %NULL
> + * @out_end: ptr to phys_addr_t for end address of the range, can be %NU=
LL
> + * @out_nid: ptr to int for nid of the range, can be %NULL
> + */
> +void __init_memblock __next_local_node_mem_range(int *idx, int nid,
> +					phys_addr_t *out_start,
> +					phys_addr_t *out_end, int *out_nid)
> +{
> +	__next_flag_mem_range(idx, nid, MEMBLK_LOCAL_NODE,
> +			      out_start, out_end, out_nid);
> +}

static inline in a header file perhaps?

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJRudRaAAoJECBgQBJQdR/0WPwP/1dgJxcQSzLTWaUb1P4pkJA9
SMs6dBSola+wGugLvaLxZ6IQXmpMUZj+lXZiO0H1iXo+A9WVLbDae8BTUGgjLVAD
MAi0nMfcbjzxuVQAB53xV0N2Yoc1uuZf6eUlCD8WAEdrH3vn4DR3o8XRVNAvVY+S
WmLDWk8LdSsF78mqR0NRyT8YvmpdnKTZTu5ffI/0/BVwhJu+8Jz/GtC4QB5v8red
CJNrLIQmuAS+mIi6721RsvuYjaqYDfd3r4gIJjhxw5pMv97tHFgEXfZOuvO3RuBy
zg0NzLbJ8q6uD8BVxQPA559tMJ5rmFneksnhHkFIuAI3imuw+B2gQt8vRbz06EZL
VdiRzp6THTp8GDK+BmdxtvjDRblD6g83/kxeLTbIEoGLg+5qzXuBePpoQfTeK4+H
ThxLTkW59Xs1s+xc0bqiDiTBzKmBrUDojcrAq2DFFuUR7ub9TU6WhOv1FDygZRB1
ZNctpc0EyNkm++cYS5/ARCMA5v6vRPwdFI9TgbOXiRC/uIjhksalsBz839NDCbxG
0fy84YJPdXTImxyRdfgl+ECaDDrIMpFK5Jrvc6MCiV/YM57AYdBToHZ0/zJ6Tq1i
7Q0vdotsVZ2vgNlh0rXBwlTV6Si0NIqZuwe6ezWzLHUPP0e5kE197TGokpCp5k3U
kG1Sd3zHCdgF7OVBvNFB
=udWL
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
