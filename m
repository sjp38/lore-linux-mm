Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA5Gslfp002949
	for <linux-mm@kvack.org>; Mon, 5 Nov 2007 11:54:47 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA5GkDUx124744
	for <linux-mm@kvack.org>; Mon, 5 Nov 2007 09:54:47 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA5Gd2Bb028472
	for <linux-mm@kvack.org>; Mon, 5 Nov 2007 09:39:03 -0700
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0711051358440.7629@blonde.wat.veritas.com>
References: <200710312353.l9VNr67n013016@agora.fsl.cs.sunysb.edu>
	 <Pine.LNX.4.64.0711051358440.7629@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Mon, 05 Nov 2007 08:38:50 -0800
Message-Id: <1194280730.6271.145.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-11-05 at 15:40 +0000, Hugh Dickins wrote:
> The second problem was a hang: all cpus in
> handle_write_count_underflow
> doing lock_and_coalesce_cpu_mnt_writer_counts: new -mm stuff from Dave
> Hansen.  At first I thought that was a locking problem in Dave's code,
> but I now suspect it's that your unionfs reference counting is wrong
> somewhere, and the error accumulates until __mnt_writers drops below
> MNT_WRITER_UNDERFLOW_LIMIT, but the coalescence does nothing to help
> and we're stuck in that loop. 

I've never actually seen this happen in practice, but I do know exactly
what you're talking about.

> but I hope Dave can
> also make handle_write_count_underflow more robust, it's unfortunate
> if refcount errors elsewhere first show up as a hang there.

Actually, I think your s/while/if/ change is probably a decent fix.
Barring any other races, that loop should always have made progress on
mnt->__mnt_writers the way it is written.  If we get to:

>                 lock_and_coalesce_cpu_mnt_writer_counts();
----------------->HERE
>                 mnt_unlock_cpus();

and don't have a positive mnt->__mnt_writers, we know something is going
badly.  We WARN_ON() there, which should at least give an earlier
warning that the system is not doing well.  But it doesn't fix the
inevitable.  Could you try the attached patch and see if it at least
warns you earlier?

I have a decent guess what the bug is, too.  In the unionfs code:

> int init_lower_nd(struct nameidata *nd, unsigned int flags)
> {
> ...
> #ifdef ALLOC_LOWER_ND_FILE
>                 file = kzalloc(sizeof(struct file), GFP_KERNEL);
>                 if (unlikely(!file)) {
>                         err = -ENOMEM;
>                         break; /* exit switch statement and thus return */
>                 }
>                 nd->intent.open.file = file;
> #endif /* ALLOC_LOWER_ND_FILE */

The r/o bind mount code will mnt_drop_write() on that file's f_vfsmnt at
__fput() time.  Since that code never got a write on the mount, we'll
see an imbalance if the file was opened for a write.  I don't see this
file's mnt set anywhere, so I'm not completely sure that this is it.  In
any case, rolling your own 'struct file' without using alloc_file() and
friends is a no-no.

BTW, I have some "debugging" code in my latest set of patches that I
think should fix this kind of imbalance with the mnt->__mnt_writers().
It ensures that before we do that mnt_drop_write() at __fput() that we
absolutely did a mnt_want_write() at some point in the 'struct file's
life.  

-- Dave

 linux-2.6.git-dave/fs/namespace.c        |   31 ++++++++++++++++++++++---------
 linux-2.6.git-dave/include/linux/mount.h |    1 +
 2 files changed, 23 insertions(+), 9 deletions(-)

diff -puN fs/namei.c~fix-naughty-loop fs/namei.c
diff -puN fs/namespace.c~fix-naughty-loop fs/namespace.c
--- linux-2.6.git/fs/namespace.c~fix-naughty-loop	2007-11-05 08:03:59.000000000 -0800
+++ linux-2.6.git-dave/fs/namespace.c	2007-11-05 08:35:06.000000000 -0800
@@ -225,16 +225,29 @@ static void lock_and_coalesce_cpu_mnt_wr
  */
 static void handle_write_count_underflow(struct vfsmount *mnt)
 {
-	while (atomic_read(&mnt->__mnt_writers) <
-		MNT_WRITER_UNDERFLOW_LIMIT) {
-		/*
-		 * It isn't necessary to hold all of the locks
-		 * at the same time, but doing it this way makes
-		 * us share a lot more code.
-		 */
-		lock_and_coalesce_cpu_mnt_writer_counts();
-		mnt_unlock_cpus();
+	if (atomic_read(&mnt->__mnt_writers) >=
+	    MNT_WRITER_UNDERFLOW_LIMIT)
+		return;
+	/*
+	 * It isn't necessary to hold all of the locks
+	 * at the same time, but doing it this way makes
+	 * us share a lot more code.
+	 */
+	lock_and_coalesce_cpu_mnt_writer_counts();
+	/*
+	 * If coalescing the per-cpu writer counts did not
+	 * get us back to a positive writer count, we have
+	 * a bug.
+	 */
+	if ((atomic_read(&mnt->__mnt_writers) < 0) &&
+	    !(mnt->mnt_flags & MNT_IMBALANCED_WRITE_COUNT)) {
+		printk("leak detected on mount(%p) writers count: %d\n",
+			mnt, atomic_read(&mnt->__mnt_writers));
+		WARN_ON(1);
+		/* use the flag to keep the dmesg spam down */
+		mnt->mnt_flags |= MNT_IMBALANCED_WRITE_COUNT;
 	}
+	mnt_unlock_cpus();
 }
 
 /**
diff -puN include/linux/mount.h~fix-naughty-loop include/linux/mount.h
--- linux-2.6.git/include/linux/mount.h~fix-naughty-loop	2007-11-05 08:22:21.000000000 -0800
+++ linux-2.6.git-dave/include/linux/mount.h	2007-11-05 08:28:20.000000000 -0800
@@ -32,6 +32,7 @@ struct mnt_namespace;
 #define MNT_READONLY	0x40	/* does the user want this to be r/o? */
 
 #define MNT_SHRINKABLE	0x100
+#define MNT_IMBALANCED_WRITE_COUNT	0x200 /* just for debugging */
 
 #define MNT_SHARED	0x1000	/* if the vfsmount is a shared mount */
 #define MNT_UNBINDABLE	0x2000	/* if the vfsmount is a unbindable mount */
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
