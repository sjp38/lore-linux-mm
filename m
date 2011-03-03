Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E4D8D8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:29:42 -0500 (EST)
MIME-Version: 1.0
Message-ID: <763a2305-27c6-4f44-8962-db72b434c037@default>
Date: Thu, 3 Mar 2011 09:29:04 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 0/3] drivers/staging: zcache: dynamic page cache/swap
 compression
References: <20110207032407.GA27404@ca-server1.us.oracle.com>
 <1ddd01a8-591a-42bc-8bb3-561843b31acb@default>
 <AANLkTimFATx-gYVgY_pVdZsySSBmXvKFkhTJUeVFBcop@mail.gmail.com>
 <AANLkTimqSSxHrLhL9t4DOmDeuAA41B9e-qnr+vnUsucL@mail.gmail.com>
 <AANLkTi=4QkV4wtMmDd6+XXhvkva+fq9m5PVYGC0qBUc3@mail.gmail.com>
 <AANLkTimOssgM7JYSpwB=5zmF_JJ2ByH+PWO7N+YZNB_y@mail.gmail.com>
 <e647042e-419e-4e61-a563-e489596bd659@default
 AANLkTim_U+mJtHk7drvqMOmUwd4ro8J0dazZMDsNqH=o@mail.gmail.com>
In-Reply-To: <AANLkTim_U+mJtHk7drvqMOmUwd4ro8J0dazZMDsNqH=o@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Matt <jackdachef@gmail.com>, gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, linux-btrfs@vger.kernel.org, Josef Bacik <josef@redhat.com>, Dan Rosenberg <drosenberg@vsecurity.com>, Yan Zheng <zheng.z.yan@intel.com>, miaox@cn.fujitsu.com, Li Zefan <lizf@cn.fujitsu.com>

> > I definitely see a bug in cleancache_get_key in the monolithic
> > zcache+cleancache+frontswap patch I posted on oss.oracle.com
> > that is corrected in linux-next but I don't see how it could
> > get provoked by btrfs.
> >
> > The bug is that, in cleancache_get_key, the return value of fhfn
> should
> > be checked against 255. =C2=A0If the return value is 255,
> cleancache_get_key
> > should return -1. =C2=A0This should disable cleancache for any filesyst=
em
> > where KEY_MAX is too large.
> >
> > But cleancache_get_key always calls fhfn with connectable =3D=3D 0 and
> > CLEANCACHE_KEY_MAX=3D=3D6 should be greater than
> BTRFS_FID_SIZE_CONNECTABLE
> > (which I think should be 5?). =C2=A0And the elements written into the
> > typecast btrfs_fid should be only writing the first 5 32-bit words.
>=20
> BTRFS_FID_SIZE_NON_CONNECTALBE is 5,  not BTRFS_FID_SIZE_CONNECTABLE.
> Anyway, you passed connectable with 0 so it should be only writing the
> first 5 32-bit words as you said.
> That's one I missed. ;-)
>=20
> Thanks.
> --
> Kind regards,
> Minchan Kim

Sorry, I realized that I solved this with Matt offlist and never
posted the solution on-list, so for the archives:

This patch applies on top of the cleancache patch.  It is really
a horrible hack but solving it correctly requires the interface
to encode_fh ops to change, which would require changes to many
filesystems, so best saved for a later time.  If/when cleancache
gets merged, this patch will need to be applied on top of it
for btrfs to work properly when cleancache is enabled.

Basically, the problem is that, in all current filesystems,
obtaining the filehandle requires a dentry ONLY if connectable
is set.  Otherwise, the dentry is only used to get the inode.
But cleancache_get_key only has an inode, and the alias list
of dentries associated with the inode may be empty.  So
either the encode_fh interface would need to be changed
or, in this hack-y solution, a dentry is created temporarily
only for the purpose of dereferencing it.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

diff -Napur -X linux-2.6.37.1/Documentation/dontdiff linux-2.6.37.1/mm/clea=
ncache.c linux-2.6.37.1-fix/mm/cleancache.c
--- linux-2.6.37.1/mm/cleancache.c=092011-02-25 11:38:47.000000000 -0800
+++ linux-2.6.37.1-fix/mm/cleancache.c=092011-02-25 08:53:46.000000000 -080=
0
@@ -78,15 +78,14 @@ static int cleancache_get_key(struct ino
 =09int (*fhfn)(struct dentry *, __u32 *fh, int *, int);
 =09int maxlen =3D CLEANCACHE_KEY_MAX;
 =09struct super_block *sb =3D inode->i_sb;
-=09struct dentry *d;
=20
 =09key->u.ino =3D inode->i_ino;
 =09if (sb->s_export_op !=3D NULL) {
 =09=09fhfn =3D sb->s_export_op->encode_fh;
 =09=09if  (fhfn) {
-=09=09=09d =3D list_first_entry(&inode->i_dentry,
-=09=09=09=09=09=09struct dentry, d_alias);
-=09=09=09(void)(*fhfn)(d, &key->u.fh[0], &maxlen, 0);
+=09=09=09struct dentry d;
+=09=09=09d.d_inode =3D inode;
+=09=09=09(void)(*fhfn)(&d, &key->u.fh[0], &maxlen, 0);
 =09=09=09if (maxlen > CLEANCACHE_KEY_MAX)
 =09=09=09=09return -1;
 =09=09}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
