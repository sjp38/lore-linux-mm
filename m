Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 770276B01BF
	for <linux-mm@kvack.org>; Thu, 20 May 2010 07:25:11 -0400 (EDT)
Message-ID: <4BF51B0A.1050901@redhat.com>
Date: Thu, 20 May 2010 07:20:42 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: RFC: dirty_ratio back to 40%
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

We've seen multiple performance regressions linked to the lower(20%)
dirty_ratio.  When performing enough IO to overwhelm the background  
flush daemons the percent of dirty pagecache memory quickly climbs 
to the new/lower dirty_ratio value of 20%.  At that point all writing 
processes are forced to stop and write dirty pagecache pages back to disk.  
This causes performance regressions in several benchmarks as well as causing
a noticeable overall sluggishness.  We all know that the dirty_ratio is
an integrity vs performance trade-off but the file system journaling
will cover any devastating effects in the event of a system crash.

Increasing the dirty_ratio to 40% will regain the performance loss seen
in several benchmarks.  Whats everyone think about this???





------------------------------------------------------------------------

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ef27e73..645a462 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -78,7 +78,7 @@ int vm_highmem_is_dirtyable;
 /*
  * The generator of dirty data starts writeback at this percentage
  */
-int vm_dirty_ratio = 20;
+int vm_dirty_ratio = 40;
 
 /*
  * vm_dirty_bytes starts at 0 (disabled) so that it is a function of

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
