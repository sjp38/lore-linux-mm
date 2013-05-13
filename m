Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 66BD26B0034
	for <linux-mm@kvack.org>; Mon, 13 May 2013 01:05:12 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id xb12so157229pbc.14
        for <linux-mm@kvack.org>; Sun, 12 May 2013 22:05:11 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V2 1/3] memcg: rewrite the comment about race condition of page stat accounting
Date: Mon, 13 May 2013 13:04:51 +0800
Message-Id: <1368421491-4897-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

While doing memcg page stat accounting, we need to access page_cgroup
members including pc->mem_cgroup and pc->flags, so there are 3 candidates
which have potential race conditions with it: move account, charge, uncharge.

But page stat and uncharge can also take it easy because the former is done
before the page is deleted from radix-tree and the later is after the delete,
so they will be serialized by some other locks(like page lock).

So the races among them will be solved by:

	  stat	   	move		  charge	    uncharge
stat	   X	      move lock   	 no race	    no race
move	       		 X	     lock_page_cgroup    lock_page_cgroup
charge  				    X		 lock_page_cgroup
uncharge						       X

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fe4f123..b31513e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2317,9 +2317,10 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
  * are no race with "charge".
  *
  * Considering "uncharge", we know that memcg doesn't clear pc->mem_cgroup
- * at "uncharge" intentionally. So, we always see valid pc->mem_cgroup even
- * if there are race with "uncharge". Statistics itself is properly handled
- * by flags.
+ * at "uncharge" intentionally but clear PageCgroupUsed flag for that page.
+ * Besides, the file-stat operations happen before a page is deleted from
+ * radix-tree while uncharge is after the delete. So there are no race with
+ * "uncharge" too.
  *
  * Considering "move", this is an only case we see a race. To make the race
  * small, we check mm->moving_account and detect there are possibility of race
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
