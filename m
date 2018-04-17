Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAD726B000E
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:06:27 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l19so4258107qkk.11
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 04:06:27 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 22si8156124qtm.234.2018.04.17.04.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 04:06:26 -0700 (PDT)
From: Li Wang <liwang@redhat.com>
Subject: [RFC PATCH] mm: correct status code which move_pages() returns for zero page
Date: Tue, 17 Apr 2018 19:06:15 +0800
Message-Id: <20180417110615.16043-1-liwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>

move_pages(2) declears that status code for zero page is supposed to
be -EFAULT. But now it (LTP/move_pages04 test) gets -EPERM, the root
cause is that not goto out_flush after store_status() saves the err
which add_page_for_migration() returns for zero page.

LTP move_pages04:
   TFAIL  :  move_pages04.c:143: status[1] is EPERM, expected EFAULT

Signed-off-by: Li Wang <liwang@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index f65dd69..2b315fc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1608,7 +1608,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			continue;
 
 		err = store_status(status, i, err, 1);
-		if (err)
+		if (!err)
 			goto out_flush;
 
 		err = do_move_pages_to_node(mm, &pagelist, current_node);
-- 
2.9.5
