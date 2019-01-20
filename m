Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5C4F8E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 22:30:51 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id p4so11586697pgj.21
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 19:30:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d27sor14338055pgm.9.2019.01.19.19.30.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 19:30:50 -0800 (PST)
From: Xiongchun Duan <duanxiongchun@bytedance.com>
Subject: [PATCH 0/5] fix offline memcgroup still hold in memory
Date: Sat, 19 Jan 2019 22:30:16 -0500
Message-Id: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: shy828301@gmail.com, mhocko@kernel.org, tj@kernel.org, hannes@cmpxchg.org, zhangyongsu@bytedance.com, liuxiaozhou@bytedance.com, zhengfeiran@bytedance.com, wangdongdong.6@bytedance.com, Xiongchun Duan <duanxiongchun@bytedance.com>

we find that in huge memory system frequent creat creation and deletion
memcgroup make the system leave lots of offline memcgroup.we had seen 100000 
unrelease offline memcgroup in our system(512G memory).

this memcgroup hold because some memory page still charged.
so we try to Multiple interval call force_empty to reclaim this memory page.

after applying those patchs,in our system,the unrelease offline memcgroup
was reduced from 100000 to 100.


Xiongchun Duan (5):
  Memcgroup: force empty after memcgroup offline
  Memcgroup: Add timer to trigger workqueue
  Memcgroup:add a global work
  Memcgroup:Implement force empty work function
  Memcgroup:add cgroup fs to show offline memcgroup status

 Documentation/cgroup-v1/memory.txt |   7 +-
 Documentation/sysctl/kernel.txt    |  10 ++
 include/linux/memcontrol.h         |  11 ++
 kernel/sysctl.c                    |   9 ++
 mm/memcontrol.c                    | 271 +++++++++++++++++++++++++++++++++++++
 5 files changed, 306 insertions(+), 2 deletions(-)

-- 
1.8.3.1
