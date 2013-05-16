Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 472766B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 04:00:56 -0400 (EDT)
Message-ID: <519489EA.7000209@cn.fujitsu.com>
Date: Thu, 16 May 2013 15:25:30 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 8/8] vmcore: support mmap() on /proc/vmcore
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <20130515090626.28109.95938.stgit@localhost6.localdomain6>
In-Reply-To: <20130515090626.28109.95938.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, riel@redhat.com, hughd@google.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, kumagai-atsushi@mxc.nes.nec.co.jp, walken@google.com, cpw@sgi.com, jingbai.ma@hp.com

=E4=BA=8E 2013=E5=B9=B405=E6=9C=8815=E6=97=A5 17:06, HATAYAMA Daisuke =E5=
=86=99=E9=81=93:
> This patch introduces mmap=5Fvmcore().
>=20
> Don't permit writable nor executable mapping even with mprotect()
> because this mmap() is aimed at reading crash dump memory.
> Non-writable mapping is also requirement of remap=5Fpfn=5Frange() when
> mapping linear pages on non-consecutive physical pages; see
> is=5Fcow=5Fmapping().
>=20
> Set VM=5FMIXEDMAP flag to remap memory by remap=5Fpfn=5Frange and by
> remap=5Fvmalloc=5Frange=5Fpertial at the same time for a single
> vma. do=5Fmunmap() can correctly clean partially remapped vma with two
> functions in abnormal case. See zap=5Fpte=5Frange(), vm=5Fnormal=5Fpage()=
 and
> their comments for details.
>=20
> On x86-32 PAE kernels, mmap() supports at most 16TB memory only. This
> limitation comes from the fact that the third argument of
> remap=5Fpfn=5Frange(), pfn, is of 32-bit length on x86-32: unsigned long.
>=20
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
> ---

Assuming that patch 4 & 5 of this series are ok:

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

>=20
>  fs/proc/vmcore.c |   86 ++++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  1 files changed, 86 insertions(+), 0 deletions(-)
>=20
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 7f2041c..2c72487 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -20,6 +20,7 @@
>  #include <linux/init.h>
>  #include <linux/crash=5Fdump.h>
>  #include <linux/list.h>
> +#include <linux/vmalloc.h>
>  #include <asm/uaccess.h>
>  #include <asm/io.h>
>  #include "internal.h"
> @@ -200,9 +201,94 @@ static ssize=5Ft read=5Fvmcore(struct file *file, ch=
ar =5F=5Fuser *buffer,
>  	return acc;
>  }
> =20
> +static int mmap=5Fvmcore(struct file *file, struct vm=5Farea=5Fstruct *v=
ma)
> +{
> +	size=5Ft size =3D vma->vm=5Fend - vma->vm=5Fstart;
> +	u64 start, end, len, tsz;
> +	struct vmcore *m;
> +
> +	start =3D (u64)vma->vm=5Fpgoff << PAGE=5FSHIFT;
> +	end =3D start + size;
> +
> +	if (size > vmcore=5Fsize || end > vmcore=5Fsize)
> +		return -EINVAL;
> +
> +	if (vma->vm=5Fflags & (VM=5FWRITE | VM=5FEXEC))
> +		return -EPERM;
> +
> +	vma->vm=5Fflags &=3D ~(VM=5FMAYWRITE | VM=5FMAYEXEC);
> +	vma->vm=5Fflags |=3D VM=5FMIXEDMAP;
> +
> +	len =3D 0;
> +
> +	if (start < elfcorebuf=5Fsz) {
> +		u64 pfn;
> +
> +		tsz =3D elfcorebuf=5Fsz - start;
> +		if (size < tsz)
> +			tsz =3D size;
> +		pfn =3D =5F=5Fpa(elfcorebuf + start) >> PAGE=5FSHIFT;
> +		if (remap=5Fpfn=5Frange(vma, vma->vm=5Fstart, pfn, tsz,
> +				    vma->vm=5Fpage=5Fprot))
> +			return -EAGAIN;
> +		size -=3D tsz;
> +		start +=3D tsz;
> +		len +=3D tsz;
> +
> +		if (size =3D=3D 0)
> +			return 0;
> +	}
> +
> +	if (start < elfcorebuf=5Fsz + elfnotes=5Fsz) {
> +		void *kaddr;
> +
> +		tsz =3D elfcorebuf=5Fsz + elfnotes=5Fsz - start;
> +		if (size < tsz)
> +			tsz =3D size;
> +		kaddr =3D elfnotes=5Fbuf + start - elfcorebuf=5Fsz;
> +		if (remap=5Fvmalloc=5Frange=5Fpartial(vma, vma->vm=5Fstart + len,
> +						kaddr, tsz)) {
> +			do=5Fmunmap(vma->vm=5Fmm, vma->vm=5Fstart, len);
> +			return -EAGAIN;
> +		}
> +		size -=3D tsz;
> +		start +=3D tsz;
> +		len +=3D tsz;
> +
> +		if (size =3D=3D 0)
> +			return 0;
> +	}
> +
> +	list=5Ffor=5Feach=5Fentry(m, &vmcore=5Flist, list) {
> +		if (start < m->offset + m->size) {
> +			u64 paddr =3D 0;
> +
> +			tsz =3D m->offset + m->size - start;
> +			if (size < tsz)
> +				tsz =3D size;
> +			paddr =3D m->paddr + start - m->offset;
> +			if (remap=5Fpfn=5Frange(vma, vma->vm=5Fstart + len,
> +					    paddr >> PAGE=5FSHIFT, tsz,
> +					    vma->vm=5Fpage=5Fprot)) {
> +				do=5Fmunmap(vma->vm=5Fmm, vma->vm=5Fstart, len);
> +				return -EAGAIN;
> +			}
> +			size -=3D tsz;
> +			start +=3D tsz;
> +			len +=3D tsz;
> +
> +			if (size =3D=3D 0)
> +				return 0;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
>  static const struct file=5Foperations proc=5Fvmcore=5Foperations =3D {
>  	.read		=3D read=5Fvmcore,
>  	.llseek		=3D default=5Fllseek,
> +	.mmap		=3D mmap=5Fvmcore,
>  };
> =20
>  static struct vmcore* =5F=5Finit get=5Fnew=5Felement(void)
>=20
>=20
> =5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec
>=20

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
