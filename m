Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2EC6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 22:37:56 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so1885423eek.23
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 19:37:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w48si32709980eel.176.2014.04.30.19.37.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 19:37:54 -0700 (PDT)
Date: Thu, 1 May 2014 12:37:38 +1000
From: NeilBrown <neilb@suse.de>
Subject: [PATCH] SCHED: remove proliferation of wait_on_bit action
 functions.
Message-ID: <20140501123738.3e64b2d2@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/9+OzCq1pr/H.F0YtKwas2wv"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, David Howells <dhowells@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--Sig_/9+OzCq1pr/H.F0YtKwas2wv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


[[ get_maintainer.pl suggested 61 email address for this patch.
   I've trimmed that list somewhat.  Hope I didn't miss anyone
   important...
   I'm hoping it will go in through the scheduler tree, but would
   particularly like an Acked-by for the fscache parts.  Other acks
   welcome.
]]

The current "wait_on_bit" interface requires an 'action' function
to be provided which does the actual waiting.
There are over 20 such functions, many of them identical.
Most cases can be satisfied by one of just two functions, one
which uses io_schedule() and one which just uses schedule().

So:
 Rename wait_on_bit and        wait_on_bit_lock to
        wait_on_bit_action and wait_on_bit_lock_action
 to make it explicit that they need an action function.

 Introduce new wait_on_bit{,_lock} and wait_on_bit{,_lock}_io
 which are *not* given an action function but implicitly use
 a standard one.
 The decision to error-out if a signal is pending is now made
 based on the 'mode' argument rather than being encoded in the action
 function.


 All instances of the old wait_on_bit and wait_on_bit_lock which
 can use the new version have been changed accordingly and their
 action functions have been discarded.
 wait_on_bit{_lock} does not return any specific error code in the
 event of a signal so the caller must check for non-zero and
 interpolate their own error code as appropriate.

The wait_on_bit() call in __fscache_wait_on_invalidate() was ambiguous
as it specified TASK_UNINTERRUPTIBLE but used
fscache_wait_bit_interruptible as an action function.
As any error return is never checked I assumed that 'uninterruptible'
was correct.

The main remaining user of wait_on_bit{,_lock}_action is NFS which
needs to use a freezer-aware schedule() call.

A comment in fs/gfs2/glock.c notes that having multiple 'action'
functions is useful as they display differently in the 'wchan' field
of 'ps'. (and /proc/$PID/wchan).
As the new bit_wait{,_io} functions are tagged "__sched", they will
not show up at all, but something higher in the stack.  So the
distinction will still be visible, only with different function names
(gds2_glock_wait versus gfs2_glock_dq_wait in the gfs2/glock.c case).


Signed-off-by: NeilBrown <neilb@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: David Howells <dhowells@redhat.com> (fscache)
Cc: Steven Whitehouse <swhiteho@redhat.com> (gfs2)

diff --git a/Documentation/filesystems/caching/operations.txt b/Documentati=
on/filesystems/caching/operations.txt
index bee2a5f93d60..a1c052cbba35 100644
--- a/Documentation/filesystems/caching/operations.txt
+++ b/Documentation/filesystems/caching/operations.txt
@@ -90,7 +90,7 @@ operations:
      to be cleared before proceeding:
=20
 		wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
-			    fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
=20
=20
  (2) The operation may be fast asynchronous (FSCACHE_OP_FAST), in which ca=
se it
diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index 66c5d130c8c2..c6b692dd3b88 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -615,16 +615,6 @@ static void write_endio(struct bio *bio, int error)
 }
=20
 /*
- * This function is called when wait_on_bit is actually waiting.
- */
-static int do_io_schedule(void *word)
-{
-	io_schedule();
-
-	return 0;
-}
-
-/*
  * Initiate a write on a dirty buffer, but don't wait for it.
  *
  * - If the buffer is not dirty, exit.
@@ -640,8 +630,8 @@ static void __write_dirty_buffer(struct dm_buffer *b,
 		return;
=20
 	clear_bit(B_DIRTY, &b->state);
-	wait_on_bit_lock(&b->state, B_WRITING,
-			 do_io_schedule, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_lock_io(&b->state, B_WRITING,
+			    TASK_UNINTERRUPTIBLE);
=20
 	if (!write_list)
 		submit_io(b, WRITE, b->block, write_endio);
@@ -675,9 +665,9 @@ static void __make_buffer_clean(struct dm_buffer *b)
 	if (!b->state)	/* fast case */
 		return;
=20
-	wait_on_bit(&b->state, B_READING, do_io_schedule, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&b->state, B_READING, TASK_UNINTERRUPTIBLE);
 	__write_dirty_buffer(b, NULL);
-	wait_on_bit(&b->state, B_WRITING, do_io_schedule, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&b->state, B_WRITING, TASK_UNINTERRUPTIBLE);
 }
=20
 /*
@@ -1030,7 +1020,7 @@ static void *new_read(struct dm_bufio_client *c, sect=
or_t block,
 	if (need_submit)
 		submit_io(b, READ, b->block, read_endio);
=20
-	wait_on_bit(&b->state, B_READING, do_io_schedule, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&b->state, B_READING, TASK_UNINTERRUPTIBLE);
=20
 	if (b->read_error) {
 		int error =3D b->read_error;
@@ -1209,15 +1199,13 @@ again:
 				dropped_lock =3D 1;
 				b->hold_count++;
 				dm_bufio_unlock(c);
-				wait_on_bit(&b->state, B_WRITING,
-					    do_io_schedule,
-					    TASK_UNINTERRUPTIBLE);
+				wait_on_bit_io(&b->state, B_WRITING,
+					       TASK_UNINTERRUPTIBLE);
 				dm_bufio_lock(c);
 				b->hold_count--;
 			} else
-				wait_on_bit(&b->state, B_WRITING,
-					    do_io_schedule,
-					    TASK_UNINTERRUPTIBLE);
+				wait_on_bit_io(&b->state, B_WRITING,
+					       TASK_UNINTERRUPTIBLE);
 		}
=20
 		if (!test_bit(B_DIRTY, &b->state) &&
@@ -1321,15 +1309,15 @@ retry:
=20
 	__write_dirty_buffer(b, NULL);
 	if (b->hold_count =3D=3D 1) {
-		wait_on_bit(&b->state, B_WRITING,
-			    do_io_schedule, TASK_UNINTERRUPTIBLE);
+		wait_on_bit_io(&b->state, B_WRITING,
+			       TASK_UNINTERRUPTIBLE);
 		set_bit(B_DIRTY, &b->state);
 		__unlink_buffer(b);
 		__link_buffer(b, new_block, LIST_DIRTY);
 	} else {
 		sector_t old_block;
-		wait_on_bit_lock(&b->state, B_WRITING,
-				 do_io_schedule, TASK_UNINTERRUPTIBLE);
+		wait_on_bit_lock_io(&b->state, B_WRITING,
+				    TASK_UNINTERRUPTIBLE);
 		/*
 		 * Relink buffer to "new_block" so that write_callback
 		 * sees "new_block" as a block number.
@@ -1341,8 +1329,8 @@ retry:
 		__unlink_buffer(b);
 		__link_buffer(b, new_block, b->list_mode);
 		submit_io(b, WRITE, new_block, write_endio);
-		wait_on_bit(&b->state, B_WRITING,
-			    do_io_schedule, TASK_UNINTERRUPTIBLE);
+		wait_on_bit_io(&b->state, B_WRITING,
+			       TASK_UNINTERRUPTIBLE);
 		__unlink_buffer(b);
 		__link_buffer(b, old_block, b->list_mode);
 	}
diff --git a/drivers/md/dm-snap.c b/drivers/md/dm-snap.c
index ebddef5237e4..172ba0d6e4e0 100644
--- a/drivers/md/dm-snap.c
+++ b/drivers/md/dm-snap.c
@@ -1032,20 +1032,13 @@ static void start_merge(struct dm_snapshot *s)
 		snapshot_merge_next_chunks(s);
 }
=20
-static int wait_schedule(void *ptr)
-{
-	schedule();
-
-	return 0;
-}
-
 /*
  * Stop the merging process and wait until it finishes.
  */
 static void stop_merge(struct dm_snapshot *s)
 {
 	set_bit(SHUTDOWN_MERGE, &s->state_bits);
-	wait_on_bit(&s->state_bits, RUNNING_MERGE, wait_schedule,
+	wait_on_bit(&s->state_bits, RUNNING_MERGE,
 		    TASK_UNINTERRUPTIBLE);
 	clear_bit(SHUTDOWN_MERGE, &s->state_bits);
 }
diff --git a/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c b/drivers/media/us=
b/dvb-usb-v2/dvb_usb_core.c
index de02db802ace..620ab7d92692 100644
--- a/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c
+++ b/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c
@@ -253,13 +253,6 @@ static int dvb_usbv2_adapter_stream_exit(struct dvb_us=
b_adapter *adap)
 	return usb_urb_exitv2(&adap->stream);
 }
=20
-static int wait_schedule(void *ptr)
-{
-	schedule();
-
-	return 0;
-}
-
 static int dvb_usb_start_feed(struct dvb_demux_feed *dvbdmxfeed)
 {
 	struct dvb_usb_adapter *adap =3D dvbdmxfeed->demux->priv;
@@ -273,7 +266,7 @@ static int dvb_usb_start_feed(struct dvb_demux_feed *dv=
bdmxfeed)
 			dvbdmxfeed->pid, dvbdmxfeed->index);
=20
 	/* wait init is done */
-	wait_on_bit(&adap->state_bits, ADAP_INIT, wait_schedule,
+	wait_on_bit(&adap->state_bits, ADAP_INIT,
 			TASK_UNINTERRUPTIBLE);
=20
 	if (adap->active_fe =3D=3D -1)
@@ -568,7 +561,7 @@ static int dvb_usb_fe_sleep(struct dvb_frontend *fe)
=20
 	if (!adap->suspend_resume_active) {
 		set_bit(ADAP_SLEEP, &adap->state_bits);
-		wait_on_bit(&adap->state_bits, ADAP_STREAMING, wait_schedule,
+		wait_on_bit(&adap->state_bits, ADAP_STREAMING,
 				TASK_UNINTERRUPTIBLE);
 	}
=20
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 3955e475ceec..35bdf6623a2c 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3373,16 +3373,10 @@ done_unlocked:
 	return 0;
 }
=20
-static int eb_wait(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
 void wait_on_extent_buffer_writeback(struct extent_buffer *eb)
 {
-	wait_on_bit(&eb->bflags, EXTENT_BUFFER_WRITEBACK, eb_wait,
-		    TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&eb->bflags, EXTENT_BUFFER_WRITEBACK,
+		       TASK_UNINTERRUPTIBLE);
 }
=20
 static int lock_extent_buffer_for_io(struct extent_buffer *eb,
diff --git a/fs/buffer.c b/fs/buffer.c
index 9ddb9fc7d923..2f3b63882c72 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -61,16 +61,9 @@ inline void touch_buffer(struct buffer_head *bh)
 }
 EXPORT_SYMBOL(touch_buffer);
=20
-static int sleep_on_buffer(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
 void __lock_buffer(struct buffer_head *bh)
 {
-	wait_on_bit_lock(&bh->b_state, BH_Lock, sleep_on_buffer,
-							TASK_UNINTERRUPTIBLE);
+	wait_on_bit_lock_io(&bh->b_state, BH_Lock, TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__lock_buffer);
=20
@@ -123,7 +116,7 @@ EXPORT_SYMBOL(buffer_check_dirty_writeback);
  */
 void __wait_on_buffer(struct buffer_head * bh)
 {
-	wait_on_bit(&bh->b_state, BH_Lock, sleep_on_buffer, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&bh->b_state, BH_Lock, TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__wait_on_buffer);
=20
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 8813ff776ba3..d4a24ef95647 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -3931,13 +3931,6 @@ cifs_sb_master_tcon(struct cifs_sb_info *cifs_sb)
 	return tlink_tcon(cifs_sb_master_tlink(cifs_sb));
 }
=20
-static int
-cifs_sb_tcon_pending_wait(void *unused)
-{
-	schedule();
-	return signal_pending(current) ? -ERESTARTSYS : 0;
-}
-
 /* find and return a tlink with given uid */
 static struct tcon_link *
 tlink_rb_search(struct rb_root *root, kuid_t uid)
@@ -4036,11 +4029,10 @@ cifs_sb_tlink(struct cifs_sb_info *cifs_sb)
 	} else {
 wait_for_construction:
 		ret =3D wait_on_bit(&tlink->tl_flags, TCON_LINK_PENDING,
-				  cifs_sb_tcon_pending_wait,
 				  TASK_INTERRUPTIBLE);
 		if (ret) {
 			cifs_put_tlink(tlink);
-			return ERR_PTR(ret);
+			return ERR_PTR(-ERESTARTSYS);
 		}
=20
 		/* if it's good, return it */
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index be568b7311d6..ef9bef118342 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -342,7 +342,8 @@ static void __inode_wait_for_writeback(struct inode *in=
ode)
 	wqh =3D bit_waitqueue(&inode->i_state, __I_SYNC);
 	while (inode->i_state & I_SYNC) {
 		spin_unlock(&inode->i_lock);
-		__wait_on_bit(wqh, &wq, inode_wait, TASK_UNINTERRUPTIBLE);
+		__wait_on_bit(wqh, &wq, bit_wait,
+			      TASK_UNINTERRUPTIBLE);
 		spin_lock(&inode->i_lock);
 	}
 }
diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 29d7feb62cf7..faf8bf87b5c5 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -160,7 +160,7 @@ void __fscache_enable_cookie(struct fscache_cookie *coo=
kie,
 	_enter("%p", cookie);
=20
 	wait_on_bit_lock(&cookie->flags, FSCACHE_COOKIE_ENABLEMENT_LOCK,
-			 fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			 TASK_UNINTERRUPTIBLE);
=20
 	if (test_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags))
 		goto out_unlock;
@@ -255,7 +255,7 @@ static int fscache_acquire_non_index_cookie(struct fsca=
che_cookie *cookie)
 	if (!fscache_defer_lookup) {
 		_debug("non-deferred lookup %p", &cookie->flags);
 		wait_on_bit(&cookie->flags, FSCACHE_COOKIE_LOOKING_UP,
-			    fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		_debug("complete");
 		if (test_bit(FSCACHE_COOKIE_UNAVAILABLE, &cookie->flags))
 			goto unavailable;
@@ -463,7 +463,6 @@ void __fscache_wait_on_invalidate(struct fscache_cookie=
 *cookie)
 	_enter("%p", cookie);
=20
 	wait_on_bit(&cookie->flags, FSCACHE_COOKIE_INVALIDATING,
-		    fscache_wait_bit_interruptible,
 		    TASK_UNINTERRUPTIBLE);
=20
 	_leave("");
@@ -525,7 +524,7 @@ void __fscache_disable_cookie(struct fscache_cookie *co=
okie, bool invalidate)
 	}
=20
 	wait_on_bit_lock(&cookie->flags, FSCACHE_COOKIE_ENABLEMENT_LOCK,
-			 fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			 TASK_UNINTERRUPTIBLE);
 	if (!test_and_clear_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags))
 		goto out_unlock_enable;
=20
diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index 4226f6680b06..28da12e5559d 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -91,8 +91,6 @@ static inline bool fscache_object_congested(void)
 	return workqueue_congested(WORK_CPU_UNBOUND, fscache_object_wq);
 }
=20
-extern int fscache_wait_bit(void *);
-extern int fscache_wait_bit_interruptible(void *);
 extern int fscache_wait_atomic_t(atomic_t *);
=20
 /*
diff --git a/fs/fscache/main.c b/fs/fscache/main.c
index 7c27907e650c..818057de05c6 100644
--- a/fs/fscache/main.c
+++ b/fs/fscache/main.c
@@ -198,24 +198,6 @@ static void __exit fscache_exit(void)
 module_exit(fscache_exit);
=20
 /*
- * wait_on_bit() sleep function for uninterruptible waiting
- */
-int fscache_wait_bit(void *flags)
-{
-	schedule();
-	return 0;
-}
-
-/*
- * wait_on_bit() sleep function for interruptible waiting
- */
-int fscache_wait_bit_interruptible(void *flags)
-{
-	schedule();
-	return signal_pending(current);
-}
-
-/*
  * wait_on_atomic_t() sleep function for uninterruptible waiting
  */
 int fscache_wait_atomic_t(atomic_t *p)
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 7f5c658af755..e9bb50c391db 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -298,7 +298,6 @@ int fscache_wait_for_deferred_lookup(struct fscache_coo=
kie *cookie)
=20
 	jif =3D jiffies;
 	if (wait_on_bit(&cookie->flags, FSCACHE_COOKIE_LOOKING_UP,
-			fscache_wait_bit_interruptible,
 			TASK_INTERRUPTIBLE) !=3D 0) {
 		fscache_stat(&fscache_n_retrievals_intr);
 		_leave(" =3D -ERESTARTSYS");
@@ -342,7 +341,6 @@ int fscache_wait_for_operation_activation(struct fscach=
e_object *object,
 	if (stat_op_waits)
 		fscache_stat(stat_op_waits);
 	if (wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
-			fscache_wait_bit_interruptible,
 			TASK_INTERRUPTIBLE) !=3D 0) {
 		ret =3D fscache_cancel_op(op, do_cancel);
 		if (ret =3D=3D 0)
@@ -351,7 +349,7 @@ int fscache_wait_for_operation_activation(struct fscach=
e_object *object,
 		/* it's been removed from the pending queue by another party,
 		 * so we should get to run shortly */
 		wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
-			    fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 	}
 	_debug("<<< GO");
=20
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index aec7f73832f0..6f617dc8629a 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -856,27 +856,6 @@ void gfs2_holder_uninit(struct gfs2_holder *gh)
 }
=20
 /**
- * gfs2_glock_holder_wait
- * @word: unused
- *
- * This function and gfs2_glock_demote_wait both show up in the WCHAN
- * field. Thus I've separated these otherwise identical functions in
- * order to be more informative to the user.
- */
-
-static int gfs2_glock_holder_wait(void *word)
-{
-        schedule();
-        return 0;
-}
-
-static int gfs2_glock_demote_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
-/**
  * gfs2_glock_wait - wait on a glock acquisition
  * @gh: the glock holder
  *
@@ -888,7 +867,7 @@ int gfs2_glock_wait(struct gfs2_holder *gh)
 	unsigned long time1 =3D jiffies;
=20
 	might_sleep();
-	wait_on_bit(&gh->gh_iflags, HIF_WAIT, gfs2_glock_holder_wait, TASK_UNINTE=
RRUPTIBLE);
+	wait_on_bit(&gh->gh_iflags, HIF_WAIT, TASK_UNINTERRUPTIBLE);
 	if (time_after(jiffies, time1 + HZ)) /* have we waited > a second? */
 		/* Lengthen the minimum hold time. */
 		gh->gh_gl->gl_hold_time =3D min(gh->gh_gl->gl_hold_time +
@@ -1128,7 +1107,7 @@ void gfs2_glock_dq_wait(struct gfs2_holder *gh)
 	struct gfs2_glock *gl =3D gh->gh_gl;
 	gfs2_glock_dq(gh);
 	might_sleep();
-	wait_on_bit(&gl->gl_flags, GLF_DEMOTE, gfs2_glock_demote_wait, TASK_UNINT=
ERRUPTIBLE);
+	wait_on_bit(&gl->gl_flags, GLF_DEMOTE, TASK_UNINTERRUPTIBLE);
 }
=20
 /**
diff --git a/fs/gfs2/lock_dlm.c b/fs/gfs2/lock_dlm.c
index c1eb555dc588..fe112daf1174 100644
--- a/fs/gfs2/lock_dlm.c
+++ b/fs/gfs2/lock_dlm.c
@@ -936,12 +936,6 @@ fail:
 	return error;
 }
=20
-static int dlm_recovery_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
 static int control_first_done(struct gfs2_sbd *sdp)
 {
 	struct lm_lockstruct *ls =3D &sdp->sd_lockstruct;
@@ -976,7 +970,7 @@ restart:
 		fs_info(sdp, "control_first_done wait gen %u\n", start_gen);
=20
 		wait_on_bit(&ls->ls_recover_flags, DFL_DLM_RECOVERY,
-			    dlm_recovery_wait, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		goto restart;
 	}
=20
diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
index 22f954051bb8..0e5b0943f278 100644
--- a/fs/gfs2/ops_fstype.c
+++ b/fs/gfs2/ops_fstype.c
@@ -1010,20 +1010,13 @@ void gfs2_lm_unmount(struct gfs2_sbd *sdp)
 		lm->lm_unmount(sdp);
 }
=20
-static int gfs2_journalid_wait(void *word)
-{
-	if (signal_pending(current))
-		return -EINTR;
-	schedule();
-	return 0;
-}
-
 static int wait_on_journal(struct gfs2_sbd *sdp)
 {
 	if (sdp->sd_lockstruct.ls_ops->lm_mount =3D=3D NULL)
 		return 0;
=20
-	return wait_on_bit(&sdp->sd_flags, SDF_NOJOURNALID, gfs2_journalid_wait, =
TASK_INTERRUPTIBLE);
+	return wait_on_bit(&sdp->sd_flags, SDF_NOJOURNALID, TASK_INTERRUPTIBLE)
+		? -EINTR : 0;
 }
=20
 void gfs2_online_uevent(struct gfs2_sbd *sdp)
diff --git a/fs/gfs2/recovery.c b/fs/gfs2/recovery.c
index 7ad4094d68c0..dc6b6d1ddcb5 100644
--- a/fs/gfs2/recovery.c
+++ b/fs/gfs2/recovery.c
@@ -591,12 +591,6 @@ done:
 	wake_up_bit(&jd->jd_flags, JDF_RECOVERY);
 }
=20
-static int gfs2_recovery_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
 int gfs2_recover_journal(struct gfs2_jdesc *jd, bool wait)
 {
 	int rv;
@@ -609,7 +603,7 @@ int gfs2_recover_journal(struct gfs2_jdesc *jd, bool wa=
it)
 	BUG_ON(!rv);
=20
 	if (wait)
-		wait_on_bit(&jd->jd_flags, JDF_RECOVERY, gfs2_recovery_wait,
+		wait_on_bit(&jd->jd_flags, JDF_RECOVERY,
 			    TASK_UNINTERRUPTIBLE);
=20
 	return wait ? jd->jd_recover_error : 0;
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index de8afad89e51..21f22b809592 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -850,12 +850,6 @@ static int gfs2_make_fs_ro(struct gfs2_sbd *sdp)
 	return error;
 }
=20
-static int gfs2_umount_recovery_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
 /**
  * gfs2_put_super - Unmount the filesystem
  * @sb: The VFS superblock
@@ -880,7 +874,7 @@ restart:
 			continue;
 		spin_unlock(&sdp->sd_jindex_spin);
 		wait_on_bit(&jd->jd_flags, JDF_RECOVERY,
-			    gfs2_umount_recovery_wait, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		goto restart;
 	}
 	spin_unlock(&sdp->sd_jindex_spin);
diff --git a/fs/inode.c b/fs/inode.c
index f96d2a6f88cc..389d0d379f8a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1695,13 +1695,6 @@ int inode_needs_sync(struct inode *inode)
 }
 EXPORT_SYMBOL(inode_needs_sync);
=20
-int inode_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-EXPORT_SYMBOL(inode_wait);
-
 /*
  * If we try to find an inode in the inode hash while it is being
  * deleted, we have to wait until the filesystem completes its
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 38cfcf5f6fce..44ab297cecba 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -763,12 +763,6 @@ static void warn_dirty_buffer(struct buffer_head *bh)
 	       bdevname(bh->b_bdev, b), (unsigned long long)bh->b_blocknr);
 }
=20
-static int sleep_on_shadow_bh(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
 /*
  * If the buffer is already part of the current transaction, then there
  * is nothing we need to do.  If it is already part of a prior
@@ -906,8 +900,8 @@ repeat:
 		if (buffer_shadow(bh)) {
 			JBUFFER_TRACE(jh, "on shadow: sleep");
 			jbd_unlock_bh_state(bh);
-			wait_on_bit(&bh->b_state, BH_Shadow,
-				    sleep_on_shadow_bh, TASK_UNINTERRUPTIBLE);
+			wait_on_bit_io(&bh->b_state, BH_Shadow,
+				       TASK_UNINTERRUPTIBLE);
 			goto repeat;
 		}
=20
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 284ca901fe16..6ffbc3dc6714 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -362,8 +362,8 @@ start:
 	 * Prevent starvation issues if someone is doing a consistency
 	 * sync-to-disk
 	 */
-	ret =3D wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
+	ret =3D wait_on_bit_action(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
+				 nfs_wait_bit_killable, TASK_KILLABLE);
 	if (ret)
 		return ret;
=20
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0c438973f3c8..cd6e656d839e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1061,8 +1061,8 @@ int nfs_revalidate_mapping(struct inode *inode, struc=
t address_space *mapping)
 	 * the bit lock here if it looks like we're going to be doing that.
 	 */
 	for (;;) {
-		ret =3D wait_on_bit(bitlock, NFS_INO_INVALIDATING,
-				  nfs_wait_bit_killable, TASK_KILLABLE);
+		ret =3D wait_on_bit_action(bitlock, NFS_INO_INVALIDATING,
+					 nfs_wait_bit_killable, TASK_KILLABLE);
 		if (ret)
 			goto out;
 		spin_lock(&inode->i_lock);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index efac602edb37..9b9f8a21f29c 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -783,8 +783,8 @@ nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, =
u32 j)
 static void nfs4_wait_ds_connect(struct nfs4_pnfs_ds *ds)
 {
 	might_sleep();
-	wait_on_bit(&ds->ds_state, NFS4DS_CONNECTING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
+	wait_on_bit_action(&ds->ds_state, NFS4DS_CONNECTING,
+			   nfs_wait_bit_killable, TASK_KILLABLE);
 }
=20
 static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2349518eef2c..2ec217e5f899 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1251,8 +1251,8 @@ int nfs4_wait_clnt_recover(struct nfs_client *clp)
 	might_sleep();
=20
 	atomic_inc(&clp->cl_count);
-	res =3D wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
+	res =3D wait_on_bit_action(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
+				 nfs_wait_bit_killable, TASK_KILLABLE);
 	if (res)
 		goto out;
 	if (clp->cl_cons_state < 0)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 2ffebf2081ce..f369a74f2b31 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -258,12 +258,6 @@ void nfs_release_request(struct nfs_page *req)
 	kref_put(&req->wb_kref, nfs_free_request);
 }
=20
-static int nfs_wait_bit_uninterruptible(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
 /**
  * nfs_wait_on_request - Wait for a request to complete.
  * @req: request to wait upon.
@@ -274,9 +268,8 @@ static int nfs_wait_bit_uninterruptible(void *word)
 int
 nfs_wait_on_request(struct nfs_page *req)
 {
-	return wait_on_bit(&req->wb_flags, PG_BUSY,
-			nfs_wait_bit_uninterruptible,
-			TASK_UNINTERRUPTIBLE);
+	return wait_on_bit_io(&req->wb_flags, PG_BUSY,
+			      TASK_UNINTERRUPTIBLE);
 }
=20
 bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_pa=
ge *prev, struct nfs_page *req)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cb53d450ae32..f5cbe18e01a8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1913,7 +1913,7 @@ pnfs_layoutcommit_inode(struct inode *inode, bool syn=
c)
 	if (test_and_set_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags)) {
 		if (!sync)
 			goto out;
-		status =3D wait_on_bit_lock(&nfsi->flags,
+		status =3D wait_on_bit_lock_action(&nfsi->flags,
 				NFS_INO_LAYOUTCOMMITTING,
 				nfs_wait_bit_killable,
 				TASK_KILLABLE);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9a3b6a4cd6b9..2f2871c4eaa8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -393,7 +393,7 @@ int nfs_writepages(struct address_space *mapping, struc=
t writeback_control *wbc)
 	int err;
=20
 	/* Stop dirtying of new pages while we sync */
-	err =3D wait_on_bit_lock(bitlock, NFS_INO_FLUSHING,
+	err =3D wait_on_bit_lock_action(bitlock, NFS_INO_FLUSHING,
 			nfs_wait_bit_killable, TASK_KILLABLE);
 	if (err)
 		goto out_err;
@@ -1694,7 +1694,7 @@ int nfs_commit_inode(struct inode *inode, int how)
 			return error;
 		if (!may_wait)
 			goto out_mark_dirty;
-		error =3D wait_on_bit(&NFS_I(inode)->flags,
+		error =3D wait_on_bit_action(&NFS_I(inode)->flags,
 				NFS_INO_COMMIT,
 				nfs_wait_bit_killable,
 				TASK_KILLABLE);
diff --git a/include/linux/wait.h b/include/linux/wait.h
index bd68819f0815..438dc6044587 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -854,11 +854,14 @@ int wake_bit_function(wait_queue_t *wait, unsigned mo=
de, int sync, void *key);
 		(wait)->flags =3D 0;					\
 	} while (0)
=20
+
+extern int bit_wait(void *);
+extern int bit_wait_io(void *);
+
 /**
  * wait_on_bit - wait for a bit to be cleared
  * @word: the word being waited on, a kernel virtual address
  * @bit: the bit of the word being waited on
- * @action: the function used to sleep, which may take special actions
  * @mode: the task state to sleep in
  *
  * There is a standard hashed waitqueue table for generic use. This
@@ -867,9 +870,62 @@ int wake_bit_function(wait_queue_t *wait, unsigned mod=
e, int sync, void *key);
  * call wait_on_bit() in threads waiting for the bit to clear.
  * One uses wait_on_bit() where one is waiting for the bit to clear,
  * but has no intention of setting it.
+ * Returned value will be zero if the bit was cleared, or non-zero
+ * if the process received a signal and the mode permitted wakeup
+ * on that signal.
+ */
+static inline int
+wait_on_bit(void *word, int bit, unsigned mode)
+{
+	if (!test_bit(bit, word))
+		return 0;
+	return out_of_line_wait_on_bit(word, bit,
+				       bit_wait,
+				       mode & 65535);
+}
+
+/**
+ * wait_on_bit_io - wait for a bit to be cleared
+ * @word: the word being waited on, a kernel virtual address
+ * @bit: the bit of the word being waited on
+ * @mode: the task state to sleep in
+ *
+ * Use the standard hashed waitqueue table to wait for a bit
+ * to be cleared.  This is similar to wait_on_bit(), but calls
+ * io_schedule() instead of schedule() for the actual waiting.
+ *
+ * Returned value will be zero if the bit was cleared, or non-zero
+ * if the process received a signal and the mode permitted wakeup
+ * on that signal.
+ */
+static inline int
+wait_on_bit_io(void *word, int bit, unsigned mode)
+{
+	if (!test_bit(bit, word))
+		return 0;
+	return out_of_line_wait_on_bit(word, bit,
+				       bit_wait_io,
+				       mode & 65535);
+}
+
+/**
+ * wait_on_bit_action - wait for a bit to be cleared
+ * @word: the word being waited on, a kernel virtual address
+ * @bit: the bit of the word being waited on
+ * @action: the function used to sleep, which may take special actions
+ * @mode: the task state to sleep in
+ *
+ * Use the standard hashed waitqueue table to wait for a bit
+ * to be cleared, and allow the waiting action to be specified.
+ * This is like wait_on_bit() but allows fine control of how the waiting
+ * is done.
+ *
+ * Returned value will be zero if the bit was cleared, or non-zero
+ * if the process received a signal and the mode permitted wakeup
+ * on that signal.
  */
 static inline int
-wait_on_bit(void *word, int bit, int (*action)(void *), unsigned mode)
+wait_on_bit_action(void *word, int bit, int (*action)(void *), unsigned mo=
de)
 {
 	if (!test_bit(bit, word))
 		return 0;
@@ -880,7 +936,6 @@ wait_on_bit(void *word, int bit, int (*action)(void *),=
 unsigned mode)
  * wait_on_bit_lock - wait for a bit to be cleared, when wanting to set it
  * @word: the word being waited on, a kernel virtual address
  * @bit: the bit of the word being waited on
- * @action: the function used to sleep, which may take special actions
  * @mode: the task state to sleep in
  *
  * There is a standard hashed waitqueue table for generic use. This
@@ -891,9 +946,61 @@ wait_on_bit(void *word, int bit, int (*action)(void *)=
, unsigned mode)
  * wait_on_bit() in threads waiting to be able to set the bit.
  * One uses wait_on_bit_lock() where one is waiting for the bit to
  * clear with the intention of setting it, and when done, clearing it.
+ *
+ * Returns zero if the bit was (eventually) found to be clear and was
+ * set.  Returns non-zero if a signal was delivered to the process and
+ * the @mode allows that signal to wake the process.
+ */
+static inline int
+wait_on_bit_lock(void *word, int bit, unsigned mode)
+{
+	if (!test_and_set_bit(bit, word))
+		return 0;
+	return out_of_line_wait_on_bit_lock(word, bit, bit_wait, mode);
+}
+
+/**
+ * wait_on_bit_lock - wait for a bit to be cleared, when wanting to set it
+ * @word: the word being waited on, a kernel virtual address
+ * @bit: the bit of the word being waited on
+ * @mode: the task state to sleep in
+ *
+ * Use the standard hashed waitqueue table to wait for a bit
+ * to be cleared and then to atomically set it.  This is similar
+ * to wait_on_bit(), but calls io_schedule() instead of schedule()
+ * for the actual waiting.
+ *
+ * Returns zero if the bit was (eventually) found to be clear and was
+ * set.  Returns non-zero if a signal was delivered to the process and
+ * the @mode allows that signal to wake the process.
+ */
+static inline int
+wait_on_bit_lock_io(void *word, int bit, unsigned mode)
+{
+	if (!test_and_set_bit(bit, word))
+		return 0;
+	return out_of_line_wait_on_bit_lock(word, bit, bit_wait_io, mode);
+}
+
+/**
+ * wait_on_bit_lock_action - wait for a bit to be cleared, when wanting to=
 set it
+ * @word: the word being waited on, a kernel virtual address
+ * @bit: the bit of the word being waited on
+ * @action: the function used to sleep, which may take special actions
+ * @mode: the task state to sleep in
+ *
+ * Use the standard hashed waitqueue table to wait for a bit
+ * to be cleared and then to set it, and allow the waiting action
+ * to be specified.
+ * This is like wait_on_bit() but allows fine control of how the waiting
+ * is done.
+ *
+ * Returns zero if the bit was (eventually) found to be clear and was
+ * set.  Returns non-zero if a signal was delivered to the process and
+ * the @mode allows that signal to wake the process.
  */
 static inline int
-wait_on_bit_lock(void *word, int bit, int (*action)(void *), unsigned mode)
+wait_on_bit_lock_action(void *word, int bit, int (*action)(void *), unsign=
ed mode)
 {
 	if (!test_and_set_bit(bit, word))
 		return 0;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 5777c13849ba..a219be961c0a 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -90,7 +90,6 @@ struct writeback_control {
  * fs/fs-writeback.c
  */=09
 struct bdi_writeback;
-int inode_wait(void *);
 void writeback_inodes_sb(struct super_block *, enum wb_reason reason);
 void writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 							enum wb_reason reason);
@@ -105,7 +104,7 @@ void inode_wait_for_writeback(struct inode *inode);
 static inline void wait_on_inode(struct inode *inode)
 {
 	might_sleep();
-	wait_on_bit(&inode->i_state, __I_NEW, inode_wait, TASK_UNINTERRUPTIBLE);
+	wait_on_bit(&inode->i_state, __I_NEW, TASK_UNINTERRUPTIBLE);
 }
=20
 /*
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index adf98622cb32..54e75226c2c4 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -28,12 +28,6 @@
 #include <linux/compat.h>
=20
=20
-static int ptrace_trapping_sleep_fn(void *flags)
-{
-	schedule();
-	return 0;
-}
-
 /*
  * ptrace a task: make the debugger its new parent and
  * move it to the ptrace list.
@@ -371,7 +365,7 @@ unlock_creds:
 out:
 	if (!retval) {
 		wait_on_bit(&task->jobctl, JOBCTL_TRAPPING_BIT,
-			    ptrace_trapping_sleep_fn, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		proc_ptrace_connector(task, PTRACE_ATTACH);
 	}
=20
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 7d50f794e248..0c0795002f56 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -502,3 +502,21 @@ void wake_up_atomic_t(atomic_t *p)
 	__wake_up_bit(atomic_t_waitqueue(p), p, WAIT_ATOMIC_T_BIT_NR);
 }
 EXPORT_SYMBOL(wake_up_atomic_t);
+
+__sched int bit_wait(void *word)
+{
+	if (signal_pending_state(current->state, current))
+		return 1;
+	schedule();
+	return 0;
+}
+EXPORT_SYMBOL(bit_wait);
+
+__sched int bit_wait_io(void *word)
+{
+	if (signal_pending_state(current->state, current))
+		return 1;
+	io_schedule();
+	return 0;
+}
+EXPORT_SYMBOL(bit_wait_io);
diff --git a/mm/filemap.c b/mm/filemap.c
index 5020b280a771..ce6be16eae73 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -241,18 +241,6 @@ void delete_from_page_cache(struct page *page)
 }
 EXPORT_SYMBOL(delete_from_page_cache);
=20
-static int sleep_on_page(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
-static int sleep_on_page_killable(void *word)
-{
-	sleep_on_page(word);
-	return fatal_signal_pending(current) ? -EINTR : 0;
-}
-
 static int filemap_check_errors(struct address_space *mapping)
 {
 	int ret =3D 0;
@@ -690,7 +678,7 @@ void wait_on_page_bit(struct page *page, int bit_nr)
 	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
=20
 	if (test_bit(bit_nr, &page->flags))
-		__wait_on_bit(page_waitqueue(page), &wait, sleep_on_page,
+		__wait_on_bit(page_waitqueue(page), &wait, bit_wait_io,
 							TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(wait_on_page_bit);
@@ -703,7 +691,7 @@ int wait_on_page_bit_killable(struct page *page, int bi=
t_nr)
 		return 0;
=20
 	return __wait_on_bit(page_waitqueue(page), &wait,
-			     sleep_on_page_killable, TASK_KILLABLE);
+			     bit_wait_io, TASK_KILLABLE);
 }
=20
 /**
@@ -770,7 +758,7 @@ void __lock_page(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
=20
-	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
+	__wait_on_bit_lock(page_waitqueue(page), &wait, bit_wait_io,
 							TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__lock_page);
@@ -780,7 +768,7 @@ int __lock_page_killable(struct page *page)
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
=20
 	return __wait_on_bit_lock(page_waitqueue(page), &wait,
-					sleep_on_page_killable, TASK_KILLABLE);
+					bit_wait_io, TASK_KILLABLE);
 }
 EXPORT_SYMBOL_GPL(__lock_page_killable);
=20
diff --git a/mm/ksm.c b/mm/ksm.c
index 68710e80994a..33c8b475df65 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1979,18 +1979,12 @@ void ksm_migrate_page(struct page *newpage, struct =
page *oldpage)
 #endif /* CONFIG_MIGRATION */
=20
 #ifdef CONFIG_MEMORY_HOTREMOVE
-static int just_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
 static void wait_while_offlining(void)
 {
 	while (ksm_run & KSM_RUN_OFFLINE) {
 		mutex_unlock(&ksm_thread_mutex);
 		wait_on_bit(&ksm_run, ilog2(KSM_RUN_OFFLINE),
-				just_wait, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		mutex_lock(&ksm_thread_mutex);
 	}
 }
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 1c6ffaa8902f..e9ef6516c693 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -2127,12 +2127,6 @@ static void hci_inq_req(struct hci_request *req, uns=
igned long opt)
 	hci_req_add(req, HCI_OP_INQUIRY, sizeof(cp), &cp);
 }
=20
-static int wait_inquiry(void *word)
-{
-	schedule();
-	return signal_pending(current);
-}
-
 int hci_inquiry(void __user *arg)
 {
 	__u8 __user *ptr =3D arg;
@@ -2183,7 +2177,7 @@ int hci_inquiry(void __user *arg)
 		/* Wait until Inquiry procedure finishes (HCI_INQUIRY flag is
 		 * cleared). If it is interrupted by a signal, return -EINTR.
 		 */
-		if (wait_on_bit(&hdev->flags, HCI_INQUIRY, wait_inquiry,
+		if (wait_on_bit(&hdev->flags, HCI_INQUIRY,
 				TASK_INTERRUPTIBLE))
 			return -EINTR;
 	}
diff --git a/security/keys/gc.c b/security/keys/gc.c
index d3222b6d7d59..9609a7f0faea 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -92,15 +92,6 @@ static void key_gc_timer_func(unsigned long data)
 }
=20
 /*
- * wait_on_bit() sleep function for uninterruptible waiting
- */
-static int key_gc_wait_bit(void *flags)
-{
-	schedule();
-	return 0;
-}
-
-/*
  * Reap keys of dead type.
  *
  * We use three flags to make sure we see three complete cycles of the gar=
bage
@@ -123,7 +114,7 @@ void key_gc_keytype(struct key_type *ktype)
 	schedule_work(&key_gc_work);
=20
 	kdebug("sleep");
-	wait_on_bit(&key_gc_flags, KEY_GC_REAPING_KEYTYPE, key_gc_wait_bit,
+	wait_on_bit(&key_gc_flags, KEY_GC_REAPING_KEYTYPE,
 		    TASK_UNINTERRUPTIBLE);
=20
 	key_gc_dead_keytype =3D NULL;
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 381411941cc1..26a94f18af94 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -21,24 +21,6 @@
=20
 #define key_negative_timeout	60	/* default timeout on a negative key's exi=
stence */
=20
-/*
- * wait_on_bit() sleep function for uninterruptible waiting
- */
-static int key_wait_bit(void *flags)
-{
-	schedule();
-	return 0;
-}
-
-/*
- * wait_on_bit() sleep function for interruptible waiting
- */
-static int key_wait_bit_intr(void *flags)
-{
-	schedule();
-	return signal_pending(current) ? -ERESTARTSYS : 0;
-}
-
 /**
  * complete_request_key - Complete the construction of a key.
  * @cons: The key construction record.
@@ -592,10 +574,9 @@ int wait_for_key_construction(struct key *key, bool in=
tr)
 	int ret;
=20
 	ret =3D wait_on_bit(&key->flags, KEY_FLAG_USER_CONSTRUCT,
-			  intr ? key_wait_bit_intr : key_wait_bit,
 			  intr ? TASK_INTERRUPTIBLE : TASK_UNINTERRUPTIBLE);
-	if (ret < 0)
-		return ret;
+	if (ret)
+		return -ERESTARTSYS;
 	if (test_bit(KEY_FLAG_NEGATIVE, &key->flags)) {
 		smp_rmb();
 		return key->type_data.reject_error;

--Sig_/9+OzCq1pr/H.F0YtKwas2wv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU2Gzcjnsnt1WYoG5AQJ0Xw//THqC3dLnhP1EMmUYpOapyCCRVODd7x6M
RpwdOtVGDYHb9FhMLFiUQCuRmWiroepOwSAtk0tdF3ZYzjNHypv86tNOzGPRUNpX
naX+vUJGzK9aJcQCiFWR1v5gEcqIfhmTGCORKAB2d21ydtifhCLx2TbLODFki7T2
DzRWj6rTbrzrfYrIqk9XSRuDvpUe4XF+9I31kbLx9n42tmiXbvJMEyH/3f6fpovj
ajUW5sBqVzIGQqyoSKFcQ23AYaObk4vNYZCBMpne6eXsPLoPnP3ArXgEPkGBD47H
+m2p2GCqaHz5Fie76jKGoPCsInxd0awqKPDgYBOiQAH4kIJnQnSpesm3g9r8x3oO
zGlmSLOyzuua7gDX9ceAxqJZtcPKZ2sdKU8kbcJhSvnhmz4IMRtmIFhVQcRQxKC7
a/Wf/fcR9kjCDLK6kzXkHz2bfuxMGFLBTL0ZtWcCvhjB5RkvSHB9a2xmjufEOobC
6KWO4rBmoSQsMcxvrwTKIbSNd0G6ZEElz+NfPdeHffxop8QTHFYznCPUpIU8J0CZ
GjKpS3HlN4yN/bdE9947+X7UUjbvJi3NFCjDUEpPL3VuWxIUaVlOdpnTsbdz14PR
CJFL6W98NwPc24SX/fRpFyClYJWm+95waKQ1Ov00wZFPl5TJTWGx0kJkAkDfSaEh
AXDAfj16mFs=
=AFPS
-----END PGP SIGNATURE-----

--Sig_/9+OzCq1pr/H.F0YtKwas2wv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
