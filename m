Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29EA18E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:17:49 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id d18so10824336pfe.0
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 09:17:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 79sor4472441pfq.34.2019.01.11.09.17.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 09:17:47 -0800 (PST)
Date: Fri, 11 Jan 2019 07:17:43 -1000
From: Joey Pabalinas <joeypabalinas@gmail.com>
Subject: Re: [PATCH] rbtree: fix the red root
Message-ID: <20190111171743.qx44dlsdaowdt3no@gmail.com>
References: <YrcPMrGmYbPe_xgNEV6Q0jqc5XuPYmL2AFSyeNmg1gW531bgZnBGfEUK5_ktqDBaNW37b-NP2VXvlliM7_PsBRhSfB649MaW1Ne7zT9lHc=@protonmail.ch>
 <20190111165145.23628-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="yqofroxyylfvf7td"
Content-Disposition: inline
In-Reply-To: <20190111165145.23628-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joey Pabalinas <joeypabalinas@gmail.com>


--yqofroxyylfvf7td
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 11, 2019 at 11:51:45AM -0500, Qian Cai wrote:
> A GFP was reported,
>=20
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
>         kasan_die_handler.cold.22+0x11/0x31
>         notifier_call_chain+0x17b/0x390
>         atomic_notifier_call_chain+0xa7/0x1b0
>         notify_die+0x1be/0x2e0
>         do_general_protection+0x13e/0x330
>         general_protection+0x1e/0x30
>         rb_insert_color+0x189/0x1480
>         create_object+0x785/0xca0
>         kmemleak_alloc+0x2f/0x50
>         kmem_cache_alloc+0x1b9/0x3c0
>         getname_flags+0xdb/0x5d0
>         getname+0x1e/0x20
>         do_sys_open+0x3a1/0x7d0
>         __x64_sys_open+0x7e/0xc0
>         do_syscall_64+0x1b3/0x820
>         entry_SYSCALL_64_after_hwframe+0x49/0xbe
>=20
> It turned out,
>=20
> gparent =3D rb_red_parent(parent);
> tmp =3D gparent->rb_right; <-- GFP triggered here.
>=20
> Apparently, "gparent" is NULL which indicates "parent" is rbtree's root
> which is red. Otherwise, it will be treated properly a few lines above.

Good catch, acked. After thinking through the logic a bit your solution
seems like the simplest fix.

Now, I didn't do _extensive_ testing but a quick compile and bootup of
the patch with CONFIG_KASAN_INLINE enabled has yet to throw any GFPs,
so take that as you will.

Reviewed-by: Joey Pabalinas <joeypabalinas@gmail.com>
Tested-by: Joey Pabalinas <joeypabalinas@gmail.com>

> /*
>  * If there is a black parent, we are done.
>  * Otherwise, take some corrective action as,
>  * per 4), we don't want a red root or two
>  * consecutive red nodes.
>  */
> if(rb_is_black(parent))
> 	break;
>=20
> Hence, it violates the rule #1 and need a fix up.
>=20
> Reported-by: Esme <esploit@protonmail.ch>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  lib/rbtree.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>=20
> diff --git a/lib/rbtree.c b/lib/rbtree.c
> index d3ff682fd4b8..acc969ad8de9 100644
> --- a/lib/rbtree.c
> +++ b/lib/rbtree.c
> @@ -127,6 +127,13 @@ __rb_insert(struct rb_node *node, struct rb_root *ro=
ot,
>  			break;
> =20
>  		gparent =3D rb_red_parent(parent);
> +		if (unlikely(!gparent)) {
> +			/*
> +			 * The root is red so correct it.
> +			 */
> +			rb_set_parent_color(parent, NULL, RB_BLACK);
> +			break;
> +		}
> =20
>  		tmp =3D gparent->rb_right;
>  		if (parent !=3D tmp) {	/* parent =3D=3D gparent->rb_left */
> --=20
> 2.17.2 (Apple Git-113)
>=20

--=20
Cheers,
Joey Pabalinas

--yqofroxyylfvf7td
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEENpTlWU2hUK/KMvHp2rGdfm9DtVIFAlw4z7YACgkQ2rGdfm9D
tVLJsg//aTGUdBk9D/pGQFJUcdzB6+sD0sDmwqc6caJkhQZ7ID6W3OWeKbXkFewd
hHCG8V5nYgrXBdYZEEEvJeYQqYba2JNXXFr/TL6qYMCV+vVH+LTOTj2fX21QzEfj
cjpMLFuGSL8riCWPd6IQOD3Fp089AW/Fbe5vkKmqWtuLCKj8JGgd6FfIZ9Wu/cGS
JLfke1PAtphpvTcxZkE2CsYXBBmQYTT17kdleEXEaKi132HRCmR+wLWtKq42HKFy
GjQrv7e00EabrViZ5YpRcstcFBC1S4kgOv/jItsM7fgm/zuL4xIIPPFUtzwPBjdr
MwpbFmXIioQccvps32Ichu/0dTap6+gpLpgUWfVJweWW3G/N8Hl5EAk/pgig0/JE
UlJPTJ0wHNoBRbdADkvyX2DrKNlm9K4/0TbiZct0yFzyUXTY2XSygWLj9U/mMdeG
x7DwBOZcp3Ln+iqaSE5dPlcn0XGgeFJnbyLKe6TT1O49FnbDZLCqBsbHbRKp8s89
iJoOK2zpG/z5GYEyifIRJju9DGxYJ6ihKAuVy9UqwmNI/wMlW9mkGaaJULOVL/Ql
Y8xl5VCs4By94IfgAA05vlL/BwiCB2DSMq08+k3Xy6r7JxfTl+D5+rAY3g0v1b82
lKBHQDTcCJMzgJX8rpef2K8YSzKoKeT105aTgiJghyEH+WVFUOA=
=XjO3
-----END PGP SIGNATURE-----

--yqofroxyylfvf7td--
