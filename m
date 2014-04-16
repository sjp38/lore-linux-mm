Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id B10C86B0044
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 01:52:39 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so8391490eek.30
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 22:52:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o46si28486023eem.159.2014.04.15.22.52.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 22:52:38 -0700 (PDT)
Date: Wed, 16 Apr 2014 15:52:30 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 17/19] VFS: set PF_FSTRANS while namespace_sem is held.
Message-ID: <20140416155230.4d02e4b9@notabene.brown>
In-Reply-To: <20140416044618.GX18016@ZenIV.linux.org.uk>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040337.10604.86740.stgit@notabene.brown>
	<20140416044618.GX18016@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/AHIx/=TRorm595oyDqzGVg8"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

--Sig_/AHIx/=TRorm595oyDqzGVg8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 16 Apr 2014 05:46:18 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Wed, Apr 16, 2014 at 02:03:37PM +1000, NeilBrown wrote:
> > namespace_sem can be taken while various i_mutex locks are held, so we
> > need to avoid reclaim from blocking on an FS (particularly loop-back
> > NFS).
>=20
> I would really prefer to deal with that differently - by explicit change =
of
> gfp_t arguments of allocators.
>=20
> The thing is, namespace_sem is held *only* over allocations, and not a lot
> of them, at that - only mnt_alloc_id(), mnt_alloc_group_id(), alloc_vfsmn=
t()
> and new_mountpoint().  That is all that is allowed.
>=20
> Again, actual work with filesystems (setup, shutdown, remount, pathname
> resolution, etc.) is all done outside of namespace_sem; it's held only
> for manipulations of fs/{namespace,pnode}.c data structures and the only
> reason it isn't a spinlock is that we need to do some allocations.
>=20
> So I'd rather slap GFP_NOFS on those few allocations...

So something like this?  I put that in to my testing instead.

Thanks,
NeilBrown

diff --git a/fs/namespace.c b/fs/namespace.c
index 83dcd5083dbb..8e103b8c8323 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -103,7 +103,7 @@ static int mnt_alloc_id(struct mount *mnt)
 	int res;
=20
 retry:
-	ida_pre_get(&mnt_id_ida, GFP_KERNEL);
+	ida_pre_get(&mnt_id_ida, GFP_NOFS);
 	spin_lock(&mnt_id_lock);
 	res =3D ida_get_new_above(&mnt_id_ida, mnt_id_start, &mnt->mnt_id);
 	if (!res)
@@ -134,7 +134,7 @@ static int mnt_alloc_group_id(struct mount *mnt)
 {
 	int res;
=20
-	if (!ida_pre_get(&mnt_group_ida, GFP_KERNEL))
+	if (!ida_pre_get(&mnt_group_ida, GFP_NOFS))
 		return -ENOMEM;
=20
 	res =3D ida_get_new_above(&mnt_group_ida,
@@ -193,7 +193,7 @@ unsigned int mnt_get_count(struct mount *mnt)
=20
 static struct mount *alloc_vfsmnt(const char *name)
 {
-	struct mount *mnt =3D kmem_cache_zalloc(mnt_cache, GFP_KERNEL);
+	struct mount *mnt =3D kmem_cache_zalloc(mnt_cache, GFP_NOFS);
 	if (mnt) {
 		int err;
=20
@@ -202,7 +202,7 @@ static struct mount *alloc_vfsmnt(const char *name)
 			goto out_free_cache;
=20
 		if (name) {
-			mnt->mnt_devname =3D kstrdup(name, GFP_KERNEL);
+			mnt->mnt_devname =3D kstrdup(name, GFP_NOFS);
 			if (!mnt->mnt_devname)
 				goto out_free_id;
 		}
@@ -682,7 +682,7 @@ static struct mountpoint *new_mountpoint(struct dentry =
*dentry)
 		}
 	}
=20
-	mp =3D kmalloc(sizeof(struct mountpoint), GFP_KERNEL);
+	mp =3D kmalloc(sizeof(struct mountpoint), GFP_NOFS);
 	if (!mp)
 		return ERR_PTR(-ENOMEM);
=20

--Sig_/AHIx/=TRorm595oyDqzGVg8
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU04anjnsnt1WYoG5AQIhrg/8CkSLV3X4c4pMegKcWjixLvjggV9C0nmD
Ki7J2WYAcQLErKW3y+NMuIGWo5ZHNizwEeaSIFbqdzSiMzebtGI5lreK3Vgm6Kom
yxHsQgu528mbaZj1W29ifjwd6qyaDjmx8hgIEkBZOz1/SrRJ0QiphaQS5/VaZF4j
25qwbmPyTA92q75q7eOdy+n4y/hpZj6gPAAwjKOmLPFw7YnG1hajhUKReU7z86X1
cLCX/9ppr+KM8sHpBQfNkzIdC7+PXsHSy38R+ZRLlsdNYuIIxKHJBu1M5EsZejI4
uPAhNgws4bQohRmPQ0wDzjoiYPeYvPOM1lgln3w3JQuQ9H5/4Nr0EMRBx+BZuIAs
iUNjLNSxh7I+5Xb+kTH5ea7O75mhmDg6h0KnsFIyL7585/ve872HwTeWnjqhkaRk
B/gSXw7j6a6CUjGhk8Vpl6aKEgdyieoG0oxIU6xgkUzIjh7V54N+qRNbijGEIrXX
XwExDi31ptdiBoX8OYTpL5dtKIpJFI3+M9brUs/OHEiMTGxP+gBBoZjygvqQnooD
/UBY2sdOBQaDS843VQnYUlIhv4XpmwNGZrp7P+lgsTZmgnL39Mt2hfTC3iGvvw4o
/9lAjXcUCg19a0llfGfqMWXNWEHH8Bjo5OovO4DpN7wWccy6GhXI6U+yd0WNI4k5
Rte0ii4ppow=
=vIwc
-----END PGP SIGNATURE-----

--Sig_/AHIx/=TRorm595oyDqzGVg8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
