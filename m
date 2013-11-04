Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 200C86B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 00:32:48 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xb4so6633562pbc.8
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 21:32:47 -0800 (PST)
Received: from psmtp.com ([74.125.245.138])
        by mx.google.com with SMTP id qj1si4070319pbc.354.2013.11.03.21.32.44
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 21:32:46 -0800 (PST)
Message-ID: <5277313B.8060306@asianux.com>
Date: Mon, 04 Nov 2013 13:31:39 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH v3] mm: readahead: check return value which force_page_cache_readahead()
 returns
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <525CFAD7.9070701@asianux.com> <525FB469.4000400@asianux.com>
In-Reply-To: <525FB469.4000400@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

force_page_cache_readahead() may fail, so the callers who want to know
about it need check the return value.

force_page_cache_readahead() need not return actual read length, since
no callers care about it, and which may lead callers misunderstanding:
treat non-zero as failure.

And now, 2 callers need not check the return value:

 - in fadvise64_64(), it contents the related comment near above.
   (return success even if filesystem can't retrieve a hint).

 - page_cache_sync_readahead() itself need not return value
   (only can not improve performance when it fails).


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/madvise.c   |    4 ++--
 mm/readahead.c |   11 +++--------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 539eeb9..dee8d46 100644
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
index 7cdbb44..b186d93 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -211,8 +211,6 @@ out:
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		pgoff_t offset, unsigned long nr_to_read)
 {
-	int ret = 0;
-
 	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
 		return -EINVAL;
 
@@ -227,14 +225,12 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		err = __do_page_cache_readahead(mapping, filp,
 						offset, this_chunk, 0);
 		if (err < 0) {
-			ret = err;
-			break;
+			return err;
 		}
-		ret += err;
 		offset += this_chunk;
 		nr_to_read -= this_chunk;
 	}
-	return ret;
+	return 0;
 }
 
 /*
@@ -576,8 +572,7 @@ do_readahead(struct address_space *mapping, struct file *filp,
 	if (!mapping || !mapping->a_ops)
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
