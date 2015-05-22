Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id EC8DE829C8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 14:22:34 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so18351440qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 11:22:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z189si3211467qhd.94.2015.05.22.11.22.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 11:22:33 -0700 (PDT)
Date: Fri, 22 May 2015 20:21:51 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 3/3] memcg: change mm_update_next_owner() to search in
	sub-threads first
Message-ID: <20150522182151.GD26770@redhat.com>
References: <20150519121321.GB6203@dhcp22.suse.cz> <20150519212754.GO24861@htj.duckdns.org> <20150520131044.GA28678@dhcp22.suse.cz> <20150520132158.GB28678@dhcp22.suse.cz> <20150520175302.GA7287@redhat.com> <20150520202221.GD14256@dhcp22.suse.cz> <20150521192716.GA21304@redhat.com> <20150522093639.GE5109@dhcp22.suse.cz> <20150522162900.GA8955@redhat.com> <20150522182054.GA26770@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522182054.GA26770@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

mm_update_next_owner() checks the children and siblings to avoid
the "global" for_each_process() loop. Not sure this makes any sense,
but certainly it makes sense to check our sub-threads before anything
else.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 kernel/exit.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 1d1810d..b1f7135 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -340,6 +340,12 @@ void mm_update_next_owner(struct mm_struct *mm)
 
 	read_lock(&tasklist_lock);
 	/*
+	 * Search in the sub-threads
+	 */
+	if (assign_new_owner(mm, p))
+		goto done;
+
+	/*
 	 * Search in the children
 	 */
 	list_for_each_entry(g, &p->children, sibling) {
@@ -359,7 +365,7 @@ void mm_update_next_owner(struct mm_struct *mm)
 	 * Search through everything else, we should not get here often.
 	 */
 	for_each_process(g) {
-		if (g->flags & PF_KTHREAD)
+		if (g == p || g->flags & PF_KTHREAD)
 			continue;
 		if (assign_new_owner(mm, g))
 			goto done;
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
