Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA5436B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:11:10 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7RF4gkg027837
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:04:42 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7RFBC5J221492
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:11:12 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7RFBCVu005108
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:11:12 -0400
Date: Thu, 27 Aug 2009 16:11:08 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH 1/3] hugetlbfs: Allow the creation of files suitable for
	MAP_PRIVATE on the vfs internal mount
Message-ID: <20090827151108.GC6323@us.ibm.com>
References: <cover.1251282769.git.ebmunson@us.ibm.com> <1c66a9e98a73d61c611e5cf09b276e954965046e.1251282769.git.ebmunson@us.ibm.com> <20090827141834.GF21183@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H8ygTp4AXg6deix2"
Content-Disposition: inline
In-Reply-To: <20090827141834.GF21183@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>


--H8ygTp4AXg6deix2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 27 Aug 2009, Mel Gorman wrote:

> On Wed, Aug 26, 2009 at 11:44:51AM +0100, Eric B Munson wrote:
> > There are two means of creating mappings backed by huge pages:
> >=20
> >         1. mmap() a file created on hugetlbfs
> >         2. Use shm which creates a file on an internal mount which esse=
ntially
> >            maps it MAP_SHARED
> >=20
> > The internal mount is only used for shared mappings but there is very
> > little that stops it being used for private mappings. This patch extends
> > hugetlbfs_file_setup() to deal with the creation of files that will be
> > mapped MAP_PRIVATE on the internal hugetlbfs mount. This extended API is
> > used in a subsequent patch to implement the MAP_HUGETLB mmap() flag.
> >=20
>=20
> Hi Eric,
>=20
> I ran these patches through a series of small tests and I have just one
> concern with the changes made to can_do_hugetlb_shm(). If that returns fa=
lse
> because of MAP_HUGETLB, we then proceed to call user_shm_lock(). I think =
your
> intention might have been something like the following patch on top of yo=
urs?
>=20
> For what it's worth, once this was applied, I didn't spot any other
> problems, run-time or otherwise.
>=20

I am seeing the same thing, terminal says segfault with no memory, dmesg
complains about SHM.  Your patch fixes the issue.  Thanks.


> =3D=3D=3D=3D=3D
> hugetlbfs: Do not call user_shm_lock() for MAP_HUGETLB
>=20
> The patch
> hugetlbfs-allow-the-creation-of-files-suitable-for-map_private-on-the-vfs=
-internal-mount.patch
> alters can_do_hugetlb_shm() to check if a file is being created for shared
> memory or mmap(). If this returns false, we then unconditionally call
> user_shm_lock() triggering a warning. This block should never be entered
> for MAP_HUGETLB. This patch partially reverts the problem and fixes the c=
heck.
>=20
> This patch should be considered a fix to
> hugetlbfs-allow-the-creation-of-files-suitable-for-map_private-on-the-vfs=
-internal-mount.patch.
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---=20
>  fs/hugetlbfs/inode.c |   12 +++---------
>  1 file changed, 3 insertions(+), 9 deletions(-)
>=20
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 49d2bf9..c944cc1 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -910,15 +910,9 @@ static struct file_system_type hugetlbfs_fs_type =3D=
 {
>=20
>  static struct vfsmount *hugetlbfs_vfsmount;
>=20
> -static int can_do_hugetlb_shm(int creat_flags)
> +static int can_do_hugetlb_shm(void)
>  {
> -	if (creat_flags !=3D HUGETLB_SHMFS_INODE)
> -		return 0;
> -	if (capable(CAP_IPC_LOCK))
> -		return 1;
> -	if (in_group_p(sysctl_hugetlb_shm_group))
> -		return 1;
> -	return 0;
> +	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
>  }
>=20
>  struct file *hugetlb_file_setup(const char *name, size_t size, int acctf=
lag,
> @@ -934,7 +928,7 @@ struct file *hugetlb_file_setup(const char *name, siz=
e_t size, int acctflag,
>  	if (!hugetlbfs_vfsmount)
>  		return ERR_PTR(-ENOENT);
>=20
> -	if (!can_do_hugetlb_shm(creat_flags)) {
> +	if (creat_flags =3D=3D HUGETLB_SHMFS_INODE && !can_do_hugetlb_shm()) {
>  		*user =3D current_user();
>  		if (user_shm_lock(size, *user)) {
>  			WARN_ONCE(1,
>=20
>=20

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--H8ygTp4AXg6deix2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqWogwACgkQsnv9E83jkzpa4QCgjsXwbpOD5X6x+8RcC66yZ0jb
HGQAnR7qpYpfzfOQO9jadJXoRAkvktQt
=Qf8/
-----END PGP SIGNATURE-----

--H8ygTp4AXg6deix2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
