Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 357486B0260
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:32:33 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id kq3so35551895wjc.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:32:33 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id 33si6494436wrm.266.2017.01.25.13.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 13:32:32 -0800 (PST)
Message-ID: <1485379919.2998.159.camel@decadent.org.uk>
Subject: Re: [PATCH 2/2] fs: Harden against open(..., O_CREAT, 02777) in a
 setgid directory
From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 25 Jan 2017 21:31:59 +0000
In-Reply-To: <826ec4aab64ec304944098d15209f8c1ae65bb29.1485377903.git.luto@kernel.org>
References: <cover.1485377903.git.luto@kernel.org>
	 <826ec4aab64ec304944098d15209f8c1ae65bb29.1485377903.git.luto@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-JwyhHvofVkiTz0Fz3eNL"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, security@kernel.org
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>


--=-JwyhHvofVkiTz0Fz3eNL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-01-25 at 13:06 -0800, Andy Lutomirski wrote:
> Currently, if you open("foo", O_WRONLY | O_CREAT | ..., 02777) in a
> directory that is setgid and owned by a different gid than current's
> fsgid, you end up with an SGID executable that is owned by the
> directory's GID.=C2=A0=C2=A0This is a Bad Thing (tm).=C2=A0=C2=A0Exploiti=
ng this is
> nontrivial because most ways of creating a new file create an empty
> file and empty executables aren't particularly interesting, but this
> is nevertheless quite dangerous.
>=20
> Harden against this type of attack by detecting this particular
> corner case (unprivileged program creates SGID executable inode in
> SGID directory owned by a different GID) and clearing the new
> inode's SGID bit.
>=20
> > Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
> =C2=A0fs/inode.c | 21 +++++++++++++++++++--
> =C2=A01 file changed, 19 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/inode.c b/fs/inode.c
> index f7029c40cfbd..d7e4b80470dd 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -2007,11 +2007,28 @@ void inode_init_owner(struct inode *inode, const =
struct inode *dir,
> =C2=A0{
> =C2=A0	inode->i_uid =3D current_fsuid();
> =C2=A0	if (dir && dir->i_mode & S_ISGID) {
> +		bool changing_gid =3D !gid_eq(inode->i_gid, dir->i_gid);
[...]

inode->i_gid hasn't been initialised yet.  This should compare with
current_fsgid(), shouldn't it?

Ben.

--=20
Ben Hutchings
It is easier to write an incorrect program than to understand a correct
one.


--=-JwyhHvofVkiTz0Fz3eNL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAliJGU8ACgkQ57/I7JWG
EQmC4RAApNScdegP2BE86vVROI7ZNOJKaxf0SFqYSiXmQFuJZR7X5bxCqswyQwUh
soNh7TNp0z2bXhxQJaqJqBsBbnVXF3nEgLSoKiw8nEK0TGVjclB3uU9oS9Os5ehb
i4WmvnEi4Y4BWFi7vbhAikEOf9dexr7ypN9cmaX2mGfr1aIbdAza3kq3sFF5vXqK
50o3wnNPH9mTw/rRte3sxoCr60TtbQ4KFutxvcA7v7G40lnoVyt3u0NIh9jQ1FHx
C8LB8e9zIsXu5D8IV+FIxPlckavqxxfCgYZqW+cJnDChRXvawM0fUGh2jEIIBVnn
YCdR3Pg+8bxH+6mTgcPy/jGf7MNNXuTFwEMLgIctxEnZIeeOHneRwBUb5UiByjn7
b6NchWMh8ZAiCz/FB9xV1kEU1UwyodOqPQ8c+JSrQEusHv0VrUNjTlVZWG92KO6d
ZFlrzp0D8u/Sp+qk4RTtD3M0HHNWmCzi3HZ+4ugaTKkN8FDw6hkYfFLQQdFvFI19
V1BJfoRUrCoq1AuInT4Gl2SiL7wJfU9sagvdXf6UAPQZ0FlyL0lm9cZ0TQoiCo/D
biOdR88rxksZXZprFY/Zs5D2+Ma7A5fc+vafzt9U6zOodg6polUaWRJYHTFykn0i
ElgdgSCHMhAUOZXC7lhnzcfmYnvy8oGxelNSWGCYuW93Jgmz/DI=
=4zSj
-----END PGP SIGNATURE-----

--=-JwyhHvofVkiTz0Fz3eNL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
