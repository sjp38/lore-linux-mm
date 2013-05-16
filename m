Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 647D16B0034
	for <linux-mm@kvack.org>; Thu, 16 May 2013 02:08:07 -0400 (EDT)
Message-ID: <5194758D.90502@cn.fujitsu.com>
Date: Thu, 16 May 2013 13:58:37 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 2/8] vmcore: allocate buffer for ELF headers on page-size
 alignment
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <20130515090551.28109.73350.stgit@localhost6.localdomain6>
In-Reply-To: <20130515090551.28109.73350.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

=E4=BA=8E 2013=E5=B9=B405=E6=9C=8815=E6=97=A5 17:05, HATAYAMA Daisuke =E5=
=86=99=E9=81=93:
> Allocate ELF headers on page-size boundary using =5F=5Fget=5Ffree=5Fpages=
()
> instead of kmalloc().
>=20
> Later patch will merge PT=5FNOTE entries into a single unique one and
> decrease the buffer size actually used. Keep original buffer size in
> variable elfcorebuf=5Fsz=5Forig to kfree the buffer later and actually
> used buffer size with rounded up to page-size boundary in variable
> elfcorebuf=5Fsz separately.
>=20
> The size of part of the ELF buffer exported from /proc/vmcore is
> elfcorebuf=5Fsz.
>=20
> The merged, removed PT=5FNOTE entries, i.e. the range [elfcorebuf=5Fsz,
> elfcorebuf=5Fsz=5Forig], is filled with 0.
>=20
> Use size of the ELF headers as an initial offset value in
> set=5Fvmcore=5Flist=5Foffsets=5Felf{64,32} and
> process=5Fptload=5Fprogram=5Fheaders=5Felf{64,32} in order to indicate th=
at
> the offset includes the holes towards the page boundary.
>=20
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
> ---

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

>=20
>  fs/proc/vmcore.c |   80 ++++++++++++++++++++++++++++++------------------=
------
>  1 files changed, 45 insertions(+), 35 deletions(-)
>=20
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index ab0c92e..48886e6 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -32,6 +32,7 @@ static LIST=5FHEAD(vmcore=5Flist);
>  /* Stores the pointer to the buffer containing kernel elf core headers. =
*/
>  static char *elfcorebuf;
>  static size=5Ft elfcorebuf=5Fsz;
> +static size=5Ft elfcorebuf=5Fsz=5Forig;
> =20
>  /* Total size of vmcore file. */
>  static u64 vmcore=5Fsize;
> @@ -186,7 +187,7 @@ static struct vmcore* =5F=5Finit get=5Fnew=5Felement(=
void)
>  	return kzalloc(sizeof(struct vmcore), GFP=5FKERNEL);
>  }
> =20
> -static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf64(char *elfptr)
> +static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf64(char *elfptr, size=5Ft=
 elfsz)
>  {
>  	int i;
>  	u64 size;
> @@ -195,7 +196,7 @@ static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf64(cha=
r *elfptr)
> =20
>  	ehdr=5Fptr =3D (Elf64=5FEhdr *)elfptr;
>  	phdr=5Fptr =3D (Elf64=5FPhdr*)(elfptr + sizeof(Elf64=5FEhdr));
> -	size =3D sizeof(Elf64=5FEhdr) + ((ehdr=5Fptr->e=5Fphnum) * sizeof(Elf64=
=5FPhdr));
> +	size =3D elfsz;
>  	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++) {
>  		size +=3D phdr=5Fptr->p=5Fmemsz;
>  		phdr=5Fptr++;
> @@ -203,7 +204,7 @@ static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf64(cha=
r *elfptr)
>  	return size;
>  }
> =20
> -static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf32(char *elfptr)
> +static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf32(char *elfptr, size=5Ft=
 elfsz)
>  {
>  	int i;
>  	u64 size;
> @@ -212,7 +213,7 @@ static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf32(cha=
r *elfptr)
> =20
>  	ehdr=5Fptr =3D (Elf32=5FEhdr *)elfptr;
>  	phdr=5Fptr =3D (Elf32=5FPhdr*)(elfptr + sizeof(Elf32=5FEhdr));
> -	size =3D sizeof(Elf32=5FEhdr) + ((ehdr=5Fptr->e=5Fphnum) * sizeof(Elf32=
=5FPhdr));
> +	size =3D elfsz;
>  	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++) {
>  		size +=3D phdr=5Fptr->p=5Fmemsz;
>  		phdr=5Fptr++;
> @@ -280,7 +281,7 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf64(=
char *elfptr, size=5Ft *elfsz,
>  	phdr.p=5Fflags   =3D 0;
>  	note=5Foff =3D sizeof(Elf64=5FEhdr) +
>  			(ehdr=5Fptr->e=5Fphnum - nr=5Fptnote +1) * sizeof(Elf64=5FPhdr);
> -	phdr.p=5Foffset  =3D note=5Foff;
> +	phdr.p=5Foffset  =3D roundup(note=5Foff, PAGE=5FSIZE);
>  	phdr.p=5Fvaddr   =3D phdr.p=5Fpaddr =3D 0;
>  	phdr.p=5Ffilesz  =3D phdr.p=5Fmemsz =3D phdr=5Fsz;
>  	phdr.p=5Falign   =3D 0;
> @@ -294,6 +295,8 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf64(=
char *elfptr, size=5Ft *elfsz,
>  	i =3D (nr=5Fptnote - 1) * sizeof(Elf64=5FPhdr);
>  	*elfsz =3D *elfsz - i;
>  	memmove(tmp, tmp+i, ((*elfsz)-sizeof(Elf64=5FEhdr)-sizeof(Elf64=5FPhdr)=
));
> +	memset(elfptr + *elfsz, 0, i);
> +	*elfsz =3D roundup(*elfsz, PAGE=5FSIZE);
> =20
>  	/* Modify e=5Fphnum to reflect merged headers. */
>  	ehdr=5Fptr->e=5Fphnum =3D ehdr=5Fptr->e=5Fphnum - nr=5Fptnote + 1;
> @@ -361,7 +364,7 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf32(=
char *elfptr, size=5Ft *elfsz,
>  	phdr.p=5Fflags   =3D 0;
>  	note=5Foff =3D sizeof(Elf32=5FEhdr) +
>  			(ehdr=5Fptr->e=5Fphnum - nr=5Fptnote +1) * sizeof(Elf32=5FPhdr);
> -	phdr.p=5Foffset  =3D note=5Foff;
> +	phdr.p=5Foffset  =3D roundup(note=5Foff, PAGE=5FSIZE);
>  	phdr.p=5Fvaddr   =3D phdr.p=5Fpaddr =3D 0;
>  	phdr.p=5Ffilesz  =3D phdr.p=5Fmemsz =3D phdr=5Fsz;
>  	phdr.p=5Falign   =3D 0;
> @@ -375,6 +378,8 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf32(=
char *elfptr, size=5Ft *elfsz,
>  	i =3D (nr=5Fptnote - 1) * sizeof(Elf32=5FPhdr);
>  	*elfsz =3D *elfsz - i;
>  	memmove(tmp, tmp+i, ((*elfsz)-sizeof(Elf32=5FEhdr)-sizeof(Elf32=5FPhdr)=
));
> +	memset(elfptr + *elfsz, 0, i);
> +	*elfsz =3D roundup(*elfsz, PAGE=5FSIZE);
> =20
>  	/* Modify e=5Fphnum to reflect merged headers. */
>  	ehdr=5Fptr->e=5Fphnum =3D ehdr=5Fptr->e=5Fphnum - nr=5Fptnote + 1;
> @@ -398,9 +403,7 @@ static int =5F=5Finit process=5Fptload=5Fprogram=5Fhe=
aders=5Felf64(char *elfptr,
>  	phdr=5Fptr =3D (Elf64=5FPhdr*)(elfptr + sizeof(Elf64=5FEhdr)); /* PT=5F=
NOTE hdr */
> =20
>  	/* First program header is PT=5FNOTE header. */
> -	vmcore=5Foff =3D sizeof(Elf64=5FEhdr) +
> -			(ehdr=5Fptr->e=5Fphnum) * sizeof(Elf64=5FPhdr) +
> -			phdr=5Fptr->p=5Fmemsz; /* Note sections */
> +	vmcore=5Foff =3D elfsz + roundup(phdr=5Fptr->p=5Fmemsz, PAGE=5FSIZE);
> =20
>  	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++, phdr=5Fptr++) {
>  		if (phdr=5Fptr->p=5Ftype !=3D PT=5FLOAD)
> @@ -435,9 +438,7 @@ static int =5F=5Finit process=5Fptload=5Fprogram=5Fhe=
aders=5Felf32(char *elfptr,
>  	phdr=5Fptr =3D (Elf32=5FPhdr*)(elfptr + sizeof(Elf32=5FEhdr)); /* PT=5F=
NOTE hdr */
> =20
>  	/* First program header is PT=5FNOTE header. */
> -	vmcore=5Foff =3D sizeof(Elf32=5FEhdr) +
> -			(ehdr=5Fptr->e=5Fphnum) * sizeof(Elf32=5FPhdr) +
> -			phdr=5Fptr->p=5Fmemsz; /* Note sections */
> +	vmcore=5Foff =3D elfsz + roundup(phdr=5Fptr->p=5Fmemsz, PAGE=5FSIZE);
> =20
>  	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++, phdr=5Fptr++) {
>  		if (phdr=5Fptr->p=5Ftype !=3D PT=5FLOAD)
> @@ -459,7 +460,7 @@ static int =5F=5Finit process=5Fptload=5Fprogram=5Fhe=
aders=5Felf32(char *elfptr,
>  }
> =20
>  /* Sets offset fields of vmcore elements. */
> -static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=5Felf64(char *elfpt=
r,
> +static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=5Felf64(char *elfpt=
r, size=5Ft elfsz,
>  						struct list=5Fhead *vc=5Flist)
>  {
>  	loff=5Ft vmcore=5Foff;
> @@ -469,8 +470,7 @@ static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=
=5Felf64(char *elfptr,
>  	ehdr=5Fptr =3D (Elf64=5FEhdr *)elfptr;
> =20
>  	/* Skip Elf header and program headers. */
> -	vmcore=5Foff =3D sizeof(Elf64=5FEhdr) +
> -			(ehdr=5Fptr->e=5Fphnum) * sizeof(Elf64=5FPhdr);
> +	vmcore=5Foff =3D elfsz;
> =20
>  	list=5Ffor=5Feach=5Fentry(m, vc=5Flist, list) {
>  		m->offset =3D vmcore=5Foff;
> @@ -479,7 +479,7 @@ static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=
=5Felf64(char *elfptr,
>  }
> =20
>  /* Sets offset fields of vmcore elements. */
> -static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=5Felf32(char *elfpt=
r,
> +static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=5Felf32(char *elfpt=
r, size=5Ft elfsz,
>  						struct list=5Fhead *vc=5Flist)
>  {
>  	loff=5Ft vmcore=5Foff;
> @@ -489,8 +489,7 @@ static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=
=5Felf32(char *elfptr,
>  	ehdr=5Fptr =3D (Elf32=5FEhdr *)elfptr;
> =20
>  	/* Skip Elf header and program headers. */
> -	vmcore=5Foff =3D sizeof(Elf32=5FEhdr) +
> -			(ehdr=5Fptr->e=5Fphnum) * sizeof(Elf32=5FPhdr);
> +	vmcore=5Foff =3D elfsz;
> =20
>  	list=5Ffor=5Feach=5Fentry(m, vc=5Flist, list) {
>  		m->offset =3D vmcore=5Foff;
> @@ -526,30 +525,35 @@ static int =5F=5Finit parse=5Fcrash=5Felf64=5Fheade=
rs(void)
>  	}
> =20
>  	/* Read in all elf headers. */
> -	elfcorebuf=5Fsz =3D sizeof(Elf64=5FEhdr) + ehdr.e=5Fphnum * sizeof(Elf6=
4=5FPhdr);
> -	elfcorebuf =3D kmalloc(elfcorebuf=5Fsz, GFP=5FKERNEL);
> +	elfcorebuf=5Fsz=5Forig =3D sizeof(Elf64=5FEhdr) + ehdr.e=5Fphnum * size=
of(Elf64=5FPhdr);
> +	elfcorebuf=5Fsz =3D elfcorebuf=5Fsz=5Forig;
> +	elfcorebuf =3D (void *) =5F=5Fget=5Ffree=5Fpages(GFP=5FKERNEL | =5F=5FG=
FP=5FZERO,
> +					       get=5Forder(elfcorebuf=5Fsz=5Forig));
>  	if (!elfcorebuf)
>  		return -ENOMEM;
>  	addr =3D elfcorehdr=5Faddr;
> -	rc =3D read=5Ffrom=5Foldmem(elfcorebuf, elfcorebuf=5Fsz, &addr, 0);
> +	rc =3D read=5Ffrom=5Foldmem(elfcorebuf, elfcorebuf=5Fsz=5Forig, &addr, =
0);
>  	if (rc < 0) {
> -		kfree(elfcorebuf);
> +		free=5Fpages((unsigned long)elfcorebuf,
> +			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
> =20
>  	/* Merge all PT=5FNOTE headers into one. */
>  	rc =3D merge=5Fnote=5Fheaders=5Felf64(elfcorebuf, &elfcorebuf=5Fsz, &vm=
core=5Flist);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free=5Fpages((unsigned long)elfcorebuf,
> +			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
>  	rc =3D process=5Fptload=5Fprogram=5Fheaders=5Felf64(elfcorebuf, elfcore=
buf=5Fsz,
>  							&vmcore=5Flist);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free=5Fpages((unsigned long)elfcorebuf,
> +			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
> -	set=5Fvmcore=5Flist=5Foffsets=5Felf64(elfcorebuf, &vmcore=5Flist);
> +	set=5Fvmcore=5Flist=5Foffsets=5Felf64(elfcorebuf, elfcorebuf=5Fsz, &vmc=
ore=5Flist);
>  	return 0;
>  }
> =20
> @@ -581,30 +585,35 @@ static int =5F=5Finit parse=5Fcrash=5Felf32=5Fheade=
rs(void)
>  	}
> =20
>  	/* Read in all elf headers. */
> -	elfcorebuf=5Fsz =3D sizeof(Elf32=5FEhdr) + ehdr.e=5Fphnum * sizeof(Elf3=
2=5FPhdr);
> -	elfcorebuf =3D kmalloc(elfcorebuf=5Fsz, GFP=5FKERNEL);
> +	elfcorebuf=5Fsz=5Forig =3D sizeof(Elf32=5FEhdr) + ehdr.e=5Fphnum * size=
of(Elf32=5FPhdr);
> +	elfcorebuf=5Fsz =3D elfcorebuf=5Fsz=5Forig;
> +	elfcorebuf =3D (void *) =5F=5Fget=5Ffree=5Fpages(GFP=5FKERNEL | =5F=5FG=
FP=5FZERO,
> +					       get=5Forder(elfcorebuf=5Fsz=5Forig));
>  	if (!elfcorebuf)
>  		return -ENOMEM;
>  	addr =3D elfcorehdr=5Faddr;
> -	rc =3D read=5Ffrom=5Foldmem(elfcorebuf, elfcorebuf=5Fsz, &addr, 0);
> +	rc =3D read=5Ffrom=5Foldmem(elfcorebuf, elfcorebuf=5Fsz=5Forig, &addr, =
0);
>  	if (rc < 0) {
> -		kfree(elfcorebuf);
> +		free=5Fpages((unsigned long)elfcorebuf,
> +			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
> =20
>  	/* Merge all PT=5FNOTE headers into one. */
>  	rc =3D merge=5Fnote=5Fheaders=5Felf32(elfcorebuf, &elfcorebuf=5Fsz, &vm=
core=5Flist);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free=5Fpages((unsigned long)elfcorebuf,
> +			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
>  	rc =3D process=5Fptload=5Fprogram=5Fheaders=5Felf32(elfcorebuf, elfcore=
buf=5Fsz,
>  								&vmcore=5Flist);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free=5Fpages((unsigned long)elfcorebuf,
> +			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
> -	set=5Fvmcore=5Flist=5Foffsets=5Felf32(elfcorebuf, &vmcore=5Flist);
> +	set=5Fvmcore=5Flist=5Foffsets=5Felf32(elfcorebuf, elfcorebuf=5Fsz, &vmc=
ore=5Flist);
>  	return 0;
>  }
> =20
> @@ -629,14 +638,14 @@ static int =5F=5Finit parse=5Fcrash=5Felf=5Fheaders=
(void)
>  			return rc;
> =20
>  		/* Determine vmcore size. */
> -		vmcore=5Fsize =3D get=5Fvmcore=5Fsize=5Felf64(elfcorebuf);
> +		vmcore=5Fsize =3D get=5Fvmcore=5Fsize=5Felf64(elfcorebuf, elfcorebuf=
=5Fsz);
>  	} else if (e=5Fident[EI=5FCLASS] =3D=3D ELFCLASS32) {
>  		rc =3D parse=5Fcrash=5Felf32=5Fheaders();
>  		if (rc)
>  			return rc;
> =20
>  		/* Determine vmcore size. */
> -		vmcore=5Fsize =3D get=5Fvmcore=5Fsize=5Felf32(elfcorebuf);
> +		vmcore=5Fsize =3D get=5Fvmcore=5Fsize=5Felf32(elfcorebuf, elfcorebuf=
=5Fsz);
>  	} else {
>  		pr=5Fwarn("Warning: Core image elf header is not sane\n");
>  		return -EINVAL;
> @@ -683,7 +692,8 @@ void vmcore=5Fcleanup(void)
>  		list=5Fdel(&m->list);
>  		kfree(m);
>  	}
> -	kfree(elfcorebuf);
> +	free=5Fpages((unsigned long)elfcorebuf,
> +		   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  	elfcorebuf =3D NULL;
>  }
>  EXPORT=5FSYMBOL=5FGPL(vmcore=5Fcleanup);
>=20
>=20

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
