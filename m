Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA7218E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:53:08 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q63so10853172pfi.19
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 09:53:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h76sor4656318pfa.61.2019.01.11.09.53.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 09:53:07 -0800 (PST)
Date: Fri, 11 Jan 2019 07:53:03 -1000
From: Joey Pabalinas <joeypabalinas@gmail.com>
Subject: Re: [PATCH] rbtree: fix the red root
Message-ID: <20190111175303.72a43mdulvfd6wf3@gmail.com>
References: <YrcPMrGmYbPe_xgNEV6Q0jqc5XuPYmL2AFSyeNmg1gW531bgZnBGfEUK5_ktqDBaNW37b-NP2VXvlliM7_PsBRhSfB649MaW1Ne7zT9lHc=@protonmail.ch>
 <20190111165145.23628-1-cai@lca.pw>
 <20190111173132.GH6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="hlwwm3l6upzhm7g4"
Content-Disposition: inline
In-Reply-To: <20190111173132.GH6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joey Pabalinas <joeypabalinas@gmail.com>


--hlwwm3l6upzhm7g4
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 11, 2019 at 09:31:32AM -0800, Matthew Wilcox wrote:
> On Fri, Jan 11, 2019 at 11:51:45AM -0500, Qian Cai wrote:
> > Reported-by: Esme <esploit@protonmail.ch>
> > Signed-off-by: Qian Cai <cai@lca.pw>
>=20
> What change introduced this bug?  We need a Fixes: line so the stable
> people know how far to backport this fix.
>=20

Breaking commit _might_ be 5bc9188aa207dafd47 (rbtree: low level optimizati=
ons in rb_insert_color())

I'm thinking that the when `parent =3D rb_parent(node);` was
moved from the beginning of the loop to the function initialization
only, somehow parent not being reassigned every loop resulted in
the red root node case.

I'm sort of just guessing here admittedly and I'll do some testing after
breakfast, but nothing else in the `git log` or `git blame` changes really
jumps out at me apart from this one commit.

 void rb_insert_color(struct rb_node *node, struct rb_root *root)
 {
-       struct rb_node *parent, *gparent;
+       struct rb_node *parent =3D rb_red_parent(node), *gparent, *tmp;

        while (true) {
                /*
                 * Loop invariant: node is red
                 *
                 * If there is a black parent, we are done.
                 * Otherwise, take some corrective action as we don't
                 * want a red root or two consecutive red nodes.
                 */
-               parent =3D rb_parent(node);
                if (!parent) {
-                       rb_set_black(node);
+                       rb_set_parent_color(node, NULL, RB_BLACK);
                        break;
                } else if (rb_is_black(parent))
                        break;

-               gparent =3D rb_parent(parent);
+               gparent =3D rb_red_parent(parent);

--=20
Cheers,
Joey Pabalinas

--hlwwm3l6upzhm7g4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEENpTlWU2hUK/KMvHp2rGdfm9DtVIFAlw41/8ACgkQ2rGdfm9D
tVKT6RAApztW+XKuh1xfqQ6x5SICKuk9Kc+wQD6wp+nmhij5CHWhRH0OQV8/QcnO
ieTU3tSCr62nGAfhtqEVwKyubAMuJlYdb4WqVcXHYIkymRijiqhcCjGq/mbj/Nza
rua9lpKfKcb/o+gg7vojZV6sVB3GzE0mXFAmjdaRXCe+1+m8ZyDpnxTVH2PjsR7p
bn/d3V0j7gTUcZ2qclX0OloJC++dhG8+1Y4dhl2R0QOFQ9TKj7ChQbA5IKBFzK1Q
dVVHcFayJMhzPdKuh7PsqjQJmlFRjoL+1Fy4ocF8Co7VYP7mA//hBREmNj6qpZ8X
oCc0I/oZ00KRZBhRNYG2S9d+MsJV9csoL6F0QIq8D2ZBa+3u6qWp5rjemI8T6BnS
Lh2/+eVoRaVz7lVqsEpJiFghmdzIAv+bqbqoLjhIRuQ5pvNjLfwUrgDqvKYyxQ86
GvTHbaszdur0cdzG7OPqPCyYdsUPoBrV2nirZMDo1seaHFxcQ48mf4+Sd6a1XocT
vaEXGFqwY6lE9R21u4RSU0VMfUj6fX+Cp9pm7VH2DZrXtdV7e3/Q/TwbXUy0T9aD
tzL7CbA27IvgHCyEYeRcUni4yoY4W9t+GfMFAc2MzSW38CjkxmQIQwDTYsJCeXBV
mC79qjd6r0tqG4pZpu0zuwQ78OW+2XYnWs4T3Hv4bQKIZw+OGQU=
=F32/
-----END PGP SIGNATURE-----

--hlwwm3l6upzhm7g4--
