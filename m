Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id A52066B002C
	for <linux-mm@kvack.org>; Sun, 26 Feb 2012 00:52:36 -0500 (EST)
Received: by vbip1 with SMTP id p1so3304200vbi.14
        for <linux-mm@kvack.org>; Sat, 25 Feb 2012 21:52:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120225022710.GA29455@dcvr.yhbt.net>
References: <20120225022710.GA29455@dcvr.yhbt.net>
Date: Sun, 26 Feb 2012 13:52:35 +0800
Message-ID: <CAJd=RBDHB8yM=LGkzhOWZO6ftYFyZ42SQKySc0hUzNEQzrmVTw@mail.gmail.com>
Subject: Re: [PATCH] fadvise: avoid EINVAL if user input is valid
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Feb 25, 2012 at 10:27 AM, Eric Wong <normalperson@yhbt.net> wrote:
> The kernel is not required to act on fadvise, so fail silently
> and ignore advice as long as it has a valid descriptor and
> parameters.
>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Eric Wong <normalperson@yhbt.net>
> ---
>
> =C2=A0Of course I wouldn't knowingly call posix_fadvise() on a file in
> =C2=A0tmpfs, but a userspace app often doesn't know (nor should it
> =C2=A0care) what type of filesystem it's on.
>
> =C2=A0I encountered EINVAL while running the Ruby 1.9.3 test suite on a
> =C2=A0stock Debian wheezy installation. =C2=A0Wheezy uses tmpfs for "/tmp=
" by
> =C2=A0default and the test suite creates a temporary file to test the
> =C2=A0Ruby wrapper for posix_fadvise() on.
>
> =C2=A0mm/fadvise.c | =C2=A0 19 +++++++------------
> =C2=A01 file changed, 7 insertions(+), 12 deletions(-)
>
> diff --git a/mm/fadvise.c b/mm/fadvise.c
> index 469491e0..f9e48dd 100644
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -43,13 +43,13 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, l=
off_t len, int advice)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 mapping =3D file->f_mapping;
> - =C2=A0 =C2=A0 =C2=A0 if (!mapping || len < 0) {
> + =C2=A0 =C2=A0 =C2=A0 if (len < 0) {

Current code makes sure mapping is valid after the above check,

> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D -EINVAL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 if (mapping->a_ops->get_xip_mem) {
> + =C2=A0 =C2=A0 =C2=A0 mapping =3D file->f_mapping;
> + =C2=A0 =C2=A0 =C2=A0 if (!mapping || mapping->a_ops->get_xip_mem) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (advice) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case POSIX_FADV_NO=
RMAL:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case POSIX_FADV_RA=
NDOM:

but backing devices info is no longer evaluated with that
guarantee in your change.

-hd

75:	bdi =3D mapping->backing_dev_info;

> @@ -93,10 +93,9 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, lo=
ff_t len, int advice)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&file-=
>f_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case POSIX_FADV_WILLNEED:
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mapping->a_ops->r=
eadpage) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret =3D -EINVAL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* ignore the advice i=
f readahead isn't possible (tmpfs) */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mapping->a_ops->r=
eadpage)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* First and last =
PARTIAL page! */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0start_index =3D of=
fset >> PAGE_CACHE_SHIFT;
> @@ -106,12 +105,8 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, =
loff_t len, int advice)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nrpages =3D end_in=
dex - start_index + 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!nrpages)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0nrpages =3D ~0UL;
> -
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D force_page_cac=
he_readahead(mapping, file,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 start_index,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nrpages);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret > 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret =3D 0;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 force_page_cache_reada=
head(mapping, file, start_index, nrpages);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case POSIX_FADV_NOREUSE:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> --
> Eric Wong
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
