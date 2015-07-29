Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 13B456B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 04:34:06 -0400 (EDT)
Received: by qgii95 with SMTP id i95so1020339qgi.2
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 01:34:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a74si30222281qgf.30.2015.07.29.01.34.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 01:34:04 -0700 (PDT)
Message-ID: <55B88FF1.7050502@redhat.com>
Date: Wed, 29 Jul 2015 10:33:53 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: show proportional swap share of the mapping
References: <1434373614-1041-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1434373614-1041-1-git-send-email-minchan@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="bIWt5psMKkstMKPBx4WDUW0nPWD78awtW"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Bongkyu Kim <bongkyu.kim@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Jonathan Corbet <corbet@lwn.net>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bIWt5psMKkstMKPBx4WDUW0nPWD78awtW
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 06/15/2015 03:06 PM, Minchan Kim wrote:
> We want to know per-process workingset size for smart memory management=

> on userland and we use swap(ex, zram) heavily to maximize memory effici=
ency
> so workingset includes swap as well as RSS.
>=20
> On such system, if there are lots of shared anonymous pages, it's
> really hard to figure out exactly how many each process consumes
> memory(ie, rss + wap) if the system has lots of shared anonymous
> memory(e.g, android).
>=20
> This patch introduces SwapPss field on /proc/<pid>/smaps so we can get
> more exact workingset size per process.
>=20
> Bongkyu tested it. Result is below.
>=20
> 1. 50M used swap
> SwapTotal: 461976 kB
> SwapFree: 411192 kB
>=20
> $ adb shell cat /proc/*/smaps | grep "SwapPss:" | awk '{sum +=3D $2} EN=
D {print sum}';
> 48236
> $ adb shell cat /proc/*/smaps | grep "Swap:" | awk '{sum +=3D $2} END {=
print sum}';
> 141184

Hi Minchan,

I just found out about this patch. What kind of shared memory is that?
Since it's android, I'm inclined to think something specific like
ashmem. I'm asking because this patch won't help for more common type of
shared memory. See my comment below.

>=20
> 2. 240M used swap
> SwapTotal: 461976 kB
> SwapFree: 216808 kB
>=20
> $ adb shell cat /proc/*/smaps | grep "SwapPss:" | awk '{sum +=3D $2} EN=
D {print sum}';
> 230315
> $ adb shell cat /proc/*/smaps | grep "Swap:" | awk '{sum +=3D $2} END {=
print sum}';
> 1387744
>=20
snip
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 6dee68d013ff..d537899f4b25 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -446,6 +446,7 @@ struct mem_size_stats {
>  	unsigned long anonymous_thp;
>  	unsigned long swap;
>  	u64 pss;
> +	u64 swap_pss;
>  };
> =20
>  static void smaps_account(struct mem_size_stats *mss, struct page *pag=
e,
> @@ -492,9 +493,20 @@ static void smaps_pte_entry(pte_t *pte, unsigned l=
ong addr,
>  	} else if (is_swap_pte(*pte)) {

This won't work for sysV shm, tmpfs and MAP_SHARED | MAP_ANONYMOUS
mapping pages which are pte_none when paged out. They're currently not
accounted at all when in swap.

Jerome

>  		swp_entry_t swpent =3D pte_to_swp_entry(*pte);
> =20
> -		if (!non_swap_entry(swpent))
> +		if (!non_swap_entry(swpent)) {
> +			int mapcount;
> +
>  			mss->swap +=3D PAGE_SIZE;
> -		else if (is_migration_entry(swpent))
> +			mapcount =3D swp_swapcount(swpent);
> +			if (mapcount >=3D 2) {
> +				u64 pss_delta =3D (u64)PAGE_SIZE << PSS_SHIFT;
> +
> +				do_div(pss_delta, mapcount);
> +				mss->swap_pss +=3D pss_delta;
> +			} else {
> +				mss->swap_pss +=3D (u64)PAGE_SIZE << PSS_SHIFT;
> +			}
> +		} else if (is_migration_entry(swpent))
>  			page =3D migration_entry_to_page(swpent);
>  	}
> =20
> @@ -638,6 +650,7 @@ static int show_smap(struct seq_file *m, void *v, i=
nt is_pid)
>  		   "Anonymous:      %8lu kB\n"
>  		   "AnonHugePages:  %8lu kB\n"
>  		   "Swap:           %8lu kB\n"
> +		   "SwapPss:        %8lu kB\n"
>  		   "KernelPageSize: %8lu kB\n"
>  		   "MMUPageSize:    %8lu kB\n"
>  		   "Locked:         %8lu kB\n",
> @@ -652,6 +665,7 @@ static int show_smap(struct seq_file *m, void *v, i=
nt is_pid)
>  		   mss.anonymous >> 10,
>  		   mss.anonymous_thp >> 10,
>  		   mss.swap >> 10,
> +		   (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
>  		   vma_kernel_pagesize(vma) >> 10,
>  		   vma_mmu_pagesize(vma) >> 10,
>  		   (vma->vm_flags & VM_LOCKED) ?
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index cee108cbe2d5..afc9eb3cba48 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -432,6 +432,7 @@ extern unsigned int count_swap_pages(int, int);
>  extern sector_t map_swap_page(struct page *, struct block_device **);
>  extern sector_t swapdev_block(int, pgoff_t);
>  extern int page_swapcount(struct page *);
> +extern int swp_swapcount(swp_entry_t entry);
>  extern struct swap_info_struct *page_swap_info(struct page *);
>  extern int reuse_swap_page(struct page *);
>  extern int try_to_free_swap(struct page *);
> @@ -523,6 +524,11 @@ static inline int page_swapcount(struct page *page=
)
>  	return 0;
>  }
> =20
> +static inline int swp_swapcount(swp_entry_t entry)
> +{
> +	return 0;
> +}
> +
>  #define reuse_swap_page(page)	(page_mapcount(page) =3D=3D 1)
> =20
>  static inline int try_to_free_swap(struct page *page)
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index a7e72103f23b..7a6bd1e5a8e9 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -875,6 +875,48 @@ int page_swapcount(struct page *page)
>  }
> =20
>  /*
> + * How many references to @entry are currently swapped out?
> + * This considers COUNT_CONTINUED so it returns exact answer.
> + */
> +int swp_swapcount(swp_entry_t entry)
> +{
> +	int count, tmp_count, n;
> +	struct swap_info_struct *p;
> +	struct page *page;
> +	pgoff_t offset;
> +	unsigned char *map;
> +
> +	p =3D swap_info_get(entry);
> +	if (!p)
> +		return 0;
> +
> +	count =3D swap_count(p->swap_map[swp_offset(entry)]);
> +	if (!(count & COUNT_CONTINUED))
> +		goto out;
> +
> +	count &=3D ~COUNT_CONTINUED;
> +	n =3D SWAP_MAP_MAX + 1;
> +
> +	offset =3D swp_offset(entry);
> +	page =3D vmalloc_to_page(p->swap_map + offset);
> +	offset &=3D ~PAGE_MASK;
> +	VM_BUG_ON(page_private(page) !=3D SWP_CONTINUED);
> +
> +	do {
> +		page =3D list_entry(page->lru.next, struct page, lru);
> +		map =3D kmap_atomic(page) + offset;
> +		tmp_count =3D *map;
> +		kunmap_atomic(map);
> +
> +		count +=3D (tmp_count & ~COUNT_CONTINUED) * n;
> +		n *=3D (SWAP_CONT_MAX + 1);
> +	} while (tmp_count & COUNT_CONTINUED);
> +out:
> +	spin_unlock(&p->lock);
> +	return count;
> +}
> +
> +/*
>   * We can write to an anon page without COW if there are no other refe=
rences
>   * to it.  And as a side-effect, free up its swap: because the old con=
tent
>   * on disk will never be read, and seeking back there to write new con=
tent
>=20



--bIWt5psMKkstMKPBx4WDUW0nPWD78awtW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVuI/1AAoJEHTzHJCtsuoCmf8IAIozqtSK0Pjl8/Pen+NhJZEg
OAp/Ld1UIPfXxQ0UGsPSQ9R6nCKomskjE6FwEKVqmb/Ui94UanmrLBQiAJVcgLJA
XLPZXOO4Z7D1+XXVlcA1UEkwVu4OKcLZCOqA/KpH7+pI7ot9bOw8VvhNmAVSrju1
N5Kt6Fz4nZaIfDCAMeYD7ahZplHlk0JxsLlvHJfE3mWCjgutZWzHEQEpOGTWMQZo
mE9FrqhW5Yu+zfPRatmmF0QFXdpHeZjyb5MjX9HEyi+bWBukNbKzfN5IoKj+379M
JNnyyaHe6FI9eXWT1hHGwMnbjbp2MKFTaNfXEHVVgFlur6K8OgqmwnDXVKQ/2hQ=
=3F+Y
-----END PGP SIGNATURE-----

--bIWt5psMKkstMKPBx4WDUW0nPWD78awtW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
