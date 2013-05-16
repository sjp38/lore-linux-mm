Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2E97E6B0034
	for <linux-mm@kvack.org>; Thu, 16 May 2013 03:29:31 -0400 (EDT)
Message-ID: <51948872.5090402@cn.fujitsu.com>
Date: Thu, 16 May 2013 15:19:14 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 6/8] vmcore: allocate ELF note segment in the 2nd kernel
 vmalloc memory
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <20130515090614.28109.26492.stgit@localhost6.localdomain6>
In-Reply-To: <20130515090614.28109.26492.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

=E4=BA=8E 2013=E5=B9=B405=E6=9C=8815=E6=97=A5 17:06, HATAYAMA Daisuke =E5=
=86=99=E9=81=93:
> The reasons why we don't allocate ELF note segment in the 1st kernel
> (old memory) on page boundary is to keep backward compatibility for
> old kernels, and that if doing so, we waste not a little memory due to
> round-up operation to fit the memory to page boundary since most of
> the buffers are in per-cpu area.
>=20
> ELF notes are per-cpu, so total size of ELF note segments depends on
> number of CPUs. The current maximum number of CPUs on x86=5F64 is 5192,
> and there's already system with 4192 CPUs in SGI, where total size
> amounts to 1MB. This can be larger in the near future or possibly even
> now on another architecture that has larger size of note per a single
> cpu. Thus, to avoid the case where memory allocation for large block
> fails, we allocate vmcore objects on vmalloc memory.
>=20
> This patch adds elfnotes=5Fbuf and elfnotes=5Fsz variables to keep pointer
> to the ELF note segment buffer and its size. There's no longer the
> vmcore object that corresponds to the ELF note segment in
> vmcore=5Flist. Accordingly, read=5Fvmcore() has new case for ELF note
> segment and set=5Fvmcore=5Flist=5Foffsets=5Felf{64,32}() and other helper
> functions starts calculating offset from sum of size of ELF headers
> and size of ELF note segment.
>=20
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
> ---

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

>=20
>  fs/proc/vmcore.c |  273 +++++++++++++++++++++++++++++++++++++++++-------=
------
>  1 files changed, 209 insertions(+), 64 deletions(-)
>=20
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 6cf7fbd..4e121fda 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -34,6 +34,9 @@ static char *elfcorebuf;
>  static size=5Ft elfcorebuf=5Fsz;
>  static size=5Ft elfcorebuf=5Fsz=5Forig;
> =20
> +static char *elfnotes=5Fbuf;
> +static size=5Ft elfnotes=5Fsz;
> +
>  /* Total size of vmcore file. */
>  static u64 vmcore=5Fsize;
> =20
> @@ -154,6 +157,26 @@ static ssize=5Ft read=5Fvmcore(struct file *file, ch=
ar =5F=5Fuser *buffer,
>  			return acc;
>  	}
> =20
> +	/* Read Elf note segment */
> +	if (*fpos < elfcorebuf=5Fsz + elfnotes=5Fsz) {
> +		void *kaddr;
> +
> +		tsz =3D elfcorebuf=5Fsz + elfnotes=5Fsz - *fpos;
> +		if (buflen < tsz)
> +			tsz =3D buflen;
> +		kaddr =3D elfnotes=5Fbuf + *fpos - elfcorebuf=5Fsz;
> +		if (copy=5Fto=5Fuser(buffer, kaddr, tsz))
> +			return -EFAULT;
> +		buflen -=3D tsz;
> +		*fpos +=3D tsz;
> +		buffer +=3D tsz;
> +		acc +=3D tsz;
> +
> +		/* leave now if filled buffer already */
> +		if (buflen =3D=3D 0)
> +			return acc;
> +	}
> +
>  	list=5Ffor=5Feach=5Fentry(m, &vmcore=5Flist, list) {
>  		if (*fpos < m->offset + m->size) {
>  			tsz =3D m->offset + m->size - *fpos;
> @@ -221,23 +244,33 @@ static u64 =5F=5Finit get=5Fvmcore=5Fsize=5Felf32(c=
har *elfptr, size=5Ft elfsz)
>  	return size;
>  }
> =20
> -/* Merges all the PT=5FNOTE headers into one. */
> -static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf64(char *elfptr, size=
=5Ft *elfsz,
> -						struct list=5Fhead *vc=5Flist)
> +/**
> + * process=5Fnote=5Fheaders=5Felf64 - Perform a variety of processing on=
 ELF
> + * note segments according to the combination of function arguments.
> + *
> + * @ehdr=5Fptr  - ELF header buffer
> + * @nr=5Fnotes  - the number of program header entries of PT=5FNOTE type
> + * @notes=5Fsz  - total size of ELF note segment
> + * @notes=5Fbuf - buffer into which ELF note segment is copied
> + *
> + * Assume @ehdr=5Fptr is always not NULL. If @nr=5Fnotes is not NULL, th=
en
> + * the number of program header entries of PT=5FNOTE type is assigned to
> + * @nr=5Fnotes. If @notes=5Fsz is not NULL, then total size of ELF note
> + * segment, header part plus data part, is assigned to @notes=5Fsz. If
> + * @notes=5Fbuf is not NULL, then ELF note segment is copied into
> + * @notes=5Fbuf.
> + */
> +static int =5F=5Finit process=5Fnote=5Fheaders=5Felf64(const Elf64=5FEhd=
r *ehdr=5Fptr,
> +					     int *nr=5Fnotes, u64 *notes=5Fsz,
> +					     char *notes=5Fbuf)
>  {
>  	int i, nr=5Fptnote=3D0, rc=3D0;
> -	char *tmp;
> -	Elf64=5FEhdr *ehdr=5Fptr;
> -	Elf64=5FPhdr phdr, *phdr=5Fptr;
> +	Elf64=5FPhdr *phdr=5Fptr =3D (Elf64=5FPhdr*)(ehdr=5Fptr + 1);
>  	Elf64=5FNhdr *nhdr=5Fptr;
> -	u64 phdr=5Fsz =3D 0, note=5Foff;
> +	u64 phdr=5Fsz =3D 0;
> =20
> -	ehdr=5Fptr =3D (Elf64=5FEhdr *)elfptr;
> -	phdr=5Fptr =3D (Elf64=5FPhdr*)(elfptr + sizeof(Elf64=5FEhdr));
>  	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++, phdr=5Fptr++) {
> -		int j;
>  		void *notes=5Fsection;
> -		struct vmcore *new;
>  		u64 offset, max=5Fsz, sz, real=5Fsz =3D 0;
>  		if (phdr=5Fptr->p=5Ftype !=3D PT=5FNOTE)
>  			continue;
> @@ -253,7 +286,7 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf64(=
char *elfptr, size=5Ft *elfsz,
>  			return rc;
>  		}
>  		nhdr=5Fptr =3D notes=5Fsection;
> -		for (j =3D 0; j < max=5Fsz; j +=3D sz) {
> +		while (real=5Fsz < max=5Fsz) {
>  			if (nhdr=5Fptr->n=5Fnamesz =3D=3D 0)
>  				break;
>  			sz =3D sizeof(Elf64=5FNhdr) +
> @@ -262,20 +295,68 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf6=
4(char *elfptr, size=5Ft *elfsz,
>  			real=5Fsz +=3D sz;
>  			nhdr=5Fptr =3D (Elf64=5FNhdr*)((char*)nhdr=5Fptr + sz);
>  		}
> -
> -		/* Add this contiguous chunk of notes section to vmcore list.*/
> -		new =3D get=5Fnew=5Felement();
> -		if (!new) {
> -			kfree(notes=5Fsection);
> -			return -ENOMEM;
> +		if (notes=5Fbuf) {
> +			offset =3D phdr=5Fptr->p=5Foffset;
> +			rc =3D read=5Ffrom=5Foldmem(notes=5Fbuf + phdr=5Fsz, real=5Fsz,
> +					      &offset, 0);
> +			if (rc < 0) {
> +				kfree(notes=5Fsection);
> +				return rc;
> +			}
>  		}
> -		new->paddr =3D phdr=5Fptr->p=5Foffset;
> -		new->size =3D real=5Fsz;
> -		list=5Fadd=5Ftail(&new->list, vc=5Flist);
>  		phdr=5Fsz +=3D real=5Fsz;
>  		kfree(notes=5Fsection);
>  	}
> =20
> +	if (nr=5Fnotes)
> +		*nr=5Fnotes =3D nr=5Fptnote;
> +	if (notes=5Fsz)
> +		*notes=5Fsz =3D phdr=5Fsz;
> +
> +	return 0;
> +}
> +
> +static int =5F=5Finit get=5Fnote=5Fnumber=5Fand=5Fsize=5Felf64(const Elf=
64=5FEhdr *ehdr=5Fptr,
> +						 int *nr=5Fptnote, u64 *phdr=5Fsz)
> +{
> +	return process=5Fnote=5Fheaders=5Felf64(ehdr=5Fptr, nr=5Fptnote, phdr=
=5Fsz, NULL);
> +}
> +
> +static int =5F=5Finit copy=5Fnotes=5Felf64(const Elf64=5FEhdr *ehdr=5Fpt=
r, char *notes=5Fbuf)
> +{
> +	return process=5Fnote=5Fheaders=5Felf64(ehdr=5Fptr, NULL, NULL, notes=
=5Fbuf);
> +}
> +
> +/* Merges all the PT=5FNOTE headers into one. */
> +static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf64(char *elfptr, size=
=5Ft *elfsz,
> +					   char **notes=5Fbuf, size=5Ft *notes=5Fsz)
> +{
> +	int i, nr=5Fptnote=3D0, rc=3D0;
> +	char *tmp;
> +	Elf64=5FEhdr *ehdr=5Fptr;
> +	Elf64=5FPhdr phdr;
> +	u64 phdr=5Fsz =3D 0, note=5Foff;
> +	struct vm=5Fstruct *vm;
> +
> +	ehdr=5Fptr =3D (Elf64=5FEhdr *)elfptr;
> +
> +	rc =3D get=5Fnote=5Fnumber=5Fand=5Fsize=5Felf64(ehdr=5Fptr, &nr=5Fptnot=
e, &phdr=5Fsz);
> +	if (rc < 0)
> +		return rc;
> +
> +	*notes=5Fsz =3D roundup(phdr=5Fsz, PAGE=5FSIZE);
> +	*notes=5Fbuf =3D vzalloc(*notes=5Fsz);
> +	if (!*notes=5Fbuf)
> +		return -ENOMEM;
> +
> +	vm =3D find=5Fvm=5Farea(*notes=5Fbuf);
> +	BUG=5FON(!vm);
> +	vm->flags |=3D VM=5FUSERMAP;
> +
> +	rc =3D copy=5Fnotes=5Felf64(ehdr=5Fptr, *notes=5Fbuf);
> +	if (rc < 0)
> +		return rc;
> +
>  	/* Prepare merged PT=5FNOTE program header. */
>  	phdr.p=5Ftype    =3D PT=5FNOTE;
>  	phdr.p=5Fflags   =3D 0;
> @@ -304,23 +385,33 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf6=
4(char *elfptr, size=5Ft *elfsz,
>  	return 0;
>  }
> =20
> -/* Merges all the PT=5FNOTE headers into one. */
> -static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf32(char *elfptr, size=
=5Ft *elfsz,
> -						struct list=5Fhead *vc=5Flist)
> +/**
> + * process=5Fnote=5Fheaders=5Felf32 - Perform a variety of processing on=
 ELF
> + * note segments according to the combination of function arguments.
> + *
> + * @ehdr=5Fptr  - ELF header buffer
> + * @nr=5Fnotes  - the number of program header entries of PT=5FNOTE type
> + * @notes=5Fsz  - total size of ELF note segment
> + * @notes=5Fbuf - buffer into which ELF note segment is copied
> + *
> + * Assume @ehdr=5Fptr is always not NULL. If @nr=5Fnotes is not NULL, th=
en
> + * the number of program header entries of PT=5FNOTE type is assigned to
> + * @nr=5Fnotes. If @notes=5Fsz is not NULL, then total size of ELF note
> + * segment, header part plus data part, is assigned to @notes=5Fsz. If
> + * @notes=5Fbuf is not NULL, then ELF note segment is copied into
> + * @notes=5Fbuf.
> + */
> +static int =5F=5Finit process=5Fnote=5Fheaders=5Felf32(const Elf32=5FEhd=
r *ehdr=5Fptr,
> +					     int *nr=5Fnotes, u64 *notes=5Fsz,
> +					     char *notes=5Fbuf)
>  {
>  	int i, nr=5Fptnote=3D0, rc=3D0;
> -	char *tmp;
> -	Elf32=5FEhdr *ehdr=5Fptr;
> -	Elf32=5FPhdr phdr, *phdr=5Fptr;
> +	Elf32=5FPhdr *phdr=5Fptr =3D (Elf32=5FPhdr*)(ehdr=5Fptr + 1);
>  	Elf32=5FNhdr *nhdr=5Fptr;
> -	u64 phdr=5Fsz =3D 0, note=5Foff;
> +	u64 phdr=5Fsz =3D 0;
> =20
> -	ehdr=5Fptr =3D (Elf32=5FEhdr *)elfptr;
> -	phdr=5Fptr =3D (Elf32=5FPhdr*)(elfptr + sizeof(Elf32=5FEhdr));
>  	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++, phdr=5Fptr++) {
> -		int j;
>  		void *notes=5Fsection;
> -		struct vmcore *new;
>  		u64 offset, max=5Fsz, sz, real=5Fsz =3D 0;
>  		if (phdr=5Fptr->p=5Ftype !=3D PT=5FNOTE)
>  			continue;
> @@ -336,7 +427,7 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf32(=
char *elfptr, size=5Ft *elfsz,
>  			return rc;
>  		}
>  		nhdr=5Fptr =3D notes=5Fsection;
> -		for (j =3D 0; j < max=5Fsz; j +=3D sz) {
> +		while (real=5Fsz < max=5Fsz) {
>  			if (nhdr=5Fptr->n=5Fnamesz =3D=3D 0)
>  				break;
>  			sz =3D sizeof(Elf32=5FNhdr) +
> @@ -345,20 +436,68 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf3=
2(char *elfptr, size=5Ft *elfsz,
>  			real=5Fsz +=3D sz;
>  			nhdr=5Fptr =3D (Elf32=5FNhdr*)((char*)nhdr=5Fptr + sz);
>  		}
> -
> -		/* Add this contiguous chunk of notes section to vmcore list.*/
> -		new =3D get=5Fnew=5Felement();
> -		if (!new) {
> -			kfree(notes=5Fsection);
> -			return -ENOMEM;
> +		if (notes=5Fbuf) {
> +			offset =3D phdr=5Fptr->p=5Foffset;
> +			rc =3D read=5Ffrom=5Foldmem(notes=5Fbuf + phdr=5Fsz, real=5Fsz,
> +					      &offset, 0);
> +			if (rc < 0) {
> +				kfree(notes=5Fsection);
> +				return rc;
> +			}
>  		}
> -		new->paddr =3D phdr=5Fptr->p=5Foffset;
> -		new->size =3D real=5Fsz;
> -		list=5Fadd=5Ftail(&new->list, vc=5Flist);
>  		phdr=5Fsz +=3D real=5Fsz;
>  		kfree(notes=5Fsection);
>  	}
> =20
> +	if (nr=5Fnotes)
> +		*nr=5Fnotes =3D nr=5Fptnote;
> +	if (notes=5Fsz)
> +		*notes=5Fsz =3D phdr=5Fsz;
> +
> +	return 0;
> +}
> +
> +static int =5F=5Finit get=5Fnote=5Fnumber=5Fand=5Fsize=5Felf32(const Elf=
32=5FEhdr *ehdr=5Fptr,
> +						 int *nr=5Fptnote, u64 *phdr=5Fsz)
> +{
> +	return process=5Fnote=5Fheaders=5Felf32(ehdr=5Fptr, nr=5Fptnote, phdr=
=5Fsz, NULL);
> +}
> +
> +static int =5F=5Finit copy=5Fnotes=5Felf32(const Elf32=5FEhdr *ehdr=5Fpt=
r, char *notes=5Fbuf)
> +{
> +	return process=5Fnote=5Fheaders=5Felf32(ehdr=5Fptr, NULL, NULL, notes=
=5Fbuf);
> +}
> +
> +/* Merges all the PT=5FNOTE headers into one. */
> +static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf32(char *elfptr, size=
=5Ft *elfsz,
> +					   char **notes=5Fbuf, size=5Ft *notes=5Fsz)
> +{
> +	int i, nr=5Fptnote=3D0, rc=3D0;
> +	char *tmp;
> +	Elf32=5FEhdr *ehdr=5Fptr;
> +	Elf32=5FPhdr phdr;
> +	u64 phdr=5Fsz =3D 0, note=5Foff;
> +	struct vm=5Fstruct *vm;
> +
> +	ehdr=5Fptr =3D (Elf32=5FEhdr *)elfptr;
> +
> +	rc =3D get=5Fnote=5Fnumber=5Fand=5Fsize=5Felf32(ehdr=5Fptr, &nr=5Fptnot=
e, &phdr=5Fsz);
> +	if (rc < 0)
> +		return rc;
> +
> +	*notes=5Fsz =3D roundup(phdr=5Fsz, PAGE=5FSIZE);
> +	*notes=5Fbuf =3D vzalloc(*notes=5Fsz);
> +	if (!*notes=5Fbuf)
> +		return -ENOMEM;
> +
> +	vm =3D find=5Fvm=5Farea(*notes=5Fbuf);
> +	BUG=5FON(!vm);
> +	vm->flags |=3D VM=5FUSERMAP;
> +
> +	rc =3D copy=5Fnotes=5Felf32(ehdr=5Fptr, *notes=5Fbuf);
> +	if (rc < 0)
> +		return rc;
> +
>  	/* Prepare merged PT=5FNOTE program header. */
>  	phdr.p=5Ftype    =3D PT=5FNOTE;
>  	phdr.p=5Fflags   =3D 0;
> @@ -391,6 +530,7 @@ static int =5F=5Finit merge=5Fnote=5Fheaders=5Felf32(=
char *elfptr, size=5Ft *elfsz,
>   * the new offset fields of exported program headers. */
>  static int =5F=5Finit process=5Fptload=5Fprogram=5Fheaders=5Felf64(char =
*elfptr,
>  						size=5Ft elfsz,
> +						size=5Ft elfnotes=5Fsz,
>  						struct list=5Fhead *vc=5Flist)
>  {
>  	int i;
> @@ -402,8 +542,8 @@ static int =5F=5Finit process=5Fptload=5Fprogram=5Fhe=
aders=5Felf64(char *elfptr,
>  	ehdr=5Fptr =3D (Elf64=5FEhdr *)elfptr;
>  	phdr=5Fptr =3D (Elf64=5FPhdr*)(elfptr + sizeof(Elf64=5FEhdr)); /* PT=5F=
NOTE hdr */
> =20
> -	/* First program header is PT=5FNOTE header. */
> -	vmcore=5Foff =3D elfsz + roundup(phdr=5Fptr->p=5Fmemsz, PAGE=5FSIZE);
> +	/* Skip Elf header, program headers and Elf note segment. */
> +	vmcore=5Foff =3D elfsz + elfnotes=5Fsz;
> =20
>  	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++, phdr=5Fptr++) {
>  		u64 paddr, start, end, size;
> @@ -433,6 +573,7 @@ static int =5F=5Finit process=5Fptload=5Fprogram=5Fhe=
aders=5Felf64(char *elfptr,
> =20
>  static int =5F=5Finit process=5Fptload=5Fprogram=5Fheaders=5Felf32(char =
*elfptr,
>  						size=5Ft elfsz,
> +						size=5Ft elfnotes=5Fsz,
>  						struct list=5Fhead *vc=5Flist)
>  {
>  	int i;
> @@ -444,8 +585,8 @@ static int =5F=5Finit process=5Fptload=5Fprogram=5Fhe=
aders=5Felf32(char *elfptr,
>  	ehdr=5Fptr =3D (Elf32=5FEhdr *)elfptr;
>  	phdr=5Fptr =3D (Elf32=5FPhdr*)(elfptr + sizeof(Elf32=5FEhdr)); /* PT=5F=
NOTE hdr */
> =20
> -	/* First program header is PT=5FNOTE header. */
> -	vmcore=5Foff =3D elfsz + roundup(phdr=5Fptr->p=5Fmemsz, PAGE=5FSIZE);
> +	/* Skip Elf header, program headers and Elf note segment. */
> +	vmcore=5Foff =3D elfsz + elfnotes=5Fsz;
> =20
>  	for (i =3D 0; i < ehdr=5Fptr->e=5Fphnum; i++, phdr=5Fptr++) {
>  		u64 paddr, start, end, size;
> @@ -474,17 +615,15 @@ static int =5F=5Finit process=5Fptload=5Fprogram=5F=
headers=5Felf32(char *elfptr,
>  }
> =20
>  /* Sets offset fields of vmcore elements. */
> -static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=5Felf64(char *elfpt=
r, size=5Ft elfsz,
> +static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=5Felf64(size=5Ft el=
fsz,
> +						size=5Ft elfnotes=5Fsz,
>  						struct list=5Fhead *vc=5Flist)
>  {
>  	loff=5Ft vmcore=5Foff;
> -	Elf64=5FEhdr *ehdr=5Fptr;
>  	struct vmcore *m;
> =20
> -	ehdr=5Fptr =3D (Elf64=5FEhdr *)elfptr;
> -
> -	/* Skip Elf header and program headers. */
> -	vmcore=5Foff =3D elfsz;
> +	/* Skip Elf header, program headers and Elf note segment. */
> +	vmcore=5Foff =3D elfsz + elfnotes=5Fsz;
> =20
>  	list=5Ffor=5Feach=5Fentry(m, vc=5Flist, list) {
>  		m->offset =3D vmcore=5Foff;
> @@ -493,17 +632,15 @@ static void =5F=5Finit set=5Fvmcore=5Flist=5Foffset=
s=5Felf64(char *elfptr, size=5Ft elfsz,
>  }
> =20
>  /* Sets offset fields of vmcore elements. */
> -static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=5Felf32(char *elfpt=
r, size=5Ft elfsz,
> +static void =5F=5Finit set=5Fvmcore=5Flist=5Foffsets=5Felf32(size=5Ft el=
fsz,
> +						size=5Ft elfnotes=5Fsz,
>  						struct list=5Fhead *vc=5Flist)
>  {
>  	loff=5Ft vmcore=5Foff;
> -	Elf32=5FEhdr *ehdr=5Fptr;
>  	struct vmcore *m;
> =20
> -	ehdr=5Fptr =3D (Elf32=5FEhdr *)elfptr;
> -
> -	/* Skip Elf header and program headers. */
> -	vmcore=5Foff =3D elfsz;
> +	/* Skip Elf header, program headers and Elf note segment. */
> +	vmcore=5Foff =3D elfsz + elfnotes=5Fsz;
> =20
>  	list=5Ffor=5Feach=5Fentry(m, vc=5Flist, list) {
>  		m->offset =3D vmcore=5Foff;
> @@ -554,20 +691,23 @@ static int =5F=5Finit parse=5Fcrash=5Felf64=5Fheade=
rs(void)
>  	}
> =20
>  	/* Merge all PT=5FNOTE headers into one. */
> -	rc =3D merge=5Fnote=5Fheaders=5Felf64(elfcorebuf, &elfcorebuf=5Fsz, &vm=
core=5Flist);
> +	rc =3D merge=5Fnote=5Fheaders=5Felf64(elfcorebuf, &elfcorebuf=5Fsz,
> +				      &elfnotes=5Fbuf, &elfnotes=5Fsz);
>  	if (rc) {
>  		free=5Fpages((unsigned long)elfcorebuf,
>  			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
>  	rc =3D process=5Fptload=5Fprogram=5Fheaders=5Felf64(elfcorebuf, elfcore=
buf=5Fsz,
> -							&vmcore=5Flist);
> +						  elfnotes=5Fsz,
> +						  &vmcore=5Flist);
>  	if (rc) {
>  		free=5Fpages((unsigned long)elfcorebuf,
>  			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
> -	set=5Fvmcore=5Flist=5Foffsets=5Felf64(elfcorebuf, elfcorebuf=5Fsz, &vmc=
ore=5Flist);
> +	set=5Fvmcore=5Flist=5Foffsets=5Felf64(elfcorebuf=5Fsz, elfnotes=5Fsz,
> +				      &vmcore=5Flist);
>  	return 0;
>  }
> =20
> @@ -614,20 +754,23 @@ static int =5F=5Finit parse=5Fcrash=5Felf32=5Fheade=
rs(void)
>  	}
> =20
>  	/* Merge all PT=5FNOTE headers into one. */
> -	rc =3D merge=5Fnote=5Fheaders=5Felf32(elfcorebuf, &elfcorebuf=5Fsz, &vm=
core=5Flist);
> +	rc =3D merge=5Fnote=5Fheaders=5Felf32(elfcorebuf, &elfcorebuf=5Fsz,
> +				      &elfnotes=5Fbuf, &elfnotes=5Fsz);
>  	if (rc) {
>  		free=5Fpages((unsigned long)elfcorebuf,
>  			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
>  	rc =3D process=5Fptload=5Fprogram=5Fheaders=5Felf32(elfcorebuf, elfcore=
buf=5Fsz,
> -								&vmcore=5Flist);
> +						  elfnotes=5Fsz,
> +						  &vmcore=5Flist);
>  	if (rc) {
>  		free=5Fpages((unsigned long)elfcorebuf,
>  			   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  		return rc;
>  	}
> -	set=5Fvmcore=5Flist=5Foffsets=5Felf32(elfcorebuf, elfcorebuf=5Fsz, &vmc=
ore=5Flist);
> +	set=5Fvmcore=5Flist=5Foffsets=5Felf32(elfcorebuf=5Fsz, elfnotes=5Fsz,
> +				      &vmcore=5Flist);
>  	return 0;
>  }
> =20
> @@ -706,6 +849,8 @@ void vmcore=5Fcleanup(void)
>  		list=5Fdel(&m->list);
>  		kfree(m);
>  	}
> +	vfree(elfnotes=5Fbuf);
> +	elfnotes=5Fbuf =3D NULL;
>  	free=5Fpages((unsigned long)elfcorebuf,
>  		   get=5Forder(elfcorebuf=5Fsz=5Forig));
>  	elfcorebuf =3D NULL;
>=20
>=20

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
