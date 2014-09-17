Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id A5AC06B0035
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 21:10:31 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id w7so882454lbi.18
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 18:10:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si26539782lbv.18.2014.09.16.18.10.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 18:10:29 -0700 (PDT)
Date: Wed, 17 Sep 2014 11:10:17 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 4/4] NFS/SUNRPC: Remove other deadlock-avoidance
 mechanisms in nfs_release_page()
Message-ID: <20140917111017.499eb3a9@notabene.brown>
In-Reply-To: <CAHQdGtQbFtLFEpzgqoMoLiG7-Y0FdFiZdpS4dgkT7hsCnqMiPA@mail.gmail.com>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916053135.22257.46476.stgit@notabene.brown>
	<CAHQdGtQbFtLFEpzgqoMoLiG7-Y0FdFiZdpS4dgkT7hsCnqMiPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/5P2dtBKeAm7hBxjx2=6jlOQ"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Devel FS Linux <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Linux Kernel mailing list <linux-kernel@vger.kernel.org>, Jeff Layton <jeff.layton@primarydata.com>

--Sig_/5P2dtBKeAm7hBxjx2=6jlOQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 16 Sep 2014 18:04:55 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> Hi Neil,
>=20
> On Tue, Sep 16, 2014 at 1:31 AM, NeilBrown <neilb@suse.de> wrote:
> > Now that nfs_release_page() doesn't block indefinitely, other deadlock
> > avoidance mechanisms aren't needed.
> >  - it doesn't hurt for kswapd to block occasionally.  If it doesn't
> >    want to block it would clear __GFP_WAIT.  The current_is_kswapd()
> >    was only added to avoid deadlocks and we have a new approach for
> >    that.
> >  - memory allocation in the SUNRPC layer can very rarely try to
> >    ->releasepage() a page it is trying to handle.  The deadlock
> >    is removed as nfs_release_page() doesn't block indefinitely.
> >
> > So we don't need to set PF_FSTRANS for sunrpc network operations any
> > more.
>=20
> Jeff Layton and I had a little discussion about this earlier today.
> The issue that Jeff raised was that these 1 second waits, although
> they will eventually complete, can nevertheless have a cumulative
> large effect if, say, the reason why we're not making progress is that
> we're being called as part of a socket reconnect attempt in
> xs_tcp_setup_socket().
>=20
> In that case, any attempts to call nfs_release_page() on pages that
> need to use that socket, will result in a 1 second wait, and no
> progress in satisfying the allocation attempt.
>=20
> Our conclusion was that we still need the PF_FSTRANS in order to deal
> with that case, where we need to actually circumvent the new wait in
> order to guarantee progress on the task of allocating and connecting
> the new socket.
>=20
> Comments?

This is the one weak point in the patch that had occurred to me.
What if shrink_page_list() gets a list of pages all in the same NFS file.  =
It
will then spend one second on each of those pages...
It will typically only do 32 pages at a time (I think), but that could still
be rather long.
When I was testing with only one large NFS file, and lots of dirty anon pag=
es
to create the required pressure, I didn't see any evidence of extensive
delays, though it is possible that I didn't look in the right place.

My general feeling is that these deadlocks a very rare and an occasional one
or two second pause is a small price to pay - a price you would be unlikely
to even notice.

However ... something else occurs to me.  We could use the bdi congestion
markers to guide the timeout.
When the wait for PG_private times out, or when a connection re-establishme=
nt
is required (and maybe other similar times) we could set_bdi_congested().
Then in nfs_release_page() we could completely avoid the wait if
bdi_write_congested().

The congestion setting should encourage vmscan away from the filesystem so =
it
won't keep calling nfs_release_page() which is a bonus.

Setting bdi_congestion from the RPC layer might be awkward from a layering
perspective, but probably isn't necessary.

Would the following allay your concerns?  The change to
nfs_inode_remove_request ensures that any congestion is removed when a
'commit' completes.

We certainly could keep the PF_FSTRANS setting in the SUNRPC layer - that w=
as
why it was a separate patch.  It would be nice to find a uniform solution
though.

Thanks,
NeilBrown



diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5949ca37cd18..bc674ad250ce 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -477,10 +477,15 @@ static int nfs_release_page(struct page *page, gfp_t =
gfp)
 	 * benefit that someone else can worry about the freezer.
 	 */
 	if (mapping) {
+		struct nfs_server *nfss =3D NFS_SERVER(mapping->host);
 		nfs_commit_inode(mapping->host, 0);
-		if ((gfp & __GFP_WAIT))
+		if ((gfp & __GFP_WAIT) &&
+		    !bdi_write_congested(&nfss->backing_dev_info))
 			wait_on_page_bit_killable_timeout(page, PG_private,
 							  HZ);
+		if (PagePrivate(page))
+			set_bdi_congested(&nfss->backing_dev_info,
+					  BLK_RW_ASYNC);
 	}
 	/* If PagePrivate() is set, then the page is not freeable */
 	if (PagePrivate(page))
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 700e7a865e6d..3ab122e92c9d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -726,6 +726,7 @@ static void nfs_inode_remove_request(struct nfs_page *r=
eq)
 	struct inode *inode =3D req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi =3D NFS_I(inode);
 	struct nfs_page *head;
+	struct nfs_server *nfss =3D NFS_SERVER(inode);
=20
 	if (nfs_page_group_sync_on_bit(req, PG_REMOVE)) {
 		head =3D req->wb_head;
@@ -742,6 +743,9 @@ static void nfs_inode_remove_request(struct nfs_page *r=
eq)
 		spin_unlock(&inode->i_lock);
 	}
=20
+	if (atomic_long_read(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
+		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
 	if (test_and_clear_bit(PG_INODE_REF, &req->wb_flags))
 		nfs_release_request(req);
 	else

--Sig_/5P2dtBKeAm7hBxjx2=6jlOQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVBjfeTnsnt1WYoG5AQLFGg//eWASqaGZoXe1c5TXj0sh4Mw8kj1HvCdt
YWXaYQGuHBqETkT2rGMKIuCrnLJLQdTieagG/PE52dE9iMyhZM2N1k5NcGd1wOGY
DqVMvYb7cIL5DQu3eAHCu4D4za35mDrU+yWHm+AMQwF3VTS/iqoJEXSQmejg0cO7
dbQDeTiAIKuFahIipC3Xy5yJjI1UhOxu0X5UVwAIrXW+gztyjNYJu0x4XAmjNeHa
hjpB7K23uOEX9QEUVqik6n79cY46XSfMls16U4tyhhtT+Xmol+LHVOqLEa0IiiAE
gL6wh2kdHkVHWQrnnmzBm4a6zRzZNt0B3duUbeiJdWZTCzcOYmume6SXCj98M5wu
er5b9jV1rYttapGLve4cCPqu88SeNYOMeOADCW9eoooUAai+8+utZhVTZEpkCwGr
/xraI1RAuhVfyG3LtZ7BvO410x3472cJJ0+NhMNqApBKT/hQLXzmg0pHXpIklHUZ
O1XfZjPzb9r9StMyxX2rN6igZDnYiLizK1CXP7VfPIMPHnTSmL4paGq3J69rbBHs
6kiFrzexKcB/oH0el/zweIFUleCqEw78XTCg9NCqJ3ZLViLe8IIci4zsHGsLkIJz
i+NP+C/OrDn/qOdqna8ldXdkGL34+vqD+YuxhI9oegrn6ahAIE3fTbcbsOR1cX2E
Sa8GcMyYXz0=
=3vfx
-----END PGP SIGNATURE-----

--Sig_/5P2dtBKeAm7hBxjx2=6jlOQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
