Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id A5D686B0083
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:16:56 -0400 (EDT)
Received: by eeke49 with SMTP id e49so860340eek.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 09:16:55 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC] mm: support MIGRATE_DISCARD
In-Reply-To: <1345782330-23234-1-git-send-email-minchan@kernel.org>
References: <1345782330-23234-1-git-send-email-minchan@kernel.org>
Date: Fri, 24 Aug 2012 18:16:47 +0200
Message-ID: <xa1t393c464w.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Minchan Kim <minchan@kernel.org> writes:
> This patch introudes MIGRATE_DISCARD mode in migration.
> It drops *unmapped clean cache pages* instead of migration so that
> migration latency could be reduced by avoiding (memcpy + page remapping).
> It's useful for CMA because latency of migration is very important rather
> than eviction of background processes's workingset. In addition, it needs
> less free pages for migration targets so it could avoid memory reclaiming
> to get free pages, which is another factor increase latency.
>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Other than just a few minor comments below, the idea behind the code
looks good to me.

> ---
>  include/linux/migrate_mode.h |   11 ++++++---
>  mm/migrate.c                 |   56 ++++++++++++++++++++++++++++++++++--=
------
>  mm/page_alloc.c              |    2 +-
>  3 files changed, 55 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> index ebf3d89..8e44e30 100644
> --- a/include/linux/migrate_mode.h
> +++ b/include/linux/migrate_mode.h
> @@ -6,11 +6,16 @@
>   *	on most operations but not ->writepage as the potential stall time
>   *	is too significant
>   * MIGRATE_SYNC will block when migrating pages
> + * MIGRTATE_DISCARD will discard clean cache page instead of migration
> + *
> + * MIGRATE_ASYNC, MIGRATE_SYNC_LIGHT, MIGRATE_SYNC shouldn't be used
> + * together with OR flag.
>   */
>  enum migrate_mode {
> -	MIGRATE_ASYNC,
> -	MIGRATE_SYNC_LIGHT,
> -	MIGRATE_SYNC,
> +	MIGRATE_ASYNC =3D 1 << 0,
> +	MIGRATE_SYNC_LIGHT =3D 1 << 1,
> +	MIGRATE_SYNC =3D 1 << 2,
> +	MIGRATE_DISCARD =3D 1 << 3,
>  };
>=20=20
>  #endif		/* MIGRATE_MODE_H_INCLUDED */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 77ed2d7..90be7a9 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -225,7 +225,7 @@ static bool buffer_migrate_lock_buffers(struct buffer=
_head *head,
>  	struct buffer_head *bh =3D head;
>=20=20
>  	/* Simple case, sync compaction */
> -	if (mode !=3D MIGRATE_ASYNC) {
> +	if (!(mode & MIGRATE_ASYNC)) {

You're doing bit operations on enum type and except enum type to have
values which are not defined within the enum type (ie. MIGRATE_SYNC |
MIGRATE_DISCARD does not map to any enum value).  I feel that the
variable should be changed to be =E2=80=9Cunsigned=E2=80=9D (maybe with __b=
itwise)
rather than =E2=80=9Cenum migrate_mode=E2=80=9D.

>  		do {
>  			get_bh(bh);
>  			lock_buffer(bh);
> @@ -313,7 +313,7 @@ static int migrate_page_move_mapping(struct address_s=
pace *mapping,
>  	 * the mapping back due to an elevated page count, we would have to
>  	 * block waiting on other references to be dropped.
>  	 */
> -	if (mode =3D=3D MIGRATE_ASYNC && head &&
> +	if (mode & MIGRATE_ASYNC && head &&

Please use parens around bit operations. :)

>  			!buffer_migrate_lock_buffers(head, mode)) {
>  		page_unfreeze_refs(page, expected_count);
>  		spin_unlock_irq(&mapping->tree_lock);
> @@ -521,7 +521,7 @@ int buffer_migrate_page(struct address_space *mapping,
>  	 * with an IRQ-safe spinlock held. In the sync case, the buffers
>  	 * need to be locked now
>  	 */
> -	if (mode !=3D MIGRATE_ASYNC)
> +	if (!(mode & MIGRATE_ASYNC))
>  		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
>=20=20
>  	ClearPagePrivate(page);
> @@ -603,7 +603,7 @@ static int fallback_migrate_page(struct address_space=
 *mapping,
>  {
>  	if (PageDirty(page)) {
>  		/* Only writeback pages in full synchronous migration */
> -		if (mode !=3D MIGRATE_SYNC)
> +		if (!(mode & MIGRATE_SYNC))
>  			return -EBUSY;
>  		return writeout(mapping, page);
>  	}
> @@ -678,6 +678,19 @@ static int move_to_new_page(struct page *newpage, st=
ruct page *page,
>  	return rc;
>  }
>=20=20
> +static int discard_page(struct page *page)
> +{
> +	int ret =3D -EAGAIN;
> +
> +	struct address_space *mapping =3D page_mapping(page);
> +	if (page_has_private(page))
> +		if (!try_to_release_page(page, GFP_KERNEL))
> +			return ret;
> +	if (remove_mapping(mapping, page))
> +		ret =3D 0;
> +	return ret;
> +}
> +
>  static int __unmap_and_move(struct page *page, struct page *newpage,
>  			int force, bool offlining, enum migrate_mode mode)
>  {
> @@ -685,9 +698,12 @@ static int __unmap_and_move(struct page *page, struc=
t page *newpage,
>  	int remap_swapcache =3D 1;
>  	struct mem_cgroup *mem;
>  	struct anon_vma *anon_vma =3D NULL;
> +	enum ttu_flags ttu_flags;
> +	bool discard_mode =3D false;
> +	bool file =3D false;
>=20=20
>  	if (!trylock_page(page)) {
> -		if (!force || mode =3D=3D MIGRATE_ASYNC)
> +		if (!force || mode & MIGRATE_ASYNC)
>  			goto out;
>=20=20
>  		/*
> @@ -733,7 +749,7 @@ static int __unmap_and_move(struct page *page, struct=
 page *newpage,
>  		 * the retry loop is too short and in the sync-light case,
>  		 * the overhead of stalling is too much
>  		 */
> -		if (mode !=3D MIGRATE_SYNC) {
> +		if (!(mode & MIGRATE_SYNC)) {
>  			rc =3D -EBUSY;
>  			goto uncharge;
>  		}
> @@ -799,12 +815,32 @@ static int __unmap_and_move(struct page *page, stru=
ct page *newpage,
>  		goto skip_unmap;
>  	}
>=20=20
> +	file =3D page_is_file_cache(page);
> +	ttu_flags =3D TTU_IGNORE_ACCESS;
> +retry:
> +	if (!(mode & MIGRATE_DISCARD) || !file || PageDirty(page))
> +		ttu_flags |=3D (TTU_MIGRATION | TTU_IGNORE_MLOCK);
> +	else
> +		discard_mode =3D true;
> +
>  	/* Establish migration ptes or remove ptes */
> -	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +	rc =3D try_to_unmap(page, ttu_flags);
>=20=20
>  skip_unmap:
> -	if (!page_mapped(page))
> -		rc =3D move_to_new_page(newpage, page, remap_swapcache, mode);
> +	if (rc =3D=3D SWAP_SUCCESS) {
> +		if (!discard_mode)
> +			rc =3D move_to_new_page(newpage, page,
> +					remap_swapcache, mode);

Please use braces around this statement.

> +		else {
> +

Useless empty line.

> +			rc =3D discard_page(page);
> +			goto uncharge;
> +		}
> +	} else if (rc =3D=3D SWAP_MLOCK && discard_mode) {
> +		mode &=3D ~MIGRATE_DISCARD;
> +		discard_mode =3D false;
> +		goto retry;
> +	}
>=20=20
>  	if (rc && remap_swapcache)
>  		remove_migration_ptes(page, page);
> @@ -907,7 +943,7 @@ static int unmap_and_move_huge_page(new_page_t get_ne=
w_page,
>  	rc =3D -EAGAIN;
>=20=20
>  	if (!trylock_page(hpage)) {
> -		if (!force || mode !=3D MIGRATE_SYNC)
> +		if (!force || !(mode & MIGRATE_SYNC))
>  			goto out;
>  		lock_page(hpage);
>  	}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ba3100a..e14b960 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5670,7 +5670,7 @@ static int __alloc_contig_migrate_range(unsigned lo=
ng start, unsigned long end)
>=20=20
>  		ret =3D migrate_pages(&cc.migratepages,
>  				    __alloc_contig_migrate_alloc,
> -				    0, false, MIGRATE_SYNC);
> +				    0, false, MIGRATE_SYNC|MIGRATE_DISCARD);
>  	}
>=20=20
>  	putback_lru_pages(&cc.migratepages);
> --=20
> 1.7.9.5
>

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
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQN6jvAAoJECBgQBJQdR/0RGIP/iNDruWS4V6UcyAbqwLNCb2m
8czP397XwSPxkUTYr3S9qeUMhuRydvlh26xhWFaNVwJ4fNF8D6zNFgviGd0LVJVF
FDJTwHg7QEj3GLLHq9/Y7kFl0BhuvDMOeu48ZMcPL4lDtyA4g61KjAMvqZCbX7cj
2OHJFk3taVOlVsRdndLQF0+1/0vpQyKHBVe9L5kQhqGwwvtCTZPzn8o4GhFjeGkH
7tV2FV9zXftYYvXFZMZ8O8k3vzJ24dxGeHLoiI4WRfKgAvdk4g2Lvxc2a6WedXb3
3lR7uv4gXl5aFl30D5eQYXizSGzYD348Up8Ej1USxLQK9bXES31OzN/8rSCIObS4
lWaczMxL4MoPmCOkJ4K2TuluW1RBZ6+Td4RXOpUnykRUd/FdrbQ2gP+Vcb89M/Xw
AcRizhV4wF1QTlngwgFyWC3GXmbAz7y5NBRZuk9aKCXPQgsh9eZskdQiHFBz+iXH
3D+BAzzlOA2UFnhJCKdmj2zFds/o6tAZ4fkV4GRMF0RlJ62U42VOyub2S6z51ZzL
DwscS/LJ+AjHf7m5Ulxmm52NGNdPs5x3ME1/CF11Nw9nuf+92krTlYaGg4Q4/0ga
vz14fia+qcq9KfJJEkp3kxxBFtsCFF/Ru6FF3rYcsZNMLg2EFbJJ85VcpigB872e
iTwrHKPphGFC1SrPW7ft
=sJui
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
