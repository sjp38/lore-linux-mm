Date: Thu, 2 Nov 2000 12:34:00 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: PATCH [2.4.0test10]: Kiobuf#01, expand IO return codes from iobufs
Message-ID: <20001102123400.A1876@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YToU2i3Vx8H2dn7O"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--YToU2i3Vx8H2dn7O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Kiobuf diff 01: allow for both the errno and the number of bytes
transferred to be returned in a kiobuf after IO.  We need both in
order to know how many pages have been dirtied after a failed IO.

Also includes a fix to the brw_kiovec code to make sure that EIO is
returned if no bytes were transferred successfully.

--Stephen

--YToU2i3Vx8H2dn7O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="01-retval.diff"

diff -ru linux-2.4.0-test10.kio.00/drivers/char/raw.c linux-2.4.0-test10.kio.01/drivers/char/raw.c
--- linux-2.4.0-test10.kio.00/drivers/char/raw.c	Wed Nov  1 22:25:30 2000
+++ linux-2.4.0-test10.kio.01/drivers/char/raw.c	Thu Nov  2 12:00:35 2000
@@ -321,10 +321,10 @@
 		
 		err = brw_kiovec(rw, 1, &iobuf, dev, b, sector_size);
 
+		transferred += iobuf->retval;
 		if (err >= 0) {
-			transferred += err;
-			size -= err;
-			buf += err;
+			size -= iobuf->retval;
+			buf += iobuf->retval;
 		}
 
 		unmap_kiobuf(iobuf); /* The unlock_kiobuf is implicit here */
diff -ru linux-2.4.0-test10.kio.00/fs/buffer.c linux-2.4.0-test10.kio.01/fs/buffer.c
--- linux-2.4.0-test10.kio.00/fs/buffer.c	Wed Nov  1 22:25:34 2000
+++ linux-2.4.0-test10.kio.01/fs/buffer.c	Thu Nov  2 12:01:14 2000
@@ -1924,6 +1924,8 @@
 	
 	spin_unlock(&unused_list_lock);
 
+	if (!iosize)
+		return -EIO;
 	return iosize;
 }
 
@@ -2049,6 +2051,11 @@
 	}
 
  finished:
+
+	iobuf->retval = transferred;
+	if (err < 0)
+		iobuf->errno = err;
+	
 	if (transferred)
 		return transferred;
 	return err;
diff -ru linux-2.4.0-test10.kio.00/include/linux/iobuf.h linux-2.4.0-test10.kio.01/include/linux/iobuf.h
--- linux-2.4.0-test10.kio.00/include/linux/iobuf.h	Thu Nov  2 12:02:43 2000
+++ linux-2.4.0-test10.kio.01/include/linux/iobuf.h	Thu Nov  2 12:07:27 2000
@@ -52,7 +52,12 @@
 
 	/* Dynamic state for IO completion: */
 	atomic_t	io_count;	/* IOs still in progress */
-	int		errno;		/* Status of completed IO */
+
+	/* Equivalent to the return value and "errno" after a syscall: */
+	int		errno;		/* Error from completed IO (usual
+					   kernel negative values) */
+	int		retval;		/* Return value of completed IO */
+
 	void		(*end_io) (struct kiobuf *); /* Completion callback */
 	wait_queue_head_t wait_queue;
 };

--YToU2i3Vx8H2dn7O--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
