Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1A986B0006
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 08:13:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s6so681794pgn.16
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 05:13:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h17sor258321pfn.93.2018.04.18.05.13.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 05:13:05 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: Fix do_pages_move status handling
Date: Wed, 18 Apr 2018 14:12:55 +0200
Message-Id: <20180418121255.334-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Wang <liwang@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, ltp@lists.linux.it, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Li Wang has reported that LTP move_pages04 test fails with the current
tree:
LTP move_pages04:
   TFAIL  :  move_pages04.c:143: status[1] is EPERM, expected EFAULT

The test allocates an array of two pages, one is present while the other
is not (resp. backed by zero page) and it expects EFAULT for the second
page as the man page suggests. We are reporting EPERM which doesn't make
any sense and this is a result of a bug from cf5f16b23ec9 ("mm:
unclutter THP migration").

do_pages_move tries to handle as many pages in one batch as possible so
we queue all pages with the same node target together and that
corresponds to [start, i] range which is then used to update status
array. add_page_for_migration will correctly notice the zero (resp.
!present) page and returns with EFAULT which gets written to the status.
But if this is the last page in the array we do not update start and so
the last store_status after the loop will overwrite the range of the
last batch with NUMA_NO_NODE (which corresponds to EPERM).

Fix this by simply bailing out from the last flush if the pagelist
is empty as there is clearly nothing more to do.

Fixes: cf5f16b23ec9 ("mm: unclutter THP migration")
Reported-and-Tested-by: Li Wang <liwang@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi Andrew,
this is a new regression in 4.17-rc1 so it would be great to merge
sooner rather than later. It is a user visible change. The original
bug report is http://lkml.kernel.org/r/20180417110615.16043-1-liwang@redhat.com
Thanks to Li Wang for his testing!

 mm/migrate.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index 507cf9ba21bf..c7e5f6447417 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1634,6 +1634,9 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		current_node = NUMA_NO_NODE;
 	}
 out_flush:
+	if (list_empty(&pagelist))
+		return err;
+
 	/* Make sure we do not overwrite the existing error */
 	err1 = do_move_pages_to_node(mm, &pagelist, current_node);
 	if (!err1)
-- 
2.16.3
