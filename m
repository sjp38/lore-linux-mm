Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id CC5006B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 23:53:30 -0500 (EST)
Received: by pbcup15 with SMTP id up15so1131911pbc.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 20:53:30 -0800 (PST)
Date: Mon, 5 Mar 2012 20:52:55 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] page_cgroup: fix horrid swap accounting regression
Message-ID: <alpine.LSU.2.00.1203052046410.24068@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Why is memcg's swap accounting so broken?  Insane counts, wrong ownership,
unfreeable structures, which later get freed and then accessed after free.

Turns out to be a tiny a little 3.3-rc1 regression in 9fb4b7cc0724
"page_cgroup: add helper function to get swap_cgroup": the helper
function (actually named lookup_swap_cgroup()) returns an address
using void* arithmetic, but the structure in question is a short.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/page_cgroup.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- 3.3-rc6/mm/page_cgroup.c	2012-01-20 08:42:35.320020840 -0800
+++ linux/mm/page_cgroup.c	2012-03-05 19:51:13.535372098 -0800
@@ -379,13 +379,15 @@ static struct swap_cgroup *lookup_swap_c
 	pgoff_t offset = swp_offset(ent);
 	struct swap_cgroup_ctrl *ctrl;
 	struct page *mappage;
+	struct swap_cgroup *sc;
 
 	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
 	if (ctrlp)
 		*ctrlp = ctrl;
 
 	mappage = ctrl->map[offset / SC_PER_PAGE];
-	return page_address(mappage) + offset % SC_PER_PAGE;
+	sc = page_address(mappage);
+	return sc + offset % SC_PER_PAGE;
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
