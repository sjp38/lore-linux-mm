Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id A40766B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 02:09:22 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 124so45855772pfg.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 23:09:22 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id h26si9455050pfj.143.2016.02.29.23.09.21
        for <linux-mm@kvack.org>;
        Mon, 29 Feb 2016 23:09:21 -0800 (PST)
Date: Tue, 1 Mar 2016 02:09:11 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160301070911.GD3730@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org


There are a few issues around 1GB THP support that I've come up against
while working on DAX support that I think may be interesting to discuss
in person.

 - Do we want to add support for 1GB THP for anonymous pages?  DAX support
   is driving the initial 1GB THP support, but would anonymous VMAs also
   benefit from 1GB support?  I'm not volunteering to do this work, but
   it might make an interesting conversation if we can identify some users
   who think performance would be better if they had 1GB THP support.

 - Latency of a major page fault.  According to various public reviews,
   main memory bandwidth is about 30GB/s on a Core i7-5960X with 4
   DDR4 channels.  I think people are probably fairly unhappy about
   doing only 30 page faults per second.  So maybe we need a more complex
   scheme to handle major faults where we insert a temporary 2MB mapping,
   prepare the other 2MB pages in the background, then merge them into
   a 1GB mapping when they're completed.

 - Cache pressure from 1GB page support.  If we're using NT stores, they
   bypass the cache, and all should be good.  But if there are
   architectures that support THP and not NT stores, zeroing a page is
   just going to obliterate their caches.

Other topics that might interest people from a VM/FS point of view:

 - Uses for (or replacement of) the radix tree.  We're currently
   looking at using the radix tree with DAX in order to reduce the number
   of calls into the filesystem.  That's leading to various enhancements
   to the radix tree, such as support for a lock bit for exceptional
   entries (Neil Brown), and support for multi-order entries (me).
   Is the (enhanced) radix tree the right data structure to be using
   for this brave new world of huge pages in the page cache, or should
   we be looking at some other data structure like an RB-tree?

 - Can we get rid of PAGE_CACHE_SIZE now?  Finally?  Pretty please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
