Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D53D6B0038
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 01:47:56 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so8437013eek.10
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 22:47:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si28426267eei.325.2014.04.15.22.47.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 22:47:54 -0700 (PDT)
Date: Wed, 16 Apr 2014 15:47:46 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 10/19] NET: set PF_FSTRANS while holding sk_lock
Message-ID: <20140416154746.7dbb4485@notabene.brown>
In-Reply-To: <1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040336.10604.96000.stgit@notabene.brown>
	<1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/YX/W05=F6X9qrxW7nKLwnOj"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, netdev@vger.kernel.org

--Sig_/YX/W05=F6X9qrxW7nKLwnOj
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Apr 2014 22:13:46 -0700 Eric Dumazet <eric.dumazet@gmail.com>
wrote:

> On Wed, 2014-04-16 at 14:03 +1000, NeilBrown wrote:
> > sk_lock can be taken while reclaiming memory (in nfsd for loop-back
> > NFS mounts, and presumably in nfs), and memory can be allocated while
> > holding sk_lock, at least via:
> >=20
> >  inet_listen -> inet_csk_listen_start ->reqsk_queue_alloc
> >=20
> > So to avoid deadlocks, always set PF_FSTRANS while holding sk_lock.
> >=20
> > This deadlock was found by lockdep.
>=20
> Wow, this is adding expensive stuff in fast path, only for nfsd :(

Yes, this was probably one part that I was least comfortable about.

>=20
> BTW, why should the current->flags should be saved on a socket field,
> and not a current->save_flags. This really looks a thread property, not
> a socket one.
>=20
> Why nfsd could not have PF_FSTRANS in its current->flags ?

nfsd does have PF_FSTRANS set in current->flags.  But some other processes
might not.

If any process takes sk_lock, allocates memory, and then blocks in reclaim =
it
could be waiting for nfsd.  If nfsd waits for that sk_lock, it would cause a
deadlock.

Thinking a bit more carefully .... I suspect that any socket that nfsd
created would only ever be locked by nfsd.  If that is the case then the
problem can be resolved entirely within nfsd.  We would need to tell lockdep
that there are two sorts of sk_locks, those which nfsd uses and all the
rest.  That might get a little messy, but wouldn't impact performance.

Is it justified to assume that sockets created by nfsd threads would only
ever be locked by nfsd threads (and interrupts, which won't be allocating
memory so don't matter), or might there be locked by other threads - e.g for
'netstat -a' etc??


>=20
> For applications handling millions of sockets, this makes a difference.
>=20

Thanks,
NeilBrown


--Sig_/YX/W05=F6X9qrxW7nKLwnOj
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU04Zgjnsnt1WYoG5AQKvxBAAv9gDOMnc/LfCUMBQxzIaIokErrHkCKxM
8u1W93ux2PFls2k6qTlSCVSBpO6chk1Avr9SWPyJZvTFYUnh98PiDV1tKVxJCek8
42kflXGTxHUFXkSBV1ue21mOdn7gw0R3myuMZ8zXD/JFl9sDylwuUbg28hexfWky
sPEu3OCd9DiKm+2uWSe+wlFDWDHkzknRw6g0Ym5/PfuiOl6SgNcHT4w97+Jp1hkd
Xs/TQSIv3aRevVoBtFdtQ90vHE2lEakCOShqyH+oH2ryYmaCsAV2nJzOcpYxZTsL
FTo3Xh+NqDIWUZEsulJtN1vrkOpAIEeJgRcGxwIEauYi/+mGEFF6O+Xo2QK8Dq0c
/rJrDsNvzJ0EHkaIZACsYXQRHljRPzYGmRCoSnsSnnea/Uqda9sluxPzR7Gsxc0B
DqyJd00t6fTQHwWGBG/XEvf1htts4s7rFwLysfBOnK5W5Rc3rih6/ue+i4Ebptmu
tzekBzYicl83hb8KXhpUD4h+PkW1UtUJsbmP5qhMK8wRqzhnsyliil8yxJDY2YTo
Z+qCD7lsacI2NtAvB0hwNQmXG1rq7oYn0rF7s/1vwl+AQSEaYHELWUm6cb9cE+42
OhlnV7nle5yy/mPF93G54m+qwRDlFM8xM7PH7t9JoGdFRXDW/QMh7ma9k2HjVBH/
jxxIu5TYBIw=
=PGsl
-----END PGP SIGNATURE-----

--Sig_/YX/W05=F6X9qrxW7nKLwnOj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
