Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EFD576B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 12:10:07 -0500 (EST)
Subject: Re: [PATCH 05/13] VM/NFS: The VM must tell the filesystem when to
 free reclaimable pages
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20100215055533.GF5723@laptop>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
	 <20100215055533.GF5723@laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 15 Feb 2010 12:09:49 -0500
Message-ID: <1266253789.2911.107.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-02-15 at 16:55 +1100, Nick Piggin wrote:=20
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index c06739b..6a0aec7 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -503,6 +503,7 @@ static void balance_dirty_pages(struct address_spac=
e *mapping,
> >  			.nr_to_write	=3D write_chunk,
> >  			.range_cyclic	=3D 1,
> >  		};
> > +		long bdi_nr_unstable =3D 0;
> > =20
> >  		get_dirty_limits(&background_thresh, &dirty_thresh,
> >  				&bdi_thresh, bdi);
> > @@ -512,8 +513,10 @@ static void balance_dirty_pages(struct address_spa=
ce *mapping,
> >  		nr_writeback =3D global_page_state(NR_WRITEBACK);
> > =20
> >  		bdi_nr_reclaimable =3D bdi_stat(bdi, BDI_DIRTY);
> > -		if (bdi_cap_account_unstable(bdi))
> > -			bdi_nr_reclaimable +=3D bdi_stat(bdi, BDI_UNSTABLE);
> > +		if (bdi_cap_account_unstable(bdi)) {
> > +			bdi_nr_unstable =3D bdi_stat(bdi, BDI_UNSTABLE);
> > +			bdi_nr_reclaimable +=3D bdi_nr_unstable;
> > +		}
> >  		bdi_nr_writeback =3D bdi_stat(bdi, BDI_WRITEBACK);
> > =20
> >  		if (bdi_nr_reclaimable + bdi_nr_writeback <=3D bdi_thresh)
> > @@ -541,6 +544,11 @@ static void balance_dirty_pages(struct address_spa=
ce *mapping,
> >  		 * up.
> >  		 */
> >  		if (bdi_nr_reclaimable > bdi_thresh) {
> > +			wbc.force_commit_unstable =3D 0;
> > +			/* Force NFS to also free up unstable writes. */
> > +			if (bdi_nr_unstable > bdi_nr_reclaimable / 2)
> > +				wbc.force_commit_unstable =3D 1;
>=20
> This seems like it is putting NFS specific logic into the VM. OK,
> we already have it because we have these unstable pages, but all
> we really cared about before is that dirty+unstable ~=3D reclaimable.
>=20
> Shouldn't NFS just work out its ratio of dirty and unstable pages
> and just do the right thing in its writeback path?
>=20

Part of the problem is that balance_dirty_pages is looking at per-bdi
statistics, whereas the NFS layer is being called back on an
inode-by-inode basis.
Doing a per-bdi calculation every time we get called back in write_inode
is possible, but can be very inefficient for workloads that involve
writing to several files in parallel. In contrast, all we're really
adding to the VM layer here is a single extra comparison.

The issue here is that the VM wants to do non-blocking I/O using
WB_SYNC_NONE to write out the data. While that is well defined as far as
writeback of dirty pages is concerned, it is difficult to figure a
strategy for handling repeated calls to write_inode().

If we send a 'commit' rpc call every time the balance_dirty_pages loop,
or the bdi_writeback thread triggers a call to write_inode(), then we
end up causing the server to sync its pagecache to disk when we've only
managed to send it a few dirty pages.
We've tried adding a heuristic in the NFS layer that says it should
issue a commit when it sees that there are no more writes in flight for
that inode. However when we do so, we see that balance_dirty_pages ends
up spinning while the last few writes are being sent off.

The point of the extra 'force_commit_unstable' knob is that it allows
the caller to tell the NFS layer that we've written out enough dirty
pages, and that as far as the VM is concerned we can best make progress
by attacking the pileup of unstable writes. As I said above, that can be
done using a single extra comparison in the balance_dirty_pages, instead
of redoing the entire calculation for each inode called by
writeback_inodes_wbc(). Furthermore, it means that the bdi_writeback
thread can continue to do opportunistic writebacks without triggering a
lot of unnecessary flushes on the server.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
