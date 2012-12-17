Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 5595C6B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 17:24:25 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id dq11so2782351wgb.26
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 14:24:23 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] CMA: call to putback_lru_pages
In-Reply-To: <1355779504-30798-1-git-send-email-srinivas.pandruvada@linux.intel.com>
References: <1355779504-30798-1-git-send-email-srinivas.pandruvada@linux.intel.com>
Date: Mon, 17 Dec 2012 23:24:14 +0100
Message-ID: <xa1tlicwiagh.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

[+marek]

On Mon, Dec 17 2012, Srinivas Pandruvada wrote:
> As per documentation and other places calling putback_lru_pages,
> on error only, except for CMA. I am not sure this is a problem
> for CMA or not.

If ret >=3D 0 than the list is empty anyway so the effect of this patch is
to save a function call.  It's also true that other callers call it only
on error so __alloc_contig_migrate_range() is an odd man out here.  As
such:

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Signed-off-by: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>
> ---
>  mm/page_alloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 83637df..5a887bf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5802,8 +5802,8 @@ static int __alloc_contig_migrate_range(struct comp=
act_control *cc,
>  				    alloc_migrate_target,
>  				    0, false, MIGRATE_SYNC);
>  	}
> -
> -	putback_movable_pages(&cc->migratepages);
> +	if (ret < 0)
> +		putback_movable_pages(&cc->migratepages);
>  	return ret > 0 ? 0 : ret;
>  }

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
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQz5uOAAoJECBgQBJQdR/0RxYQAIYOaRxRLVeK36MdEMjw5te/
nR3fvcicQVNlYuKgSEaujTjNW1o2NG7fBhoe42LtVC4meNHOND113LNP+rYH51QY
2aGnImQ89FBur0nE+vF860D8Ec8kqRItk2z9xkSosllA/bJnNb3Svfl+QUcT9l8B
jUufaatBlO79pCLzdJgzCuk0jMPUFNH9/msquBgS6Lu6UCFCAORauVtyYHt4f9Q8
wL/N3lMqrV74/YPVVdlyR5SWKgE7ERAMGHfDixOjgbscVNYo7u1BWY4dh8xm5tfr
+lotXKaT1q6dkDWh1AG4A5k8PeoLyUFU/9mom2jDZ+w45wRgiqA1TfN965KSlImv
iqO3T2ap5VQ9aFB3jGsv0cpvH2uZ7GuRasEeUltTBNjWON/loLtVfhbQcV4j4jDl
uxLVQCgMQezKY+MakwuVSnVji2hCIdl8cAUh1fuUcXMQE1NMCfq0e3Zvq750VcHo
kxTC31FfGMQ7zIeHIdoG1hWJuurXTLLVDHDoybcHI1PYxw34cSvHgSHP8ENaslQZ
+yhubunVH6IJC/qaItw9VL9I00qrYt0RsvrTrLl2dY1EGp2Ps9zBQ4RNCF6TVgSj
uTEAiW7WiMu2KRp6vVECzroH/jC+acZWk3yFYj9Pu+BIhNVxlN3vgJurSWIY9Lhj
Ff+HbPf5P8GXJl6NSMbP
=tZM/
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
