Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 200DD6B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 18:47:53 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so1259945eek.3
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:47:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s46si5279907eeg.75.2014.04.23.15.47.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 15:47:51 -0700 (PDT)
Date: Thu, 24 Apr 2014 08:47:40 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 1/5] MM: avoid throttling reclaim for loop-back nfsd
 threads.
Message-ID: <20140424084740.44a416e4@notabene.brown>
In-Reply-To: <20140423150318.d4bcf234faa5bea7fcb57b9b@linux-foundation.org>
References: <20140423022441.4725.89693.stgit@notabene.brown>
	<20140423024058.4725.71995.stgit@notabene.brown>
	<20140423150318.d4bcf234faa5bea7fcb57b9b@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/gVq0EJx4uYNh11lkimZo1pT"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Mel Gorman <mgorman@suse.com>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

--Sig_/gVq0EJx4uYNh11lkimZo1pT
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 23 Apr 2014 15:03:18 -0700 Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Wed, 23 Apr 2014 12:40:58 +1000 NeilBrown <neilb@suse.de> wrote:
>=20
> > When a loop-back NFS mount is active and the backing device for the
> > NFS mount becomes congested, that can impose throttling delays on the
> > nfsd threads.
> >=20
> > These delays significantly reduce throughput and so the NFS mount
> > remains congested.
> >=20
> > This results in a live lock and the reduced throughput persists.
> >=20
> > This live lock has been found in testing with the 'wait_iff_congested'
> > call, and could possibly be caused by the 'congestion_wait' call.
> >=20
> > This livelock is similar to the deadlock which justified the
> > introduction of PF_LESS_THROTTLE, and the same flag can be used to
> > remove this livelock.
> >=20
> > To minimise the impact of the change, we still throttle nfsd when the
> > filesystem it is writing to is congested, but not when some separate
> > filesystem (e.g. the NFS filesystem) is congested.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  mm/vmscan.c |   18 ++++++++++++++++--
> >  1 file changed, 16 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a9c74b409681..e011a646de95 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1424,6 +1424,18 @@ putback_inactive_pages(struct lruvec *lruvec, st=
ruct list_head *page_list)
> >  	list_splice(&pages_to_free, page_list);
> >  }
> > =20
> > +/* If a kernel thread (such as nfsd for loop-back mounts) services
>=20
> /*
>  * If ...
>=20
> please
>=20
> > + * a backing device by writing to the page cache it sets PF_LESS_THROT=
TLE.
> > + * In that case we should only throttle if the backing device it is
> > + * writing to is congested.  In other cases it is safe to throttle.
> > + */
> > +static int current_may_throttle(void)
> > +{
> > +	return !(current->flags & PF_LESS_THROTTLE) ||
> > +		current->backing_dev_info =3D=3D NULL ||
> > +		bdi_write_congested(current->backing_dev_info);
> > +}
> > +
> >  /*
> >   * shrink_inactive_list() is a helper for shrink_zone().  It returns t=
he number
> >   * of reclaimed pages
> > @@ -1552,7 +1564,8 @@ shrink_inactive_list(unsigned long nr_to_scan, st=
ruct lruvec *lruvec,
> >  		 * implies that pages are cycling through the LRU faster than
> >  		 * they are written so also forcibly stall.
> >  		 */
> > -		if (nr_unqueued_dirty =3D=3D nr_taken || nr_immediate)
> > +		if ((nr_unqueued_dirty =3D=3D nr_taken || nr_immediate)
> > +		    && current_may_throttle())
>=20
> 	foo &&
> 	bar
>=20
> please.  As you did in in current_may_throttle().
>=20
> >  			congestion_wait(BLK_RW_ASYNC, HZ/10);
> >  	}
> > =20
> > @@ -1561,7 +1574,8 @@ shrink_inactive_list(unsigned long nr_to_scan, st=
ruct lruvec *lruvec,
> >  	 * is congested. Allow kswapd to continue until it starts encountering
> >  	 * unqueued dirty pages or cycling through the LRU too quickly.
> >  	 */
> > -	if (!sc->hibernation_mode && !current_is_kswapd())
> > +	if (!sc->hibernation_mode && !current_is_kswapd()
> > +	    && current_may_throttle())
>=20
> ditto
>=20
> >  		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> > =20
> >  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
> >=20

Thanks.  I've made those changes and will resend just that patch.
As it is quite independent of all the others can you take it and I'll funnel
the others through other trees?

Thanks
NeilBrown

--Sig_/gVq0EJx4uYNh11lkimZo1pT
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU1hDDDnsnt1WYoG5AQI9jA/+NXYdoiGvtJCey8EL55LIltoj0t/pgFUp
HJ5LMxkQnY0AHZ6NarrHHPDmktCPlPjOjYpPEU/yWb8V5nZZQOQ7vv/LRsun14Ck
vCMRG43Et2jJS5bALtp0FuePSp2vXQld+H4ol4fEbFQIkcJNVr58Z01aXinpPGUx
YeNJpPMY6IJC72V646YaQ2ET8SOAYwaDqrOA0S+KNj5QMsycfPpI9Ww4Lkf418tc
J/UGAbecXLvOTZFQB+fe9asg8QWZtL586XPkz8oN6de4YMcPEsNV15hyKfvpkvxG
fgoipV7cwuRE18OiYuwdHt7ZG6PBBgEdpElaX4Indn+XFB8ThdRFhxlGJQ5mkVKB
CFY/hl4vTL7BtjYLanHxyjbIhFLs7alDOLhrrw3Crd2j3PDGiMdGvSEec+khK4GE
AaSHsWom14YpQe4qert6wm87jDSwxV5rzh9GdieaL+p39q4JUmPVo7WAEyBY7uvT
DZHcbvBMz1aDn91D8Ay00O33RmH31hhfeqPUIPFpYcLSr51mjwfvOFeRmXEEbWWU
fZlVCOUjXyZiUofxm9qIwGWq7dg1QmOouIpfrEO2Cv9wngSq4iLaCJ0pzvq+xLe1
rn8YOSf5uyCVD8vkjRon7omxRDWX03ZlPrI4KC1kurszo9bzIR2sDh7KHZlgrBht
qVoODT+cRGI=
=i294
-----END PGP SIGNATURE-----

--Sig_/gVq0EJx4uYNh11lkimZo1pT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
