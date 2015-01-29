Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6121E6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 06:51:59 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id 10so27145925lbg.6
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 03:51:58 -0800 (PST)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [2a02:6b8:0:1402::10])
        by mx.google.com with ESMTPS id po2si7198502lbc.18.2015.01.29.03.51.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 03:51:57 -0800 (PST)
From: Roman Gushchin <klamm@yandex-team.ru>
Subject: [PATCH] mm: don't account shared file pages in user_reserve_pages
Date: Thu, 29 Jan 2015 14:51:27 +0300
Message-Id: <1422532287-23601-1-git-send-email-klamm@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>, Andrew Morton <akpm@linux-foundation.org>, Andrew Shewmaker <agshew@gmail.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Shared file pages are never accounted in memory overcommit code,
so it isn't reasonable to count them in a code that limits the
maximal size of a process in OVERCOMMIT_NONE mode.

If a process has few large file mappings, the consequent attempts
to allocate anonymous memory may unexpectedly fail with -ENOMEM,
while there is free memory and overcommit limit if significantly
larger than the committed amount (as displayed in /proc/meminfo).

The problem is significantly smoothed by commit c9b1d0981fcc
("mm: limit growth of 3% hardcoded other user reserve"),
which limits the impact of this check with 128Mb (tunable via sysctl),
but it can still be a problem on small machines.

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrew Shewmaker <agshew@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 7f684d5..151fadf 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -220,7 +220,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	 */
 	if (mm) {
 		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
-		allowed -= min(mm->total_vm / 32, reserve);
+		allowed -= min((mm->total_vm - mm->shared_vm) / 32, reserve);
 	}
 
 	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
