Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f170.google.com (mail-gg0-f170.google.com [209.85.161.170])
	by kanga.kvack.org (Postfix) with ESMTP id 849C66B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:54:31 -0500 (EST)
Received: by mail-gg0-f170.google.com with SMTP id l4so1223787ggi.29
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:54:31 -0800 (PST)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id s6si22928696yho.14.2014.01.13.17.54.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 17:54:30 -0800 (PST)
Received: by mail-pd0-f182.google.com with SMTP id g10so1990375pdj.13
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:54:29 -0800 (PST)
Date: Mon, 13 Jan 2014 17:54:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/3] mm/memcg: iteration skip memcgs not yet fully
 initialized
In-Reply-To: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1401131752360.2229@eggly.anvils>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It is surprising that the mem_cgroup iterator can return memcgs which
have not yet been fully initialized.  By accident (or trial and error?)
this appears not to present an actual problem; but it may be better to
prevent such surprises, by skipping memcgs not yet online.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Decide for yourself whether to take this or not.  I spent quite a while
digging into a mysterious "trying to register non-static key" issue from
lockdep, which originated from the iterator returning a vmalloc'ed memcg
a moment before the res_counter_init()s had done their spin_lock_init()s.
But the backtrace was an odd one of our own mis-devising, not a charge or
reclaim or stats trace, so probably it's never been a problem for vanilla.

 mm/memcontrol.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

--- mmotm/mm/memcontrol.c	2014-01-10 18:25:02.236448954 -0800
+++ linux/mm/memcontrol.c	2014-01-12 22:21:10.700570471 -0800
@@ -1119,10 +1119,8 @@ skip_node:
 	 * protected by css_get and the tree walk is rcu safe.
 	 */
 	if (next_css) {
-		struct mem_cgroup *mem = mem_cgroup_from_css(next_css);
-
-		if (css_tryget(&mem->css))
-			return mem;
+		if ((next_css->flags & CSS_ONLINE) && css_tryget(next_css))
+			return mem_cgroup_from_css(next_css);
 		else {
 			prev_css = next_css;
 			goto skip_node;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
