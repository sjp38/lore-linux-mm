Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6C1900137
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 17:07:47 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p74L7fWk014679
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 14:07:44 -0700
Received: from yxi11 (yxi11.prod.google.com [10.190.3.11])
	by wpaz33.hot.corp.google.com with ESMTP id p74L7Is1008200
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 14:07:40 -0700
Received: by yxi11 with SMTP id 11so1591412yxi.11
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 14:07:38 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 0/3] page count lock for simpler put_page
Date: Thu,  4 Aug 2011 14:07:19 -0700
Message-Id: <1312492042-13184-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

I'd like to sollicit comments on the following patches againse v3.0:

Patch 1 introduces new accessors for page->_count. I believe it is
actually ready for upstream submission.

Patch 2 introduces a new page count lock. Using it, the interaction between
__split_huge_page_refcount and put_compound_page is much simplified.
I would like to get comments about this part. One known issue is that
my implementation of the page count lock does not currently provide
the required memory barrier semantics on non-x86 architectures.
This could however be remedied if we decide to go ahead with the idea.

Patch 3 demonstrates my motivation for this patch series: in my pre-THP
implementation of idle page tracking, I was able to use get_page_unless_zero
in a way that __split_huge_page_refcount made unsafe. Building on top of
patch 2, I can make the required operation safe again. If patch 2 was to
be rejected, I would like to get suggestions about alternative approaches
to implement the get_first_page_unless_zero() operation described here.

Michel Lespinasse (3):
  mm: Replace naked page->_count accesses with accessor functions
  mm: page count lock
  mm: get_first_page_unless_zero()

 arch/powerpc/mm/gup.c                        |    4 +-
 arch/powerpc/platforms/512x/mpc512x_shared.c |    5 +-
 arch/x86/mm/gup.c                            |    6 +-
 drivers/net/niu.c                            |    4 +-
 include/linux/mm.h                           |   38 ++++++--
 include/linux/pagemap.h                      |   10 ++-
 mm/huge_memory.c                             |   25 +++---
 mm/internal.h                                |   97 ++++++++++++++++++++-
 mm/memory_hotplug.c                          |    4 +-
 mm/swap.c                                    |  122 +++++++++++---------------
 10 files changed, 205 insertions(+), 110 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
