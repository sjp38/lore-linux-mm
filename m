Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA15686
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 14:15:57 -0400
Date: Tue, 6 Apr 1999 20:07:57 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904061831340.394-100000@laser.random>
Message-ID: <Pine.LNX.4.05.9904061934380.1017-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Andrea Arcangeli wrote:

>I could write a simulation to check the hash function...

I was looking at the inode pointer part of the hash function and I think
something like this should be better.

Index: include/linux/pagemap.h
===================================================================
RCS file: /var/cvs/linux/include/linux/pagemap.h,v
retrieving revision 1.1.2.14
diff -u -r1.1.2.14 pagemap.h
--- pagemap.h	1999/04/05 23:33:20	1.1.2.14
+++ linux/include/linux/pagemap.h	1999/04/06 18:08:32
@@ -32,7 +39,7 @@
  */
 static inline unsigned long _page_hashfn(struct inode * inode, unsigned long offset)
 {
-#define i (((unsigned long) inode)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
+#define i (((unsigned long) inode-PAGE_OFFSET)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
 #define o (offset >> PAGE_SHIFT)
 #define s(x) ((x)+((x)>>PAGE_HASH_BITS))
 	return s(i+o) & (PAGE_HASH_SIZE-1);
(((unsigned long) inode-PAGE_OFFSET)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))

I am not sure if it will make difference, but at least it looks smarter to me
because it will remove a not interesting amount of information from the
input of the hash.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
