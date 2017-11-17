Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 481136B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 02:15:29 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 9so458271ion.22
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 23:15:29 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id t65si557122iod.304.2017.11.16.23.15.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 23:15:28 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH] kmemcheck: add scheduling point to kmemleak_scan
Date: Fri, 17 Nov 2017 15:03:56 +0800
Message-ID: <1510902236-4444-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

kmemleak_scan will scan struct page for each node and it can be really
large and resulting in a soft lockup. We have seen a soft lockup when do
scan while compile kernel:

 [  220.561051] watchdog: BUG: soft lockup - CPU#53 stuck for 22s! [bash:10287]
 [...]
 [  220.753837] Call Trace:
 [  220.756296]  kmemleak_scan+0x21a/0x4c0
 [  220.760034]  kmemleak_write+0x312/0x350
 [  220.763866]  ? do_wp_page+0x147/0x4c0
 [  220.767521]  full_proxy_write+0x5a/0xa0
 [  220.771351]  __vfs_write+0x33/0x150
 [  220.774833]  ? __inode_security_revalidate+0x4c/0x60
 [  220.779782]  ? selinux_file_permission+0xda/0x130
 [  220.784479]  ? _cond_resched+0x15/0x30
 [  220.788221]  vfs_write+0xad/0x1a0
 [  220.791529]  SyS_write+0x52/0xc0
 [  220.794758]  do_syscall_64+0x61/0x1a0
 [  220.798411]  entry_SYSCALL64_slow_path+0x25/0x25

Fix this by adding cond_resched every 1024 pages.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/kmemleak.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index e4738d5..e9f2e86 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1523,6 +1523,8 @@ static void kmemleak_scan(void)
 			if (page_count(page) == 0)
 				continue;
 			scan_block(page, page + 1, NULL);
+			if (!(pfn % 1024))
+				cond_resched();
 		}
 	}
 	put_online_mems();
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
