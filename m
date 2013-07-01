Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 2A9296B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 05:22:48 -0400 (EDT)
Date: Mon, 1 Jul 2013 05:13:55 -0400
From: Chen Gong <gong.chen@linux.intel.com>
Subject: Re: [PATCH] mm/memory-failure.c: fix memory leak in successful soft
 offlining
Message-ID: <20130701091355.GA14444@gchen.bj.intel.com>
References: <1368807482-11153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6TrnltStXW4iwmi0"
Content-Disposition: inline
In-Reply-To: <1368807482-11153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 17, 2013 at 12:18:02PM -0400, Naoya Horiguchi wrote:
> Date: Fri, 17 May 2013 12:18:02 -0400
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> To: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen
>  <andi@firstfloor.org>, linux-kernel@vger.kernel.org, Naoya Horiguchi
>  <n-horiguchi@ah.jp.nec.com>
> Subject: [PATCH] mm/memory-failure.c: fix memory leak in successful soft
>  offlining
>=20
> After a successful page migration by soft offlining, the source page is
> not properly freed and it's never reusable even if we unpoison it afterwa=
rd.
>=20
> This is caused by the race between freeing page and setting PG_hwpoison.
> In successful soft offlining, the source page is put (and the refcount
> becomes 0) by putback_lru_page() in unmap_and_move(), where it's linked to
> pagevec and actual freeing back to buddy is delayed. So if PG_hwpoison is
> set for the page before freeing, the freeing does not functions as expect=
ed
> (in such case freeing aborts in free_pages_prepare() check.)
>=20
> This patch tries to make sure to free the source page before setting
> PG_hwpoison on it. To avoid reallocating, the page keeps MIGRATE_ISOLATE
> until after setting PG_hwpoison.
>=20
> This patch also removes obsolete comments about "keeping elevated refcoun=
t"
> because what they say is not true. Unlike memory_failure(), soft_offline_=
page()
> uses no special page isolation code, and the soft-offlined pages have no
> difference from buddy pages except PG_hwpoison. So no need to keep refcou=
nt
> elevated.
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 22 ++++++++++++++++++----
>  1 file changed, 18 insertions(+), 4 deletions(-)
>=20
> diff --git linux-v3.9-rc3.orig/mm/memory-failure.c linux-v3.9-rc3/mm/memo=
ry-failure.c
> index 4e01082..894262d 100644
> --- linux-v3.9-rc3.orig/mm/memory-failure.c
> +++ linux-v3.9-rc3/mm/memory-failure.c
> @@ -1410,7 +1410,8 @@ static int __get_any_page(struct page *p, unsigned =
long pfn, int flags)
> =20
>  	/*
>  	 * Isolate the page, so that it doesn't get reallocated if it
> -	 * was free.
> +	 * was free. This flag should be kept set until the source page
> +	 * is freed and PG_hwpoison on it is set.
>  	 */
>  	set_migratetype_isolate(p, true);
>  	/*
> @@ -1433,7 +1434,6 @@ static int __get_any_page(struct page *p, unsigned =
long pfn, int flags)
>  		/* Not a free page */
>  		ret =3D 1;
>  	}
> -	unset_migratetype_isolate(p, MIGRATE_MOVABLE);
>  	unlock_memory_hotplug();
>  	return ret;
>  }
> @@ -1503,7 +1503,6 @@ static int soft_offline_huge_page(struct page *page=
, int flags)
>  		atomic_long_add(1 << compound_trans_order(hpage),
>  				&num_poisoned_pages);
>  	}
> -	/* keep elevated page count for bad page */
>  	return ret;
>  }
> =20
> @@ -1568,7 +1567,7 @@ int soft_offline_page(struct page *page, int flags)
>  			atomic_long_inc(&num_poisoned_pages);
>  		}
>  	}
> -	/* keep elevated page count for bad page */
> +	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
>  	return ret;
>  }
> =20
> @@ -1634,7 +1633,22 @@ static int __soft_offline_page(struct page *page, =
int flags)
>  			if (ret > 0)
>  				ret =3D -EIO;
>  		} else {
> +			/*
> +			 * After page migration succeeds, the source page can
> +			 * be trapped in pagevec and actual freeing is delayed.
> +			 * Freeing code works differently based on PG_hwpoison,
> +			 * so there's a race. We need to make sure that the
> +			 * source page should be freed back to buddy before
> +			 * setting PG_hwpoison.
> +			 */
> +			if (!is_free_buddy_page(page))
> +				lru_add_drain_all();
> +			if (!is_free_buddy_page(page))
> +				drain_all_pages();
>  			SetPageHWPoison(page);
> +			if (!is_free_buddy_page(page))
> +				pr_info("soft offline: %#lx: page leaked\n",
> +					pfn);
>  			atomic_long_inc(&num_poisoned_pages);
>  		}
>  	} else {
> --=20
> 1.7.11.7
>=20
Hi, Naoya

What happens about this patch? It looks find to me but not merged yet.
If something I missed, would you please tell me again?

--6TrnltStXW4iwmi0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJR0UhTAAoJEI01n1+kOSLHWegP/jPbIOa4VsMTfNfywCTFlOYw
ry3XGPhOKxdiZtSKLrGN71p3OAQSyz/WXuOFMKrieXsj5Xbvxya/TzqlPsUFT1z1
HnMPT9redMW7cdNjNpkq3EGDudZP3anyCvTxJK3RY4PEdMZzAq+vvlVHBLq3VPs7
BJBBFYJ0u2TT6TfXCWnuQ1u/jvP3ICYWzyUCVqnKASe6hGRc4MUsHdPZX5E01rlO
6dFZkcHkLKPaIVjBJ54E/gVGfNFOIB8k2ZdP6DhpRncH3TbAHhniecrGYz0cSOri
X7OTCWqDT6bTrJpL/y6TeLx46QDF/zyv4fDXFL8gdlPtwdMAI7A6RfjoHSWzn33p
NOaDqc1DvD+97+XGF8tS35WGsVJILanc8A2Xn+0ipJ5cPj4v/GaWMzcynjSbFN1k
7W8PB7fHBBV8qx2MLNscft7W71HVf8K0GIgkrbghkkimKlMrbji70YeoQG2P0RwK
Hxlw5+GiGSzesU5lc7bjw6N2EQoz3FUnI/q/o4OQ/EWV8DOhfUaVhUazMD9wqiLS
YW2TErWDUMpnNibRqQlu7r/i4hsANc1kY7n4qyIe8/66IrU6tLNSbqHUAn1lrw2q
3ni38bnBPVVOtnvwQrRv0M5v1V9y0gmvjOSm8nGEE0DgeJXFzDNQzqNDdHsyK3g3
r4fKAQ30Y2E/a0OQEncd
=fMY0
-----END PGP SIGNATURE-----

--6TrnltStXW4iwmi0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
