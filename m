Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA24330
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 17:18:26 -0500
Date: Sun, 10 Jan 1999 22:18:10 GMT
Message-Id: <199901102218.WAA01598@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com>
References: <199901101659.QAA00922@dax.scot.redhat.com>
	<Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Jan 1999 10:35:10 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> The thing I want to make re-entrant is just semaphore accesses: at the
> point where we would otherwise deadlock on the writer semaphore it's much
> better to just allow nested writes. I suspect all filesystems can already
> handle nested writes - they are a lot easier to handle than truly
> concurrent ones.

We used to do it anyway, before inodes were locked for write, if I
remember correctly.  

What I'm after is something like the patch below for a fix (don't apply
it: it should work and should fix the problem, but it's really just for
illustration).  It enforces an i_atomic_allocate semaphore to lock
against truncate().  The write-page filemap code takes this semaphore,
but does _not_ take i_sem at all.  

Frankly, I really don't think we want to serialise writes so
aggressively in the first place.  In POSIX, O_APPEND is the only case
where we need to do this (and since that modifies i_size, it's a natural
case to do under the i_atomic_allocate semaphore in any case).

This patch should fix the problem in hand, but what I think we really
want is a read/write semaphore for i_atomic_allocate: we want normal
read and write IO to a file to guard against a concurrent truncate(),
but _not_ against each other (in situations such as threaded/async IO to
a database file, multiple outstanding IOs can be a big win).  Basically,
most writes should take out a read lock on the filesize so that the file
won't disappear from under their feet; only extending or truncating the
file should take out an i_atomic_allocate write lock (assuming the same
sorts of semantics for r/w semaphores as we already have for r/w
spinlocks).

Are there really any filesystems we know can't deal with
concurrent/reentrant writes to an inode?  We already have to deal with
concurrent reads with a single write in progress, after all.

--Stephen

----------------------------------------------------------------
--- fs/inode.c.~1~	Fri Jan  8 16:13:05 1999
+++ fs/inode.c	Sun Jan 10 21:58:46 1999
@@ -132,6 +132,7 @@
 	INIT_LIST_HEAD(&inode->i_dentry);
 	sema_init(&inode->i_sem, 1);
 	sema_init(&inode->i_atomic_write, 1);
+	sema_init(&inode->i_atomic_allocate, 1);
 }
 
 static inline void write_inode(struct inode *inode)
--- fs/open.c~	Fri Jan  8 17:24:19 1999
+++ fs/open.c	Sun Jan 10 21:59:49 1999
@@ -70,6 +70,7 @@
 	int error;
 	struct iattr newattrs;
 
+	down(&inode->i_atomic_allocate);
 	down(&inode->i_sem);
 	newattrs.ia_size = length;
 	newattrs.ia_valid = ATTR_SIZE | ATTR_CTIME;
@@ -81,6 +82,7 @@
 			inode->i_op->truncate(inode);
 	}
 	up(&inode->i_sem);
+	up(&inode->i_atomic_allocate);
 	return error;
 }
 
--- include/linux/fs.h.~1~	Sun Jan 10 21:56:23 1999
+++ include/linux/fs.h	Sun Jan 10 21:58:39 1999
@@ -358,6 +358,7 @@
 	unsigned long		i_nrpages;
 	struct semaphore	i_sem;
 	struct semaphore	i_atomic_write;
+	struct semaphore	i_atomic_allocate;
 	struct inode_operations	*i_op;
 	struct super_block	*i_sb;
 	struct wait_queue	*i_wait;
--- mm/filemap.c~	Fri Jan  8 16:13:06 1999
+++ mm/filemap.c	Sun Jan 10 22:01:52 1999
@@ -1113,9 +1113,9 @@
 	 * and file could be released ... increment the count to be safe.
 	 */
 	file->f_count++;
-	down(&inode->i_sem);
+	down(&inode->i_atomic_allocate);
 	result = do_write_page(inode, file, (const char *) page, offset);
-	up(&inode->i_sem);
+	up(&inode->i_atomic_allocate);
 	fput(file);
 	return result;
 }


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
