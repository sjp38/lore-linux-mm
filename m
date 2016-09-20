Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCA66B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:52:55 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p53so14277147qtp.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 22:52:55 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id u124si2296372vkg.88.2016.09.19.22.52.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 22:52:54 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH v2] mm,ksm: fix endless looping in allocating memory when ksm enable
Date: Tue, 20 Sep 2016 13:50:13 +0800
Message-ID: <1474350613-25041-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

I hit the following issue when run a OOM case of the LTP and
ksm enable.

Call trace:
[<ffffffc000086a88>] __switch_to+0x74/0x8c
[<ffffffc000a1bae0>] __schedule+0x23c/0x7bc
[<ffffffc000a1c09c>] schedule+0x3c/0x94
[<ffffffc000a1eb84>] rwsem_down_write_failed+0x214/0x350
[<ffffffc000a1e32c>] down_write+0x64/0x80
[<ffffffc00021f794>] __ksm_exit+0x90/0x19c
[<ffffffc0000be650>] mmput+0x118/0x11c
[<ffffffc0000c3ec4>] do_exit+0x2dc/0xa74
[<ffffffc0000c46f8>] do_group_exit+0x4c/0xe4
[<ffffffc0000d0f34>] get_signal+0x444/0x5e0
[<ffffffc000089fcc>] do_signal+0x1d8/0x450
[<ffffffc00008a35c>] do_notify_resume+0x70/0x78

it will leads to a hung task because the exiting task cannot get the
mmap sem for write. but the root cause is that the ksmd holds it for
read while allocateing memory which just takes ages to complete.
and ksmd will loop in the following path.

 scan_get_next_rmap_item
          down_read
                get_next_rmap_item
                        alloc_rmap_item   #ksmd will loop permanently.

The caller alloc_rmap_item with GFP_KERENL will trigger OOM killer when free
memory is under pressure. and it can will successfully bail out without calling
out_of_memory. because it find the OOM invoked by other process is in progress
in the same zone. therefore, memory allocation will loop again and again.

we fix it by changing the GFP to add __GFP_NORETRY. if it is so, alloc_rmap_item
allow to sometimes memory allocation fails, if it fails , ksmd will jsut give up
and takes a sleep. even though memory is low, OOM killer would not be triggered.
at the same time, GFP_NOWARN shuld be also added. because we're not at all
interested in hearing abot that.

CC: <stable@vger.kernel.org>
Suggested-by: Hugh Dickins <hughd@google.com>
Suggested-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/ksm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 73d43ba..5048083 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -283,7 +283,8 @@ static inline struct rmap_item *alloc_rmap_item(void)
 {
 	struct rmap_item *rmap_item;
 
-	rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
+	rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL |
+						__GFP_NORETRY | __GFP_NOWARN);
 	if (rmap_item)
 		ksm_rmap_items++;
 	return rmap_item;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
