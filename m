Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 471F36B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 06:05:26 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c202so24501488oih.8
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 03:05:26 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id z206si699307oiz.285.2017.10.25.03.05.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 03:05:25 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH 2/2] scsi: megaraid: Track the page allocations for struct fusion_context
Date: Wed, 25 Oct 2017 17:57:08 +0800
Message-ID: <1508925428-51660-2-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1508925428-51660-1-git-send-email-xieyisheng1@huawei.com>
References: <1508925428-51660-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kashyap.desai@broadcom.com, sumit.saxena@broadcom.com, shivasharan.srikanteshwara@broadcom.com, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com
Cc: megaraidlinux.pdl@broadcom.com, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, Yisheng Xie <xieyisheng1@huawei.com>, linux-mm@kvack.org, Shu Wang <shuwang@redhat.com>

I have get many kmemleak reports just similar to commit 70c54e210ee9
(scsi: megaraid_sas: fix memleak in megasas_alloc_cmdlist_fusion)
on v4.14-rc6, however it seems have a different stroy:

unreferenced object 0xffff8b5139d9d2c0 (size 192):
  comm "kworker/0:0", pid 3, jiffies 4294689182 (age 11347.731s)
  hex dump (first 32 bytes):
    00 33 84 7b 41 8b ff ff 00 33 84 7b 00 00 00 00  .3.{A....3.{....
    00 30 8c 7b 41 8b ff ff 00 30 8c 7b 00 00 00 00  .0.{A....0.{....
  backtrace:
    [<ffffffff927461ea>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff92215eee>] kmem_cache_alloc_trace+0xce/0x1d0
    [<ffffffffc03f96e4>] megasas_alloc_cmdlist_fusion+0xd4/0x180 [megaraid_sas]
    [<ffffffffc03f9df5>] megasas_alloc_cmds_fusion+0x25/0x410 [megaraid_sas]
    [<ffffffffc03fb05d>] megasas_init_adapter_fusion+0x21d/0x6e0 [megaraid_sas]
    [<ffffffffc03f70e8>] megasas_init_fw+0x338/0xd00 [megaraid_sas]
    [<ffffffffc03f806e>] megasas_probe_one.part.34+0x5be/0x1040 [megaraid_sas]
    [<ffffffffc03f8b36>] megasas_probe_one+0x46/0xc0 [megaraid_sas]
    [<ffffffff923c0ec5>] local_pci_probe+0x45/0xa0
    [<ffffffff9209fcf4>] work_for_cpu_fn+0x14/0x20
    [<ffffffff920a2e09>] process_one_work+0x149/0x360
    [<ffffffff920a3578>] worker_thread+0x1d8/0x3c0
    [<ffffffff920a8bb9>] kthread+0x109/0x140
    [<ffffffff92751bc5>] ret_from_fork+0x25/0x30
    [<ffffffffffffffff>] 0xffffffffffffffff

Struct fusion_context may alloc by get_free_pages, which contain
pointers to other slab allocations(via megasas_alloc_cmdlist_fusion).
Since kmemleak does not track/scan page allocations, the slab objects
will be reported as leaks(false positives). This patch adds kmemleak
callbacks to allow tracking of such pages.

Cc: linux-mm@kvack.org
Cc: Shu Wang <shuwang@redhat.com>
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 drivers/scsi/megaraid/megaraid_sas_fusion.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/scsi/megaraid/megaraid_sas_fusion.c b/drivers/scsi/megaraid/megaraid_sas_fusion.c
index 11bd2e6..9a1be45 100644
--- a/drivers/scsi/megaraid/megaraid_sas_fusion.c
+++ b/drivers/scsi/megaraid/megaraid_sas_fusion.c
@@ -48,6 +48,7 @@
 #include <linux/mutex.h>
 #include <linux/poll.h>
 #include <linux/vmalloc.h>
+#include <linux/kmemleak.h>
 
 #include <scsi/scsi.h>
 #include <scsi/scsi_cmnd.h>
@@ -4512,6 +4513,14 @@ void megasas_fusion_ocr_wq(struct work_struct *work)
 			dev_err(&instance->pdev->dev, "Failed from %s %d\n", __func__, __LINE__);
 			return -ENOMEM;
 		}
+	} else {
+		/*
+		 * Allow kmemleak to scan these pages as they contain pointers
+		 * to additional allocations via megasas_alloc_cmdlist_fusion.
+		 */
+		size_t size = (size_t)PAGE_SIZE << instance->ctrl_context_pages;
+
+		kmemleak_alloc(instance->ctrl_context, size, 1, GFP_KERNEL);
 	}
 
 	fusion = instance->ctrl_context;
@@ -4548,9 +4557,15 @@ void megasas_fusion_ocr_wq(struct work_struct *work)
 
 		if (is_vmalloc_addr(fusion))
 			vfree(fusion);
-		else
+		else {
+			/*
+			 * Remove kmemleak object previously allocated in
+			 * megasas_alloc_fusion_context.
+			 */
+			kmemleak_free(fusion);
 			free_pages((ulong)fusion,
 				instance->ctrl_context_pages);
+		}
 	}
 }
 
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
