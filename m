Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7221F6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 08:14:23 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so8714542pbb.27
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 05:14:23 -0700 (PDT)
Message-ID: <525D3148.8030707@asianux.com>
Date: Tue, 15 Oct 2013 20:12:56 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/madvise.c: return 0 instead of read bytes after force_page_cache_readahead()
 succeeds.
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org> <52390907.7050101@asianux.com> <525CF787.6050107@asianux.com>
In-Reply-To: <525CF787.6050107@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

madvise_willneed() will return 0 when succeed, so need return 0 instead
of read bytes after force_page_cache_readahead() succeeds.

The related commit: "fee53ce mm/readahead.c: return the value which
force_page_cache_readahead() returns" causes this issue.

After modification, it can pass LTP common test (disable CONFIG_SWAP).
Although the original one also can pass LTP common test, still better
to fix it.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/madvise.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index dee8d46..3a739cd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -220,6 +220,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
 	struct file *file = vma->vm_file;
+	int ret = 0;
 
 #ifdef CONFIG_SWAP
 	if (!file || mapping_cap_swap_backed(file->f_mapping)) {
@@ -247,8 +248,9 @@ static long madvise_willneed(struct vm_area_struct *vma,
 		end = vma->vm_end;
 	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-	return force_page_cache_readahead(file->f_mapping, file,
+	ret = force_page_cache_readahead(file->f_mapping, file,
 					start, end - start);
+	return ret < 0 ? ret : 0;
 }
 
 /*
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
