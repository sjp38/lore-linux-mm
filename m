Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C41C66B007E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 10:59:26 -0500 (EST)
Received: by gxk3 with SMTP id 3so58451gxk.6
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 07:59:23 -0800 (PST)
Subject: [PATCH -mm] Kill existing current task quickly
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 17 Feb 2010 00:59:17 +0900
Message-ID: <1266335957.1709.67.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

I am not sure why didn't we break the loop until now. 
As looking git log, I found it is removed by Nick at b78483a.
He mentioned "introduced a problem". If I miss something, 
pz, correct me. 

== CUT_HERE ==

[PATCH -mm] Kill existing current task quickly

If we found current task is existing but didn't set TIF_MEMDIE
during OOM victim selection, let's stop unnecessary looping for
getting high badness score task and go ahead for killing current.

This patch would make side effect skip OOM_DISABLE test.
But It's okay since the task is existing and oom_kill_process
doesn't show any killing message since __oom_kill_task will
interrupt it in oom_kill_process.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>
---
 mm/oom_kill.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3618be3..5c21398 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -295,6 +295,7 @@ static struct task_struct
*select_bad_process(unsigned long *ppoints,
 
 			chosen = p;
 			*ppoints = ULONG_MAX;
+			break;
 		}
 
 		if (p->signal->oom_adj == OOM_DISABLE)
-- 
1.6.5



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
