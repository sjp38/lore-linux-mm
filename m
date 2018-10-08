Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 466BD6B0007
	for <linux-mm@kvack.org>; Sun,  7 Oct 2018 21:19:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g72-v6so6613834pfk.9
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 18:19:37 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id a34-v6si16520597pld.149.2018.10.07.18.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Oct 2018 18:19:35 -0700 (PDT)
Received: from epcas1p4.samsung.com (unknown [182.195.41.48])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20181008011932epoutp0394f28051f640924f2e349ad3fea607a8~bfWWQexAl0494904949epoutp03f
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 01:19:32 +0000 (GMT)
Mime-Version: 1.0
Subject: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
Reply-To: ytk.lee@samsung.com
From: Yong-Taek Lee <ytk.lee@samsung.com>
Message-ID: <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
Date: Mon, 08 Oct 2018 10:19:31 +0900
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mhocko@kernel.org" <mhocko@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>
Cc: Yong-Taek Lee <ytk.lee@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

It is introduced by commit 44a70adec910 ("mm, oom_adj: make sure
processes sharing mm have same view of oom_score_adj"). Most of
user process's mm_users is bigger than 1 but only one thread group.
In this case, for_each_process loop meaninglessly try to find processes
which sharing same mm even though there is only one thread group.

My idea is that target task's nr thread is smaller than mm_users if there
are more thread groups sharing the same mm. So we can skip loop
if mm_user and nr_thread are same. 

test result
while true; do count=0; time while [ $count -lt 10000 ]; do echo -1000 > /proc/1457/oom_score_adj; count=$((count+1)); done; done;

before patch
0m00.59s real     0m00.09s user     0m00.51s system
0m00.59s real     0m00.14s user     0m00.45s system
0m00.58s real     0m00.11s user     0m00.47s system
0m00.58s real     0m00.10s user     0m00.48s system
0m00.59s real     0m00.11s user     0m00.48s system

after patch
0m00.15s real     0m00.07s user     0m00.08s system
0m00.14s real     0m00.10s user     0m00.04s system
0m00.14s real     0m00.10s user     0m00.05s system
0m00.14s real     0m00.08s user     0m00.07s system
0m00.14s real     0m00.08s user     0m00.07s system

Signed-off-by: Lee YongTaek <ytk.lee@samsung.com>
---
 fs/proc/base.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index f9f72aee6d45..54b2fb5e9c51 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1056,6 +1056,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
        struct mm_struct *mm = NULL;
        struct task_struct *task;
        int err = 0;
+       int mm_users = 0;

        task = get_proc_task(file_inode(file));
        if (!task)
@@ -1092,7 +1093,8 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
                struct task_struct *p = find_lock_task_mm(task);

                if (p) {
-                       if (atomic_read(&p->mm->mm_users) > 1) {
+                       mm_users = atomic_read(&p->mm->mm_users);
+                       if ((mm_users > 1) && (mm_users != get_nr_threads(p))) {
                                mm = p->mm;
                                atomic_inc(&mm->mm_count);
                        }
--
