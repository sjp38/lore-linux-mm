Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4EA6B0037
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:57:15 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so2470957pbc.33
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:57:14 -0800 (PST)
Received: from mail-pb0-x22d.google.com (mail-pb0-x22d.google.com [2607:f8b0:400e:c01::22d])
        by mx.google.com with ESMTPS id tq5si2745989pac.182.2014.02.06.15.57.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 15:57:12 -0800 (PST)
Received: by mail-pb0-f45.google.com with SMTP id un15so2444148pbc.18
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:57:11 -0800 (PST)
Date: Thu, 6 Feb 2014 15:56:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] cgroup: use an ordered workqueue for cgroup destruction
Message-ID: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Sometimes the cleanup after memcg hierarchy testing gets stuck in
mem_cgroup_reparent_charges(), unable to bring non-kmem usage down to 0.

There may turn out to be several causes, but a major cause is this: the
workitem to offline parent can get run before workitem to offline child;
parent's mem_cgroup_reparent_charges() circles around waiting for the
child's pages to be reparented to its lrus, but it's holding cgroup_mutex
which prevents the child from reaching its mem_cgroup_reparent_charges().

Just use an ordered workqueue for cgroup_destroy_wq.

Fixes: e5fca243abae ("cgroup: use a dedicated workqueue for cgroup destruction")
Suggested-by: Filipe Brandenburger <filbranden@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org # 3.10+
---

 kernel/cgroup.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- 3.14-rc1/kernel/cgroup.c	2014-02-02 18:49:07.737302111 -0800
+++ linux/kernel/cgroup.c	2014-02-06 15:20:35.548904965 -0800
@@ -4845,12 +4845,12 @@ static int __init cgroup_wq_init(void)
 	/*
 	 * There isn't much point in executing destruction path in
 	 * parallel.  Good chunk is serialized with cgroup_mutex anyway.
-	 * Use 1 for @max_active.
+	 * Must be ordered to make sure parent is offlined after children.
 	 *
 	 * We would prefer to do this in cgroup_init() above, but that
 	 * is called before init_workqueues(): so leave this until after.
 	 */
-	cgroup_destroy_wq = alloc_workqueue("cgroup_destroy", 0, 1);
+	cgroup_destroy_wq = alloc_ordered_workqueue("cgroup_destroy", 0);
 	BUG_ON(!cgroup_destroy_wq);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
