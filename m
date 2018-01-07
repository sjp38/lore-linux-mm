Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B25E6B0266
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 00:14:32 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w74so2290797wmf.0
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 21:14:32 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.20])
        by mx.google.com with ESMTPS id v7si3622782wre.538.2018.01.06.21.14.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jan 2018 21:14:30 -0800 (PST)
Message-ID: <1515302062.6507.18.camel@gmx.de>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
From: Mike Galbraith <efault@gmx.de>
Date: Sun, 07 Jan 2018 06:14:22 +0100
In-Reply-To: <20171222084625.007160464@linuxfoundation.org>
References: <20171222084623.668990192@linuxfoundation.org>
	 <20171222084625.007160464@linuxfoundation.org>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Fri, 2017-12-22 at 09:45 +0100, Greg Kroah-Hartman wrote:
> 4.14-stable review patch.  If anyone has any objections, please let me kn=
ow.

FYI, this broke kdump, or rather the makedumpfile part thereof.
=A0Forward looking wreckage is par for the kdump course, but...

> ------------------
>=20
> From: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>=20
> commit 83e3c48729d9ebb7af5a31a504f3fd6aff0348c4 upstream.
>=20
> Size of the mem_section[] array depends on the size of the physical addre=
ss space.
>=20
> In preparation for boot-time switching between paging modes on x86-64
> we need to make the allocation of mem_section[] dynamic, because otherwis=
e
> we waste a lot of RAM: with CONFIG_NODE_SHIFT=3D10, mem_section[] size is=
 32kB
> for 4-level paging and 2MB for 5-level paging mode.
>=20
> The patch allocates the array on the first call to sparse_memory_present_=
with_active_regions().
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-mm@kvack.org
> Link: http://lkml.kernel.org/r/20170929140821.37654-2-kirill.shutemov@lin=
ux.intel.com
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>=20
> ---
>  include/linux/mmzone.h |    6 +++++-
>  mm/page_alloc.c        |   10 ++++++++++
>  mm/sparse.c            |   17 +++++++++++------
>  3 files changed, 26 insertions(+), 7 deletions(-)
>=20
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1152,13 +1152,17 @@ struct mem_section {
>  #define SECTION_ROOT_MASK	(SECTIONS_PER_ROOT - 1)
> =20
>  #ifdef CONFIG_SPARSEMEM_EXTREME
> -extern struct mem_section *mem_section[NR_SECTION_ROOTS];
> +extern struct mem_section **mem_section;
>  #else
>  extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROO=
T];
>  #endif
> =20
>  static inline struct mem_section *__nr_to_section(unsigned long nr)
>  {
> +#ifdef CONFIG_SPARSEMEM_EXTREME
> +	if (!mem_section)
> +		return NULL;
> +#endif
>  	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
>  		return NULL;
>  	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5651,6 +5651,16 @@ void __init sparse_memory_present_with_a
>  	unsigned long start_pfn, end_pfn;
>  	int i, this_nid;
> =20
> +#ifdef CONFIG_SPARSEMEM_EXTREME
> +	if (!mem_section) {
> +		unsigned long size, align;
> +
> +		size =3D sizeof(struct mem_section) * NR_SECTION_ROOTS;
> +		align =3D 1 << (INTERNODE_CACHE_SHIFT);
> +		mem_section =3D memblock_virt_alloc(size, align);
> +	}
> +#endif
> +
>  	for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, &this_nid)
>  		memory_present(this_nid, start_pfn, end_pfn);
>  }
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -23,8 +23,7 @@
>   * 1) mem_section	- memory sections, mem_map's for valid memory
>   */
>  #ifdef CONFIG_SPARSEMEM_EXTREME
> -struct mem_section *mem_section[NR_SECTION_ROOTS]
> -	____cacheline_internodealigned_in_smp;
> +struct mem_section **mem_section;
>  #else
>  struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT]
>  	____cacheline_internodealigned_in_smp;
> @@ -101,7 +100,7 @@ static inline int sparse_index_init(unsi
>  int __section_nr(struct mem_section* ms)
>  {
>  	unsigned long root_nr;
> -	struct mem_section* root;
> +	struct mem_section *root =3D NULL;
> =20
>  	for (root_nr =3D 0; root_nr < NR_SECTION_ROOTS; root_nr++) {
>  		root =3D __nr_to_section(root_nr * SECTIONS_PER_ROOT);
> @@ -112,7 +111,7 @@ int __section_nr(struct mem_section* ms)
>  		     break;
>  	}
> =20
> -	VM_BUG_ON(root_nr =3D=3D NR_SECTION_ROOTS);
> +	VM_BUG_ON(!root);
> =20
>  	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
>  }
> @@ -330,11 +329,17 @@ again:
>  static void __init check_usemap_section_nr(int nid, unsigned long *usema=
p)
>  {
>  	unsigned long usemap_snr, pgdat_snr;
> -	static unsigned long old_usemap_snr =3D NR_MEM_SECTIONS;
> -	static unsigned long old_pgdat_snr =3D NR_MEM_SECTIONS;
> +	static unsigned long old_usemap_snr;
> +	static unsigned long old_pgdat_snr;
>  	struct pglist_data *pgdat =3D NODE_DATA(nid);
>  	int usemap_nid;
> =20
> +	/* First call */
> +	if (!old_usemap_snr) {
> +		old_usemap_snr =3D NR_MEM_SECTIONS;
> +		old_pgdat_snr =3D NR_MEM_SECTIONS;
> +	}
> +
>  	usemap_snr =3D pfn_to_section_nr(__pa(usemap) >> PAGE_SHIFT);
>  	pgdat_snr =3D pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
>  	if (usemap_snr =3D=3D pgdat_snr)
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
