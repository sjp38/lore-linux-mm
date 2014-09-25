Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 702F06B0037
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 23:23:55 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id gq15so11710301lab.39
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 20:23:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb1si621378lbc.139.2014.09.24.20.23.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 20:23:53 -0700 (PDT)
Date: Thu, 25 Sep 2014 13:23:39 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 1/5] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-ID: <20140925132339.2629ffaa@notabene.brown>
In-Reply-To: <20140924070418.GA990@gmail.com>
References: <20140924012422.4838.29188.stgit@notabene.brown>
	<20140924012832.4838.59410.stgit@notabene.brown>
	<20140924070418.GA990@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/3F0C5Wh1afvW5ZV7Em7amCB"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

--Sig_/3F0C5Wh1afvW5ZV7Em7amCB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 24 Sep 2014 09:04:18 +0200 Ingo Molnar <mingo@kernel.org> wrote:

>=20
> * NeilBrown <neilb@suse.de> wrote:
>=20
> > @@ -859,6 +860,8 @@ int wake_bit_function(wait_queue_t *wait, unsigned =
mode, int sync, void *key);
> > =20
> >  extern int bit_wait(struct wait_bit_key *);
> >  extern int bit_wait_io(struct wait_bit_key *);
> > +extern int bit_wait_timeout(struct wait_bit_key *);
> > +extern int bit_wait_io_timeout(struct wait_bit_key *);
> > =20
> >  /**
> >   * wait_on_bit - wait for a bit to be cleared
> > diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> > index 15cab1a4f84e..380678b3cba4 100644
> > --- a/kernel/sched/wait.c
> > +++ b/kernel/sched/wait.c
> > @@ -343,6 +343,18 @@ int __sched out_of_line_wait_on_bit(void *word, in=
t bit,
> >  }
> >  EXPORT_SYMBOL(out_of_line_wait_on_bit);
> > =20
> > +int __sched out_of_line_wait_on_bit_timeout(
> > +	void *word, int bit, wait_bit_action_f *action,
> > +	unsigned mode, unsigned long timeout)
> > +{
> > +	wait_queue_head_t *wq =3D bit_waitqueue(word, bit);
> > +	DEFINE_WAIT_BIT(wait, word, bit);
> > +
> > +	wait.key.timeout =3D jiffies + timeout;
> > +	return __wait_on_bit(wq, &wait, action, mode);
> > +}
> > +EXPORT_SYMBOL(out_of_line_wait_on_bit_timeout);
> > +
> >  int __sched
> >  __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
> >  			wait_bit_action_f *action, unsigned mode)
> > @@ -520,3 +532,27 @@ __sched int bit_wait_io(struct wait_bit_key *word)
> >  	return 0;
> >  }
> >  EXPORT_SYMBOL(bit_wait_io);
> > +
> > +__sched int bit_wait_timeout(struct wait_bit_key *word)
> > +{
> > +	unsigned long now =3D ACCESS_ONCE(jiffies);
> > +	if (signal_pending_state(current->state, current))
> > +		return 1;
> > +	if (time_after_eq(now, word->timeout))
> > +		return -EAGAIN;
> > +	schedule_timeout(word->timeout - now);
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL(bit_wait_timeout);
> > +
> > +__sched int bit_wait_io_timeout(struct wait_bit_key *word)
> > +{
> > +	unsigned long now =3D ACCESS_ONCE(jiffies);
> > +	if (signal_pending_state(current->state, current))
> > +		return 1;
> > +	if (time_after_eq(now, word->timeout))
> > +		return -EAGAIN;
> > +	io_schedule_timeout(word->timeout - now);
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL(bit_wait_io_timeout);
>=20
> New scheduler APIs should be exported via EXPORT_SYMBOL_GPL().
>=20

Fine with me.

 Trond, can you just edit that into the patch you have, or do you want me to
 re-send?
 Also maybe added Jeff's=20
    Acked-by: Jeff Layton <jlayton@primarydata.com>
 to the NFS bits.

Thanks,
NeilBrown

--Sig_/3F0C5Wh1afvW5ZV7Em7amCB
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCOKuznsnt1WYoG5AQJlnQ//eLcFQi2fKy0WKO5U61vvbWwEX1myaR3j
kJbbNOxgDWPIwzncSyOIKjWKZGOPZH2lZ0gkt9aDcdPYld8XTaEertxdSflQaR0j
RZJO/Bx3PTc2hfHe0isBDkIL7wZocvxQe8jFee0rk9blX1ymkAhMb6Q/Vom5Ve8M
gelRn5nxQV4DYjoV/SyqcTPpE87+lAz+N7dMdFSo0y0zkGXsyBrkOoLKYkExDFIE
UBN2xOkzPaPKLT8ZZalzJgZGc28q7Cx+AHv22fDKCb9HDlaKc4zWJuOCkUgX9qun
s/KjeXx/El7xO+OYJDGADBHrS6g6pDnNpXcqGuRDmAsXsthnxkCBiRMuUgoRHMVf
eNdidRZcMHq99qHJAh48BrxdbjY2wqQcbG0BN4JB7KWzHJy2xhqnzQZM35ra3RqL
+XkR+UpC/hgHbEABYIHQbzN5Stf5bTc8uqthIMVyKQjHNJJABFrYGz9cblTCzSBX
cz2BwGQSB+DcFUjPaIiPMPe5bhFGB4eAlWBDhkqrmlbz/osHFjSjvorYrEJ5iarQ
4MAa7DnsTp0ak7lUI2sDBo5PjJX7mgsXTY0wnjUxLKIQVaIrPWPQ30NsT+TFuikk
Nrpp7TVu7i+oa1paciJJC2ff/QLHWKkqcLsMj7F2eJ4/6vkeTM+oHI67ViI9wtyj
W6sNGpRVqqw=
=5m/y
-----END PGP SIGNATURE-----

--Sig_/3F0C5Wh1afvW5ZV7Em7amCB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
