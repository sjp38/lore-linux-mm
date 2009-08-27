Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C94466B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:20:59 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7RFKhOG013906
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:20:43 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7RFL4Ov235550
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:21:04 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7RFKxjF015261
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:21:04 -0400
Date: Thu, 27 Aug 2009 16:20:50 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: hugetlbfs: Do not call user_shm_lock() for MAP_HUGETLB fix
Message-ID: <20090827152050.GD6323@us.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n/aVsWSeQ4JHkrmm"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mel@csn.ul.ie, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>


--n/aVsWSeQ4JHkrmm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The patch
hugetlbfs-allow-the-creation-of-files-suitable-for-map_private-on-the-vfs-i=
nternal-mount.patch
alters can_do_hugetlb_shm() to check if a file is being created for shared
memory or mmap(). If this returns false, we then unconditionally call
user_shm_lock() triggering a warning. This block should never be entered
for MAP_HUGETLB. This patch partially reverts the problem and fixes the che=
ck.

This patch should be considered a fix to
hugetlbfs-allow-the-creation-of-files-suitable-for-map_private-on-the-vfs-i=
nternal-mount.patch.

=46rom: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 fs/hugetlbfs/inode.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 49d2bf9..c944cc1 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -910,15 +910,9 @@ static struct file_system_type hugetlbfs_fs_type =3D {

 static struct vfsmount *hugetlbfs_vfsmount;

-static int can_do_hugetlb_shm(int creat_flags)
+static int can_do_hugetlb_shm(void)
 {
-       if (creat_flags !=3D HUGETLB_SHMFS_INODE)
-               return 0;
-       if (capable(CAP_IPC_LOCK))
-               return 1;
-       if (in_group_p(sysctl_hugetlb_shm_group))
-               return 1;
-       return 0;
+       return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group=
);
 }

 struct file *hugetlb_file_setup(const char *name, size_t size, int acctfla=
g,
@@ -934,7 +928,7 @@ struct file *hugetlb_file_setup(const char *name, size_=
t size, int acctflag,
        if (!hugetlbfs_vfsmount)
                return ERR_PTR(-ENOENT);

-       if (!can_do_hugetlb_shm(creat_flags)) {
+       if (creat_flags =3D=3D HUGETLB_SHMFS_INODE && !can_do_hugetlb_shm()=
) {
                *user =3D current_user();
                if (user_shm_lock(size, *user)) {
                        WARN_ONCE(1,


--n/aVsWSeQ4JHkrmm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqWpFIACgkQsnv9E83jkzolOwCdFLG8QBYR9XCjBM4bJ7jZHxJB
CAsAn3snyXzDd+vrq+yvA9ye41bnV4o0
=jnCm
-----END PGP SIGNATURE-----

--n/aVsWSeQ4JHkrmm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
