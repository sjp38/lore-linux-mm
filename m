Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3288E6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 01:16:43 -0400 (EDT)
Received: by mail-bk0-f65.google.com with SMTP id r7so424647bkg.4
        for <linux-mm@kvack.org>; Thu, 08 Aug 2013 22:16:41 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 9 Aug 2013 13:16:41 +0800
Message-ID: <CAMyfujfZayb8_673vkb2hdE9J_w+wPTD4aQ6TsY+aWxb9EzY8A@mail.gmail.com>
Subject: [PATCH 1/1] pagemap: fix buffer overflow in add_page_map()
From: yonghua zheng <younghua.zheng@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Motohiro KOSAKI <kosaki.motohiro@gmail.com>

Hi,

Recently we met quite a lot of random kernel panic issues after enable
CONFIG_PROC_PAGE_MONITOR in kernel, after debuggint sometime we found
this has something to do with following bug in pagemap:

In struc pagemapread:

struct pagemapread {
    int pos, len;
    pagemap_entry_t *buffer;
    bool v2;
};

pos is number of PM_ENTRY_BYTES in buffer, but len is the size of buffer,
it is a mistake to compare pos and len in add_page_map() for checking
buffer is full or not, and this can lead to buffer overflow and random
kernel panic issue.

Correct len to be total number of PM_ENTRY_BYTES in buffer.

Signed-off-by: Yonghua Zheng <younghua.zheng@gmail.com>
---
 fs/proc/task_mmu.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dbf61f6..cb98853 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1116,8 +1116,8 @@ static ssize_t pagemap_read(struct file *file,
char __user *buf,
         goto out_task;

     pm.v2 = soft_dirty_cleared;
-    pm.len = PM_ENTRY_BYTES * (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
-    pm.buffer = kmalloc(pm.len, GFP_TEMPORARY);
+    pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
+    pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
     ret = -ENOMEM;
     if (!pm.buffer)
         goto out_task;

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
