Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l4BDx3kb017534
	for <linux-mm@kvack.org>; Fri, 11 May 2007 13:59:03 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4BDx2bh2506872
	for <linux-mm@kvack.org>; Fri, 11 May 2007 15:59:02 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4BDwwNO030182
	for <linux-mm@kvack.org>; Fri, 11 May 2007 15:58:58 +0200
Message-Id: <20070511135827.393181482@de.ibm.com>
Date: Fri, 11 May 2007 15:58:27 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 0/6] [rfc] guest page hinting version 5
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: virtualization@lists.osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zachary Amsden <zach@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hubertus Franke <frankeh@watson.ibm.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

After way to many months here is the fifth version of the guest page
hinting patches. Compared to version four a few improvements have been
added:
 - Avoid page_host_discards() calls outside of page-states.h
 - The discard list is now implemented via the page_free_discarded
   hook and architecture specific code.
 - PG_state_change page flag has been replaced with architecture
   specficic primitives. s390 now uses PG_arch_1 and avoids to waste
   another page flag (it still uses two additional bits).
 - Add calls to make pages volatile when pages are moved from the
   active to the inactive list and set max_buffer_heads to zero to
   force a try_to_release_page call to get more page into volatile
   state.
 - remap_file_pages now works with guest page hinting, although the
   discard of a page contained in a non-linear mapping is slow.
 - Simplified the check in the mlock code.
 - In general the code looks a bit nicer now.

I tried to implement batched state transitions to volatile but after
a few failures I gave up. Basically, most pages are made volatile with
the unlock_page call after the end of i/o. To postpone a make volatile
attempt requires to take a page reference. Trouble is you can't release
a page reference from interrupt context. This has to be done in task
context, so we can't use a pvec/array for keep the references. There is
no room in struct page for a list, so it turns out lazy make volatile
is hard to implement.

The patches apply on the current git tree.

Many thanks go to Oliver Paukstadt who kept me busy with bug reports
and uncountable dumps ..

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
