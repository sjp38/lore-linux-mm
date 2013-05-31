Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 779216B003B
	for <linux-mm@kvack.org>; Fri, 31 May 2013 14:39:05 -0400 (EDT)
Subject: [v4][PATCH 6/6] mm: vmscan: drain batch list during long operations
From: Dave Hansen <dave@sr71.net>
Date: Fri, 31 May 2013 11:39:04 -0700
References: <20130531183855.44DDF928@viggo.jf.intel.com>
In-Reply-To: <20130531183855.44DDF928@viggo.jf.intel.com>
Message-Id: <20130531183904.76C2B57D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

This was a suggestion from Mel:

	http://lkml.kernel.org/r/20120914085634.GM11157@csn.ul.ie

Any pages we collect on 'batch_for_mapping_removal' will have
their lock_page() held during the duration of their stay on the
list.  If some other user is trying to get at them during this
time, they might end up having to wait.

This ensures that we drain the batch if we are about to perform a
pageout() or congestion_wait(), either of which will take some
time.  We expect this to help mitigate the worst of the latency
increase that the batching could cause.

I added some statistics to the __remove_mapping_batch() code to
track how large the lists are that we pass in to it.  With this
patch, the average list length drops about 10% (from about 4.1 to
3.8).  The workload here was a make -j4 kernel compile on a VM
with 200MB of RAM.

I've still got the statistics patch around if anyone is
interested.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/vmscan.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN mm/vmscan.c~drain-batch-list-during-long-operations mm/vmscan.c
--- linux.git/mm/vmscan.c~drain-batch-list-during-long-operations	2013-05-30 16:07:51.962138013 -0700
+++ linux.git-davehans/mm/vmscan.c	2013-05-30 16:07:51.966138189 -0700
@@ -1003,6 +1003,16 @@ static unsigned long shrink_page_list(st
 			if (!sc->may_writepage)
 				goto keep_locked;
 
+			/*
+			 * We hold a bunch of page locks on the batch.
+			 * pageout() can take a while, so drain the
+			 * batch before we perform pageout.
+			 */
+			nr_reclaimed +=
+		               __remove_mapping_batch(&batch_for_mapping_rm,
+		                                      &ret_pages,
+		                                      &free_pages);
+
 			/* Page is dirty, try to write it out here */
 			switch (pageout(page, mapping, sc)) {
 			case PAGE_KEEP:
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
