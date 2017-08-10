Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7210B6B025F
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:17:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z3so6794507pfk.4
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:17:26 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 89si4647056plb.361.2017.08.10.06.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 06:17:24 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id l64so602842pge.2
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:17:24 -0700 (PDT)
Date: Thu, 10 Aug 2017 21:17:37 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170810131737.skdyy4qcxlikbyeh@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20170810125133.2poixhni4d5aqkpy@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Aug 10, 2017 at 08:51:33PM +0800, Boqun Feng wrote:
[...]
> > > > +		/* Check if the ring was overwritten. */
> > > > +		if (h->hist_id !=3D cur->hist_id_save[c])
> > >=20
> > > Could we use:
> > >=20
> > > 		if (h->hist_id !=3D idx)
> >=20
> > No, we cannot.
> >=20
>=20
> Hey, I'm not buying it. task_struct::hist_id and task_struct::xhlock_idx
> are increased at the same place(in add_xhlock()), right?
>=20
> And, yes, xhlock_idx will get decreased when we do ring-buffer
> unwinding, but that's OK, because we need to throw away those recently
> added items.
>=20
> And xhlock_idx always points to the most recently added valid item,
> right?  Any other item's idx must "before()" the most recently added
> one's, right? So ::xhlock_idx acts just like a timestamp, doesn't it?
>=20
> Maybe I'm missing something subtle, but could you show me an example,
> that could end up being a problem if we use xhlock_idx as the hist_id?
>=20
> > hist_id is a kind of timestamp and used to detect overwriting
> > data into places of same indexes of the ring buffer. And idx is
> > just an index. :) IOW, they mean different things.
> >=20
> > >=20
> > > here, and
> > >=20
> > > > +			invalidate_xhlock(h);
> > > > +	}
> > > >  }
> > > >
> > > >  static int cross_lock(struct lockdep_map *lock)
> > > > @@ -4826,6 +4851,7 @@ static inline int depend_after(struct held_lo=
ck
> > > *hlock)
> > > >   * Check if the xhlock is valid, which would be false if,
> > > >   *
> > > >   *    1. Has not used after initializaion yet.
> > > > + *    2. Got invalidated.
> > > >   *
> > > >   * Remind hist_lock is implemented as a ring buffer.
> > > >   */
> > > > @@ -4857,6 +4883,7 @@ static void add_xhlock(struct held_lock *hloc=
k)
> > > >
> > > >  	/* Initialize hist_lock's members */
> > > >  	xhlock->hlock =3D *hlock;
> > > > +	xhlock->hist_id =3D current->hist_id++;
>=20
> Besides, is this code correct? Does this just make xhlock->hist_id
> one-less-than the curr->hist_id, which cause the invalidation every time
> you do ring buffer unwinding?
>=20
> Regards,
> Boqun
>=20

So basically, I'm suggesting do this on top of your patch, there is also
a fix in commit_xhlocks(), which I think you should swap the parameters
in before(...), no matter using task_struct::hist_id or using
task_struct::xhlock_idx as the timestamp.

Hope this could make my point more clear, and if I do miss something,
please point it out, thanks ;-)

Regards,
Boqun
------------>8

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 074872f016f8..886ba79bfc38 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -854,9 +854,6 @@ struct task_struct {
 	unsigned int xhlock_idx;
 	/* For restoring at history boundaries */
 	unsigned int xhlock_idx_hist[XHLOCK_NR];
-	unsigned int hist_id;
-	/* For overwrite check at each context exit */
-	unsigned int hist_id_save[XHLOCK_NR];
 #endif
=20
 #ifdef CONFIG_UBSAN
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 699fbeab1920..04c6c8d68e18 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4752,10 +4752,8 @@ void crossrelease_hist_start(enum xhlock_context_t c)
 {
 	struct task_struct *cur =3D current;
=20
-	if (cur->xhlocks) {
+	if (cur->xhlocks)
 		cur->xhlock_idx_hist[c] =3D cur->xhlock_idx;
-		cur->hist_id_save[c] =3D cur->hist_id;
-	}
 }
=20
 void crossrelease_hist_end(enum xhlock_context_t c)
@@ -4769,7 +4767,7 @@ void crossrelease_hist_end(enum xhlock_context_t c)
 		cur->xhlock_idx =3D idx;
=20
 		/* Check if the ring was overwritten. */
-		if (h->hist_id !=3D cur->hist_id_save[c])
+		if (h->hist_id !=3D idx)
 			invalidate_xhlock(h);
 	}
 }
@@ -4849,7 +4847,7 @@ static void add_xhlock(struct held_lock *hlock)
=20
 	/* Initialize hist_lock's members */
 	xhlock->hlock =3D *hlock;
-	xhlock->hist_id =3D current->hist_id++;
+	xhlock->hist_id =3D idx;
=20
 	xhlock->trace.nr_entries =3D 0;
 	xhlock->trace.max_entries =3D MAX_XHLOCK_TRACE_ENTRIES;
@@ -5005,7 +5003,7 @@ static int commit_xhlock(struct cross_lock *xlock, st=
ruct hist_lock *xhlock)
 static void commit_xhlocks(struct cross_lock *xlock)
 {
 	unsigned int cur =3D current->xhlock_idx;
-	unsigned int prev_hist_id =3D xhlock(cur).hist_id;
+	unsigned int prev_hist_id =3D cur + 1;
 	unsigned int i;
=20
 	if (!graph_lock())
@@ -5030,7 +5028,7 @@ static void commit_xhlocks(struct cross_lock *xlock)
 			 * hist_id than the following one, which is impossible
 			 * otherwise.
 			 */
-			if (unlikely(before(xhlock->hist_id, prev_hist_id)))
+			if (unlikely(before(prev_hist_id, xhlock->hist_id)))
 				break;
=20
 			prev_hist_id =3D xhlock->hist_id;
@@ -5120,12 +5118,9 @@ void lockdep_init_task(struct task_struct *task)
 	int i;
=20
 	task->xhlock_idx =3D UINT_MAX;
-	task->hist_id =3D 0;
=20
-	for (i =3D 0; i < XHLOCK_NR; i++) {
+	for (i =3D 0; i < XHLOCK_NR; i++)
 		task->xhlock_idx_hist[i] =3D UINT_MAX;
-		task->hist_id_save[i] =3D 0;
-	}
=20
 	task->xhlocks =3D kzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR,
 				GFP_KERNEL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
