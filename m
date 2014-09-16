Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1C64D6B0038
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 19:41:25 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id p9so795798lbv.10
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 16:41:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si1863517laf.115.2014.09.16.16.41.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 16:41:24 -0700 (PDT)
Date: Wed, 17 Sep 2014 09:41:13 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 0/4] Remove possible deadlocks in nfs_release_page()
Message-ID: <20140917094113.0cb07cf1@notabene.brown>
In-Reply-To: <20140916074741.1de870c5@tlielax.poochiereds.net>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916074741.1de870c5@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/PeO.vTXB5CZ=.Tnfg/xaxQv"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

--Sig_/PeO.vTXB5CZ=.Tnfg/xaxQv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 16 Sep 2014 07:47:41 -0400 Jeff Layton <jeff.layton@primarydata.com>
wrote:


> Also, we call things like invalidate_complete_page2 from the cache
> invalidation code. Will we end up with potential problems now that we
> have a stronger possibility that a page might not be freeable when it
> calls releasepage? (no idea on this -- I'm just spitballing)
>=20

Answering just this part here:
 invalidate_complete_page2() is only called immediately after a call to
do_launder_page().
For nfs, that means nfs_launder_page() was called, which calls nfs_wb_page()
which in turn calls
		ret =3D nfs_commit_inode(inode, FLUSH_SYNC);

so the inode is fully committed when invalidate_complete_page2 is called, so
nfs_release_page will succeed.

So there shouldn't be a problem there.

Thanks,
NeilBrown

--Sig_/PeO.vTXB5CZ=.Tnfg/xaxQv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVBjKmTnsnt1WYoG5AQIKoxAAwHYOT2px8v/27OkcGivaLkX0QeRC/v7N
DGFYWzkLZCJQTk8ubsU8qTaMiYBsCHBfxMh7RxIQ66IQ4YOis9/3BiMTFtA81eQL
sm8TK64e4jBSPrTSwevJ4GUGlJBF/xWZTfYKCGjzaGDo3I/G+WB6fTj2YJDulWnk
xgoDy1s23yrvdKJpiC3av9hnvnFAYv4d/sv2axOQGzKDfMn62f8vApPLpqphoq+1
Zone0nWEKTZbDxS0vhf+cN5wDkXtITyjd3WViocfx/QgGPDSZRTvauIXaSmsxYmC
x4jB2n9bnyAI/ifetUjQwt7WbXu61gmI2Tzkny+hZQBTtng/N3S3UBQlCDfJRszD
Gn9juNyfO2NbUJb3z1SxUtPo/liHECOzxt/4qmWgVxRs0BQjcY3WdMejOK19llBO
brBixSxRyNE9c60upOeS3/7kosQSIQttz0KOP0p+/iNmva7h7i5/tgXGpM79vLmn
DTCCQtU/bNnNaTkUgviSZgm68TrmE6HTHJ4JWdKKgDqDFeb0XJaKqd6yS8zmm7lk
l3ChbGiK2ul66xNgFkFfBv1QXozpz9lGfvujoESnMrvWTCYbREWg8mVNEIxyhe2K
3WWlQhEMF5OklFyBUCuQKq+xnNr5O+EiHPboA4wl1PVGRP79pILQ1vbBFdOg/FPD
3fd8+iJf7nc=
=Lclc
-----END PGP SIGNATURE-----

--Sig_/PeO.vTXB5CZ=.Tnfg/xaxQv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
