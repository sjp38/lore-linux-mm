Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l94LrYds012633
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 17:53:34 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l94LrXJu488428
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 15:53:33 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l94LrXEg006087
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 15:53:33 -0600
Subject: [PATCH][2.6.23-rc8-mm2] Fixes to hugetlbfs_read() support
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <b040c32a0710031441v3139bd28lce757b2c63796686@mail.gmail.com>
References: <20071001133524.0566b556.akpm@linux-foundation.org>
	 <b040c32a0710012221m3218f717yf606135eb0dc56d4@mail.gmail.com>
	 <20071001224115.548ee427.akpm@linux-foundation.org>
	 <1191346335.6106.23.camel@dyn9047017100.beaverton.ibm.com>
	 <20071002111949.c8184a3a.akpm@linux-foundation.org>
	 <1191364926.6106.57.camel@dyn9047017100.beaverton.ibm.com>
	 <b040c32a0710021914i5ced503aoebe6e749cd2201af@mail.gmail.com>
	 <b040c32a0710021941q583e2169t40e196675318f19d@mail.gmail.com>
	 <20071003025853.GA14698@localhost.localdomain>
	 <1191425944.6106.79.camel@dyn9047017100.beaverton.ibm.com>
	 <b040c32a0710031441v3139bd28lce757b2c63796686@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 04 Oct 2007 14:56:41 -0700
Message-Id: <1191535001.6106.104.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: David Gibson <david@gibson.dropbear.id.au>, Andrew Morton <akpm@linux-foundation.org>, William Lee Irwin III <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Ken,

Here is the latest against 2.6.23-rc8-mm2. If you are happy with this,
I will ask Andrew to pick it up. I did test this version :)

Thanks,
Badari

Various fixes to hugetlbfs_read() support

- handle HOLES correcty
- clean up weird looking loop condition reported by Ken Chen
- integrated "not updating file offset after read" fix by Ken Chen
- holding i_mutex to prevent any unwanted interactions with truncate

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

 fs/hugetlbfs/inode.c |   36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

Index: linux-2.6.23-rc8/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.23-rc8.orig/fs/hugetlbfs/inode.c	2007-09-27 11:32:23.000000000 -0700
+++ linux-2.6.23-rc8/fs/hugetlbfs/inode.c	2007-10-04 16:42:14.000000000 -0700
@@ -228,11 +228,13 @@ static ssize_t hugetlbfs_read(struct fil
 	struct address_space *mapping = filp->f_mapping;
 	struct inode *inode = mapping->host;
 	unsigned long index = *ppos >> HPAGE_SHIFT;
+	unsigned long offset = *ppos & ~HPAGE_MASK;
 	unsigned long end_index;
 	loff_t isize;
-	unsigned long offset;
 	ssize_t retval = 0;
 
+	mutex_lock(&inode->i_mutex);
+
 	/* validate length */
 	if (len == 0)
 		goto out;
@@ -241,7 +243,6 @@ static ssize_t hugetlbfs_read(struct fil
 	if (!isize)
 		goto out;
 
-	offset = *ppos & ~HPAGE_MASK;
 	end_index = (isize - 1) >> HPAGE_SHIFT;
 	for (;;) {
 		struct page *page;
@@ -263,18 +264,23 @@ static ssize_t hugetlbfs_read(struct fil
 		page = find_get_page(mapping, index);
 		if (unlikely(page == NULL)) {
 			/*
-			 * We can't find the page in the cache - bail out ?
+			 * We have a HOLE, zero out the user-buffer for the
+			 * length of the hole or request.
 			 */
-			goto out;
+			ret = len < nr ? len : nr;
+			if (clear_user(buf, ret))
+				ret = -EFAULT;
+		} else {
+			/*
+			 * We have the page, copy it to user space buffer.
+			 */
+			ret = hugetlbfs_read_actor(page, offset, buf, len, nr);
 		}
-		/*
-		 * Ok, we have the page, copy it to user space buffer.
-		 */
-		ret = hugetlbfs_read_actor(page, offset, buf, len, nr);
 		if (ret < 0) {
 			if (retval == 0)
 				retval = ret;
-			page_cache_release(page);
+			if (page)
+				page_cache_release(page);
 			goto out;
 		}
 
@@ -284,12 +290,16 @@ static ssize_t hugetlbfs_read(struct fil
 		index += offset >> HPAGE_SHIFT;
 		offset &= ~HPAGE_MASK;
 
-		page_cache_release(page);
-		if (ret == nr && len)
-			continue;
-		goto out;
+		if (page)
+			page_cache_release(page);
+
+		/* short read or no more work */
+		if ((ret != nr) || (len == 0))
+			break;
 	}
 out:
+	*ppos = ((loff_t) index << HPAGE_SHIFT) + offset;
+	mutex_unlock(&inode->i_mutex);
 	return retval;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
