Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id F17018E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 15:06:06 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id j3so33942199itf.5
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 12:06:06 -0800 (PST)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id x17si76662itj.18.2019.01.02.12.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 12:06:05 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 2/3] mm: memcontrol: do not try to do swap when force empty
Date: Thu,  3 Jan 2019 04:05:32 +0800
Message-Id: <1546459533-36247-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The typical usecase of force empty is to try to reclaim as much as
possible memory before offlining a memcg.  Since there should be no
attached tasks to offlining memcg, the tasks anonymous pages would have
already been freed or uncharged.  Even though anonymous pages get
swapped out, but they still get charged to swap space.  So, it sounds
pointless to do swap for force empty.

I tried to dig into the history of this, it was introduced by
commit 8c7c6e34a125 ("memcg: mem+swap controller core"), but there is
not any clue about why it was done so at the first place.

The below simple test script shows slight file cache reclaim improvement
when swap is on.

echo 3 > /proc/sys/vm/drop_caches
mkdir /sys/fs/cgroup/memory/test
echo 30 > /sys/fs/cgroup/memory/test/memory.swappiness
echo $$ >/sys/fs/cgroup/memory/test/cgroup.procs
cat /proc/meminfo | grep ^Cached|awk -F" " '{print $2}'
dd if=/dev/zero of=/mnt/test bs=1M count=1024
ping localhost > /dev/null &
echo 1 > /sys/fs/cgroup/memory/test/memory.force_empty
killall ping
echo $$ >/sys/fs/cgroup/memory/cgroup.procs
cat /proc/meminfo | grep ^Cached|awk -F" " '{print $2}'
rmdir /sys/fs/cgroup/memory/test
cat /proc/meminfo | grep ^Cached|awk -F" " '{print $2}'

The number of page cache is:
			w/o		w/
before force empty    1088792        1088784
after force empty     41492          39428
reclaimed	      1047300        1049356

Without doing swap, force empty can reclaim 2MB more memory in 1GB page
cache.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6e1469b..bbf39b5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2872,7 +2872,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 			return -EINTR;
 
 		progress = try_to_free_mem_cgroup_pages(memcg, 1,
-							GFP_KERNEL, true);
+							GFP_KERNEL, false);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
-- 
1.8.3.1
