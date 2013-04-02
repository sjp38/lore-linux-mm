Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D82DE6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 16:28:21 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ccbed25b-f02b-4491-9287-8b4764945462@default>
Date: Tue, 2 Apr 2013 13:27:58 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 1/2] mm: break up swap_writepage() for frontswap backends
References: <<1364874600-878-1-git-send-email-bob.liu@oracle.com>>
In-Reply-To: <<1364874600-878-1-git-send-email-bob.liu@oracle.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, minchan@kernel.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, ngupta@vflare.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, Bob Liu <bob.liu@oracle.com>

> From: Bob Liu [mailto:lliubbo@gmail.com]
> Sent: Monday, April 01, 2013 9:50 PM
> To: akpm@linux-foundation.org
> Cc: linux-mm@kvack.org; minchan@kernel.org; sjenning@linux.vnet.ibm.com; =
rcj@linux.vnet.ibm.com;
> ngupta@vflare.org; konrad.wilk@oracle.com; dan.magenheimer@oracle.com; Bo=
b Liu
> Subject: [PATCH 1/2] mm: break up swap_writepage() for frontswap backends
>=20
> From: Seth Jennings <sjenning@linux.vnet.ibm.com>
>=20
> swap_writepage() is currently where frontswap hooks into the swap
> write path to capture pages with the frontswap_store() function.
> However, if a frontswap backend wants to "resume" the writeback of
> a page to the swap device, it can't call swap_writepage() as
> the page will simply reenter the backend.
>=20
> This patch separates swap_writepage() into a top and bottom half, the
> bottom half named __swap_writepage() to allow a frontswap backend,
> like zswap, to resume writeback beyond the frontswap_store() hook.
>=20
> __add_to_swap_cache() is also made non-static so that the page for
> which writeback is to be resumed can be added to the swap cache.
>=20
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>

Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>

> ---
>  include/linux/swap.h |    2 ++
>  mm/page_io.c         |   14 +++++++++++---
>  mm/swap_state.c      |    2 +-
>  3 files changed, 14 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 2818a12..76f6c3b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -330,6 +330,7 @@ static inline void mem_cgroup_uncharge_swap(swp_entry=
_t ent)
>  /* linux/mm/page_io.c */
>  extern int swap_readpage(struct page *);
>  extern int swap_writepage(struct page *page, struct writeback_control *w=
bc);
> +extern int __swap_writepage(struct page *page, struct writeback_control =
*wbc);
>  extern int swap_set_page_dirty(struct page *page);
>  extern void end_swap_bio_read(struct bio *bio, int err);
>=20
> @@ -345,6 +346,7 @@ extern unsigned long total_swapcache_pages(void);
>  extern void show_swap_cache_info(void);
>  extern int add_to_swap(struct page *);
>  extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
> +extern int __add_to_swap_cache(struct page *page, swp_entry_t entry);
>  extern void __delete_from_swap_cache(struct page *);
>  extern void delete_from_swap_cache(struct page *);
>  extern void free_page_and_swap_cache(struct page *);
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 78eee32..8e6bcf1 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -185,9 +185,7 @@ bad_bmap:
>   */
>  int swap_writepage(struct page *page, struct writeback_control *wbc)
>  {
> -=09struct bio *bio;
> -=09int ret =3D 0, rw =3D WRITE;
> -=09struct swap_info_struct *sis =3D page_swap_info(page);
> +=09int ret =3D 0;
>=20
>  =09if (try_to_free_swap(page)) {
>  =09=09unlock_page(page);
> @@ -199,6 +197,16 @@ int swap_writepage(struct page *page, struct writeba=
ck_control *wbc)
>  =09=09end_page_writeback(page);
>  =09=09goto out;
>  =09}
> +=09ret =3D __swap_writepage(page, wbc);
> +out:
> +=09return ret;
> +}
> +
> +int __swap_writepage(struct page *page, struct writeback_control *wbc)
> +{
> +=09struct bio *bio;
> +=09int ret =3D 0, rw =3D WRITE;
> +=09struct swap_info_struct *sis =3D page_swap_info(page);
>=20
>  =09if (sis->flags & SWP_FILE) {
>  =09=09struct kiocb kiocb;
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 7efcf15..fe43fd5 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -78,7 +78,7 @@ void show_swap_cache_info(void)
>   * __add_to_swap_cache resembles add_to_page_cache_locked on swapper_spa=
ce,
>   * but sets SwapCache flag and private instead of mapping and index.
>   */
> -static int __add_to_swap_cache(struct page *page, swp_entry_t entry)
> +int __add_to_swap_cache(struct page *page, swp_entry_t entry)
>  {
>  =09int error;
>  =09struct address_space *address_space;
> --
> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
