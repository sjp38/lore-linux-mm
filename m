Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id AC87E6B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 21:27:11 -0500 (EST)
Date: Sat, 25 Feb 2012 02:27:10 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: [PATCH] fadvise: avoid EINVAL if user input is valid
Message-ID: <20120225022710.GA29455@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The kernel is not required to act on fadvise, so fail silently
and ignore advice as long as it has a valid descriptor and
parameters.

Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Eric Wong <normalperson@yhbt.net>
---

 Of course I wouldn't knowingly call posix_fadvise() on a file in
 tmpfs, but a userspace app often doesn't know (nor should it
 care) what type of filesystem it's on.

 I encountered EINVAL while running the Ruby 1.9.3 test suite on a
 stock Debian wheezy installation.  Wheezy uses tmpfs for "/tmp" by
 default and the test suite creates a temporary file to test the
 Ruby wrapper for posix_fadvise() on.

 mm/fadvise.c |   19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index 469491e0..f9e48dd 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -43,13 +43,13 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 		goto out;
 	}
 
-	mapping = file->f_mapping;
-	if (!mapping || len < 0) {
+	if (len < 0) {
 		ret = -EINVAL;
 		goto out;
 	}
 
-	if (mapping->a_ops->get_xip_mem) {
+	mapping = file->f_mapping;
+	if (!mapping || mapping->a_ops->get_xip_mem) {
 		switch (advice) {
 		case POSIX_FADV_NORMAL:
 		case POSIX_FADV_RANDOM:
@@ -93,10 +93,9 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 		spin_unlock(&file->f_lock);
 		break;
 	case POSIX_FADV_WILLNEED:
-		if (!mapping->a_ops->readpage) {
-			ret = -EINVAL;
+		/* ignore the advice if readahead isn't possible (tmpfs) */
+		if (!mapping->a_ops->readpage)
 			break;
-		}
 
 		/* First and last PARTIAL page! */
 		start_index = offset >> PAGE_CACHE_SHIFT;
@@ -106,12 +105,8 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
 		nrpages = end_index - start_index + 1;
 		if (!nrpages)
 			nrpages = ~0UL;
-		
-		ret = force_page_cache_readahead(mapping, file,
-				start_index,
-				nrpages);
-		if (ret > 0)
-			ret = 0;
+
+		force_page_cache_readahead(mapping, file, start_index, nrpages);
 		break;
 	case POSIX_FADV_NOREUSE:
 		break;
-- 
Eric Wong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
