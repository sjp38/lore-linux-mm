Subject: Re: [PATCH] remove throttle_vm_writeout()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1IdjOa-0002qg-00@dorka.pomaz.szeredi.hu>
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
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sTHr541QelHxWYI4WmLX"
Date: Fri, 05 Oct 2007 11:47:03 +0200
Message-Id: <1191577623.22357.69.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=-sTHr541QelHxWYI4WmLX
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-10-05 at 11:22 +0200, Miklos Szeredi wrote:
> > So how do we end up with more writeback pages than that? should we teac=
h
> > pdflush about these limits as well?
>=20
> Ugh.
>=20
> I think we should rather fix vmscan to not spin when all pages of a
> zone are already under writeout.  Which is the _real_ problem,
> according to Andrew.



diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 4ef4d22..eff2438 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -88,7 +88,7 @@ static inline void wait_on_inode(struct inode *inode)
 int wakeup_pdflush(long nr_pages);
 void laptop_io_completion(void);
 void laptop_sync_completion(void);
-void throttle_vm_writeout(gfp_t gfp_mask);
+void throttle_vm_writeout(struct zone *zone, gfp_t gfp_mask);
=20
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index eec1481..f949997 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -326,11 +326,8 @@ void balance_dirty_pages_ratelimited_nr(struct address=
_space *mapping,
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
=20
-void throttle_vm_writeout(gfp_t gfp_mask)
+void throttle_vm_writeout(struct zone *zone, gfp_t gfp_mask)
 {
-	long background_thresh;
-	long dirty_thresh;
-
 	if ((gfp_mask & (__GFP_FS|__GFP_IO)) !=3D (__GFP_FS|__GFP_IO)) {
 		/*
 		 * The caller might hold locks which can prevent IO completion
@@ -342,17 +339,16 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 	}
=20
         for ( ; ; ) {
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		unsigned long thresh =3D zone_page_state(zone, NR_ACTIVE) +
+			zone_page_state(zone, NR_INACTIVE);
=20
-                /*
-                 * Boost the allowable dirty threshold a bit for page
-                 * allocators so they don't get DoS'ed by heavy writers
-                 */
-                dirty_thresh +=3D dirty_thresh / 10;      /* wheeee... */
+		/*
+		 * wait when 75% of the zone's pages are under writeback
+		 */
+		thresh -=3D thresh >> 2;
+		if (zone_page_state(zone, NR_WRITEBACK) < thresh)
+			break;
=20
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <=3D dirty_thresh)
-                        	break;
                 congestion_wait(WRITE, HZ/10);
         }
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1be5a63..7dd6bd9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -948,7 +948,7 @@ static unsigned long shrink_zone(int priority, struct z=
one *zone,
 		}
 	}
=20
-	throttle_vm_writeout(sc->gfp_mask);
+	throttle_vm_writeout(zone, sc->gfp_mask);
=20
 	atomic_dec(&zone->reclaim_in_progress);
 	return nr_reclaimed;


--=-sTHr541QelHxWYI4WmLX
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHBggXXA2jU0ANEf4RAoYxAJ0SsPUjcXeXb4YNTjDKwSqGJ/vtQwCfaqfU
FhuArBz9ahCcgdqUfMFP97w=
=ADs0
-----END PGP SIGNATURE-----

--=-sTHr541QelHxWYI4WmLX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
