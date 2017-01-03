Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C98FB6B0253
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 16:37:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so1534341834pgc.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 13:37:57 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y12si70146185pge.222.2017.01.03.13.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 13:37:56 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH] dax: fix deadlock with DAX 4k holes
Date: Tue,  3 Jan 2017 14:36:05 -0700
Message-Id: <1483479365-13607-1-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <20161027112230.wsumgs62fqdxt3sc@xzhoul.usersys.redhat.com>
References: <20161027112230.wsumgs62fqdxt3sc@xzhoul.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiong Zhou <xzhou@redhat.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Currently in DAX if we have three read faults on the same hole address we
can end up with the following:

Thread 0		Thread 1		Thread 2
--------		--------		--------
dax_iomap_fault
 grab_mapping_entry
  lock_slot
   <locks empty DAX entry>

  			dax_iomap_fault
			 grab_mapping_entry
			  get_unlocked_mapping_entry
			   <sleeps on empty DAX entry>

						dax_iomap_fault
						 grab_mapping_entry
						  get_unlocked_mapping_entry
						   <sleeps on empty DAX entry>
  dax_load_hole
   find_or_create_page
   ...
    page_cache_tree_insert
     dax_wake_mapping_entry_waiter
      <wakes one sleeper>
     __radix_tree_replace
      <swaps empty DAX entry with 4k zero page>

			<wakes>
			get_page
			lock_page
			...
			put_locked_mapping_entry
			unlock_page
			put_page

						<sleeps forever on the DAX
						 wait queue>

The crux of the problem is that once we insert a 4k zero page, all locking
from then on is done in terms of that 4k zero page and any additional
threads sleeping on the empty DAX entry will never be woken.  Fix this by
waking all sleepers when we replace the DAX radix tree entry with a 4k zero
page.  This will allow all sleeping threads to successfully transition from
locking based on the DAX empty entry to locking on the 4k zero page.

With the test case reported by Xiong this happens very regularly in my test
setup, with some runs resulting in 9+ threads in this deadlocked state.
With this fix I've been able to run that same test dozens of times in a
loop without issue.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reported-by: Xiong Zhou <xzhou@redhat.com>
Fixes: commit ac401cc78242 ("dax: New fault locking")
Cc: Jan Kara <jack@suse.cz>
Cc: stable@vger.kernel.org # 4.7+
---

This issue exists as far back as v4.7, and I was easly able to reproduce it
with v4.7 using the same test.

Unfortunately this patch won't apply cleanly to the stable trees, but the
change is very simple and should be easy to replicate by hand.  Please ping
me if you'd like patches that apply cleanly to the v4.9 and v4.8.15 trees.

---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index d0e4d10..b772a33 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -138,7 +138,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 				dax_radix_locked_entry(0, RADIX_DAX_EMPTY));
 			/* Wakeup waiters for exceptional entry lock */
 			dax_wake_mapping_entry_waiter(mapping, page->index, p,
-						      false);
+						      true);
 		}
 	}
 	__radix_tree_replace(&mapping->page_tree, node, slot, page,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
