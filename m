Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3ADC96B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 13:44:41 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [RFC v2 0/5] Transparent on-demand struct page initialization embedded in the buddy allocator
Date: Fri,  2 Aug 2013 12:44:22 -0500
Message-Id: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
In-Reply-To: <1373594635-131067-1-git-send-email-holt@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, holt@sgi.com, nzimmer@sgi.com, rob@landley.net, travis@sgi.com, daniel@numascale-asia.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, yinghai@kernel.org, mgorman@suse.de

We are still restricting ourselves ourselves to 2MiB initialization to keep the
patch set a little smaller and more clear.

We are still struggling with the expand().  Nearly always the first reference
to a struct page which is in the middle of the 2MiB region.  We were unable to
find a good solution.  Also, given the strong warning at the head of expand(),
we did not feel experienced enough to refactor it to make things always
reference the 2MiB page first.
The only other fastpath impact left is the expansion in prep_new_page.

With this patch, we did boot a 16TiB machine.
The two main areas that benefit from this patch is free_all_bootmem and
memmap_init_zone.  Without the patches it took 407 seconds and 1151 seconds
respectively.  With the patches it took 220 and 49 seconds respectively.
This is a total savings of 1289 seconds (21 minutes).
These times were aquired using a modified version of script which record the
time in uSecs at the beginning of each line of output.

The previous patch set was faster through free_all_bootmem but I wanted to
include Yinghai suggestion.  Hopefully I didn't miss the mark too much with
that patch and yes I do still need to optimize it.

I know there are some still rough parts but I wanted to check in with the full
patch set.

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
 mm/page_alloc.c            | 194 ++++++++++++++++++++++++++++++++++++---------
 7 files changed, 225 insertions(+), 56 deletions(-)

-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
