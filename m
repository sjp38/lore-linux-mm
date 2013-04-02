Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 39E986B0006
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 16:28:37 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <18fd40ab-eb9a-4a90-bea5-9b3d2603d7fa@default>
Date: Tue, 2 Apr 2013 13:28:16 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 2/2] mm: allow for outstanding swap writeback accounting
References: <<1364874612-925-1-git-send-email-bob.liu@oracle.com>>
In-Reply-To: <<1364874612-925-1-git-send-email-bob.liu@oracle.com>>
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
> Subject: [PATCH 2/2] mm: allow for outstanding swap writeback accounting
>=20
> From: Seth Jennings <sjenning@linux.vnet.ibm.com>
>=20
> To prevent flooding the swap device with writebacks, frontswap
> backends need to count and limit the number of outstanding
> writebacks.  The incrementing of the counter can be done before
> the call to __swap_writepage().  However, the caller must receive
> a notification when the writeback completes in order to decrement
> the counter.
>=20
> To achieve this functionality, this patch modifies
> __swap_writepage() to take the bio completion callback function
> as an argument.
>=20
> end_swap_bio_write(), the normal bio completion function, is also
> made non-static so that code doing the accounting can call it
> after the accounting is done.
>=20
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>

Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>

> ---
>  include/linux/swap.h |    4 +++-
>  mm/page_io.c         |    9 +++++----
>  2 files changed, 8 insertions(+), 5 deletions(-)
>=20
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 76f6c3b..b5b12c7 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -330,7 +330,9 @@ static inline void mem_cgroup_uncharge_swap(swp_entry=
_t ent)
>  /* linux/mm/page_io.c */
>  extern int swap_readpage(struct page *);
>  extern int swap_writepage(struct page *page, struct writeback_control *w=
bc);
> -extern int __swap_writepage(struct page *page, struct writeback_control =
*wbc);
> +extern void end_swap_bio_write(struct bio *bio, int err);
> +extern int __swap_writepage(struct page *page, struct writeback_control =
*wbc,
> +=09void (*end_write_func)(struct bio *, int));
>  extern int swap_set_page_dirty(struct page *page);
>  extern void end_swap_bio_read(struct bio *bio, int err);
>=20
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 8e6bcf1..8e0e5c0 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -42,7 +42,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
>  =09return bio;
>  }
>=20
> -static void end_swap_bio_write(struct bio *bio, int err)
> +void end_swap_bio_write(struct bio *bio, int err)
>  {
>  =09const int uptodate =3D test_bit(BIO_UPTODATE, &bio->bi_flags);
>  =09struct page *page =3D bio->bi_io_vec[0].bv_page;
> @@ -197,12 +197,13 @@ int swap_writepage(struct page *page, struct writeb=
ack_control *wbc)
>  =09=09end_page_writeback(page);
>  =09=09goto out;
>  =09}
> -=09ret =3D __swap_writepage(page, wbc);
> +=09ret =3D __swap_writepage(page, wbc, end_swap_bio_write);
>  out:
>  =09return ret;
>  }
>=20
> -int __swap_writepage(struct page *page, struct writeback_control *wbc)
> +int __swap_writepage(struct page *page, struct writeback_control *wbc,
> +=09void (*end_write_func)(struct bio *, int))
>  {
>  =09struct bio *bio;
>  =09int ret =3D 0, rw =3D WRITE;
> @@ -234,7 +235,7 @@ int __swap_writepage(struct page *page, struct writeb=
ack_control *wbc)
>  =09=09return ret;
>  =09}
>=20
> -=09bio =3D get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
> +=09bio =3D get_swap_bio(GFP_NOIO, page, end_write_func);
>  =09if (bio =3D=3D NULL) {
>  =09=09set_page_dirty(page);
>  =09=09unlock_page(page);
> --
> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
