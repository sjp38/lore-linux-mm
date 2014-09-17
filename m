Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 87C306B0035
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 20:19:32 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id q108so882566qgd.21
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 17:19:32 -0700 (PDT)
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
        by mx.google.com with ESMTPS id b1si933214qat.61.2014.09.16.17.19.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 17:19:31 -0700 (PDT)
Received: by mail-qc0-f173.google.com with SMTP id i8so1031984qcq.4
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 17:19:31 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 16 Sep 2014 20:19:29 -0400
Subject: Re: [PATCH 0/4] Remove possible deadlocks in nfs_release_page()
Message-ID: <20140916201929.2e355cae@tlielax.poochiereds.net>
In-Reply-To: <20140917094113.0cb07cf1@notabene.brown>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916074741.1de870c5@tlielax.poochiereds.net>
	<20140917094113.0cb07cf1@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/Ys0zqew17SC2TGhq3/B+BHp"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

--Sig_/Ys0zqew17SC2TGhq3/B+BHp
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 17 Sep 2014 09:41:13 +1000
NeilBrown <neilb@suse.de> wrote:

> On Tue, 16 Sep 2014 07:47:41 -0400 Jeff Layton <jeff.layton@primarydata.c=
om>
> wrote:
>=20
>=20
> > Also, we call things like invalidate_complete_page2 from the cache
> > invalidation code. Will we end up with potential problems now that we
> > have a stronger possibility that a page might not be freeable when it
> > calls releasepage? (no idea on this -- I'm just spitballing)
> >=20
>=20
> Answering just this part here:
>  invalidate_complete_page2() is only called immediately after a call to
> do_launder_page().
> For nfs, that means nfs_launder_page() was called, which calls nfs_wb_pag=
e()
> which in turn calls
> 		ret =3D nfs_commit_inode(inode, FLUSH_SYNC);
>=20
> so the inode is fully committed when invalidate_complete_page2 is called,=
 so
> nfs_release_page will succeed.
>=20
> So there shouldn't be a problem there.
>=20

Yep, Trond pointed that out today when we were discussing it. Thanks
for confirming it here though...

--=20
Jeff Layton <jlayton@primarydata.com>

--Sig_/Ys0zqew17SC2TGhq3/B+BHp
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUGNORAAoJEAAOaEEZVoIVdxsP/iWsCXblcW/GyBvM33IWf/8D
kMkX5kZKlL8qzpDI8zXssrw8f84LzwgPcWqawn9NyfGjhGcTUyWgUU3CbhGjHUWO
3Sfd1xWToc3gm75ZQQCcNSk5PhVAaProerx4c7U/G+rp4zaHylSjGCEqFhxQuw2Y
sbHwewFwSq+68zcTR8U/wfZuqGl8pC2L4mz4WCmjA8lGNsLlrtC0V7Y16wgAFhSa
iN5L7GWght21Mdzd8DJUdTTeG0wuU07VsWuc2eE5Xt6LYOMv3343ZFoAWbRtwOYA
xuxe6t/C/Rw9lBPcyYlIAYEkgZm0UWjLE0iFbfChrLlqo2BEXt/IWnGRLSzcO+yM
GAGVnqOK5wTdHKpXtIRiAFFbRVcKEcU8YDOaGRSWBw0DTx9aSgJFtzb/U756FAJq
qQ7t1E/7N6GwsuwHtF2U3pNOdHI1VdmbkEU0KqAvOe8KJZkBLe2O+61gAYxBeT1h
Ok8BzUyWphBK1/SSEzNtY7ERgjq5kxUhrmt7uttwKOqs9pf5yD7m4KAGDg0kbbbC
bTKs+e1K5oM6OR09cu7LxRdrdV06FaMIH7x2DjCFn5ycoEGXdn5NjMwktgl+kmal
tslpZ2HeyF87WoRKkvaQ+VvZ4PKOBpHG6osTTj9cseQlaDZuf+HxIOzKSMSVSRil
TSB4k0+FfSv77ie7p1jq
=cwpv
-----END PGP SIGNATURE-----

--Sig_/Ys0zqew17SC2TGhq3/B+BHp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
