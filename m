Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id D597A6B005C
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 20:51:15 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so60965eek.15
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 17:51:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c48si15151350eeb.67.2014.04.16.17.51.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 17:51:14 -0700 (PDT)
Date: Thu, 17 Apr 2014 10:51:05 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 16/19] VFS: use GFP_NOFS rather than GFP_KERNEL in
 __d_alloc.
Message-ID: <20140417105105.7772d09d@notabene.brown>
In-Reply-To: <20140416090051.GK15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040337.10604.61837.stgit@notabene.brown>
	<20140416062520.GG15995@dastard>
	<20140416164941.37587da6@notabene.brown>
	<20140416090051.GK15995@dastard>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/IOui8nzd.ykBR2y_BhCeNCV"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

--Sig_/IOui8nzd.ykBR2y_BhCeNCV
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 16 Apr 2014 19:00:51 +1000 Dave Chinner <david@fromorbit.com> wrote:

> On Wed, Apr 16, 2014 at 04:49:41PM +1000, NeilBrown wrote:
> > On Wed, 16 Apr 2014 16:25:20 +1000 Dave Chinner <david@fromorbit.com> w=
rote:
> >=20
> > > On Wed, Apr 16, 2014 at 02:03:37PM +1000, NeilBrown wrote:
> > > > __d_alloc can be called with i_mutex held, so it is safer to
> > > > use GFP_NOFS.
> > > >=20
> > > > lockdep reports this can deadlock when loop-back NFS is in use,
> > > > as nfsd may be required to write out for reclaim, and nfsd certainly
> > > > takes i_mutex.
> > >=20
> > > But not the same i_mutex as is currently held. To me, this seems
> > > like a false positive? If you are holding the i_mutex on an inode,
> > > then you have a reference to the inode and hence memory reclaim
> > > won't ever take the i_mutex on that inode.
> > >=20
> > > FWIW, this sort of false positive was a long stabding problem for
> > > XFS - we managed to get rid of most of the false positives like this
> > > by ensuring that only the ilock is taken within memory reclaim and
> > > memory reclaim can't be entered while we hold the ilock.
> > >=20
> > > You can't do that with the i_mutex, though....
> > >=20
> > > Cheers,
> > >=20
> > > Dave.
> >=20
> > I'm not sure this is a false positive.
> > You can call __d_alloc when creating a file and so are holding i_mutex =
on the
> > directory.
> > nfsd might also want to access that directory.
> >=20
> > If there was only 1 nfsd thread, it would need to get i_mutex and do it=
's
> > thing before replying to that request and so before it could handle the
> > COMMIT which __d_alloc is waiting for.
>=20
> That seems wrong - the NFS client in __d_alloc holds a mutex on a
> NFS client directory inode. The NFS server can't access that
> specific mutex - it's on the other side of the "network". The NFS
> server accesses mutexs from local filesystems, so __d_alloc would
> have to be blocked on a local filesystem inode i_mutex for the nfsd
> to get hung up behind it...

I'm not thinking of mutexes on the NFS inodes but the local filesystem inod=
es
exactly as you describe below.

>=20
> However, my confusion comes from the fact that we do GFP_KERNEL
> memory allocation with the i_mutex held all over the place.

Do we?  Should we?  Isn't the whole point of GFP_NOFS to use it when holding
any filesystem lock?

>           If the
> problem is:
>=20
> 	local fs access -> i_mutex
> .....
> 	nfsd -> i_mutex (blocked)
> .....
> 	local fs access -> kmalloc(GFP_KERNEL)
> 			-> direct reclaim
> 			-> nfs_release_page
> 			-> <send write/commit request to blocked nfsds>
> 			   <deadlock>
>=20
> then why is it just __d_alloc that needs this fix?  Either this is a
> problem *everywhere* or it's not a problem at all.

I think it is a problem everywhere that it is a problem :-)
If you are holding an FS lock, then you should be using GFP_NOFS.
Currently a given filesystem can get away with sometimes using GFP_KERNEL
because that particular lock never causes contention during reclaim for that
particular filesystem.

Adding loop-back NFS into the mix broadens the number of locks which can
cause a problem as it creates interdependencies between different filesyste=
ms.

>=20
> If it's a problem everywhere it means that we simply can't allow
> reclaim from localhost NFS mounts to run from contexts that could
> block an NFSD. i.e. you cannot run NFS client memory reclaim from
> filesystems that are NFS server exported filesystems.....

Well.. you cannot allow NFS client memory reclaim *while holding locks in*
filesystems that are NFS exported.

I think this is most effectively generalised to:
  you cannot allow FS memory reclaim while holding locks in filesystems whi=
ch
  can be NFS exported

which I think is largely the case already - and lockdep can help us find
those places where we currently do allow FS reclaim while holding an FS loc=
k.

Thanks,
NeilBrown

--Sig_/IOui8nzd.ykBR2y_BhCeNCV
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU08leTnsnt1WYoG5AQJQzA/8Cvoi/4unSULSSR/yD8Bso7yrf/66DY4Y
5BknlIQnXLLRnQKRYFbTeMA/Vku/rPyQeWPbX22ealsi2+p7uStAhaqSnAJPPPj/
e+nfkJilCswjWqbuvcwU3oPHGxOA234vHiueT1uIvGyylFUuXvOtL1vPgtaFjlPs
KUYjS36XSD17u/UfTEm8jcTyV1z/QdEbu+jhGGB8/wNGqA9mQDar7ykdcUI37iPf
4YJtGQuzU2NvX+JMVMZtbkRZBn4LPP983oo+2+JSFNDeIDeBlVxOfzErJ1QKLpNq
CJYC86j+baIkf92M1mpOFEanXgIlvitHofxSCcJ29k0YQDhLZUF0DPrQhdKtSnoK
kVcF5pnUwLbcu7jHkHT/8Uip1CijkpqSg920ZhYJAnMseLWM+er2gQIUXkXRzWJd
062RpdhKK5/m0MTbXZJ8crAycFQFLep1vG++jrbYQ0VAQ7TzCF4+iREBxmLiH1sd
Oh3l4DdIcDqXchSocKyDAiFA+O8CHCKoBPTyA3YKCNBtmmyIouWjylLOeGMiD4AD
yuCks0tlZdtfvZMaqV43yxEkNUsLybnxf3StilD0zJFkQZtWAq43efcIt2XOeiR/
R9BUs3QNOao2ockixg+9T1LV1l1G9RNvcSkrF+j6x0/9uINhcfffqrusqBK5V7FW
4Oc/mEI+igY=
=2sPU
-----END PGP SIGNATURE-----

--Sig_/IOui8nzd.ykBR2y_BhCeNCV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
