Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4BBC66B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 17:37:22 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so9990499pbb.3
        for <linux-mm@kvack.org>; Tue, 27 May 2014 14:37:21 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id x4si20445250pbw.180.2014.05.27.14.37.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 14:37:21 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so9800939pad.2
        for <linux-mm@kvack.org>; Tue, 27 May 2014 14:37:20 -0700 (PDT)
Date: Tue, 27 May 2014 14:36:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm/next] memcg-mm-introduce-lowlimit-reclaim-fix2.patch
Message-ID: <alpine.LSU.2.11.1405271432400.4485@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mem_cgroup_within_guarantee() oopses in _raw_spin_lock_irqsave() when
booted with cgroup_disable=memory.  Fix that in the obvious inelegant
way for now - though I hope we are moving towards a world in which
almost all of the mem_cgroup_disabled() tests will vanish, with a
root_mem_cgroup which can handle the basics even when disabled.

I bet there's a neater way of doing this, rearranging the loop (and we
shall want to avoid spinlocking on root_mem_cgroup when we reach that
new world), but that's the kind of thing I'd get wrong in a hurry!

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/memcontrol.c |    3 +++
 1 file changed, 3 insertions(+)

--- mmotm/mm/memcontrol.c	2014-05-21 18:12:18.072022438 -0700
+++ linux/mm/memcontrol.c	2014-05-21 19:34:30.608546905 -0700
@@ -2793,6 +2793,9 @@ static struct mem_cgroup *mem_cgroup_loo
 bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
 		struct mem_cgroup *root)
 {
+	if (mem_cgroup_disabled())
+		return false;
+
 	do {
 		if (!res_counter_low_limit_excess(&memcg->res))
 			return true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
