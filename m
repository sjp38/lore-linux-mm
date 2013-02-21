Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 9E2BA6B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 21:22:29 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id wz12so3257328pbc.17
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 18:22:28 -0800 (PST)
Date: Thu, 21 Feb 2013 10:22:19 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 2/4 v3]swap: __swap_duplicate check bad swap entry
Message-ID: <20130221022219.GE32580@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org

Sorry if you receive this one twice, last mail get mail address messed.

In swapin_readahead(), read_swap_cache_async() can read a bad swap entry,
because we don't check if readahead swap entry is bad. This doesn't break
anything but such swapin page is wasteful and can only be freed at page
reclaim. We avoid read such swap entry.

And next patch will mark a swap entry bad temporarily for discard. Without this
patch, swap entry count will be messed.

Thanks Hugh to inspire swapin_readahead could use bad swap entry.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 mm/swapfile.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2013-02-18 15:21:09.285317914 +0800
+++ linux/mm/swapfile.c	2013-02-18 15:21:34.545004083 +0800
@@ -2374,6 +2374,11 @@ static int __swap_duplicate(swp_entry_t
 		goto unlock_out;
 
 	count = p->swap_map[offset];
+	if (unlikely(swap_count(count) == SWAP_MAP_BAD)) {
+		err = -ENOENT;
+		goto unlock_out;
+	}
+
 	has_cache = count & SWAP_HAS_CACHE;
 	count &= ~SWAP_HAS_CACHE;
 	err = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
