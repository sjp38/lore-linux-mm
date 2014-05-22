Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 54C1B6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 06:56:48 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so5445749qcy.31
        for <linux-mm@kvack.org>; Thu, 22 May 2014 03:56:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id m3si4808521qaz.65.2014.05.22.03.56.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 May 2014 03:56:47 -0700 (PDT)
Date: Thu, 22 May 2014 12:56:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barriers and waitqueue
 lookups in unlock_page fastpath v7
Message-ID: <20140522105638.GT30445@twins.programming.kicks-ass.net>
References: <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
 <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
 <20140521213354.GL2485@laptop.programming.kicks-ass.net>
 <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
 <20140522000715.GA23991@suse.de>
 <20140522072001.GP30445@twins.programming.kicks-ass.net>
 <20140522104051.GE23991@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9rFIWt66tTOC0xtM"
Content-Disposition: inline
In-Reply-To: <20140522104051.GE23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>


--9rFIWt66tTOC0xtM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 22, 2014 at 11:40:51AM +0100, Mel Gorman wrote:
> +void __wake_up_page_bit(wait_queue_head_t *wqh, struct page *page, void =
*word, int bit)
> +{
> +	struct wait_bit_key key =3D __WAIT_BIT_KEY_INITIALIZER(word, bit);
> +	unsigned long flags;
> +
> +	/* If there is no PG_waiters bit, always take the slow path */

That comment is misleading, this is actually a fast path for
!PG_waiters.

> +	if (!__PG_WAITERS && waitqueue_active(wq)) {
> +		__wake_up(wq, TASK_NORMAL, 1, &key);
> +		return;
> +	}
> +
> +	/*
> +	 * Unlike __wake_up_bit it is necessary to check waitqueue_active to be
> +	 * checked under the wqh->lock to avoid races with parallel additions
> +	 * to the waitqueue. Otherwise races could result in lost wakeups
> +	 */
> +	spin_lock_irqsave(&wqh->lock, flags);
> +	if (waitqueue_active(wqh))
> +		__wake_up_common(wqh, TASK_NORMAL, 1, 0, &key);
> +	else
> +		ClearPageWaiters(page);
> +	spin_unlock_irqrestore(&wqh->lock, flags);
> +}

So I think you missed one Clear opportunity here that was in my original
proposal, possibly because you also frobbed PG_writeback in.

If you do:

	spin_lock_irqsave(&wqh->lock, flags);
	if (!waitqueue_active(wqh) || !__wake_up_common(wqh, TASK_NORMAL, 1, 0, &k=
ey))
		ClearPageWaiters(page);
	spin_unlock_irqrestore(&wqh->lock, flags);

With the below change to __wake_up_common(), we'll also clear the bit
when there's no waiters of @page, even if there's waiters for another
page.

I suppose the one thing to say for the big open coded loop is that its
much easier to read than this scattered stuff.

---
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 0ffa20ae657b..213c5bfe6b56 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -61,18 +61,23 @@ EXPORT_SYMBOL(remove_wait_queue);
  * started to run but is not in state TASK_RUNNING. try_to_wake_up() retur=
ns
  * zero in this (rare) case, and we handle it by continuing to scan the qu=
eue.
  */
-static void __wake_up_common(wait_queue_head_t *q, unsigned int mode,
+static bool __wake_up_common(wait_queue_head_t *q, unsigned int mode,
 			int nr_exclusive, int wake_flags, void *key)
 {
 	wait_queue_t *curr, *next;
+	bool woke =3D false;
=20
 	list_for_each_entry_safe(curr, next, &q->task_list, task_list) {
 		unsigned flags =3D curr->flags;
=20
-		if (curr->func(curr, mode, wake_flags, key) &&
-				(flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
-			break;
+		if (curr->func(curr, mode, wake_flags, key)) {
+			woke =3D true;
+			if ((flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
+				break;
+		}
 	}
+
+	return woke;
 }
=20
 /**



--9rFIWt66tTOC0xtM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTfdfhAAoJEHZH4aRLwOS6JrAP/0dcm8LCDhwDZyaOa8q7PSvk
HbZ9BIB+u5GOATocUkUtt9T0dNvwjql5CmrXwOYWn6NDBOieK1ffye9GDCEcBwUM
W8n5T7PCspPvm8CHtvF2q9rAAq64hegqmHJt5b14ioS8ayng4kXpP2YLYYFfk/qw
LW/nYGRXjzTiwpYb8XeLZygEgLkPsTB8vHxhl00JbU1jqXOTUZMDJPJuvwrEbUee
/DLO8W5n8khaBILlNcNTI/o/NnGNO9PQZC6UYgCpD34pqlSDk9Yv57djphgwsC2O
oF5WZA2o2fxhVO3sckHG69TxHQdgVXPOqEJfV3nk+KmvDZ+DQ2gCgQcCJR1tB1u/
qbBSQQUSUjigCj+Yx/2LKGqEe+XCOJHUFti3HFqxiSPDdQeGscnKT8b410TqJMIc
XRJKOG0jgUchkIX/1JhGogj21pMCSw4s7xorUTroju9UBLElwOnwGbzxda1ngfc8
tYxXj2LoiNcGtG/3lrsfieIOLK63JUb6B39U7DGitjcmSJbqhN71R0kS9tIoPRnN
jxMgQOqtrrNB+j6iObK2FVpambxixFVYXdi1opZu3tvwRduDf7Idpp4lNA5DuSYy
vUH78Cdv8lbxvcNvlJl4CuJs2owMPc3dvlzz1QgxNnIjQdlhr30f+no1wY1Rrfl/
NBcar+LpjMXy6TQi0orS
=o1BX
-----END PGP SIGNATURE-----

--9rFIWt66tTOC0xtM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
