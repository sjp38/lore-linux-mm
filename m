Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id E61A56B0072
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 11:01:47 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t49so942294wey.0
        for <linux-mm@kvack.org>; Fri, 11 Jan 2013 08:01:46 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 2/2] Enhance read_block of page_owner.c
In-Reply-To: <1357871401-7075-2-git-send-email-minchan@kernel.org>
References: <1357871401-7075-1-git-send-email-minchan@kernel.org> <1357871401-7075-2-git-send-email-minchan@kernel.org>
Date: Fri, 11 Jan 2013 17:01:29 +0100
Message-ID: <xa1t8v7zbteu.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>, Randy Dunlap <rdunlap@infradead.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

It occurred to me -- and I know it will sound like a heresy -- that
maybe providing an overly long example in C is not the best option here.
Why not page_owner.py with the following content instead (not tested):


#!/usr/bin/python
import collections
import sys

counts =3D collections.defaultdict(int)

txt =3D ''
for line in sys.stdin:
    if line =3D=3D '\n':
        counts[txt] +=3D 1
        txt =3D ''
    else:
        txt +=3D line
counts[txt] +=3D 1

for txt, num in sorted(counts.items(), txt=3Dlambda x: x[1]):
    if len(txt) > 1:
        print '%d times:\n%s' % num, txt


And it's so =E2=80=9Clong=E2=80=9D only because I chose not to read the who=
le file at
once as in:

=20=20=20=20
counts =3D collections.defaultdict(int)
for txt in sys.stdin.read().split('\n\n'):
    counts[txt] +=3D 1


On Fri, Jan 11 2013, Minchan Kim wrote:
> The read_block reads char one by one until meeting two newline.
> It's not good for the performance and current code isn't good shape
> for readability.
>
> This patch enhances speed and clean up.
>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Andy Whitcroft <apw@shadowen.org>
> Cc: Alexander Nyberg <alexn@dsv.su.se>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  Documentation/page_owner.c |   34 +++++++++++++---------------------
>  1 file changed, 13 insertions(+), 21 deletions(-)
>
> diff --git a/Documentation/page_owner.c b/Documentation/page_owner.c
> index 43dde96..96bf481 100644
> --- a/Documentation/page_owner.c
> +++ b/Documentation/page_owner.c
> @@ -28,26 +28,17 @@ static int max_size;
>=20=20
>  struct block_list *block_head;
>=20=20
> -int read_block(char *buf, FILE *fin)
> +int read_block(char *buf, int buf_size, FILE *fin)
>  {
> -	int ret =3D 0;
> -	int hit =3D 0;
> -	int val;
> -	char *curr =3D buf;
> -
> -	for (;;) {
> -		val =3D getc(fin);
> -		if (val =3D=3D EOF) return -1;
> -		*curr =3D val;
> -		ret++;
> -		if (*curr =3D=3D '\n' && hit =3D=3D 1)
> -			return ret - 1;
> -		else if (*curr =3D=3D '\n')
> -			hit =3D 1;
> -		else
> -			hit =3D 0;
> -		curr++;
> +	char *curr =3D buf, *const buf_end =3D buf + buf_size;
> +
> +	while (buf_end - curr > 1 && fgets(curr, buf_end - curr, fin)) {
> +		if (*curr =3D=3D '\n') /* empty line */
> +			return curr - buf;
> +		curr +=3D strlen(curr);
>  	}
> +
> +	return -1; /* EOF or no space left in buf. */
>  }
>=20=20
>  static int compare_txt(struct block_list *l1, struct block_list *l2)
> @@ -84,10 +75,12 @@ static void add_list(char *buf, int len)
>  	}
>  }
>=20=20
> +#define BUF_SIZE	1024
> +
>  int main(int argc, char **argv)
>  {
>  	FILE *fin, *fout;
> -	char buf[1024];
> +	char buf[BUF_SIZE];
>  	int ret, i, count;
>  	struct block_list *list2;
>  	struct stat st;
> @@ -106,11 +99,10 @@ int main(int argc, char **argv)
>  	list =3D malloc(max_size * sizeof(*list));
>=20=20
>  	for(;;) {
> -		ret =3D read_block(buf, fin);
> +		ret =3D read_block(buf, BUF_SIZE, fin);
>  		if (ret < 0)
>  			break;
>=20=20
> -		buf[ret] =3D '\0';
>  		add_list(buf, ret);
>  	}
>=20=20
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
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQ8DdZAAoJECBgQBJQdR/0o9IP/j6sGEEG+/1jhxU7aGArPxUz
l02oRknLXP3VoNDYWLsgWaw9wqlPq0ggykFdGjVtX0X5nrxCFTXC2OsTe1CqbzxC
ufGs1uFfdDdOjCn0Wm8u628hvzhR0ypLnJL2qA9qsZcFJkXh7MA9KZrTxmDNHXez
6HguygPPUHith85Dp0vYMvJ+9isyzAnN6VTSMs+B7ylwJ5jgyekdNM/Mq8ILa/GI
PhTUz00wvlrCpTcvO0k4sXVGhP8WiSiqwBLVKmD8LJ8V/af13s4z/nZXMZ68N7Rv
L0YvUpcXTS2X2fNQnvN6x+TLQpADepwZcexKwKSg5BePtyt1H368F1C8EXdEWTY5
8ywQRTs2b/YgCZe++GQ7vip00F1FTFDBnRKxB5IIl2V9fwA6pGUfivHHBUzHkQOD
F5hFKP/8jRD4QoMcplfSHGJWY61K8TGE6/D5qJFQFoa2IE5KiFlp7cBZwvalbWY9
Wanzb2Xn6ksfh/+xSGAEUkH0fYbtCIiEYDtVry4GDWL3O1yHUw1Uh5mWcREPcj2r
9BPiiWgf0HDtRTxfkn46/8d0wpKpFVle9LZ93dGYx1woaJR/Duvk2W8mkz6QMJrQ
Ci/D8ifnGZomex5maaaTX8xvON48YIKYGt1ThuxJ/ZEIJrJsdtVIsp7UMxcOw/g0
W++zo9bZwXqSBMVsNp3j
=k3/t
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
