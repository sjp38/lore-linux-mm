Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id A5F0C6B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 17:39:51 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so10003386pbb.11
        for <linux-mm@kvack.org>; Tue, 27 May 2014 14:39:51 -0700 (PDT)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id yn4si20850385pac.38.2014.05.27.14.39.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 14:39:50 -0700 (PDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so10044116pbc.1
        for <linux-mm@kvack.org>; Tue, 27 May 2014 14:39:50 -0700 (PDT)
Date: Tue, 27 May 2014 14:38:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm/next]
 vmscan-memcg-always-use-swappiness-of-the-reclaimed-memcg-swappiness-and-o
 om-control-fix.patch
In-Reply-To: <alpine.LSU.2.11.1405271432400.4485@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1405271436200.4485@eggly.anvils>
References: <alpine.LSU.2.11.1405271432400.4485@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mem_cgroup_swappiness() oopses immediately when
booted with cgroup_disable=memory.  Fix that in the obvious inelegant
way for now - though I hope we are moving towards a world in which
almost all of the mem_cgroup_disabled() tests will vanish, with a
root_mem_cgroup which can handle the basics even when disabled.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm/mm/memcontrol.c	2014-05-21 18:12:18.072022438 -0700
+++ linux/mm/memcontrol.c	2014-05-21 19:34:30.608546905 -0700
@@ -1531,7 +1531,7 @@ static unsigned long mem_cgroup_margin(s
 int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
 	/* root ? */
-	if (!memcg->css.parent)
+	if (mem_cgroup_disabled() || !memcg->css.parent)
 		return vm_swappiness;
 
 	return memcg->swappiness;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
