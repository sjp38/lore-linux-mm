Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id CDC666B0035
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 23:12:32 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id w7so1000222lbi.4
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 20:12:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z6si26664742lbi.93.2014.09.16.20.12.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 20:12:30 -0700 (PDT)
Date: Wed, 17 Sep 2014 13:12:18 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 4/4] NFS/SUNRPC: Remove other deadlock-avoidance
 mechanisms in nfs_release_page()
Message-ID: <20140917131218.4f664002@notabene.brown>
In-Reply-To: <CAHQdGtST5nEE-Wh99vKLNPsOHc_pSgau4om7dWr+GhfLauFBnA@mail.gmail.com>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916053135.22257.46476.stgit@notabene.brown>
	<CAHQdGtQbFtLFEpzgqoMoLiG7-Y0FdFiZdpS4dgkT7hsCnqMiPA@mail.gmail.com>
	<20140917111017.499eb3a9@notabene.brown>
	<CAHQdGtST5nEE-Wh99vKLNPsOHc_pSgau4om7dWr+GhfLauFBnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/n0z0uzqpRGjsQka7TYj+pkv"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Devel FS Linux <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Linux Kernel mailing list <linux-kernel@vger.kernel.org>, Jeff Layton <jeff.layton@primarydata.com>

--Sig_/n0z0uzqpRGjsQka7TYj+pkv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 16 Sep 2014 21:32:43 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Tue, Sep 16, 2014 at 9:10 PM, NeilBrown <neilb@suse.de> wrote:
> >
> > However ... something else occurs to me.  We could use the bdi congesti=
on
> > markers to guide the timeout.
> > When the wait for PG_private times out, or when a connection re-establi=
shment
> > is required (and maybe other similar times) we could set_bdi_congested(=
).
> > Then in nfs_release_page() we could completely avoid the wait if
> > bdi_write_congested().
> >
> > The congestion setting should encourage vmscan away from the filesystem=
 so it
> > won't keep calling nfs_release_page() which is a bonus.
> >
> > Setting bdi_congestion from the RPC layer might be awkward from a layer=
ing
> > perspective, but probably isn't necessary.
> >
> > Would the following allay your concerns?  The change to
> > nfs_inode_remove_request ensures that any congestion is removed when a
> > 'commit' completes.
> >
> > We certainly could keep the PF_FSTRANS setting in the SUNRPC layer - th=
at was
> > why it was a separate patch.  It would be nice to find a uniform soluti=
on
> > though.
> >
> > Thanks,
> > NeilBrown
> >
> >
> >
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 5949ca37cd18..bc674ad250ce 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -477,10 +477,15 @@ static int nfs_release_page(struct page *page, gf=
p_t gfp)
> >          * benefit that someone else can worry about the freezer.
> >          */
> >         if (mapping) {
> > +               struct nfs_server *nfss =3D NFS_SERVER(mapping->host);
> >                 nfs_commit_inode(mapping->host, 0);
> > -               if ((gfp & __GFP_WAIT))
> > +               if ((gfp & __GFP_WAIT) &&
> > +                   !bdi_write_congested(&nfss->backing_dev_info))
> >                         wait_on_page_bit_killable_timeout(page, PG_priv=
ate,
> >                                                           HZ);
> > +               if (PagePrivate(page))
> > +                       set_bdi_congested(&nfss->backing_dev_info,
> > +                                         BLK_RW_ASYNC);
> >         }
> >         /* If PagePrivate() is set, then the page is not freeable */
> >         if (PagePrivate(page))
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index 700e7a865e6d..3ab122e92c9d 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -726,6 +726,7 @@ static void nfs_inode_remove_request(struct nfs_pag=
e *req)
> >         struct inode *inode =3D req->wb_context->dentry->d_inode;
> >         struct nfs_inode *nfsi =3D NFS_I(inode);
> >         struct nfs_page *head;
> > +       struct nfs_server *nfss =3D NFS_SERVER(inode);
> >
> >         if (nfs_page_group_sync_on_bit(req, PG_REMOVE)) {
> >                 head =3D req->wb_head;
> > @@ -742,6 +743,9 @@ static void nfs_inode_remove_request(struct nfs_pag=
e *req)
> >                 spin_unlock(&inode->i_lock);
> >         }
> >
> > +       if (atomic_long_read(&nfss->writeback) < NFS_CONGESTION_OFF_THR=
ESH)
> > +               clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASY=
NC);
>=20
> Hmm.... We already have this equivalent functionality in
> nfs_end_page_writeback(), so adding it to nfs_inode_remove_request()
> is just causing duplication as far as the stable writeback path is
> concerned. How about adding it to nfs_commit_release_pages() instead?
>=20
> Otherwise, yes, the above does indeed look at if it has merit. Have
> you got a good test?
>=20

Altered patch below.  I'll post a proper one after some testing.

For testing I create a memory pressure load with:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
#!/bin/bash

umount /mnt/ramdisk
umount /mnt/ramdisk
mount -t tmpfs -o size=3D4G none /mnt/ramdisk
#swapoff -a

i=3D0
while [ $i -le 10000 ]; do
        i=3D$(($i+1))
        dd if=3D/dev/zero of=3D/mnt/ramdisk/testdata.dd bs=3D1M count=3D6500
	date
done
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D

Where the '4G' matches memory size, and then write out to an NFS file with

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
#!/bin/bash

umount /mnt2 /mnt3
umount /mnt2 /mnt3
mount /dev/sdd /mnt2
exportfs -avu
exportfs -av
mount $* 127.0.0.1:/mnt2 /mnt3
for j in {1..100}; do
i=3D1
while [ $i -le 10000 ]; do
        echo "Step $i"
        date +%H:%M:%S
        i=3D$(($i+1))
        zcat /boot/vmlinux-3.13.3-1-desktop.gz | uuencode -
        date +%H:%M:%S
done | dd of=3D/mnt3/testdat.file bs=3D1M

done
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Pick your own way to create a large file of random data .. though
probably /dev/zero would do.

With both those going for a few hours the current kernel will deadlock.
With my patches it doesn't.
I'll see if I can come up with some way to measure maximum delay in
try_to_free_pages() and see how the 'congestion' change affects that.

Thanks,
NeilBrown


----------------------
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
index 700e7a865e6d..8d4aae9d977a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1641,6 +1641,7 @@ static void nfs_commit_release_pages(struct nfs_commi=
t_data *data)
 	struct nfs_page	*req;
 	int status =3D data->task.tk_status;
 	struct nfs_commit_info cinfo;
+	struct nfs_server *nfss;
=20
 	while (!list_empty(&data->pages)) {
 		req =3D nfs_list_entry(data->pages.next);
@@ -1674,6 +1675,10 @@ static void nfs_commit_release_pages(struct nfs_comm=
it_data *data)
 	next:
 		nfs_unlock_and_release_request(req);
 	}
+	nfss =3D NFS_SERVER(data->inode);
+	if (atomic_long_read(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
+		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
 	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
 	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
 		nfs_commit_clear_lock(NFS_I(data->inode));


--Sig_/n0z0uzqpRGjsQka7TYj+pkv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVBj8Eznsnt1WYoG5AQKiIA//UcZTKMBavmJWLxEFzfQTZCqphxVdZ460
NME8/FhDW5kyjv1vnuVSJIisnxUxDvhMih0ZCqZjs50lsHY8+hXhtrYPMt7Jha7A
n46o1TIXn/U1c9iSBV3juo5riwOEaeaU1AF8fV5FwRkhw2aXglg48atozNqg6lmL
kqFuP5TDPxNk1bDozZrNgj4iQ5a2rdF+6DfYI5DhHoaUpdD4UUNT2cz5oX/V84fM
B4z7p9Kmx5UA9dXaryMmEa48YHOd6deUSA44MEx4+4f7+pqdlB1aAeGkknDL7saA
0E9yb3xrs5Mnih7PoJQs50388RJ+js7iYI7A0JAABvhNa3TgLcUTGTaQdkGxgVrf
3Gff7YaLyM/EPvoaMbgHsRaPV/FU6UZQAVkDbjPH6tMO10Bpyv+BecvTzhV5h31E
wBKpKbOoVbK0iXqT4NkG4VMEoxc8ZeP3vYmiZzua5dMH+T4nMbEJWNbzq7Nosw3a
yYBJ9s/lo7xXFtLcxkmUaRQn/UMTesf1tvFunlATsBnMTz32nlYVCK4XiFf541pQ
DyvUoJZeWrf54X+J3QUZ7aGfNfRWev9pGMzxXVkjuXkpVHnVrL0RWQjvqoh19skC
MHldEIZ22/XXqBuImzp6JTxPov5fA182cu1/NHZvhP39K/istW5ktwbHVRA6HDul
Un8XpG+L2iQ=
=6Lhc
-----END PGP SIGNATURE-----

--Sig_/n0z0uzqpRGjsQka7TYj+pkv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
