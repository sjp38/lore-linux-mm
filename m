Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 256946B0032
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 07:53:04 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so1980508pbc.8
        for <linux-mm@kvack.org>; Thu, 01 Aug 2013 04:53:03 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V5 3/8] memcg: check for proper lock held in mem_cgroup_update_page_stat
Date: Thu,  1 Aug 2013 19:52:26 +0800
Message-Id: <1375357946-10228-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@gmail.com, gthelen@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

We should call mem_cgroup_begin_update_page_stat() before
mem_cgroup_update_page_stat() to get proper locks, however the
latter doesn't do any checking that we use proper locking, which
would be hard. Suggested by Michal Hock we could at least test for
rcu_read_lock_held() because RCU is held if !mem_cgroup_disabled().

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7691cef..4a55d46 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2301,6 +2301,7 @@ void mem_cgroup_update_page_stat(struct page *page,
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
