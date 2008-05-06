Date: Tue, 06 May 2008 14:40:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: on CONFIG_MM_OWNER=y, kernel panic is possible.
Message-Id: <20080506142255.AC5D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

on CONFIG_MM_OWNER=y (that is automatically turned on by mem-cgroup),
kernel panic is possible by following scenario in mm_update_next_owner().

1. mm_update_next_owner() is called.
2. found caller task in do_each_thread() loop.
3. thus, BUG_ON(c == p) is true, it become kernel panic.

end up, We should left out current task.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>

---
 kernel/exit.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/kernel/exit.c
===================================================================
--- a/kernel/exit.c     2008-05-04 22:57:23.000000000 +0900
+++ b/kernel/exit.c     2008-05-06 15:01:26.000000000 +0900
@@ -627,7 +627,7 @@ retry:
         * here often
         */
        do_each_thread(g, c) {
-               if (c->mm == mm)
+               if ((c != p) && (c->mm == mm))
                        goto assign_new_owner;
        } while_each_thread(g, c);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
