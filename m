Subject: Re: [PATCH] remove throttle_vm_writeout()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1IdkOf-0002tK-00@dorka.pomaz.szeredi.hu>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	 <20071004145640.18ced770.akpm@linux-foundation.org>
	 <E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
	 <20071004160941.e0c0c7e5.akpm@linux-foundation.org>
	 <E1Ida56-0002Zz-00@dorka.pomaz.szeredi.hu>
	 <20071004164801.d8478727.akpm@linux-foundation.org>
	 <E1Idanu-0002c1-00@dorka.pomaz.szeredi.hu>
	 <20071004174851.b34a3220.akpm@linux-foundation.org>
	 <1191572520.22357.42.camel@twins>
	 <E1IdjOa-0002qg-00@dorka.pomaz.szeredi.hu>
	 <1191577623.22357.69.camel@twins>
	 <E1IdkOf-0002tK-00@dorka.pomaz.szeredi.hu>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xvWACWmAD7yJCd1FfN9E"
Date: Fri, 05 Oct 2007 12:57:34 +0200
Message-Id: <1191581854.22357.85.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

--=-xvWACWmAD7yJCd1FfN9E
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-10-05 at 12:27 +0200, Miklos Szeredi wrote:
> > diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> > index 4ef4d22..eff2438 100644
> > --- a/include/linux/writeback.h
> > +++ b/include/linux/writeback.h
> > @@ -88,7 +88,7 @@ static inline void wait_on_inode(struct inode *inode)
> >  int wakeup_pdflush(long nr_pages);
> >  void laptop_io_completion(void);
> >  void laptop_sync_completion(void);
> > -void throttle_vm_writeout(gfp_t gfp_mask);
> > +void throttle_vm_writeout(struct zone *zone, gfp_t gfp_mask);
> > =20
> >  /* These are exported to sysctl. */
> >  extern int dirty_background_ratio;
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index eec1481..f949997 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -326,11 +326,8 @@ void balance_dirty_pages_ratelimited_nr(struct add=
ress_space *mapping,
> >  }
> >  EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
> > =20
> > -void throttle_vm_writeout(gfp_t gfp_mask)
> > +void throttle_vm_writeout(struct zone *zone, gfp_t gfp_mask)
> >  {
> > -	long background_thresh;
> > -	long dirty_thresh;
> > -
> >  	if ((gfp_mask & (__GFP_FS|__GFP_IO)) !=3D (__GFP_FS|__GFP_IO)) {
> >  		/*
> >  		 * The caller might hold locks which can prevent IO completion
> > @@ -342,17 +339,16 @@ void throttle_vm_writeout(gfp_t gfp_mask)
> >  	}
> > =20
> >          for ( ; ; ) {
> > -		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
> > +		unsigned long thresh =3D zone_page_state(zone, NR_ACTIVE) +
> > +			zone_page_state(zone, NR_INACTIVE);
> > =20
> > -                /*
> > -                 * Boost the allowable dirty threshold a bit for page
> > -                 * allocators so they don't get DoS'ed by heavy writer=
s
> > -                 */
> > -                dirty_thresh +=3D dirty_thresh / 10;      /* wheeee...=
 */
> > +		/*
> > +		 * wait when 75% of the zone's pages are under writeback
> > +		 */
> > +		thresh -=3D thresh >> 2;
> > +		if (zone_page_state(zone, NR_WRITEBACK) < thresh)
> > +			break;
> > =20
> > -                if (global_page_state(NR_UNSTABLE_NFS) +
> > -			global_page_state(NR_WRITEBACK) <=3D dirty_thresh)
> > -                        	break;
> >                  congestion_wait(WRITE, HZ/10);
> >          }
> >  }
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 1be5a63..7dd6bd9 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -948,7 +948,7 @@ static unsigned long shrink_zone(int priority, stru=
ct zone *zone,
> >  		}
> >  	}
> > =20
> > -	throttle_vm_writeout(sc->gfp_mask);
> > +	throttle_vm_writeout(zone, sc->gfp_mask);
> > =20
> >  	atomic_dec(&zone->reclaim_in_progress);
> >  	return nr_reclaimed;
> >=20
> >=20
>=20
> I think that's an improvement in all respects.
>=20
> However it still does not generally address the deadlock scenario: if
> there's a small DMA zone, and fuse manages to put all of those pages
> under writeout, then there's trouble.
>=20
> But it's not really fuse specific.  If it was a normal filesystem that
> did that, and it needed a GFP_DMA allocation for writeout, it is in
> trouble also, as that allocation would fail (at least no deadlock).
>=20
> Or is GFP_DMA never used by fs/io writeout paths?

I agree that its not complete. (hence the lack of sign-off etc.)

'normally' writeback pages just need an interrupt to signal the stuff is
written back. ie. the writeback completion path is atomic.=20

 [ result of the thinking below -- the above is esp. true for swap pages
   - so maybe we should ensure that !swap traffic can never exceed this
   75% - that way, swap can always us get out of a tight spot ]

Maybe we should make that a requirement, although I see how that becomes
rather hard for FUSE (which is where Andrews PF_MEMALLOC suggestion
comes from - but I really dislike PF_MEMALLOC exposed to userspace).

Limiting FUSE to say 50% (suggestion from your other email) sounds like
a horrible hack to me. - Need more time to think on this.

.. o O [ process of thinking ]

While I think, I might as well tell the problem I had with
throttle_vm_writeout(), which is nfs unstable pages. Those don't go away
by waiting for it - as throttle_vm_writeout() does. So once you have an
excess of those, you're stuck as well.

In this patch I totally ignored unstable, but I'm not sure that's the
proper thing to do, I'd need to figure out what happens to an unstable
page when passed into pageout() - or if its passed to pageout at all.

If unstable pages would be passed to pageout(), and it would properly
convert them to writeback and clean them, then there is nothing wrong.

(Trond?)



--=-xvWACWmAD7yJCd1FfN9E
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHBhieXA2jU0ANEf4RAhQLAKCOECcWGNMIQv5oxPKeuAgBJNLVCACdEJis
KGQMii+1Ea2ch8pZZ3i3kf4=
=X8Li
-----END PGP SIGNATURE-----

--=-xvWACWmAD7yJCd1FfN9E--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
