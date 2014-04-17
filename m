Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2C97A6B0070
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 21:50:31 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so81041eei.5
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 18:50:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si32737644eer.297.2014.04.16.18.50.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 18:50:29 -0700 (PDT)
Date: Thu, 17 Apr 2014 11:50:18 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH/RFC 00/19] Support loop-back NFS mounts
Message-ID: <20140417115018.460345d0@notabene.brown>
In-Reply-To: <20140417012739.GU15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416104207.75b044e8@tlielax.poochiereds.net>
	<20140417102048.2fc8275c@notabene.brown>
	<20140417012739.GU15995@dastard>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/aR.nJzAOWD3tAtDyjyGs6Ar"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org, Ming Lei <ming.lei@canonical.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

--Sig_/aR.nJzAOWD3tAtDyjyGs6Ar
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 17 Apr 2014 11:27:39 +1000 Dave Chinner <david@fromorbit.com> wrote:

> On Thu, Apr 17, 2014 at 10:20:48AM +1000, NeilBrown wrote:
> > A good example is the deadlock with the flush-* threads.
> > flush-* will lock a page, and  then call ->writepage.  If ->writepage
> > allocates memory it can enter reclaim, call ->releasepage on NFS, and b=
lock
> > waiting for a COMMIT to complete.
> > The COMMIT might already be running, performing fsync on that same file=
 that
> > flush-* is flushing.  It locks each page in turn.  When it  gets to the=
 page
> > that flush-* has locked, it will deadlock.
>=20
> It's nfs_release_page() again....
>=20
> > In general, if nfsd is allowed to block on local filesystem, and local
> > filesystem is allowed to block on NFS, then a deadlock can happen.
> > We would need a clear hierarchy
> >=20
> >    __GFP_NETFS > __GFP_FS > __GFP_IO
> >=20
> > for it to work.  I'm not sure the extra level really helps a lot and it=
 would
> > be a lot of churn.
>=20
> I think you are looking at this the wrong way - it's not the other
> filesystems that have to avoid memory reclaim recursion, it's the
> NFS client mount that is on loopback that needs to avoid recursion.
>=20
> IMO, the fix should be that the NFS client cannot block on messages sent =
to the NFSD
> on the same host during memory reclaim. That is, nfs_release_page()
> cannot send commit messages to the server if the server is on
> localhost. Instead, it just tells memory reclaim that it can't
> reclaim that page.
>=20
> If nfs_release_page() no longer blocks in memory reclaim, and all
> these nfsd-gets-blocked-in-GFP_KERNEL-memory-allocation recursion
> problems go away. Do the same for all the other memory reclaim
> operations in the NFS client, and you've got a solution that should
> work without needing to walk all over the rest of the kernel....

Maybe.
It is nfs_release_page() today. I wonder if it could be other things another
day.  I want to be sure I have a solution that really makes sense.

However ... the thing that nfs_release_page is doing it sending a COMMIT to
tell the server to flush to stable storage.  It does that so that if the
server crashes, then the client can re-send.
Of course when it is a loop-back mount the client is the server so the COMM=
IT
is completely pointless.  If the client notices that it is sending a COMMIT
to itself, it can simply assume a positive reply.

You are right, that would make the patch set a lot less intrusive.  I'll gi=
ve
it some serious thought - thanks.

NeilBrown

--Sig_/aR.nJzAOWD3tAtDyjyGs6Ar
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU08zWjnsnt1WYoG5AQKfQw//WIl8Mf1G0vzy816TBvi7fx3VCp6SUV7s
jQeCJSD0IPRzCFmxH1ZJFzy3jIK8J3dbT8cSGjxXYegOq+kyyVjbHXOG2msC1riY
ytOGUQnOS8MHscbcAOR7r61t/1t7FZiSJ51Th7pykepQmbm9QNEna+U0wzna3poK
NNRDrs1J0eySpLTydegKoyg4w6KP6MLXqlYQm1FigvkreDEZ9mvBW7NrGycwDQF8
NZgq8+dGCL3MAq+uZ7WMqAoCZwZUrusVZBc3zvXYWepSMFSW1FOmQP971QZ9DgI2
KzarhdGOSFTbVHLhZafYV0X2k/hATVoIJpXh3Kl2ak0qdnuuUPJ/s64zxvQ3N4wo
3zBU0/TvcEVs6toQfcT/Zi91rCIvVvl8BOssIosbwknfLyi/JEYtnDJ+MxWBlg1G
xlaEF1pDaQYEix5Ocg1qyU7oroFv98+pZ4BZeDI7Y/A6gasVvR3NKBOFcadozYuo
FBTuYO6ZTSVPZ1+ASqykb5hh3GGKO5oM4x7xX0dQRSADk4qo4FLfv6ONKK2OfjQo
r6FBlpw9OU6su26F4XzDkFLPb3xUDgfY7gMG6vIZYmCS7JGOvTg2rpk6inZxzATb
40mX+gFDXs5oE9XGaqz2Fl7Lw/BNluPNDEpkmWJX42+7cdClnc2XPSJyvpFx7nLH
lfrN+yaHFBM=
=c/XS
-----END PGP SIGNATURE-----

--Sig_/aR.nJzAOWD3tAtDyjyGs6Ar--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
