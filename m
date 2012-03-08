Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 87E1E6B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:19:36 -0500 (EST)
Date: Thu, 8 Mar 2012 15:19:27 -0600
From: Tyler Hicks <tyhicks@canonical.com>
Subject: Re: [PATCH] hugetlbfs: lockdep annotate root inode properly
Message-ID: <20120308211926.GB6546@boyd>
References: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120308130256.c7855cbd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="qcHopEYAB45HaUaB"
Content-Disposition: inline
In-Reply-To: <20120308130256.c7855cbd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, davej@redhat.com, jboyer@redhat.com, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mimi Zohar <zohar@linux.vnet.ibm.com>


--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2012-03-08 13:02:56, Andrew Morton wrote:
> On Thu,  8 Mar 2012 14:45:16 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>=20
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >=20
> > This fix the below lockdep warning
>=20
> OK, what's going on here.
>=20
> >  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> >  [ INFO: possible circular locking dependency detected ]
> >  3.3.0-rc4+ #190 Not tainted
> >  -------------------------------------------------------
> >  shared/1568 is trying to acquire lock:
> >   (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffff811efa0f>] huget=
lbfs_file_mmap+0x7d/0x108
> >=20
> >  but task is already holding lock:
> >   (&mm->mmap_sem){++++++}, at: [<ffffffff810f5589>] sys_mmap_pgoff+0xd4=
/0x12f
> >=20
> >  which lock already depends on the new lock.
> >=20
> >=20
> >  the existing dependency chain (in reverse order) is:
> >=20
> >  -> #1 (&mm->mmap_sem){++++++}:
> >         [<ffffffff8109fb8f>] lock_acquire+0xd5/0xfa
> >         [<ffffffff810ee439>] might_fault+0x6d/0x90
> >         [<ffffffff8111bc12>] filldir+0x6a/0xc2
> >         [<ffffffff81129942>] dcache_readdir+0x5c/0x222
> >         [<ffffffff8111be58>] vfs_readdir+0x76/0xac
> >         [<ffffffff8111bf6a>] sys_getdents+0x79/0xc9
> >         [<ffffffff816940a2>] system_call_fastpath+0x16/0x1b
> >=20
> >  -> #0 (&sb->s_type->i_mutex_key#12){+.+.+.}:
> >         [<ffffffff8109f40a>] __lock_acquire+0xa6c/0xd60
> >         [<ffffffff8109fb8f>] lock_acquire+0xd5/0xfa
> >         [<ffffffff816916be>] __mutex_lock_common+0x48/0x350
> >         [<ffffffff81691a85>] mutex_lock_nested+0x2a/0x31
> >         [<ffffffff811efa0f>] hugetlbfs_file_mmap+0x7d/0x108
> >         [<ffffffff810f4fd0>] mmap_region+0x26f/0x466
> >         [<ffffffff810f545b>] do_mmap_pgoff+0x294/0x2ee
> >         [<ffffffff810f55a9>] sys_mmap_pgoff+0xf4/0x12f
> >         [<ffffffff8103d1f2>] sys_mmap+0x1d/0x1f
> >         [<ffffffff816940a2>] system_call_fastpath+0x16/0x1b
> >=20
> >  other info that might help us debug this:
> >=20
> >   Possible unsafe locking scenario:
> >=20
> >         CPU0                    CPU1
> >         ----                    ----
> >    lock(&mm->mmap_sem);
> >                                 lock(&sb->s_type->i_mutex_key#12);
> >                                 lock(&mm->mmap_sem);
> >    lock(&sb->s_type->i_mutex_key#12);
> >=20
> >   *** DEADLOCK ***
> >=20
> >  1 lock held by shared/1568:
> >   #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff810f5589>] sys_mmap_pgoff=
+0xd4/0x12f
> >=20
> >  stack backtrace:
> >  Pid: 1568, comm: shared Not tainted 3.3.0-rc4+ #190
> >  Call Trace:
> >   [<ffffffff81688bf9>] print_circular_bug+0x1f8/0x209
> >   [<ffffffff8109f40a>] __lock_acquire+0xa6c/0xd60
> >   [<ffffffff8110e7b6>] ? files_lglock_local_lock_cpu+0x61/0x61
> >   [<ffffffff811efa0f>] ? hugetlbfs_file_mmap+0x7d/0x108
> >   [<ffffffff8109fb8f>] lock_acquire+0xd5/0xfa
> >   [<ffffffff811efa0f>] ? hugetlbfs_file_mmap+0x7d/0x108
> >=20
>=20
> Why have these lockdep warnings started coming out now - was the VFS
> changed to newly take i_mutex somewhere in the directory handling?

I'm not sure that they're new warnings. My patch (linked to below) may
have just gave folks a false hope that their nagging lockdep problems
are over.

>=20
>=20
> Sigh.  Was lockdep_annotate_inode_mutex_key() sufficiently
> self-explanatory to justify leaving it undocumented?
>=20
> <goes off and reads e096d0c7e2e>
>=20
> OK, the patch looks correct given the explanation in e096d0c7e2e, but
> I'd like to understand why it becomes necessary only now.
>=20
> > NOTE: This patch also require=20
> > http://thread.gmane.org/gmane.linux.file-systems/58795/focus=3D59565
> > to remove the lockdep warning
>=20
> And that patch has been basically ignored.

Al commented on it here:

https://lkml.org/lkml/2012/2/16/518

He said that while my patch is correct, taking i_mutex inside mmap_sem
is still wrong.

Tyler

>=20
> Sigh.  I guess I'll grab both patches, but I'm not confident in doing
> so without an overall explanation of what is happening here.
>=20
>=20

--qcHopEYAB45HaUaB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCgAGBQJPWSJeAAoJENaSAD2qAscKKEAP/jk/2bRr2jMoH7hDrkrK8zS1
PUd18+vCk0kUlpsvZy4LL6tvXqoyCJxXmebEfSnhJ+7AMB45dNa0yt516Til0qZD
y0ScheMlbYnlVIWtG3iOs2bvdonvVH1ON9lj+xjnq9YLK4q4XotsNGD5QPsxcFf4
+eKjS7Ltc014+yXXA10PUio2csBwXuor9dYkrvvkBI0Vq1U40pECgE4qm9StbLhh
Ka6e4q+DzKN9Q+Mmef7wqBsZ83fDlI7kvRI6WrAohWDTGvtGckekxeD0OxIs/T+E
BaIsLGnQVQe3JuKPbfLYEhUgJe/qYNgr/AKe+5aITSZ0bAv2M17JA20WHWkaNUmW
6G0/CZorFV/aRyc5e7bOydWfihtJyDtV2oHGAY9nU78vXPror9E+q7iOyK5V1gtj
+q2YnrweiFit9wwZ74xIwFXZcpPVQJan2b/ojWwID710N23YW08D2rG1xuzazLhJ
zPZD2BdX0cpK2TGGVEVZRJ66AStxH2vM/UXkt8dMQ/UgFrZMNoTV+PVPMQ9o/zoJ
CsRtkPoEY8ZWTQsyzEv6QegzrM848AeOyR+9aWD4cSAdaBT8IjaBdH8LppvfoAy7
YLNUJ1NE0KsTvSynR4Cmkfkfy5SxvLpFQRUKco62BZErvkUDKfMzb2ZGkJZ08Gdu
s4kTvOjpvjPNSpEd3OXB
=kDX/
-----END PGP SIGNATURE-----

--qcHopEYAB45HaUaB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
