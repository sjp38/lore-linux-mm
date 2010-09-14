Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BCEAA6B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 19:11:47 -0400 (EDT)
Date: Wed, 15 Sep 2010 09:11:18 +1000
From: Neil Brown <neilb@suse.de>
Subject: Deadlock possibly caused by too_many_isolated.
Message-ID: <20100915091118.3dbdc961@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu@suse.de, "Fengguang <fengguang.wu"@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Hi,

 I recently had a customer (running 2.6.32) report a deadlock during very
 intensive IO with lots of processes.

 Having looked at the stack traces, my guess as to the problem is this:

  There are enough threads in direct_reclaim that too_many_isolated() is
  returning true, and so some threads are blocked in shrink_inactive_list.

  Those threads that are not blocked there are attempting to do filesystem
  writeout.  But that is blocked because...

  Some threads that are blocked there, hold some IO lock (probably in the 
  filesystem) and are trying to allocate memory inside the block device
  (md/raid1 to be precise) which is allocating with GFP_NOIO and has a
  mempool to fall back on.
  As these threads don't have __GFP_IO set, they should not really be blocked
  both other threads that are doing IO.  But it seems they are.


  So I'm wondering if the loop in shrink_inactive_list should abort
  if __GFP_IO is not set ... and maybe if __GFP_FS is not set too???

  Below is a patch that I'm asking the customer to test.

  If anyone can point out a flaw in my reasoning, suggest any other
  alternatives, provide a better patch, or otherwise help me out here, I
  would greatly appreciate it.

  (I sent this email to the people mentioned in commit:
      commit 35cd78156c499ef83f60605e4643d5a98fef14fd
      Author: Rik van Riel <riel@redhat.com>
      Date:   Mon Sep 21 17:01:38 2009 -0700

          vmscan: throttle direct reclaim when too many pages are isolated already
  
   plus the obvious mail lists)

Thanks,
NeilBrown

Index: linux-2.6.32-SLE11-SP1/mm/vmscan.c
===================================================================
--- linux-2.6.32-SLE11-SP1.orig/mm/vmscan.c	2010-09-15 08:37:32.000000000 +1000
+++ linux-2.6.32-SLE11-SP1/mm/vmscan.c	2010-09-15 08:38:57.000000000 +1000
@@ -1106,6 +1106,11 @@ static unsigned long shrink_inactive_lis
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
 			return SWAP_CLUSTER_MAX;
+		if (!(sc->gfp_mask & __GFP_IO))
+			/* Not allowed to do IO, so mustn't wait
+			 * on processes that might try to
+			 */
+			return SWAP_CLUSTER_MAX;
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
