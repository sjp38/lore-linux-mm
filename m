Date: Thu, 5 Apr 2001 03:11:12 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] shmem fixes against 2.4.3-ac2
Message-ID: <Pine.LNX.4.21.0104050304250.9033-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

The following patch fixes two bugs in the shm code in 2.4.3-ac2 (and ac3,
too): 

 - shmem_writepage() does not set the page dirty bit on a page in case it
   does not get moved to the swapcache because it has pte's mapped to it. 

 - in case of a SIGBUS for a page fault on an shmem page, the inode lock
   will remain locked forever.



--- mm/shmem.c.orig	Wed Apr  4 06:44:45 2001
+++ mm/shmem.c	Thu Apr  5 04:39:03 2001
@@ -236,8 +236,10 @@
 	
 	/* Only move to the swap cache if there are no other users of
 	 * the page. */
-	if (atomic_read(&page->count) > 2)
+	if (atomic_read(&page->count) > 2) {
+		set_page_dirty(page);
 		goto out;
+	}
 	
 	inode = page->mapping->host;
 	info = &inode->u.shmem_i;
@@ -432,6 +434,7 @@
 		*ptr = NOPAGE_SIGBUS;
 	return error;
 sigbus:
+	up (&inode->i_sem);
 	*ptr = NOPAGE_SIGBUS;
 	return -EFAULT;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
