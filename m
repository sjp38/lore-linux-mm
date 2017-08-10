Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7B76B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:59:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o82so4664828pfj.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:59:19 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 1si3898079pgs.356.2017.08.10.04.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 04:59:17 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id j68so491134pfc.2
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:59:17 -0700 (PDT)
Date: Thu, 10 Aug 2017 19:59:22 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170810115922.kegrfeg6xz7mgpj4@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ieps2idy3c3cac3n"
Content-Disposition: inline
In-Reply-To: <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


--ieps2idy3c3cac3n
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 07, 2017 at 04:12:53PM +0900, Byungchul Park wrote:
> The ring buffer can be overwritten by hardirq/softirq/work contexts.
> That cases must be considered on rollback or commit. For example,
>=20
>           |<------ hist_lock ring buffer size ----->|
>           ppppppppppppiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
> wrapped > iiiiiiiiiiiiiiiiiiiiiii....................
>=20
>           where 'p' represents an acquisition in process context,
>           'i' represents an acquisition in irq context.
>=20
> On irq exit, crossrelease tries to rollback idx to original position,
> but it should not because the entry already has been invalid by
> overwriting 'i'. Avoid rollback or commit for entries overwritten.
>=20
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  include/linux/lockdep.h  | 20 +++++++++++++++++++
>  include/linux/sched.h    |  3 +++
>  kernel/locking/lockdep.c | 52 ++++++++++++++++++++++++++++++++++++++++++=
+-----
>  3 files changed, 70 insertions(+), 5 deletions(-)
>=20
> diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
> index 0c8a1b8..48c244c 100644
> --- a/include/linux/lockdep.h
> +++ b/include/linux/lockdep.h
> @@ -284,6 +284,26 @@ struct held_lock {
>   */
>  struct hist_lock {
>  	/*
> +	 * Id for each entry in the ring buffer. This is used to
> +	 * decide whether the ring buffer was overwritten or not.
> +	 *
> +	 * For example,
> +	 *
> +	 *           |<----------- hist_lock ring buffer size ------->|
> +	 *           pppppppppppppppppppppiiiiiiiiiiiiiiiiiiiiiiiiiiiii
> +	 * wrapped > iiiiiiiiiiiiiiiiiiiiiiiiiii.......................
> +	 *
> +	 *           where 'p' represents an acquisition in process
> +	 *           context, 'i' represents an acquisition in irq
> +	 *           context.
> +	 *
> +	 * In this example, the ring buffer was overwritten by
> +	 * acquisitions in irq context, that should be detected on
> +	 * rollback or commit.
> +	 */
> +	unsigned int hist_id;
> +
> +	/*
>  	 * Seperate stack_trace data. This will be used at commit step.
>  	 */
>  	struct stack_trace	trace;
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 5becef5..373466b 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -855,6 +855,9 @@ struct task_struct {
>  	unsigned int xhlock_idx;
>  	/* For restoring at history boundaries */
>  	unsigned int xhlock_idx_hist[CONTEXT_NR];
> +	unsigned int hist_id;
> +	/* For overwrite check at each context exit */
> +	unsigned int hist_id_save[CONTEXT_NR];
>  #endif
> =20
>  #ifdef CONFIG_UBSAN
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index afd6e64..5168dac 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -4742,6 +4742,17 @@ void lockdep_rcu_suspicious(const char *file, cons=
t int line, const char *s)
>  static atomic_t cross_gen_id; /* Can be wrapped */
> =20
>  /*
> + * Make an entry of the ring buffer invalid.
> + */
> +static inline void invalidate_xhlock(struct hist_lock *xhlock)
> +{
> +	/*
> +	 * Normally, xhlock->hlock.instance must be !NULL.
> +	 */
> +	xhlock->hlock.instance =3D NULL;
> +}
> +
> +/*
>   * Lock history stacks; we have 3 nested lock history stacks:
>   *
>   *   Hard IRQ
> @@ -4773,14 +4784,28 @@ void lockdep_rcu_suspicious(const char *file, con=
st int line, const char *s)
>   */
>  void crossrelease_hist_start(enum context_t c)
>  {
> -	if (current->xhlocks)
> -		current->xhlock_idx_hist[c] =3D current->xhlock_idx;
> +	struct task_struct *cur =3D current;
> +
> +	if (cur->xhlocks) {
> +		cur->xhlock_idx_hist[c] =3D cur->xhlock_idx;
> +		cur->hist_id_save[c] =3D cur->hist_id;
> +	}
>  }
> =20
>  void crossrelease_hist_end(enum context_t c)
>  {
> -	if (current->xhlocks)
> -		current->xhlock_idx =3D current->xhlock_idx_hist[c];
> +	struct task_struct *cur =3D current;
> +
> +	if (cur->xhlocks) {
> +		unsigned int idx =3D cur->xhlock_idx_hist[c];
> +		struct hist_lock *h =3D &xhlock(idx);
> +
> +		cur->xhlock_idx =3D idx;
> +
> +		/* Check if the ring was overwritten. */
> +		if (h->hist_id !=3D cur->hist_id_save[c])

Could we use:

		if (h->hist_id !=3D idx)

here, and

> +			invalidate_xhlock(h);
> +	}
>  }
> =20
>  static int cross_lock(struct lockdep_map *lock)
> @@ -4826,6 +4851,7 @@ static inline int depend_after(struct held_lock *hl=
ock)
>   * Check if the xhlock is valid, which would be false if,
>   *
>   *    1. Has not used after initializaion yet.
> + *    2. Got invalidated.
>   *
>   * Remind hist_lock is implemented as a ring buffer.
>   */
> @@ -4857,6 +4883,7 @@ static void add_xhlock(struct held_lock *hlock)
> =20
>  	/* Initialize hist_lock's members */
>  	xhlock->hlock =3D *hlock;
> +	xhlock->hist_id =3D current->hist_id++;

use:

	xhlock->hist_id =3D idx;

and,


> =20
>  	xhlock->trace.nr_entries =3D 0;
>  	xhlock->trace.max_entries =3D MAX_XHLOCK_TRACE_ENTRIES;
> @@ -4995,6 +5022,7 @@ static int commit_xhlock(struct cross_lock *xlock, =
struct hist_lock *xhlock)
>  static void commit_xhlocks(struct cross_lock *xlock)
>  {
>  	unsigned int cur =3D current->xhlock_idx;
> +	unsigned int prev_hist_id =3D xhlock(cur).hist_id;

use:
	unsigned int prev_hist_id =3D cur;

here.

Then we can get away with the added fields in task_struct at least.

Thought?

Regards,
Boqun

>  	unsigned int i;
> =20
>  	if (!graph_lock())
> @@ -5013,6 +5041,17 @@ static void commit_xhlocks(struct cross_lock *xloc=
k)
>  			break;
> =20
>  		/*
> +		 * Filter out the cases that the ring buffer was
> +		 * overwritten and the previous entry has a bigger
> +		 * hist_id than the following one, which is impossible
> +		 * otherwise.
> +		 */
> +		if (unlikely(before(xhlock->hist_id, prev_hist_id)))
> +			break;
> +
> +		prev_hist_id =3D xhlock->hist_id;
> +
> +		/*
>  		 * commit_xhlock() returns 0 with graph_lock already
>  		 * released if fail.
>  		 */
> @@ -5085,9 +5124,12 @@ void lockdep_init_task(struct task_struct *task)
>  	int i;
> =20
>  	task->xhlock_idx =3D UINT_MAX;
> +	task->hist_id =3D 0;
> =20
> -	for (i =3D 0; i < CONTEXT_NR; i++)
> +	for (i =3D 0; i < CONTEXT_NR; i++) {
>  		task->xhlock_idx_hist[i] =3D UINT_MAX;
> +		task->hist_id_save[i] =3D 0;
> +	}
> =20
>  	task->xhlocks =3D kzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR,
>  				GFP_KERNEL);
> --=20
> 1.9.1
>=20

--ieps2idy3c3cac3n
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmMSpcACgkQSXnow7UH
+ri8Owf+MEgznLkEiujZoUhrUwJnoR0tY/UtfUIVIbsNE2zfTM7g9Tw0PrMcmxPb
VLNaYTHfcAzv/AHPrBjqvj04sWpp69ZDhsM3M5VxW3xPo7Cx8sejpZSTfC1QEO+K
nYQ7+IfmTp1R7XMTmFsxW/ZF1Zx6O53cYaLWYcPw5sKBVG2QQsE2jMKXLV2ivFiE
S9Rw0Yu5DYMZkepduiVNC1LzLYOBNqrwehu+SIOHtorGDkzQMUc/f8EgSXVgjE2p
dzkgsRRRr+vo0TdWYMA7/9b+vhi2qR9eQqAyZ6boWAKgsNUOEem8JTjFOVZUOjcH
Lv/Xywwdn9PoLQsrerb130ayhZqQ9Q==
=1bXY
-----END PGP SIGNATURE-----

--ieps2idy3c3cac3n--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
