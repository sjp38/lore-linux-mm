Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id DF6936B0073
	for <linux-mm@kvack.org>; Sat, 27 Oct 2012 17:20:58 -0400 (EDT)
Received: from unknown (HELO cesarb-inspiron.home.cesarb.net) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-02.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 27 Oct 2012 21:20:56 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 2/2] mm: do not call frontswap_init() during swapoff
Date: Sat, 27 Oct 2012 19:20:47 -0200
Message-Id: <1351372847-13625-3-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1351372847-13625-1-git-send-email-cesarb@cesarb.net>
References: <1351372847-13625-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Cesar Eduardo Barros <cesarb@cesarb.net>

The call to frontswap_init() was added within enable_swap_info(), which
was called not only during sys_swapon, but also to reinsert the
swap_info into the swap_list in case of failure of try_to_unuse() within
sys_swapoff. This means that frontswap_init() might be called more than
once for the same swap area.

While as far as I could see no frontswap implementation has any problem
with it (and in fact, all the ones I found ignore the parameter passed
to frontswap_init), this could change in the future.

To prevent future problems, move the call to frontswap_init() to outside
the code shared between sys_swapon and sys_swapoff.

Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 886db96..088daf4 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1471,7 +1471,6 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 		swap_list.head = swap_list.next = p->type;
 	else
 		swap_info[prev]->next = p->type;
-	frontswap_init(p->type);
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
@@ -1480,6 +1479,7 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 {
 	spin_lock(&swap_lock);
 	_enable_swap_info(p, prio, swap_map, frontswap_map);
+	frontswap_init(p->type);
 	spin_unlock(&swap_lock);
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
