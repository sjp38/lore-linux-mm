Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 586CA6B0036
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 17:54:44 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [RFC v3 0/5] Transparent on-demand struct page initialization embedded in the buddy allocator
Date: Mon, 12 Aug 2013 16:54:35 -0500
Message-Id: <1376344480-156708-1-git-send-email-nzimmer@sgi.com>
In-Reply-To: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, holt@sgi.com, nzimmer@sgi.com, rob@landley.net, travis@sgi.com, daniel@numascale-asia.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, yinghai@kernel.org, mgorman@suse.de

We are still restricting ourselves ourselves to 2MiB initialization.
This was initially to keep the patch set a little smaller and more clear.
However given how well it is currently performing I don't see a how much
better it could be with to 2GiB chunks.

As far as extra overhead. We incur an extra function call to
ensure_page_is_initialized but that is only really expensive when we find
uninitialized pages, otherwise it is a flag check once every PTRS_PER_PMD.
To get a better feel for this we ran two quick tests.

The first was simply timing some memhogs.
This showed no measurable difference so we made a more granular test.
We spawned N threads, start a timer, each thread mallocs totalmem/N then each
thread writes to its memory to induce page faults, stop the timer.
In this case it each thread had just under 4GB of ram to fault in.
This showed a measureable difference in the page faulting.
The baseline took an average of 2.68 seconds, the new version took an
average of 2.75 seconds.  Which is .07s slower or 2.6%.
Are there some other tests I should run?

With this patch, we did boot a 16TiB machine.
The two main areas that benefit from this patch is free_all_bootmem and
memmap_init_zone.  Without the patches it took 407 seconds and 1151 seconds
respectively.  With the patches it took 13 and 39 seconds respectively.
This is a total savings of 1506 seconds (25 minutes).
These times were acquired using a modified version of script which record the
time in uSecs at the beginning of each line of output.

Overall I am fairly happy with the patch set at the moment.  It improves boot
times without noticeable runtime overhead.
I am, as always, open for suggestions.

v2: included the Yinghai's suggestion to not set the reserved bit until later.

v3: Corrected my first attempt at moving the reserved bit.
__expand_page_initialization should only be called by ensure_pages_are_initialized

Nathan Zimmer (1):
  Only set page reserved in the memblock region

Robin Holt (4):
  memblock: Introduce a for_each_reserved_mem_region iterator.
  Have __free_pages_memory() free in larger chunks.
  Move page initialization into a separate function.
  Sparse initialization of struct page array.

 include/linux/memblock.h   |  18 +++++
 include/linux/mm.h         |   2 +
 include/linux/page-flags.h |   5 +-
 mm/memblock.c              |  32 ++++++++
 mm/mm_init.c               |   2 +-
 mm/nobootmem.c             |  28 +++----
 mm/page_alloc.c            | 198 ++++++++++++++++++++++++++++++++++++---------
 7 files changed, 229 insertions(+), 56 deletions(-)

-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
