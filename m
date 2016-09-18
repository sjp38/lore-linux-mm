Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 601396B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 22:32:36 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id n185so153276208qke.2
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 19:32:36 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id l123si4257224ywc.88.2016.09.17.19.32.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Sep 2016 19:32:35 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm,ksm: fix endless looping in allocating memory when ksm enable
Date: Sun, 18 Sep 2016 10:26:10 +0800
Message-ID: <1474165570-44398-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, mhocko@suse.cz, akpm@linux-foundation.org, qiuxishi@huawei.com, guohanjun@huawei.com
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
and ksmd  will loop in the following path.

 scan_get_next_rmap_item
          down_read
                get_next_rmap_item
                        alloc_rmap_item   #ksmd will loop permanently.

we fix it by changing the GFP to allow the allocation sometimes fail, and
we're not at all interested in hearing abot that.

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
