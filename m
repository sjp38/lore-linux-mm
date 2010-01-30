From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/4] hwpoison: prevent /dev/kmem from accessing hwpoison pages
Date: Sat, 30 Jan 2010 17:25:10 +0800
Message-ID: <20100130093703.718660392@intel.com>
References: <20100130092509.793222613@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Ov8EF-0004CS-Ao
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Sep 2010 14:33:47 +0200
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E4FE75F0044
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 08:32:08 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-dev-kmem.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg KH <greg@kroah.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

When /dev/kmem read()/write() encounters hwpoison page, stop it
and return the amount of work done till now, or return -EIO if
nothing have been copied.

For simplicity, hwpoison pages accessed by vmalloc address are
siliently skipped, instead of returning -EIO.

CC: Greg KH <greg@kroah.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Ingo Molnar <mingo@elte.hu>
CC: Tejun Heo <tj@kernel.org>
CC: Nick Piggin <npiggin@suse.de>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/char/mem.c |   18 ++++++++++++++----
 mm/vmalloc.c       |    4 ++--
 2 files changed, 16 insertions(+), 6 deletions(-)

--- linux-mm.orig/drivers/char/mem.c	2010-01-30 17:14:12.000000000 +0800
+++ linux-mm/drivers/char/mem.c	2010-01-30 17:20:18.000000000 +0800
@@ -426,6 +426,9 @@ static ssize_t read_kmem(struct file *fi
 			 */
 			kbuf = xlate_dev_kmem_ptr((char *)p);
 
+			if (unlikely(virt_addr_valid(kbuf) &&
+				     PageHWPoison(virt_to_page(kbuf))))
+				return -EIO;
 			if (copy_to_user(buf, kbuf, sz))
 				return -EFAULT;
 			buf += sz;
@@ -471,6 +474,7 @@ do_write_kmem(unsigned long p, const cha
 {
 	ssize_t written, sz;
 	unsigned long copied;
+	int err = 0;
 
 	written = 0;
 #ifdef __ARCH_HAS_NO_PAGE_ZERO_MAPPED
@@ -497,13 +501,19 @@ do_write_kmem(unsigned long p, const cha
 		 */
 		ptr = xlate_dev_kmem_ptr((char *)p);
 
+		if (unlikely(virt_addr_valid(ptr) &&
+			     PageHWPoison(virt_to_page(ptr)))) {
+			err = -EIO;
+			break;
+		}
+
 		copied = copy_from_user(ptr, buf, sz);
 		if (copied) {
 			written += sz - copied;
-			if (written)
-				break;
-			return -EFAULT;
+			err = -EFAULT;
+			break;
 		}
+
 		buf += sz;
 		p += sz;
 		count -= sz;
@@ -511,7 +521,7 @@ do_write_kmem(unsigned long p, const cha
 	}
 
 	*ppos += written;
-	return written;
+	return written ? written : err;
 }
 
 
--- linux-mm.orig/mm/vmalloc.c	2010-01-30 17:14:15.000000000 +0800
+++ linux-mm/mm/vmalloc.c	2010-01-30 17:20:18.000000000 +0800
@@ -1669,7 +1669,7 @@ static int aligned_vread(char *buf, char
 		 * interface, rarely used. Instead of that, we'll use
 		 * kmap() and get small overhead in this access function.
 		 */
-		if (p) {
+		if (p && !PageHWPoison(p)) {
 			/*
 			 * we can expect USER0 is not used (see vread/vwrite's
 			 * function description)
@@ -1708,7 +1708,7 @@ static int aligned_vwrite(char *buf, cha
 		 * interface, rarely used. Instead of that, we'll use
 		 * kmap() and get small overhead in this access function.
 		 */
-		if (p) {
+		if (p && !PageHWPoison(p)) {
 			/*
 			 * we can expect USER0 is not used (see vread/vwrite's
 			 * function description)


--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
