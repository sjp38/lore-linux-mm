Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id DE03E829C8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 14:22:16 -0400 (EDT)
Received: by qget53 with SMTP id t53so13305287qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 11:22:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n8si3267633qcj.3.2015.05.22.11.22.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 11:22:16 -0700 (PDT)
Date: Fri, 22 May 2015 20:21:33 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 2/3] memcg: change assign_new_owner() to consider the
	sub-htreads
Message-ID: <20150522182133.GC26770@redhat.com>
References: <20150519121321.GB6203@dhcp22.suse.cz> <20150519212754.GO24861@htj.duckdns.org> <20150520131044.GA28678@dhcp22.suse.cz> <20150520132158.GB28678@dhcp22.suse.cz> <20150520175302.GA7287@redhat.com> <20150520202221.GD14256@dhcp22.suse.cz> <20150521192716.GA21304@redhat.com> <20150522093639.GE5109@dhcp22.suse.cz> <20150522162900.GA8955@redhat.com> <20150522182054.GA26770@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522182054.GA26770@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

mm_update_next_owner() checks the children and siblings first but
it only inspects the group leaders, and thus this optimization won't
work if the leader is zombie.

This is actually correct, the last for_each_process() loop will find
these children/siblings again, but this doesn't look consistent/clean.

Move the for_each_thread() logic from mm_update_next_owner() to
assign_new_owner(). We can also remove the "struct task_struct *c"
local.

See also the next patch relies on this change.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 kernel/exit.c |   39 ++++++++++++++++++++-------------------
 1 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 4d446ab..1d1810d 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -293,19 +293,24 @@ kill_orphaned_pgrp(struct task_struct *tsk, struct task_struct *parent)
 }
 
 #ifdef CONFIG_MEMCG
-static bool assign_new_owner(struct mm_struct *mm, struct task_struct *c)
+static bool assign_new_owner(struct mm_struct *mm, struct task_struct *g)
 {
+	struct task_struct *c;
 	bool ret = false;
 
-	if (c->mm != mm)
-		return ret;
+	for_each_thread(g, c) {
+		if (c->mm == mm) {
+			task_lock(c); /* protects c->mm from changing */
+			if (c->mm == mm) {
+				mm->owner = c;
+				ret = true;
+			}
+			task_unlock(c);
+		}
 
-	task_lock(c); /* protects c->mm from changing */
-	if (c->mm == mm) {
-		mm->owner = c;
-		ret = true;
+		if (ret || c->mm)
+			break;
 	}
-	task_unlock(c);
 
 	return ret;
 }
@@ -315,7 +320,7 @@ static bool assign_new_owner(struct mm_struct *mm, struct task_struct *c)
  */
 void mm_update_next_owner(struct mm_struct *mm)
 {
-	struct task_struct *c, *g, *p = current;
+	struct task_struct *g, *p = current;
 
 	/*
 	 * If the exiting or execing task is not the owner, it's
@@ -337,16 +342,16 @@ void mm_update_next_owner(struct mm_struct *mm)
 	/*
 	 * Search in the children
 	 */
-	list_for_each_entry(c, &p->children, sibling) {
-		if (assign_new_owner(mm, c))
+	list_for_each_entry(g, &p->children, sibling) {
+		if (assign_new_owner(mm, g))
 			goto done;
 	}
 
 	/*
 	 * Search in the siblings
 	 */
-	list_for_each_entry(c, &p->real_parent->children, sibling) {
-		if (assign_new_owner(mm, c))
+	list_for_each_entry(g, &p->real_parent->children, sibling) {
+		if (assign_new_owner(mm, g))
 			goto done;
 	}
 
@@ -356,12 +361,8 @@ void mm_update_next_owner(struct mm_struct *mm)
 	for_each_process(g) {
 		if (g->flags & PF_KTHREAD)
 			continue;
-		for_each_thread(g, c) {
-			if (assign_new_owner(mm, c))
-				goto done;
-			if (c->mm)
-				break;
-		}
+		if (assign_new_owner(mm, g))
+			goto done;
 	}
 
 	/*
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
