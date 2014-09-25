Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8680F6B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 23:55:33 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so10064336lbg.18
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 20:55:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si1164134lbn.98.2014.09.24.20.55.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 20:55:31 -0700 (PDT)
Date: Thu, 25 Sep 2014 13:55:19 +1000
From: NeilBrown <neilb@suse.de>
Subject: [PATCH 1/5 - resend] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-ID: <20140925135519.3ae1fa60@notabene.brown>
In-Reply-To: <20140924070418.GA990@gmail.com>
References: <20140924012422.4838.29188.stgit@notabene.brown>
	<20140924012832.4838.59410.stgit@notabene.brown>
	<20140924070418.GA990@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/j.ngX_FFR/P+u=EKiLXN4ri"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

--Sig_/j.ngX_FFR/P+u=EKiLXN4ri
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


In commit c1221321b7c25b53204447cff9949a6d5a7ddddc
   sched: Allow wait_on_bit_action() functions to support a timeout

I suggested that a "wait_on_bit_timeout()" interface would not meet my
need.  This isn't true - I was just over-engineering.

Including a 'private' field in wait_bit_key instead of a focused
"timeout" field was just premature generalization.  If some other
use is ever found, it can be generalized or added later.

So this patch renames "private" to "timeout" with a meaning "stop
waiting when "jiffies" reaches or passes "timeout",
and adds two of the many possible wait..bit..timeout() interfaces:

wait_on_page_bit_killable_timeout(), which is the one I want to use,
and out_of_line_wait_on_bit_timeout() which is a reasonably general
example.  Others can be added as needed.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.de>

---
This time with EXPORT_SYMBOL_GPL.

Thanks,
NeilBrown


diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 3df8c7db7a4e..87f9e4230d3a 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -502,6 +502,8 @@ static inline int lock_page_or_retry(struct page *page,=
 struct mm_struct *mm,
 extern void wait_on_page_bit(struct page *page, int bit_nr);
=20
 extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
+extern int wait_on_page_bit_killable_timeout(struct page *page,
+					     int bit_nr, unsigned long timeout);
=20
 static inline int wait_on_page_locked_killable(struct page *page)
 {
diff --git a/include/linux/wait.h b/include/linux/wait.h
index 6fb1ba5f9b2f..80115bf88671 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -25,7 +25,7 @@ struct wait_bit_key {
 	void			*flags;
 	int			bit_nr;
 #define WAIT_ATOMIC_T_BIT_NR	-1
-	unsigned long		private;
+	unsigned long		timeout;
 };
=20
 struct wait_bit_queue {
@@ -154,6 +154,7 @@ int __wait_on_bit_lock(wait_queue_head_t *, struct wait=
_bit_queue *, wait_bit_ac
 void wake_up_bit(void *, int);
 void wake_up_atomic_t(atomic_t *);
 int out_of_line_wait_on_bit(void *, int, wait_bit_action_f *, unsigned);
+int out_of_line_wait_on_bit_timeout(void *, int, wait_bit_action_f *, unsi=
gned, unsigned long);
 int out_of_line_wait_on_bit_lock(void *, int, wait_bit_action_f *, unsigne=
d);
 int out_of_line_wait_on_atomic_t(atomic_t *, int (*)(atomic_t *), unsigned=
);
 wait_queue_head_t *bit_waitqueue(void *, int);
@@ -859,6 +860,8 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode=
, int sync, void *key);
=20
 extern int bit_wait(struct wait_bit_key *);
 extern int bit_wait_io(struct wait_bit_key *);
+extern int bit_wait_timeout(struct wait_bit_key *);
+extern int bit_wait_io_timeout(struct wait_bit_key *);
=20
 /**
  * wait_on_bit - wait for a bit to be cleared
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 15cab1a4f84e..5a62915f47a8 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -343,6 +343,18 @@ int __sched out_of_line_wait_on_bit(void *word, int bi=
t,
 }
 EXPORT_SYMBOL(out_of_line_wait_on_bit);
=20
+int __sched out_of_line_wait_on_bit_timeout(
+	void *word, int bit, wait_bit_action_f *action,
+	unsigned mode, unsigned long timeout)
+{
+	wait_queue_head_t *wq =3D bit_waitqueue(word, bit);
+	DEFINE_WAIT_BIT(wait, word, bit);
+
+	wait.key.timeout =3D jiffies + timeout;
+	return __wait_on_bit(wq, &wait, action, mode);
+}
+EXPORT_SYMBOL_GPL(out_of_line_wait_on_bit_timeout);
+
 int __sched
 __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
 			wait_bit_action_f *action, unsigned mode)
@@ -520,3 +532,27 @@ __sched int bit_wait_io(struct wait_bit_key *word)
 	return 0;
 }
 EXPORT_SYMBOL(bit_wait_io);
+
+__sched int bit_wait_timeout(struct wait_bit_key *word)
+{
+	unsigned long now =3D ACCESS_ONCE(jiffies);
+	if (signal_pending_state(current->state, current))
+		return 1;
+	if (time_after_eq(now, word->timeout))
+		return -EAGAIN;
+	schedule_timeout(word->timeout - now);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(bit_wait_timeout);
+
+__sched int bit_wait_io_timeout(struct wait_bit_key *word)
+{
+	unsigned long now =3D ACCESS_ONCE(jiffies);
+	if (signal_pending_state(current->state, current))
+		return 1;
+	if (time_after_eq(now, word->timeout))
+		return -EAGAIN;
+	io_schedule_timeout(word->timeout - now);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(bit_wait_io_timeout);
diff --git a/mm/filemap.c b/mm/filemap.c
index 90effcdf948d..cbe5a9013f70 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -703,6 +703,19 @@ int wait_on_page_bit_killable(struct page *page, int b=
it_nr)
 			     bit_wait_io, TASK_KILLABLE);
 }
=20
+int wait_on_page_bit_killable_timeout(struct page *page,
+				       int bit_nr, unsigned long timeout)
+{
+	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+
+	wait.key.timeout =3D jiffies + timeout;
+	if (!test_bit(bit_nr, &page->flags))
+		return 0;
+	return __wait_on_bit(page_waitqueue(page), &wait,
+			     bit_wait_io_timeout, TASK_KILLABLE);
+}
+EXPORT_SYMBOL_GPL(wait_on_page_bit_killable_timeout);
+
 /**
  * add_page_wait_queue - Add an arbitrary waiter to a page's wait queue
  * @page: Page defining the wait queue of interest

--Sig_/j.ngX_FFR/P+u=EKiLXN4ri
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCOSJznsnt1WYoG5AQKMvxAAsMS+jKndGkOzvOOMmhCXptAylUfOrCik
YLoiZaS8z9Sl9scIu+M9rEF8lzHRkFtucRVoEMSwogl3DVIt2zC4xK66yU4j12P/
ncHqjngDWXgddJqsim1aRD7kmYN/xhbvUCOkS9DfPuQr0Myrt0uso5kufYUvsMtt
fLZpn0G3w6qPtHKZD4p3NZfKgaKWAXLrV2hj0cyisT8dy7+AvOhAIbUwDm+5vPMj
kYTtryCrIAAIrJDfPzZWGAjyTn6JfS3bRLdMuEr0DZP3o+mAnJANwC6pTzMKogwz
p3TZy+MvDus2/XY2xKbKDu8nYdohL96DHQxygFHd/aF1y/ZUcoVEjmHr5iIxbffs
7MJh3eNvHYUYmaqtPDy2tEtb47gOCQ3J4zVNTj5krdkbOnOfZfDXaI8mEEhRVJkz
u7DtNwQokA01DtC76O24I7nUR8CxMfWghN1SUE/fJBupZ0N5VfnzIelRqhSFzoDP
SBfsK+r0MyyizNPgNd8v5BU7SvtKx6uLaSWGAOXI5MiUJnOCdoFEGcwrQVoC0oyW
jsWv6HXf9P7nbK4AlJXqA54s/ScQ5LBBfRguIzmRkqFefOQc/2zOqrMcKZU5CM/G
qMKoRBzswLIrJnV9G6cis5T7sGvdLgtqnr1eY+fGMl1sWvNZTsAH6vNY06fvfe9r
AQEvHzLJIPs=
=O97G
-----END PGP SIGNATURE-----

--Sig_/j.ngX_FFR/P+u=EKiLXN4ri--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
