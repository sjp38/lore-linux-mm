Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by sgi.com (980305.SGI.8.8.8-aspam-6.2/980304.SGI-aspam:
       SGI does not authorize the use of its proprietary
       systems or networks for unsolicited or bulk email
       from the Internet.)
	via ESMTP id TAA10292757
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Mon, 8 Nov 1999 19:12:30 -0800 (PST)
	mail_from (kanoj@google.engr.sgi.com)
Received: from google.engr.sgi.com (google.engr.sgi.com [192.48.174.30])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id TAA83966
	for <@cthulhu.engr.sgi.com:linux-mm@kvack.org>;
	Mon, 8 Nov 1999 19:12:29 -0800 (PST)
	mail_from (kanoj@google.engr.sgi.com)
Received: (from kanoj@localhost) by google.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) id TAA17636 for linux-mm@kvack.org; Mon, 8 Nov 1999 19:12:28 -0800 (PST)
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911090312.TAA17636@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm25-2.3.26 Fix max_mapnr<<PAGE_SHIFT overflows
Date: Mon, 8 Nov 1999 19:12:28 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This has already been sent to Linus to be included into 2.3.27.

Kanoj

Linus,

Now that >4Gb memory support is possible, it is no longer true that
(max_mapnr << PAGE_SHIFT) can be held within a 32 bit unsigned long.
This patch tries to fix this overflow problem.

Please put into 2.3.27. Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a006_p/dir.c	Mon Nov  8 17:30:59 1999
+++ fs/ncpfs/dir.c	Mon Nov  8 16:10:42 1999
@@ -405,7 +405,6 @@
 {
 	unsigned long dent_addr = (unsigned long) dentry;
 	unsigned long min_addr = PAGE_OFFSET;
-	unsigned long max_addr = min_addr + (max_mapnr << PAGE_SHIFT);
 	unsigned long align_mask = 0x0F;
 	unsigned int len;
 	int valid = 0;
@@ -412,7 +411,7 @@
 
 	if (dent_addr < min_addr)
 		goto bad_addr;
-	if (dent_addr > max_addr - sizeof(struct dentry))
+	if (dent_addr > (unsigned long)high_memory - sizeof(struct dentry))
 		goto bad_addr;
 	if ((dent_addr & ~align_mask) != dent_addr)
 		goto bad_align;
--- /usr/tmp/p_rdiff_a006_z/kcore.c	Mon Nov  8 17:31:18 1999
+++ fs/proc/kcore.c	Mon Nov  8 16:10:42 1999
@@ -20,7 +20,7 @@
 ssize_t read_kcore(struct file * file, char * buf,
 			 size_t count, loff_t *ppos)
 {
-	unsigned long p = *ppos, memsize;
+	unsigned long long p = *ppos, memsize;
 	ssize_t read;
 	ssize_t count1;
 	char * pnt;
--- /usr/tmp/p_rdiff_a006-8/vmalloc.c	Mon Nov  8 17:31:44 1999
+++ mm/vmalloc.c	Mon Nov  8 16:10:42 1999
@@ -204,7 +204,7 @@
 	struct vm_struct *area;
 
 	size = PAGE_ALIGN(size);
-	if (!size || size > (max_mapnr << PAGE_SHIFT)) {
+	if (!size || ((PAGE_ALIGN(size) >> PAGE_SHIFT) > max_mapnr)) {
 		BUG();
 		return NULL;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
