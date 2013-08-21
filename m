Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C601E6B0034
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 22:42:23 -0400 (EDT)
Message-ID: <521428D0.2020708@asianux.com>
Date: Wed, 21 Aug 2013 10:41:20 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH v2] m: readahead: return the value which force_page_cache_readahead()
 returns
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org>
In-Reply-To: <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

force_page_cache_readahead() may fail, so need let the related upper
system calls know about it by its return value.

For system call fadvise64_64(), ignore return value because fadvise()
shall return success even if filesystem can't retrieve a hint.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/madvise.c   |    4 ++--
 mm/readahead.c |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

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
index e4ed041..1b21b5c 100644
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
