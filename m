Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id DFECF6B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 05:35:26 -0400 (EDT)
Message-ID: <5193564F.9090408@cn.fujitsu.com>
Date: Wed, 15 May 2013 17:33:03 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 1/8] vmcore: clean up read_vmcore()
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <20130515090545.28109.86085.stgit@localhost6.localdomain6>
In-Reply-To: <20130515090545.28109.86085.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

=E4=BA=8E 2013=E5=B9=B405=E6=9C=8815=E6=97=A5 17:05, HATAYAMA Daisuke =E5=
=86=99=E9=81=93:
> Rewrite part of read=5Fvmcore() that reads objects in vmcore=5Flist in the
> same way as part reading ELF headers, by which some duplicated and
> redundant codes are removed.
>=20
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
> Acked-by: Vivek Goyal <vgoyal@redhat.com>

This cleanup really makes the code more clear.

Just one minor nitpick below.

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>=20
>  fs/proc/vmcore.c |   68 ++++++++++++++++--------------------------------=
------
>  1 files changed, 20 insertions(+), 48 deletions(-)
>=20
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 17f7e08..ab0c92e 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -118,27 +118,6 @@ static ssize=5Ft read=5Ffrom=5Foldmem(char *buf, siz=
e=5Ft count,
>  	return read;
>  }
> =20
> -/* Maps vmcore file offset to respective physical address in memroy. */
> -static u64 map=5Foffset=5Fto=5Fpaddr(loff=5Ft offset, struct list=5Fhead=
 *vc=5Flist,
> -					struct vmcore **m=5Fptr)
> -{
> -	struct vmcore *m;
> -	u64 paddr;
> -
> -	list=5Ffor=5Feach=5Fentry(m, vc=5Flist, list) {
> -		u64 start, end;
> -		start =3D m->offset;
> -		end =3D m->offset + m->size - 1;
> -		if (offset >=3D start && offset <=3D end) {
> -			paddr =3D m->paddr + offset - start;
> -			*m=5Fptr =3D m;
> -			return paddr;
> -		}
> -	}
> -	*m=5Fptr =3D NULL;
> -	return 0;
> -}
> -
>  /* Read from the ELF header and then the crash dump. On error, negative =
value is
>   * returned otherwise number of bytes read are returned.
>   */
> @@ -147,8 +126,8 @@ static ssize=5Ft read=5Fvmcore(struct file *file, cha=
r =5F=5Fuser *buffer,
>  {
>  	ssize=5Ft acc =3D 0, tmp;
>  	size=5Ft tsz;
> -	u64 start, nr=5Fbytes;
> -	struct vmcore *curr=5Fm =3D NULL;
> +	u64 start;
> +	struct vmcore *m =3D NULL;
> =20
>  	if (buflen =3D=3D 0 || *fpos >=3D vmcore=5Fsize)
>  		return 0;
> @@ -174,33 +153,26 @@ static ssize=5Ft read=5Fvmcore(struct file *file, c=
har =5F=5Fuser *buffer,
>  			return acc;
>  	}
> =20
> -	start =3D map=5Foffset=5Fto=5Fpaddr(*fpos, &vmcore=5Flist, &curr=5Fm);
> -	if (!curr=5Fm)
> -        	return -EINVAL;
> -
> -	while (buflen) {
> -		tsz =3D min=5Ft(size=5Ft, buflen, PAGE=5FSIZE - (start & ~PAGE=5FMASK)=
);
> -
> -		/* Calculate left bytes in current memory segment. */
> -		nr=5Fbytes =3D (curr=5Fm->size - (start - curr=5Fm->paddr));
> -		if (tsz > nr=5Fbytes)
> -			tsz =3D nr=5Fbytes;
> -
> -		tmp =3D read=5Ffrom=5Foldmem(buffer, tsz, &start, 1);
> -		if (tmp < 0)
> -			return tmp;
> -		buflen -=3D tsz;
> -		*fpos +=3D tsz;
> -		buffer +=3D tsz;
> -		acc +=3D tsz;
> -		if (start >=3D (curr=5Fm->paddr + curr=5Fm->size)) {
> -			if (curr=5Fm->list.next =3D=3D &vmcore=5Flist)
> -				return acc;	/*EOF*/
> -			curr=5Fm =3D list=5Fentry(curr=5Fm->list.next,
> -						struct vmcore, list);
> -			start =3D curr=5Fm->paddr;
> +	list=5Ffor=5Feach=5Fentry(m, &vmcore=5Flist, list) {
> +		if (*fpos < m->offset + m->size) {
> +			tsz =3D m->offset + m->size - *fpos;
> +			if (buflen < tsz)
> +				tsz =3D buflen;

if (tsz > buflen)
        tsz =3D buflen;

seems better.

Or you can use a min=5Ft here:

tsz =3D min=5Ft(size=5Ft, m->offset + m->size - *fpos, buflen);


> +			start =3D m->paddr + *fpos - m->offset;
> +			tmp =3D read=5Ffrom=5Foldmem(buffer, tsz, &start, 1);
> +			if (tmp < 0)
> +				return tmp;
> +			buflen -=3D tsz;
> +			*fpos +=3D tsz;
> +			buffer +=3D tsz;
> +			acc +=3D tsz;
> +
> +			/* leave now if filled buffer already */
> +			if (buflen =3D=3D 0)
> +				return acc;
>  		}
>  	}
> +
>  	return acc;
>  }
> =20
>=20
>=20

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
