From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 06/14] readahead: move max_sane_readahead() calls into force_page_cache_readahead()
Date: Tue, 07 Apr 2009 19:50:45 +0800
Message-ID: <20090407115234.430730679@intel.com>
References: <20090407115039.780820496@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6F2E85F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:00:55 -0400 (EDT)
Content-Disposition: inline; filename=readahead-move-max_sane_readahead.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

Impact: code simplification.

Cc: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/fadvise.c   |    2 +-
 mm/filemap.c   |    3 +--
 mm/madvise.c   |    3 +--
 mm/readahead.c |    1 +
 4 files changed, 4 insertions(+), 5 deletions(-)

--- mm.orig/mm/fadvise.c
+++ mm/mm/fadvise.c
@@ -101,7 +101,7 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, lof
 		
 		ret = force_page_cache_readahead(mapping, file,
 				start_index,
-				max_sane_readahead(nrpages));
+				nrpages);
 		if (ret > 0)
 			ret = 0;
 		break;
--- mm.orig/mm/filemap.c
+++ mm/mm/filemap.c
@@ -1458,8 +1458,7 @@ do_readahead(struct address_space *mappi
 	if (!mapping || !mapping->a_ops || !mapping->a_ops->readpage)
 		return -EINVAL;
 
-	force_page_cache_readahead(mapping, filp, index,
-					max_sane_readahead(nr));
+	force_page_cache_readahead(mapping, filp, index, nr);
 	return 0;
 }
 
--- mm.orig/mm/madvise.c
+++ mm/mm/madvise.c
@@ -123,8 +123,7 @@ static long madvise_willneed(struct vm_a
 		end = vma->vm_end;
 	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-	force_page_cache_readahead(file->f_mapping,
-			file, start, max_sane_readahead(end - start));
+	force_page_cache_readahead(file->f_mapping, file, start, end - start);
 	return 0;
 }
 
--- mm.orig/mm/readahead.c
+++ mm/mm/readahead.c
@@ -223,6 +223,7 @@ int force_page_cache_readahead(struct ad
 	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
 		return -EINVAL;
 
+	nr_to_read = max_sane_readahead(nr_to_read);
 	while (nr_to_read) {
 		int err;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
