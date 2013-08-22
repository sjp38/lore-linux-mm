Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 5DE646B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:52:42 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so1671136pdi.13
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 02:52:41 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 2/4] memcg: check for proper lock held in mem_cgroup_update_page_stat
Date: Thu, 22 Aug 2013 17:52:11 +0800
Message-Id: <1377165131-24052-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <CAFj3OHXy5XkwhxKk=WNywp2pq__FD7BrSQwFkp+NZj15_k6BEQ@mail.gmail.com>
References: <CAFj3OHXy5XkwhxKk=WNywp2pq__FD7BrSQwFkp+NZj15_k6BEQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

We should call mem_cgroup_begin_update_page_stat() before
mem_cgroup_update_page_stat() to get proper locks, however the
latter doesn't do any checking that we use proper locking, which
would be hard. Suggested by Michal Hock we could at least test for
rcu_read_lock_held() because RCU is held if !mem_cgroup_disabled().

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 24d6d02..0a50871 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2249,6 +2249,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 	if (mem_cgroup_disabled())
 		return;
 
+	VM_BUG_ON(!rcu_read_lock_held());
 	memcg = pc->mem_cgroup;
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
