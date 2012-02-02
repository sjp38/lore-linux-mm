Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id CCCFC6B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 03:00:00 -0500 (EST)
Received: by iagz16 with SMTP id z16so3917282iag.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 00:00:00 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH] memcg: make threshold index in the right position
Date: Thu,  2 Feb 2012 15:58:14 +0800
Message-Id: <1328169494-10249-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Sha Zhengju <handai.szj@taobao.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

From: Sha Zhengju <handai.szj@taobao.com>

Index current_threshold may point to threshold that just equal to
usage after __mem_cgroup_threshold is triggerd. But after registering
a new event, it will change (pointing to threshold just below usage). 
So make it consistent here.

Cc: Kirill A. Shutemov <kirill@shutemov.name>
Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 22d94f5..ba46a01 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -183,7 +183,7 @@ struct mem_cgroup_threshold {
 
 /* For threshold */
 struct mem_cgroup_threshold_ary {
-	/* An array index points to threshold just below usage. */
+	/* An array index points to threshold just below or equal to usage. */
 	int current_threshold;
 	/* Size of entries[] */
 	unsigned int size;
@@ -4319,7 +4319,7 @@ static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
 	/* Find current threshold */
 	new->current_threshold = -1;
 	for (i = 0; i < size; i++) {
-		if (new->entries[i].threshold < usage) {
+		if (new->entries[i].threshold <= usage) {
 			/*
 			 * new->current_threshold will not be used until
 			 * rcu_assign_pointer(), so it's safe to increment
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
