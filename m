Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id CA9D26B005A
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 10:27:10 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id fg15so328789wgb.9
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 07:27:09 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] Fix wrong EOF compare
In-Reply-To: <1357797904-11194-1-git-send-email-minchan@kernel.org>
References: <1357797904-11194-1-git-send-email-minchan@kernel.org>
Date: Thu, 10 Jan 2013 16:26:58 +0100
Message-ID: <xa1ta9shm531.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 10 2013, Minchan Kim <minchan@kernel.org> wrote:
> getc returns "int" so EOF could be -1 but storing getc's return
> value to char directly makes the vaule to 255 so below condition
> is always false.

Technically, this is implementation defined and I believe on many
systems char is signed thus the loop will end on EOF or byte 255.

Either way, my point is the patch is correct, but the comment is not. ;)

Of course, even better if the function just used fgets(), ie. something
like:

int read_block(char *buf, int buf_size, FILE *fin)
{
	char *curr =3D buf, *const buf_end =3D buf + buf_size;

	while (buf_end - curr > 1 && fgets(curr, buf_end - curr, fin)) {
		if (*curr =3D=3D '\n') /* empty line */
			return curr - buf;
		curr +=3D strlen(curr);
	}

	return -1; /* EOF or no space left in buf. */
}

which is much shorter and does not have buffer overflow issues.

> It happens in my ARM system so loop is not ended, then segfaulted.
> This patch fixes it.
>
>                 *curr =3D getc(fin); // *curr =3D 255
>                 if (*curr =3D=3D EOF) return -1; // if ( 255 =3D=3D -1)
>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Andy Whitcroft <apw@shadowen.org>
> Cc: Alexander Nyberg <alexn@dsv.su.se>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  Documentation/page_owner.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/page_owner.c b/Documentation/page_owner.c
> index f0156e1..b777fb6 100644
> --- a/Documentation/page_owner.c
> +++ b/Documentation/page_owner.c
> @@ -32,12 +32,14 @@ int read_block(char *buf, FILE *fin)
>  {
>  	int ret =3D 0;
>  	int hit =3D 0;
> +	int vaule;
>  	char *curr =3D buf;
>=20=20
>  	for (;;) {
> -		*curr =3D getc(fin);
> -		if (*curr =3D=3D EOF) return -1;
> +		value =3D getc(fin);
> +		if (value =3D=3D EOF) return -1;
>=20=20
> +		*curr =3D value;
>  		ret++;
>  		if (*curr =3D=3D '\n' && hit =3D=3D 1)
>  			return ret - 1;

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

iQIcBAEBAgAGBQJQ7t3CAAoJECBgQBJQdR/0wt8QAILGSILht+e942SFJr/1IZZz
sbaqiRznalDUm1Hj/00uiOP67LFs2t7XXrnlVk0G2P1oCGzxDNFdDonayYoNxwyU
rwDBtmkEB79/794fSZATN87Ufi3Ye3Jl92QmO12EoYIrXTz+oqk1ESDfMs/xdvlk
Jp0UspTVBbGbfGb5S8coDHxqXcT6DZQyYLxpbAvVvYQDhVtVPaKdUiDvNrdkjmnA
++fyVL4+mUSZUzpAVEOY1aaiM5O8gqYQR0l7aZzahEPrfNptSF+BPLIzp4py3u+l
FSdxBHMt8ICq7Ka5ibQjvV9Vx30bf89pBmC91Om3ESS0E7S83EX5F+UIs1q7BT7k
4R0TcH3kNnaZ8mAp+1/qH0rfXzfUxpWJoINLi/xa4VcxT1eucYSmQ6534NiWx1aY
sYTvO1xiY5HXVBHef4vdn3Ru/HFxfFTjvs+mVR382/p+PkAi/Ctvd7WDCn220ZBQ
6rW7/TRJbKiafJgvZH/PmiDdXe/l/VIUvsStFUntVNos1+/QO/Uze0JzMQOzYsyt
WMda1cMNSHn5zEznfsBcaIlKa8/jKyl1QRiMg4OYVnfClWMoifDuqlCMm76TY4H3
ftGRdauqJH+joG1UDRbG4xiZ1CukqEc1sNkTKVsE3f3jM2+6grxcwfjukHBjYmvU
5LmNmlN+NzhSYV/zS6sd
=5XLl
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
