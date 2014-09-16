Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id EE8BE6B0038
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 19:38:20 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id p9so801741lbv.28
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 16:38:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rt5si26389903lbb.2.2014.09.16.16.38.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 16:38:18 -0700 (PDT)
Date: Wed, 17 Sep 2014 09:37:57 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 3/4] NFS: avoid deadlocks with loop-back mounted NFS
 filesystems.
Message-ID: <20140917093757.472c8cf2@notabene.brown>
In-Reply-To: <54182F8B.8010302@Netapp.com>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916053135.22257.68002.stgit@notabene.brown>
	<54182F8B.8010302@Netapp.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/SleaSZokHRCCDT+.Q_nPcHS"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>

--Sig_/SleaSZokHRCCDT+.Q_nPcHS
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 16 Sep 2014 08:39:39 -0400 Anna Schumaker <Anna.Schumaker@netapp.co=
m>
wrote:

> On 09/16/2014 01:31 AM, NeilBrown wrote:
> > Support for loop-back mounted NFS filesystems is useful when NFS is
> > used to access shared storage in a high-availability cluster.
> >
> > If the node running the NFS server fails, some other node can mount the
> > filesystem and start providing NFS service.  If that node already had
> > the filesystem NFS mounted, it will now have it loop-back mounted.
> >
> > nfsd can suffer a deadlock when allocating memory and entering direct
> > reclaim.
> > While direct reclaim does not write to the NFS filesystem it can send
> > and wait for a COMMIT through nfs_release_page().
>=20
> Is there anything that can be done on the nfsd side to prevent the deadlo=
cks?
>=20

I went down that path first and it didn't work out.
Setting PF_FSTRANS in nfsd (when the request comes from localhost) and then
arranging the __GFP_FS is cleared when that flag is set overcomes a number =
of
possible deadlock sources, but not all.

There are a number of situations where nfsd is waiting on some other thread
(which doesn't have PF_FSTRANS set) and that thread tries to reclaim memory
and hits nfs_release_page().
It was a long and complex patch set, and nobody liked it.
And the common thread was always that it always blocked in nfs_release_page=
().
So it seemed to make sense to just remove that blockage.

Thanks,
NeilBrown

--Sig_/SleaSZokHRCCDT+.Q_nPcHS
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVBjJ1Tnsnt1WYoG5AQIA4A/9FUdVuHypfzeP82ItnBzQ2jKdkcLlfEI6
g6BsDX9RJ28++zq7MqI1mnsyJXzZbBpvB1W6wSFWiFNq8FqZOhHH+YFzQMGY6MgX
m9NjV5Jb6aXCGwjwjlE/ocIhbgHyS3DYJyiid28Lv0j/mdsA2rux0lW86Z3QuqP+
zV4y/FQCs9Hmf0hwOmlrdVjdMe5XYtZpBgctlKaynMKooC69yfna21zzWMAW0JU4
TgNPR9XMNVULFS+rtt1tYYMbHynPtnuIS0tT7RJJjAf4EWxzlMrcHGebCoZaJZ3G
7AgadunMpvBPmBDQOwUbf2iVibEFkEUSOTqr4X6xMdOOzbNv8hGO0+7WixEuLQv/
uP5W0S+1oBSLyISUhhW8KQharjPIKbPF8pM+WLXpZclXNMDl6xRztOeHrHjc7InZ
E2HrOlR/ttWbtcTMz0B17PhkKZjyYvuRyxTXoj0cWxgnTNH4MCzGFYlDDcwqKOUu
kLZ2TCrIHpVmzhlFde6wFLpTWBzErhuo1Wna/HYFXK7sitq2hiOx0NM4DPDMNInw
tw4hxzUBjd5s7UEaW/+YEZAct8rkXWDjYAkw0fyQZFTEqjGKZXVKvY6koJDG0gZG
B/2pWkP0VyU23iZ/SjpLdpWgP030KI/X/TXYRZTzCaPipJyYGfCL/xpwWk2N7ki9
0eK6lfXjMvs=
=F4Ed
-----END PGP SIGNATURE-----

--Sig_/SleaSZokHRCCDT+.Q_nPcHS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
