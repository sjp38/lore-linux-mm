Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2616B0038
	for <linux-mm@kvack.org>; Tue, 13 May 2014 07:09:59 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id l6so168921qcy.37
        for <linux-mm@kvack.org>; Tue, 13 May 2014 04:09:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v6si7528381qas.68.2014.05.13.04.09.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 04:09:59 -0700 (PDT)
Date: Tue, 13 May 2014 13:09:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 17/19] fs: buffer: Do not use unnecessary atomic
 operations when discarding buffers
Message-ID: <20140513110951.GB30445@twins.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-18-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cKagJxsNNshY2zoa"
Content-Disposition: inline
In-Reply-To: <1399974350-11089-18-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>


--cKagJxsNNshY2zoa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 13, 2014 at 10:45:48AM +0100, Mel Gorman wrote:
> Discarding buffers uses a bunch of atomic operations when discarding buff=
ers
> because ...... I can't think of a reason. Use a cmpxchg loop to clear all=
 the
> necessary flags. In most (all?) cases this will be a single atomic operat=
ions.
>=20
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  fs/buffer.c                 | 14 +++++++++-----
>  include/linux/buffer_head.h |  5 +++++
>  2 files changed, 14 insertions(+), 5 deletions(-)
>=20
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 9ddb9fc..e80012d 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -1485,14 +1485,18 @@ EXPORT_SYMBOL(set_bh_page);
>   */
>  static void discard_buffer(struct buffer_head * bh)
>  {
> +	unsigned long b_state, b_state_old;
> +
>  	lock_buffer(bh);
>  	clear_buffer_dirty(bh);
>  	bh->b_bdev =3D NULL;
> -	clear_buffer_mapped(bh);
> -	clear_buffer_req(bh);
> -	clear_buffer_new(bh);
> -	clear_buffer_delay(bh);
> -	clear_buffer_unwritten(bh);
> +	b_state =3D bh->b_state;
> +	for (;;) {
> +		b_state_old =3D cmpxchg(&bh->b_state, b_state, (b_state & ~BUFFER_FLAG=
S_DISCARD));
> +		if (b_state_old =3D=3D b_state)
> +			break;
> +		b_state =3D b_state_old;
> +	}
>  	unlock_buffer(bh);
>  }

So.. I'm soon going to introduce atomic_{or,and}() and
atomic64_{or,and}() across the board, but of course this isn't an
atomic_long_t but a regular unsigned long.

Its a bit unfortunate we have this discrepancy with types vs atomic ops,
there's:

  cmpxchg, xchg -- mostly available for all 1,2,3,4 (and 8 where
  appropriate) byte values.

  bitops -- operate on unsigned long *

  atomic* -- operate on atomic_*t


So while ideally we'd be able to use the unconditional atomic and
operation which is available on a lot of architectures, we'll be stuck
with a cmpxchg loop instead :/

*sigh*

Anyway, nothing wrong with this patch, however, you could, if you really
wanted to push things, also include BH_Lock in that clear :-)

--cKagJxsNNshY2zoa
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTcf1/AAoJEHZH4aRLwOS6e6MQAJeE8ZLuMHpPAJXrw8YA3XXT
bFlz7fKAz4jiL8bmYX5/i291Uj2y1QBN573RtI8hl5ttdVo7UK3ugWVjEFeGxphA
OGq6REJMxEZMDFcXGuXhelOvD5Sds92/WkcvLaGTTk6ua/0aS+fpzYZ7nyRrMp1w
+qZtZvcFhQxj0WxZPbyhbtjdampbycXbdeNW8p5or5pXNosvRzeRS3LP9GTABDVF
fqQYhDk1RmMN59qywPIiFR3Q9yRr7XkyQ92Xr+K2rnXgioXi0won3GYS/dLso7Oe
WAc8SkoLec0tVyIl71JGhvpKkS+/osWyOpJtZ3A6dpe9Vy0uzp/XT9ck1ZG2QtmY
kk4ylu9uBAdhJG+KDAVBQqqzbyI2IzFrVq4jzL27vwAsCd5Jw26o3LB0ZI9befG/
elmuD+x7qPHlKYFocYHvn+YbjsTzBC4mp34gFHNczsVPAWsy5vDOlItfIwF91saK
OieEQPZo/ME5xtxycuOxAXUGzc2EIwswDaFMCTMC1B2IXfMfaxDm4oe4986zYc1b
6SEeBMweaKdc0d0oOaB4eIxdzQDNKz/TAgBcVlxfKIHy9fOCT+1dGWmpsyJM0nzL
jugiYOfMUg/kPy6tIvpGScRMNxvR+sDOtmBiM0c1Eolzz42TBiN1+PcArilAgRuB
TheCrnXlIAKag8kWvfdp
=Tnak
-----END PGP SIGNATURE-----

--cKagJxsNNshY2zoa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
