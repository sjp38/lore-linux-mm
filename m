Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id B1ACD6B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 03:29:29 -0400 (EDT)
Message-ID: <51948885.5040408@cn.fujitsu.com>
Date: Thu, 16 May 2013 15:19:33 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 7/8] vmcore: calculate vmcore file size from buffer
 size and total size of vmcore objects
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <20130515090620.28109.68803.stgit@localhost6.localdomain6>
In-Reply-To: <20130515090620.28109.68803.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

=E4=BA=8E 2013=E5=B9=B405=E6=9C=8815=E6=97=A5 17:06, HATAYAMA Daisuke =E5=
=86=99=E9=81=93:
> The previous patches newly added holes before each chunk of memory and
> the holes need to be count in vmcore file size. There are two ways to
> count file size in such a way:
>=20
> 1) supporse m as a poitner to the last vmcore object in vmcore=5Flist.
> , then file size is (m->offset + m->size), or
>=20
> 2) calculate sum of size of buffers for ELF header, program headers,
> ELF note segments and objects in vmcore=5Flist.
>=20
> Although 1) is more direct and simpler than 2), 2) seems better in
> that it reflects internal object structure of /proc/vmcore. Thus, this
> patch changes get=5Fvmcore=5Fsize=5Felf{64, 32} so that it calculates size
> in the way of 2).
>=20
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
> Acked-by: Vivek Goyal <vgoyal@redhat.com>
> ---

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

>=20
>  fs/proc/vmcore.c |   40 ++++++++++++++++++----------------------
>  1 files changed, 18 insertions(+), 22 deletions(-)
>=20
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 4e121fda..7f2041c 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -210,36 +210,28 @@ static struct vmcore* =5F=5Finit get=5Fnew=5Felemen=
t(void)
>  	return kzalloc(sizeof(struct vmcore), GFP=5FKERNEL);
>  }
> =20
> -static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf64(char *elfptr, size=5Ft=
 elfsz)
> +static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf64(size=5Ft elfsz, size=
=5Ft elfnotesegsz,
> +					struct list=5Fhead *vc=5Flist)
>  {
> -	int i;
>  	u64 size;
> -	Elf64=5FEhdr *ehdr=5Fptr;
> -	Elf64=5FPhdr *phdr=5Fptr;
> +	struct vmcore *m;
> =20
> -	ehdr=5Fptr =3D (Elf64=5FEhdr *)elfptr;
> -	phdr=5Fptr =3D (Elf64=5FPhdr*)(elfptr + sizeof(Elf64=5FEhdr));
> -	size =3D elfsz;
> -	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++) {
> -		size +=3D phdr=5Fptr->p=5Fmemsz;
> -		phdr=5Fptr++;
> +	size =3D elfsz + elfnotesegsz;
> +	list=5Ffor=5Feach=5Fentry(m, vc=5Flist, list) {
> +		size +=3D m->size;
>  	}
>  	return size;
>  }
> =20
> -static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf32(char *elfptr, size=5Ft=
 elfsz)
> +static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf32(size=5Ft elfsz, size=
=5Ft elfnotesegsz,
> +					struct list=5Fhead *vc=5Flist)
>  {
> -	int i;
>  	u64 size;
> -	Elf32=5FEhdr *ehdr=5Fptr;
> -	Elf32=5FPhdr *phdr=5Fptr;
> +	struct vmcore *m;
> =20
> -	ehdr=5Fptr =3D (Elf32=5FEhdr *)elfptr;
> -	phdr=5Fptr =3D (Elf32=5FPhdr*)(elfptr + sizeof(Elf32=5FEhdr));
> -	size =3D elfsz;
> -	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++) {
> -		size +=3D phdr=5Fptr->p=5Fmemsz;
> -		phdr=5Fptr++;
> +	size =3D elfsz + elfnotesegsz;
> +	list=5Ffor=5Feach=5Fentry(m, vc=5Flist, list) {
> +		size +=3D m->size;
>  	}
>  	return size;
>  }
> @@ -795,14 +787,18 @@ static int =5F=5Finit parse=5Fcrash=5Felf=5Fheaders=
(void)
>  			return rc;
> =20
>  		/* Determine vmcore size. */
> -		vmcore=5Fsize =3D get=5Fvmcore=5Fsize=5Felf64(elfcorebuf, elfcorebuf=
=5Fsz);
> +		vmcore=5Fsize =3D get=5Fvmcore=5Fsize=5Felf64(elfcorebuf=5Fsz,
> +						    elfnotes=5Fsz,
> +						    &vmcore=5Flist);
>  	} else if (e=5Fident[EI=5FCLASS] =3D=3D ELFCLASS32) {
>  		rc =3D parse=5Fcrash=5Felf32=5Fheaders();
>  		if (rc)
>  			return rc;
> =20
>  		/* Determine vmcore size. */
> -		vmcore=5Fsize =3D get=5Fvmcore=5Fsize=5Felf32(elfcorebuf, elfcorebuf=
=5Fsz);
> +		vmcore=5Fsize =3D get=5Fvmcore=5Fsize=5Felf32(elfcorebuf=5Fsz,
> +						    elfnotes=5Fsz,
> +						    &vmcore=5Flist);
>  	} else {
>  		pr=5Fwarn("Warning: Core image elf header is not sane\n");
>  		return -EINVAL;
>=20
>=20

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
