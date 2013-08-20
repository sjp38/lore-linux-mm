Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 1F15E6B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 23:32:56 -0400 (EDT)
Message-ID: <5212E328.40804@asianux.com>
Date: Tue, 20 Aug 2013 11:31:52 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm: readahead: return the value which force_page_cache_readahead()
 returns
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

force_page_cache_readahead() may fail, so need let the related upper
system calls know about it by its return value.

Also let related code pass "scripts/checkpatch.pl's" checking.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/fadvise.c   |    4 ++--
 mm/madvise.c   |    4 ++--
 mm/readahead.c |    3 +--
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index 3bcfd81..7da9eb1 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -107,8 +107,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		 * Ignore return value because fadvise() shall return
 		 * success even if filesystem can't retrieve a hint,
 		 */
-		force_page_cache_readahead(mapping, f.file, start_index,
-					   nrpages);
+		ret = force_page_cache_readahead(mapping, f.file, start_index,
+						 nrpages);
 		break;
 	case POSIX_FADV_NOREUSE:
 		break;
diff --git a/mm/madvise.c b/mm/madvise.c
index 936799f..3d0d484 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -247,8 +247,8 @@ static long madvise_willneed(struct vm_area_struct *vma,
 		end = vma->vm_end;
 	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-	force_page_cache_readahead(file->f_mapping, file, start, end - start);
-	return 0;
+	return force_page_cache_readahead(file->f_mapping, file,
+					start, end - start);
 }
 
 /*
diff --git a/mm/readahead.c b/mm/readahead.c
index 829a77c..5b9ac62 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -572,8 +572,7 @@ do_readahead(struct address_space *mapping, struct file *filp,
 	if (!mapping || !mapping->a_ops || !mapping->a_ops->readpage)
 		return -EINVAL;
 
-	force_page_cache_readahead(mapping, filp, index, nr);
-	return 0;
+	return force_page_cache_readahead(mapping, filp, index, nr);
 }
 
 SYSCALL_DEFINE3(readahead, int, fd, loff_t, offset, size_t, count)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
