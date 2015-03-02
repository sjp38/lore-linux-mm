Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3A86B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 12:21:20 -0500 (EST)
Received: by iecvy18 with SMTP id vy18so49645109iec.6
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:21:20 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id e67si8193778ioi.40.2015.03.02.09.21.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 09:21:19 -0800 (PST)
Received: by igjz20 with SMTP id z20so19103681igj.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:21:19 -0800 (PST)
From: Jeff Vander Stoep <jeffv@google.com>
Subject: [PATCH] mm: reorder can_do_mlock to fix audit denial
Date: Mon,  2 Mar 2015 09:20:32 -0800
Message-Id: <1425316867-6104-1-git-send-email-jeffv@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nnk@google.com
Cc: Jeff Vander Stoep <jeffv@google.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Paul Cassella <cassella@cray.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A userspace call to mmap(MAP_LOCKED) may result in the successful
locking of memory while also producing a confusing audit log denial.
can_do_mlock checks capable and rlimit. If either of these return
positive can_do_mlock returns true. The capable check leads to an LSM
hook used by apparmour and selinux which produce the audit denial.
Reordering so rlimit is checked first eliminates the denial on success,
only recording a denial when the lock is unsuccessful as a result of
the denial.

Signed-off-by: Jeff Vander Stoep <jeffv@google.com>
---
 mm/mlock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 73cf098..8a54cd2 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -26,10 +26,10 @@
 
 int can_do_mlock(void)
 {
-	if (capable(CAP_IPC_LOCK))
-		return 1;
 	if (rlimit(RLIMIT_MEMLOCK) != 0)
 		return 1;
+	if (capable(CAP_IPC_LOCK))
+		return 1;
 	return 0;
 }
 EXPORT_SYMBOL(can_do_mlock);
-- 
2.2.0.rc0.207.ga3a616c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
