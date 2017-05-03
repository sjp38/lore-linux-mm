Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DBFD66B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 14:24:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p33so44301326qte.6
        for <linux-mm@kvack.org>; Wed, 03 May 2017 11:24:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a19si2490182qkj.131.2017.05.03.11.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 11:24:52 -0700 (PDT)
Message-ID: <1493835888.20270.4.camel@redhat.com>
Subject: Re: [PATCH][RFC] mm: make kswapd try harder to keep active pages in
 cache
From: Rik van Riel <riel@redhat.com>
Date: Wed, 03 May 2017 14:24:48 -0400
In-Reply-To: <1493760444-18250-1-git-send-email-jbacik@fb.com>
References: <1493760444-18250-1-git-send-email-jbacik@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-UaqWO6QQngbGppMQGaEX"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>, linux-mm@kvack.org, hannes@cmpxchg.org, kernel-team@fb.com


--=-UaqWO6QQngbGppMQGaEX
Content-Type: multipart/alternative; boundary="=-n41fBdCEJcSMcXkW9Z5G"


--=-n41fBdCEJcSMcXkW9Z5G
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-05-02 at 17:27 -0400, Josef Bacik wrote:

> +	/*
> +	=C2=A0* If we don't have a lot of inactive or slab pages then
> there's no
> +	=C2=A0* point in trying to free them exclusively, do the normal
> scan stuff.
> +	=C2=A0*/
> +	if (nr_inactive < total_high_wmark && nr_slab <
> total_high_wmark)
> +		sc->inactive_only =3D 0;

This part looks good. Below this point, there is obviously no
point in skipping the active list.

> +	if (!global_reclaim(sc))
> +		sc->inactive_only =3D 0;

Why the different behaviour with and without cgroups?

Have you tested both of these?

> +	/*
> +	=C2=A0* We still want to slightly prefer slab over inactive, so
> if inactive
> +	=C2=A0* is large enough just skip slab shrinking for now.=C2=A0=C2=A0If=
 we
> aren't able
> +	=C2=A0* to reclaim enough exclusively from the inactive lists
> then we'll
> +	=C2=A0* reset this on the first loop and dip into slab.
> +	=C2=A0*/
> +	if (nr_inactive > total_high_wmark && nr_inactive > nr_slab)
> +		skip_slab =3D true;

I worry that this may be a little too aggressive,
and result in the slab cache growing much larger
than it should be on some systems.

I wonder if it may make more sense to have the
aggressiveness of slab scanning depend on the
ratio of inactive to reclaimable slab pages, rather
than having a hard cut-off like this?
=C2=A0
--=C2=A0
All rights reversed
--=-n41fBdCEJcSMcXkW9Z5G
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

<html><head></head><body><div>On Tue, 2017-05-02 at 17:27 -0400, Josef Baci=
k wrote:</div><div><br></div><blockquote type=3D"cite"><div>+	/*</div><div>=
+	&nbsp;* If we don't have a lot of inactive or slab pages then there's no<=
/div><div>+	&nbsp;* point in trying to free them exclusively, do the normal=
 scan stuff.</div><div>+	&nbsp;*/</div><div>+	if (nr_inactive &lt; total_hi=
gh_wmark &amp;&amp; nr_slab &lt; total_high_wmark)</div><div>+		sc-&gt;inac=
tive_only =3D 0;</div></blockquote><div><br></div><div>This part looks good=
. Below this point, there is obviously no</div><div>point in skipping the a=
ctive list.</div><div><br></div><blockquote type=3D"cite"><div>+	if (!globa=
l_reclaim(sc))</div><div>+		sc-&gt;inactive_only =3D 0;</div></blockquote><=
div><br></div><div>Why the different behaviour with and without cgroups?</d=
iv><div><br></div><div>Have you tested both of these?</div><div><br></div><=
blockquote type=3D"cite"><div>+	/*</div><div>+	&nbsp;* We still want to sli=
ghtly prefer slab over inactive, so if inactive</div><div>+	&nbsp;* is larg=
e enough just skip slab shrinking for now.&nbsp;&nbsp;If we aren't able</di=
v><div>+	&nbsp;* to reclaim enough exclusively from the inactive lists then=
 we'll</div><div>+	&nbsp;* reset this on the first loop and dip into slab.<=
/div><div>+	&nbsp;*/</div><div>+	if (nr_inactive &gt; total_high_wmark &amp=
;&amp; nr_inactive &gt; nr_slab)</div><div>+		skip_slab =3D true;</div></bl=
ockquote><div><br></div><div>I worry that this may be a little too aggressi=
ve,</div><div>and result in the slab cache growing much larger</div><div>th=
an it should be on some systems.</div><div><br></div><div>I wonder if it ma=
y make more sense to have the</div><div>aggressiveness of slab scanning dep=
end on the</div><div>ratio of inactive to reclaimable slab pages, rather</d=
iv><div>than having a hard cut-off like this?</div><div>&nbsp;</div><div><s=
pan><pre><pre>-- <br></pre>All rights reversed</pre></span></div></body></h=
tml>
--=-n41fBdCEJcSMcXkW9Z5G--

--=-UaqWO6QQngbGppMQGaEX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZCiBwAAoJEM553pKExN6DEiAH/1Qd1o7869ohqf/zXYBSyepH
NfyzZKrD2V202HWOvSvoyVqFViXTKEpoy9ArnNqjZ59OK8C2IvQAvDYvCKenbDs6
T5PVV3zacgFuy57l2DrQ2kIZPrfru6/IT6p5Uxj64Irz0XY9Wuiz+u3fZO+aPnEr
05IeCalIaYu9iqtytL8cBbK8mYjTWUPETivFelbhT7sHt5s42HfHWnXB+yoRlBbg
5scTyyvK4HPy1ZVLNLBjhFoqTU4dQeQgT/Znzz8KsCF93ivHbCT0m1o+Z5kB7bOz
eu6Lymm132tSNej9AaLuhGtapklcQKRyfSYhux47vGhfDQNjIMNgx4hMYe3/gCQ=
=FwvC
-----END PGP SIGNATURE-----

--=-UaqWO6QQngbGppMQGaEX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
