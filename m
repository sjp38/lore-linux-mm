Date: Mon, 4 Dec 2000 20:50:04 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: New patches for 2.2.18pre24 raw IO (fix for bounce buffer copy)
Message-ID: <20001204205004.H8700@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Stephen Tweedie <sct@redhat.com>, Andi Kleen <ak@muc.de>, Andrea Arcangeli <andrea@suse.de>, wtenhave@sybase.com, hdeller@redhat.com, Eric Lowe <elowe@myrile.madriver.k12.oh.us>, Larry Woodman <woodman@missioncriticallinux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I have pushed another set of raw IO patches out, this time to fix a
bug with bounce buffer copying when running on highmem boxes.  It is
likely to affect any bounce buffer copies using non-page-aligned
accesses if both highmem and normal pages are involved in the kiobuf.

The specific new patch added in this patchset is attached below.  The
full set has been uploaded as 

	kiobuf-2.2.18pre24-B.tar.gz

at

	ftp.*.kernel.org:/pub/linux/kernel/people/sct/raw-io/
and	ftp.uk.linux.org:/pub/linux/sct/fs/raw-io/

This one really should kill all known bugs, dead.  Please stress it
out and let me know if anybody encounters any further problems.  A
merge of all of the pending raw IO fixes into 2.4 should be happening
soon once the current VM changes for marking pages dirty are working.

Cheers,
 Stephen


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="raw-2.2.18pre24.91.fix-bouncecopy"

--- linux-2.2.18pre24.raw.bigmem/fs/iobuf.c.~1~	Mon Dec  4 20:13:49 2000
+++ linux-2.2.18pre24.raw.bigmem/fs/iobuf.c	Mon Dec  4 20:14:08 2000
@@ -211,10 +211,10 @@
 		unsigned long kin, kout;
 		int pagelen = length;
 		
+		if ((pagelen+offset) > PAGE_SIZE)
+			pagelen = PAGE_SIZE - offset;
+			
 		if (bounce_page) {
-			if ((pagelen+offset) > PAGE_SIZE)
-				pagelen = PAGE_SIZE - offset;
-		
 			if (direction == COPY_TO_BOUNCE) {
 				kin  = kmap(page, KM_READ);
 				kout = kmap(bounce_page, KM_WRITE);

--DocE+STaALJfprDB--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
