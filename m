Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 8F3106B0062
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 23:59:09 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Fri, 27 Jul 2012 23:58:08 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8BD3838C8039
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 23:57:55 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6S3vtQg355712
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 23:57:55 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6S3vrIv002177
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 21:57:55 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 0/5][RFC] Fallocate Volatile Ranges v6
Date: Fri, 27 Jul 2012 23:57:07 -0400
Message-Id: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

So after not getting too much positive feedback on my last
attempt at trying to use a non-shrinker method for managing
& purging volatile ranges, I decided I'd go ahead and try
to implement something along Minchan's ERECLAIM LRU list
idea.

Again this patchset has two parts:

The first 3 patches add generic volatile range management code, as 
well as tmpfs support for FALLOC_FL_MARK_VOLATILE, which uses a
shrinker to purge ranges, and converts ashmem to use
FALLOC_FL_MARK_VOLATILE, almost reducing the driver in half.


Since Kosaki-san objected to using the shrinker, as its not numa
aware, and is only called after we shrink normal lru lists. The 
second half of this patch set provides a different method that is
not shrinker based.

The last two patches introduce a new lru list, LRU_VOLATILE.
When pages are marked volatile, they are moved to this lru list,
which we will shrink first when trying to free up memory.

The reason why I'm keeping this in two parts is that I want
to be able to easily do performance comparisons between
the more lightweight, but numa-unaware, shrinker method vs the
more correct, but slower (due to the page-by-page management)
method of handling it deeper in the VM.

I know the way this is currently implemented is really bad for
performance, since we add/remove pages to the LRU_VOLATILE list
page by page instead of batching. So I know this needs more work,
but I wanted to get just some initial reactions to this approach
versus the earlier ones.

Also, I know this isn't exactly the same as the ERECLAIM lru list
that Minchan suggested, since that might also contain inactive
clean file pages as well, but I wanted to stick to just volatile
pages for now as I learn more about how the core vm works. I'll
be fine to rename LRU_VOLATILE later if its appropriate.

What's new in this iteration:
* Dropped the writepage style purging instead for the LRU_VOLATILE

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Android Kernel Team <kernel-team@android.com>
CC: Robert Love <rlove@google.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Hugh Dickins <hughd@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Rik van Riel <riel@redhat.com>
CC: Dmitry Adamushko <dmitry.adamushko@gmail.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Neil Brown <neilb@suse.de>
CC: Andrea Righi <andrea@betterlinux.com>
CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
CC: Mike Hommey <mh@glandium.org>
CC: Jan Kara <jack@suse.cz>
CC: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
CC: Michel Lespinasse <walken@google.com>
CC: Minchan Kim <minchan@kernel.org>
CC: linux-mm@kvack.org <linux-mm@kvack.org>


John Stultz (5):
  [RFC] Add volatile range management code
  [RFC] tmpfs: Add FALLOC_FL_MARK_VOLATILE/UNMARK_VOLATILE handlers
  [RFC] ashmem: Convert ashmem to use volatile ranges
  [RFC][HACK] Add LRU_VOLATILE support to the VM
  [RFC][HACK] Switch volatile/shmem over to LRU_VOLATILE

 drivers/staging/android/ashmem.c |  331 +--------------------------
 fs/open.c                        |    3 +-
 include/linux/falloc.h           |    7 +-
 include/linux/fs.h               |    1 +
 include/linux/mm_inline.h        |    2 +
 include/linux/mmzone.h           |    1 +
 include/linux/page-flags.h       |    3 +
 include/linux/swap.h             |    3 +
 include/linux/volatile.h         |   39 ++++
 mm/Makefile                      |    2 +-
 mm/memcontrol.c                  |    1 +
 mm/page_alloc.c                  |    1 +
 mm/shmem.c                       |  118 ++++++++++
 mm/swap.c                        |   71 ++++++
 mm/vmscan.c                      |   76 ++++++-
 mm/volatile.c                    |  459 ++++++++++++++++++++++++++++++++++++++
 16 files changed, 788 insertions(+), 330 deletions(-)
 create mode 100644 include/linux/volatile.h
 create mode 100644 mm/volatile.c

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
