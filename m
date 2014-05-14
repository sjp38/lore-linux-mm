Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id C86456B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 12:18:03 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id j5so3219721qga.28
        for <linux-mm@kvack.org>; Wed, 14 May 2014 09:18:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id g2si1112130qaf.89.2014.05.14.09.18.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 May 2014 09:18:03 -0700 (PDT)
Date: Wed, 14 May 2014 18:17:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140514161755.GQ30445@twins.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XO56YmfyBH8vAq+5"
Content-Disposition: inline
In-Reply-To: <20140514161152.GA2615@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>


--XO56YmfyBH8vAq+5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 14, 2014 at 06:11:52PM +0200, Oleg Nesterov wrote:
> The subsequent discussion was "off-topic", and it seems that the patch
> itself needs a bit more discussion,
>=20
> On 05/13, Peter Zijlstra wrote:
> >
> > On Tue, May 13, 2014 at 01:53:13PM +0100, Mel Gorman wrote:
> > > On Tue, May 13, 2014 at 10:45:50AM +0100, Mel Gorman wrote:
> > > >  void unlock_page(struct page *page)
> > > >  {
> > > > +	wait_queue_head_t *wqh =3D clear_page_waiters(page);
> > > > +
> > > >  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> > > > +
> > > > +	/*
> > > > +	 * No additional barrier needed due to clear_bit_unlock barrierin=
g all updates
> > > > +	 * before waking waiters
> > > > +	 */
> > > >  	clear_bit_unlock(PG_locked, &page->flags);
> > > > -	smp_mb__after_clear_bit();
> > > > -	wake_up_page(page, PG_locked);
> > >
> > > This is wrong.
>=20
> Yes,
>=20
> > > The smp_mb__after_clear_bit() is still required to ensure
> > > that the cleared bit is visible before the wakeup on all architecture=
s.
>=20
> But note that "the cleared bit is visible before the wakeup" is confusing.
> I mean, we do not need mb() before __wake_up(). We need it only because
> __wake_up_bit() checks waitqueue_active().
>=20
>=20
> And at least
>=20
> 	fs/cachefiles/namei.c:cachefiles_delete_object()
> 	fs/block_dev.c:blkdev_get()
> 	kernel/signal.c:task_clear_jobctl_trapping()
> 	security/keys/gc.c:key_garbage_collector()
>=20
> look obviously wrong.
>=20
> I would be happy to send the fix, but do I need to split it per-file?
> Given that it is trivial, perhaps I can send a single patch?

Since its all the same issue a single patch would be fine I think.

--XO56YmfyBH8vAq+5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTc5czAAoJEHZH4aRLwOS6ZNwQAIIP5UclJ7JtAJvlgXqPdn3F
wwpO6YGrqyI/DimRhomNJg6uByMx0LeH+mo7AlkYLhhwm20szkT67aKhjlXmKk04
SphhBEY9np6rs6fjsX5VwUwQjvui3BOKJsaswwyQ3FiarmSGx8XPIiAZ8hhD+QmF
hGaO++ObOjTTPJBE8r09e8YGMUY2tNqfov9H/+11XzVuuMLRWn6sSFtNAgD5GGjt
aeUYTvldd5stk6VVFQYYUg7wyg3P3lYbcy6K9CZ8QdCJvq5FwkKSUboyn04p82rS
disrgPW+vdA/ROjxWxeDV7SbL9OkvfnLwS2AMy3z0wI9iuengy07l4ybCHSF9uhz
tZ0MYSbzSBP/eaGiGPFfHTcMKexOdatnTh5Y3lgwY7ZcZYLi7hjaD4cwzDpY7Bk6
vO1fMxgtYB5wsq9cSaId0zm8JMBCIgdGPacZKxIHBRR1ZXJlkA/76WM2rJxLB0Oh
3Le9zOr7RexZ120X8MpCrRaWhHKVdEXZZfY+1GoSLThLaEnC7tVo09iii0DrgJ9x
OD+naESuFYphAIToqtd4nSVrlrFXAGi8WcPvNiqj3iVTITX/KapV+0CvWJLWFErP
IKFKulnMlj4pSQXY5l3mgoM2bnJ+yAyQPEL553yXKkrAQoWwSDK/zGDleZMiQIv8
DoH+F+EmTyRPw9R0ZEPs
=mi+k
-----END PGP SIGNATURE-----

--XO56YmfyBH8vAq+5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
