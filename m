Received: from petasus.fm.intel.com (petasus.fm.intel.com [10.1.192.37])
	by hermes.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h181iOG26506
	for <linux-mm@kvack.org>; Sat, 8 Feb 2003 01:44:24 GMT
Received: from fmsmsxvs042.fm.intel.com (fmsmsxvs042.fm.intel.com [132.233.42.128])
	by petasus.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h181g8902809
	for <linux-mm@kvack.org>; Sat, 8 Feb 2003 01:42:08 GMT
content-class: urn:content-classes:message
Subject: RE: hugepage patches
Date: Fri, 7 Feb 2003 17:47:18 -0800
Message-ID: <6315617889C99D4BA7C14687DEC8DB4E023D2E6E@fmsmsx402.fm.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C2CF14.036400FA"
From: "Seth, Rohit" <rohit.seth@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, davem@redhat.com, "Seth, Rohit" <rohit.seth@intel.com>, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2CF14.036400FA
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Andrew,

Will it be possible to have a macro, something like
is_valid_hugepage_addr, that has the arch. specific definition of
checking the validity (like len > TASK_SIZE etc) of any hugepage addr.
It will make the following code more usable across archs. I know we
could have HAVE_ARCH_HUGETLB_UNMAPPED_AREA to have arch specific thing,
but just thought if a small cahnge in existing function could make this
code widely useable.

In addition, HUGE_PAGE_ALIGNMENT sanity check is also needed in
generic_unmapped_area code for MAP_FIXED cases.

I'm attaching a patch.  For i386, the addr parameter to this function is
not modified.  But other archs like ia64 will do that.

thanks,
rohit




> -----Original Message-----
> From: Andrew Morton [mailto:akpm@digeo.com]=20
> Sent: Sunday, February 02, 2003 2:55 AM
> To: davem@redhat.com; rohit.seth@intel.com;=20
> davidm@napali.hpl.hp.com; anton@samba.org;=20
> wli@holomorphy.com; linux-mm@kvack.org
> Subject: Re: hugepage patches
>=20
>=20
> 5/4
>=20
> get_unmapped_area for hugetlbfs
>=20
> Having to specify the mapping address is a pain.  Give=20
> hugetlbfs files a file_operations.get_unmapped_area().
>=20
> The implementation is in hugetlbfs rather than in arch code=20
> because it's probably common to several architectures.  If=20
> the architecture has special needs it can define=20
> HAVE_ARCH_HUGETLB_UNMAPPED_AREA and go it alone.  Just like=20
> HAVE_ARCH_UNMAPPED_AREA.
>=20
>=20
>=20
> Having to specify the mapping address is a pain.  Give=20
> hugetlbfs files a file_operations.get_unmapped_area().
>=20
> The implementation is in hugetlbfs rather than in arch code=20
> because it's probably common to several architectures.  If=20
> the architecture has special needs it can define=20
> HAVE_ARCH_HUGETLB_UNMAPPED_AREA and go it alone.  Just like=20
> HAVE_ARCH_UNMAPPED_AREA.
>=20
>=20
>=20
>  hugetlbfs/inode.c |   46=20
> ++++++++++++++++++++++++++++++++++++++++++++--
>  1 files changed, 44 insertions(+), 2 deletions(-)
>=20
> diff -puN fs/hugetlbfs/inode.c~hugetlbfs-get_unmapped_area=20
> fs/hugetlbfs/inode.c
> --- 25/fs/hugetlbfs/inode.c~hugetlbfs-get_unmapped_area=09
> 2003-02-01 01:13:03.000000000 -0800
> +++ 25-akpm/fs/hugetlbfs/inode.c	2003-02-02=20
> 01:17:01.000000000 -0800
> @@ -74,6 +74,47 @@ static int hugetlbfs_file_mmap(struct fi
>  }
> =20
>  /*
> + * Called under down_write(mmap_sem), page_table_lock is not held */
> +
> +#ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
> +unsigned long hugetlb_get_unmapped_area(struct file *file,=20
> unsigned long addr,
> +		unsigned long len, unsigned long pgoff,=20
> unsigned long flags); #else
> +static unsigned long
> +hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
> +		unsigned long len, unsigned long pgoff,=20
> unsigned long flags)
> +{
> +	struct mm_struct *mm =3D current->mm;
> +	struct vm_area_struct *vma;
> +
> +	if (len & ~HPAGE_MASK)
> +		return -EINVAL;
> +	if (len > TASK_SIZE)
> +		return -ENOMEM;
> +
> +	if (addr) {
> +		addr =3D ALIGN(addr, HPAGE_SIZE);
> +		vma =3D find_vma(mm, addr);
> +		if (TASK_SIZE - len >=3D addr &&
> +		    (!vma || addr + len <=3D vma->vm_start))
> +			return addr;
> +	}
> +
> +	addr =3D ALIGN(mm->free_area_cache, HPAGE_SIZE);
> +
> +	for (vma =3D find_vma(mm, addr); ; vma =3D vma->vm_next) {
> +		/* At this point:  (!vma || addr < vma->vm_end). */
> +		if (TASK_SIZE - len < addr)
> +			return -ENOMEM;
> +		if (!vma || addr + len <=3D vma->vm_start)
> +			return addr;
> +		addr =3D ALIGN(vma->vm_end, HPAGE_SIZE);
> +	}
> +}
> +#endif
> +
> +/*
>   * Read a page. Again trivial. If it didn't already exist
>   * in the page cache, it is zero-filled.
>   */
> @@ -466,8 +507,9 @@ static struct address_space_operations h
>  };
> =20
>  struct file_operations hugetlbfs_file_operations =3D {
> -	.mmap		=3D hugetlbfs_file_mmap,
> -	.fsync		=3D simple_sync_file,
> +	.mmap			=3D hugetlbfs_file_mmap,
> +	.fsync			=3D simple_sync_file,
> +	.get_unmapped_area	=3D hugetlb_get_unmapped_area,
>  };
> =20
>  static struct inode_operations hugetlbfs_dir_inode_operations =3D {
>=20
> _




>=20

------_=_NextPart_001_01C2CF14.036400FA
Content-Type: application/octet-stream;
	name="patch5"
Content-Transfer-Encoding: base64
Content-Description: patch5
Content-Disposition: attachment;
	filename="patch5"

LS0tIG1tL21tYXAuYy4wCUZyaSBGZWIgIDcgMTY6MzQ6MTkgMjAwMworKysgbW0vbW1hcC5jCUZy
aSBGZWIgIDcgMTY6NDA6MjAgMjAwMwpAQCAtNjc3LDEwICs2NzcsMTMgQEAKIHVuc2lnbmVkIGxv
bmcgZ2V0X3VubWFwcGVkX2FyZWEoc3RydWN0IGZpbGUgKmZpbGUsIHVuc2lnbmVkIGxvbmcgYWRk
ciwgdW5zaWduZWQgbG9uZyBsZW4sIHVuc2lnbmVkIGxvbmcgcGdvZmYsIHVuc2lnbmVkIGxvbmcg
ZmxhZ3MpCiB7CiAJaWYgKGZsYWdzICYgTUFQX0ZJWEVEKSB7CisJCXVuc2lnbmVkIGxvbmcgcmV0
OwogCQlpZiAoYWRkciA+IFRBU0tfU0laRSAtIGxlbikKIAkJCXJldHVybiAtRU5PTUVNOwogCQlp
ZiAoYWRkciAmIH5QQUdFX01BU0spCiAJCQlyZXR1cm4gLUVJTlZBTDsKKwkJaWYgKGlzX2ZpbGVf
aHVnZXBhZ2VzKGZpbGUpICYmIChyZXQgPSBpc192YWxpZF9odWdlcGFnZV9yYW5nZSgmYWRkciwg
bGVuLCAxKSkpCisJCQlyZXR1cm4gcmV0OwogCQlyZXR1cm4gYWRkcjsKIAl9CiAKLS0tIGZzL2h1
Z2V0bGJmcy9pbm9kZS5jLjc1CUZyaSBGZWIgIDcgMTQ6MzY6MjMgMjAwMworKysgZnMvaHVnZXRs
YmZzL2lub2RlLmMJRnJpIEZlYiAgNyAxNjozMDo1OCAyMDAzCkBAIC04NywxMSArODcsMTAgQEAK
IHsKIAlzdHJ1Y3QgbW1fc3RydWN0ICptbSA9IGN1cnJlbnQtPm1tOwogCXN0cnVjdCB2bV9hcmVh
X3N0cnVjdCAqdm1hOworCXVuc2lnbmVkIGxvbmcgcmV0ID0gMDsKIAotCWlmIChsZW4gJiB+SFBB
R0VfTUFTSykKLQkJcmV0dXJuIC1FSU5WQUw7Ci0JaWYgKGxlbiA+IFRBU0tfU0laRSkKLQkJcmV0
dXJuIC1FTk9NRU07CisJaWYgKHJldCA9IGlzX3ZhbGlkX2h1Z2VwYWdlX3JhbmdlKCZhZGRyLCBs
ZW4sIDApKQorCQlyZXR1cm4gcmV0OwogCiAJaWYgKGFkZHIpIHsKIAkJYWRkciA9IEFMSUdOKGFk
ZHIsIEhQQUdFX1NJWkUpOwotLS0gYXJjaC9pMzg2L21tL2h1Z2V0bGJwYWdlLmMuMAlGcmkgRmVi
ICA3IDE2OjExOjI5IDIwMDMKKysrIGFyY2gvaTM4Ni9tbS9odWdldGxicGFnZS5jCUZyaSBGZWIg
IDcgMTY6NDM6NDYgMjAwMwpAQCAtODgsNiArODgsMjAgQEAKIAlzZXRfcHRlKHBhZ2VfdGFibGUs
IGVudHJ5KTsKIH0KIAordW5zaWduZWQgbG9uZyBpc192YWxpZF9odWdlcGFnZV9yYW5nZSh1bnNp
Z25lZCBsb25nICphZGRycCwgdW5zaWduZWQgbG9uZyBsZW4sIGludCBmbGFnKQoreworCWlmIChs
ZW4gJiB+SFBBR0VfTUFTSykKKwkJcmV0dXJuIC1FSU5WQUw7CisJaWYgKGZsYWcpIHsKKwkJaWYg
KCphZGRyICYgfkhQQUdFX01BU0spCisJCQlyZXR1cm4gLUVJTlZBTDsKKwkJcmV0dXJuIDA7CisJ
fQorCWlmIChsZW4gPiBUQVNLX1NJWkUpCisJCXJldHVybiAtRU5PTUVNOworCXJldHVybiAwOwor
fQorCiBpbnQgY29weV9odWdldGxiX3BhZ2VfcmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqZHN0LCBz
dHJ1Y3QgbW1fc3RydWN0ICpzcmMsCiAJCQlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSkKIHsK
LS0tIGluY2x1ZGUvbGludXgvaHVnZXRsYi5oLjAJRnJpIEZlYiAgNyAxNjo0NToyMiAyMDAzCisr
KyBpbmNsdWRlL2xpbnV4L2h1Z2V0bGIuaAlGcmkgRmViICA3IDE2OjUwOjMxIDIwMDMKQEAgLTIx
LDYgKzIxLDcgQEAKIHZvaWQgaHVnZXRsYl9yZWxlYXNlX2tleShzdHJ1Y3QgaHVnZXRsYl9rZXkg
Kik7CiBpbnQgaHVnZXRsYl9yZXBvcnRfbWVtaW5mbyhjaGFyICopOwogaW50IGlzX2h1Z2VwYWdl
X21lbV9lbm91Z2goc2l6ZV90KTsKK3Vuc2lnbmVkIGxvbmcgaXNfdmFsaWRfaHVnZXBhZ2VfcmFu
Z2UodW5zaWduZWQgbG9uZyAqLCB1bnNpZ25lZCBsb25nLCBpbnQpOwogCiBleHRlcm4gaW50IGh0
bGJwYWdlX21heDsKIApAQCAtMzgsNiArMzksNyBAQAogI2RlZmluZSBodWdlX3BhZ2VfcmVsZWFz
ZShwYWdlKQkJCUJVRygpCiAjZGVmaW5lIGlzX2h1Z2VwYWdlX21lbV9lbm91Z2goc2l6ZSkJCTAK
ICNkZWZpbmUgaHVnZXRsYl9yZXBvcnRfbWVtaW5mbyhidWYpCQkwCisjZGVmaW5lIGlzX3ZhbGlk
X2h1Z2VwYWdlX3JhbmdlKGFkZHIsIGxlbiwgZmxnKQkwCiAKICNlbmRpZiAvKiAhQ09ORklHX0hV
R0VUTEJfUEFHRSAqLwogCg==

------_=_NextPart_001_01C2CF14.036400FA--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
