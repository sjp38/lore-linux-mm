Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id CB0656B0068
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 19:23:37 -0500 (EST)
Received: by iacb35 with SMTP id b35so27281241iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 16:23:37 -0800 (PST)
Date: Wed, 28 Dec 2011 16:23:29 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/4] memcg: fix page migration to reset_owner
In-Reply-To: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112281622080.8257@eggly.anvils>
References: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

Usually, migration pages coming to unmap_and_move()'s putback_lru_page()
have been charged and have pc->mem_cgroup set; but there are several ways
in which a freshly allocated uncharged page can get there, oopsing when
added to LRU.  Call mem_cgroup_reset_owner() immediately after allocating.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Fix N to
    memcg: clear pc->mem_cgorup if necessary.

 mm/migrate.c |    2 ++
 1 file changed, 2 insertions(+)

--- mmotm.orig/mm/migrate.c	2011-12-22 02:53:31.900041565 -0800
+++ mmotm/mm/migrate.c	2011-12-28 14:52:37.243034125 -0800
@@ -841,6 +841,8 @@ static int unmap_and_move(new_page_t get
 	if (!newpage)
 		return -ENOMEM;
 
+	mem_cgroup_reset_owner(newpage);
+
 	if (page_count(page) == 1) {
 		/* page was freed from under us. So we are done. */
 		goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
