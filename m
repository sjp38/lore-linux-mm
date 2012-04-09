Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id D99C66B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:03:41 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so4855443bkw.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 13:03:40 -0700 (PDT)
Subject: [PATCH] mm: sync rss-counters at the end of exit_mm()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 10 Apr 2012 00:03:36 +0400
Message-ID: <20120409200336.8368.63793.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Markus Trippelsdorf <markus@trippelsdorf.de>

On task's exit do_exit() calls sync_mm_rss() but this is not enough,
there can be page-faults after this point, for example exit_mm() ->
mm_release() -> put_user() (for processing tsk->clear_child_tid).
Thus there may be some rss-counters delta in current->rss_stat.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 kernel/exit.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/exit.c b/kernel/exit.c
index d8bd3b42..8e09dbe 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -683,6 +683,7 @@ static void exit_mm(struct task_struct * tsk)
 	enter_lazy_tlb(mm, current);
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
+	sync_mm_rss(mm);
 	mmput(mm);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
