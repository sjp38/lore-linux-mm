Date: Sun, 11 Jun 2000 20:23:47 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: -ac13 buffer.c MAJOR bug
Message-ID: <20000611202347.E5506@redhat.com>
References: <200006111558.QAA02702@raistlin.arm.linux.org.uk> <3943BFA0.445B747C@sls.lcs.mit.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Content-Disposition: inline
In-Reply-To: <3943BFA0.445B747C@sls.lcs.mit.edu>; from ilh@sls.lcs.mit.edu on Sun, Jun 11, 2000 at 12:34:40PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: I Lee Hetherington <ilh@sls.lcs.mit.edu>
Cc: Russell King <rmk@arm.linux.org.uk>, Alan Cox <alan@lxorguk.ukuu.org.uk>, sully@omega.barnet.ac.uk, Bryan Paxton <evil7@bellsouth.net>, linux-kernel@vger.rutgers.edu, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

On Sun, Jun 11, 2000 at 12:34:40PM -0400, I Lee Hetherington wrote:
> I am not seeing this BUG in ac12.  It is solid for me.  It would seem to
> be an ac13 feature.

It is.  The fix is below.

The problem is that with async write-behind, buffers on the per-inode
dirty list can be cleaned and I/O can complete before the vm scanner
identifies the clean buffer and refiles it (which will remove if from
the inode list).  So, we can end up with clean buffers on the per-inode
dirty list.  It is quite legal to recycle these buffers, and 
try_to_free_buffers() already owns the necessary spinlocks to do so
by the time it gets this far.

--Stephen

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="osync-2.4.0-test1-ac13.diff1"

--- linux-2.4.0-test1-ac13/fs/buffer.c.~1~	Sun Jun 11 19:50:22 2000
+++ linux-2.4.0-test1-ac13/fs/buffer.c	Sun Jun 11 19:54:57 2000
@@ -2438,9 +2438,7 @@
 		 * queues or on the free list..
 		 */
 		if (p->b_dev != B_FREE) {
-			// @@@
-			if (p->b_inode)
-				BUG();
+			remove_inode_queue(p);
 			__remove_from_queues(p);
 		}
 		else

--Nq2Wo0NMKNjxTN9z--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
