Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 874A26B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 09:21:08 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id x13so1721084qcv.16
        for <linux-mm@kvack.org>; Thu, 15 May 2014 06:21:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id g4si2533854qai.28.2014.05.15.06.21.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 May 2014 06:21:07 -0700 (PDT)
Date: Thu, 15 May 2014 15:20:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v4
Message-ID: <20140515132058.GL30445@twins.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="F2YjuSVvMy0XUwbk"
Content-Disposition: inline
In-Reply-To: <20140515104808.GF23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>


--F2YjuSVvMy0XUwbk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 15, 2014 at 11:48:09AM +0100, Mel Gorman wrote:

> +static inline wait_queue_head_t *clear_page_waiters(struct page *page)
>  {
> +	wait_queue_head_t *wqh =3D NULL;
> +
> +	if (!PageWaiters(page))
> +		return NULL;
> +
> +	/*
> +	 * Prepare to clear PG_waiters if the waitqueue is no longer
> +	 * active. Note that there is no guarantee that a page with no
> +	 * waiters will get cleared as there may be unrelated pages
> +	 * sleeping on the same page wait queue. Accurate detection
> +	 * would require a counter. In the event of a collision, the
> +	 * waiter bit will dangle and lookups will be required until
> +	 * the page is unlocked without collisions. The bit will need to
> +	 * be cleared before freeing to avoid triggering debug checks.
> +	 *
> +	 * Furthermore, this can race with processes about to sleep on
> +	 * the same page if it adds itself to the waitqueue just after
> +	 * this check. The timeout in sleep_on_page prevents the race
> +	 * being a terminal one. In effect, the uncontended and non-race
> +	 * cases are faster in exchange for occasional worst case of the
> +	 * timeout saving us.
> +	 */
> +	wqh =3D page_waitqueue(page);
> +	if (!waitqueue_active(wqh))
> +		ClearPageWaiters(page);
> +
> +	return wqh;
> +}

So clear_page_waiters() is I think a bad name for this function, for one
it doesn't relate to returning a wait_queue_head.

Secondly, I think the clear condition is wrong, if I understand the rest
of the code correctly we'll keep PageWaiters set until the above
condition, which is not a single waiter on the waitqueue.

Would it not make much more sense to clear the page when there are no
more waiters of this page?

For the case where there are no waiters at all, this is the same
condition, but in case there's a hash collision and there's other pages
waiting, we'll iterate the lot anyway, so we might as well clear it
there.

> +/* Returns true if the page is locked */
> +static inline bool prepare_wait_bit(struct page *page, wait_queue_head_t=
 *wqh,
> +			wait_queue_t *wq, int state, int bit_nr, bool exclusive)
> +{
> +
> +	/* Set PG_waiters so a racing unlock_page will check the waitiqueue */
> +	if (!PageWaiters(page))
> +		SetPageWaiters(page);
> +
> +	if (exclusive)
> +		prepare_to_wait_exclusive(wqh, wq, state);
> +	else
> +		prepare_to_wait(wqh, wq, state);
> +	return test_bit(bit_nr, &page->flags);
>  }
> =20
>  void wait_on_page_bit(struct page *page, int bit_nr)
>  {
> +	wait_queue_head_t *wqh;
>  	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
> =20
> +	if (!test_bit(bit_nr, &page->flags))
> +		return;
> +	wqh =3D page_waitqueue(page);
> +
> +	do {
> +		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_KILLABLE, bit_nr, fal=
se))
> +			sleep_on_page_killable(page);
> +	} while (test_bit(bit_nr, &page->flags));
> +	finish_wait(wqh, &wait.wait);
>  }
>  EXPORT_SYMBOL(wait_on_page_bit);

Afaict, after this patch, wait_on_page_bit() is only used by
wait_on_page_writeback(), and might I ask why that needs the PageWaiter
set?

>  int wait_on_page_bit_killable(struct page *page, int bit_nr)
>  {
> +	wait_queue_head_t *wqh;
>  	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
> +	int ret =3D 0;
> =20
>  	if (!test_bit(bit_nr, &page->flags))
>  		return 0;
> +	wqh =3D page_waitqueue(page);
> +
> +	do {
> +		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_KILLABLE, bit_nr, fal=
se))
> +			ret =3D sleep_on_page_killable(page);
> +	} while (!ret && test_bit(bit_nr, &page->flags));
> +	finish_wait(wqh, &wait.wait);
> =20
> +	return ret;
>  }

The only user of wait_on_page_bit_killable() _was_
wait_on_page_locked_killable(), but you've just converted that to use
__wait_on_page_bit_killable().

So we can scrap this function.

>  /**
> @@ -721,6 +785,8 @@ void add_page_wait_queue(struct page *page, wait_queu=
e_t *waiter)
>  	unsigned long flags;
> =20
>  	spin_lock_irqsave(&q->lock, flags);
> +	if (!PageWaiters(page))
> +		SetPageWaiters(page);
>  	__add_wait_queue(q, waiter);
>  	spin_unlock_irqrestore(&q->lock, flags);
>  }

What does add_page_wait_queue() do and why does it need PageWaiters?

> @@ -740,10 +806,29 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
>   */
>  void unlock_page(struct page *page)
>  {
> +	wait_queue_head_t *wqh =3D clear_page_waiters(page);
> +
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +
> +	/*
> +	 * clear_bit_unlock is not necessary in this case as there is no
> +	 * need to strongly order the clearing of PG_waiters and PG_locked.
> +	 * The smp_mb__after_atomic() barrier is still required for RELEASE
> +	 * semantics as there is no guarantee that a wakeup will take place
> +	 */
> +	clear_bit(PG_locked, &page->flags);
>  	smp_mb__after_atomic();

If you need RELEASE, use _unlock() because that's exactly what it does.

> +
> +	/*
> +	 * Wake the queue if waiters were detected. Ordinarily this wakeup
> +	 * would be unconditional to catch races between the lock bit being
> +	 * set and a new process joining the queue. However, that would
> +	 * require the waitqueue to be looked up every time. Instead we
> +	 * optimse for the uncontended and non-race case and recover using
> +	 * a timeout in sleep_on_page.
> +	 */
> +	if (wqh)
> +		__wake_up_bit(wqh, &page->flags, PG_locked);

And the only reason we're not clearing PageWaiters under q->lock is to
skimp on the last contended unlock_page() ?

>  }
>  EXPORT_SYMBOL(unlock_page);
> =20
> @@ -795,22 +884,69 @@ EXPORT_SYMBOL_GPL(page_endio);
>   */
>  void __lock_page(struct page *page)
>  {
> +	wait_queue_head_t *wqh =3D page_waitqueue(page);
>  	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
> =20
> +	do {
> +		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_UNINTERRUPTIBLE, PG_l=
ocked, true))
> +			sleep_on_page(page);
> +	} while (!trylock_page(page));
> +
> +	finish_wait(wqh, &wait.wait);
>  }



So I suppose I'm failing to see the problem with something like:

extern void __lock_page(struct page *);
extern void __unlock_page(struct page *);

static inline void lock_page(struct page *page)
{
	if (!trylock_page(page))
		__lock_page(page);
}

static inline void unlock_page(struct page *page)
{
	clear_bit_unlock(&page->flags, PG_locked);
	if (PageWaiters(page))
		__unlock_page();
}

void __lock_page(struct page *page)
{
	struct wait_queue_head_t *wqh =3D page_waitqueue(page);
	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);

	spin_lock_irq(&wqh->lock);
	if (!PageWaiters(page))
		SetPageWaiters(page);

	wait.flags |=3D WQ_FLAG_EXCLUSIVE;
	preempt_disable();
	do {
		if (list_empty(&wait->task_list))
			__add_wait_queue_tail(wqh, &wait);

		set_current_state(TASK_UNINTERRUPTIBLE);

		if (test_bit(wait.key.bit_nr, wait.key.flags)) {
			spin_unlock_irq(&wqh->lock);
			schedule_preempt_disabled();
			spin_lock_irq(&wqh->lock);
		}
	} while (!trylock_page(page));

	__remove_wait_queue(wqh, &wait);
	__set_current_state(TASK_RUNNING);
	preempt_enable();
	spin_unlock_irq(&wqh->lock);
}

void __unlock_page(struct page *page)
{
	struct wait_bit_key key =3D __WAIT_BIT_KEY_INITIALIZER(&page->flags, PG_lo=
cked);
	struct wait_queue_head_t *wqh =3D page_waitqueue(page);
	wait_queue_t *curr;

	spin_lock_irq(&wqh->lock);
	list_for_each_entry(curr, &wqh->task_list, task_list) {
		unsigned int flags =3D curr->flags;

		if (curr->func(curr, TASK_NORMAL, 0, &key))
			goto unlock;
	}
	ClearPageWaiters(page);
unlock:
	spin_unlock_irq(&wqh->lock);
}

Yes, the __unlock_page() will have the unconditional wqh->lock, but it
should also call __unlock_page() a lot less, and it doesn't have that
horrid timeout.

Now, the above is clearly sub-optimal when !extended_page_flags, but I
suppose we could have two versions of __unlock_page() for that.

--F2YjuSVvMy0XUwbk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTdL86AAoJEHZH4aRLwOS63s4P/0nnNf9Epxh1d9IXmp41SWXk
2ZHW8SVfl23TBbcASQ8J/5mBJhUoIUPcHrtLtAKb47Xc9Q4Xfujdt2FA2wLvxSI0
hmXyqA4RR00PcMaeUB8GQUCC+ncVMfVTLvhiAOO63zRItoKKmAIqMwcEp/6ilTIA
nPUBAorUjeX7D/mBY/slAEr+2AqWiMOGv39AkxT/2BcqKb0LX8IijyDIq5FDUapo
CPAGVkRcuhzSmmDWOw7qEB2Qn3HZC1PxwuE2rvtD0ZJ9p1pb9yNF7rh1y7MpL+o9
mqMjVGk9UL+OBLktzV5cKnOgmmA7AwXJUQ/fkr08KMsqKlpoa9OsdspJvhJVWI7Y
k4uOoksuZi8UsfAZHXQU/5VonJr1hnFMcKPj5QQO+LOsu3HIwXadGX/NvrWOEfD6
e+IlFFLxznnVPPlFDO6xDob2BnA3GeyhaI0ezgGW903HDHjAANO0DdV3smsfpx5C
Ugr+DaTbAQSLZHRKl5YYlubUaCS9/uobrQ69wfT+GM4KtYnFzDfB+gUCgVsmra8y
L+QUpUeikQRjU8ZgB9NcQNX/Hh1RfX4mfdXZHbT8kyiNi2G/5QVXEG/nEAnwT90d
7U33JgVsechFcwYtgjhJKwyQLf7XxabJFe9S9eUIFeSXuNEDK3qfyXTfMT0qpPn6
B3kd4cfjUSQeUpRd3B3U
=4hB6
-----END PGP SIGNATURE-----

--F2YjuSVvMy0XUwbk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
