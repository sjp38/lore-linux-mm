Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 671FF6B0007
	for <linux-mm@kvack.org>; Wed, 30 May 2018 01:20:46 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t17-v6so9312607ply.13
        for <linux-mm@kvack.org>; Tue, 29 May 2018 22:20:46 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id k6-v6si26627010pgq.85.2018.05.29.22.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 22:20:45 -0700 (PDT)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] drivers: of: of_reserved_mem: detect count overflow or
 range overlap
Date: Wed, 30 May 2018 14:21:42 +0900
Message-id: <20180530052142.24761-1-jaewon31.kim@samsung.com>
References: <CGME20180530052041epcas2p395f2fbf4506d911c127cc4243838fedb@epcas2p3.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robh+dt@kernel.org, m.szyprowski@samsung.com, mitchelh@codeaurora.org
Cc: frowand.list@gmail.com, devicetree@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

During development, number of reserved memory region could be increased
and a new region could be unwantedly overlapped. In that case the new
region may work well but one of exisiting region could be affected so
that it would not be defined properly. It may require time consuming
work to find reason that there is a newly added region.

If a newly added region invoke kernel panic, it will be helpful. This
patch records if there is count overflow or range overlap, and invoke
panic if that case.

These are test example based on v4.9.

Case 1 - out of region count
<3>[    0.000000]  [0:        swapper:    0] OF: reserved mem: not enough space all defined regions.
<0>[    1.688695]  [6:      swapper/0:    1] Kernel panic - not syncing: overflow on reserved memory, check the latest change
<4>[    1.688743]  [6:      swapper/0:    1] CPU: 6 PID: 1 Comm: swapper/0 Not tainted 4.9.65+ #10
<4>[    1.688836]  [6:      swapper/0:    1] Call trace:
<4>[    1.688869]  [6:      swapper/0:    1] [<ffffff8008095748>] dump_backtrace+0x0/0x248
<4>[    1.688913]  [6:      swapper/0:    1] [<ffffff8008095b48>] show_stack+0x18/0x28
<4>[    1.688958]  [6:      swapper/0:    1] [<ffffff8008446e84>] dump_stack+0x98/0xc0
<4>[    1.689001]  [6:      swapper/0:    1] [<ffffff80081cf784>] panic+0x1e0/0x404
<4>[    1.689046]  [6:      swapper/0:    1] [<ffffff8008ddcdb8>] check_reserved_mem+0x40/0x50
<4>[    1.689091]  [6:      swapper/0:    1] [<ffffff8008090190>] do_one_initcall+0x54/0x214
<4>[    1.689138]  [6:      swapper/0:    1] [<ffffff8009eacf98>] kernel_init_freeable+0x198/0x24c
<4>[    1.689187]  [6:      swapper/0:    1] [<ffffff8009396950>] kernel_init+0x18/0x144
<4>[    1.689229]  [6:      swapper/0:    1] [<ffffff800808fa50>] ret_from_fork+0x10/0x40

Case 2 - overlapped region
<3>[    0.000000]  [0:        swapper:    0] OF: reserved mem: OVERLAP DETECTED!
<0>[    2.309331]  [2:      swapper/0:    1] Kernel panic - not syncing: reserved memory overlap, check the latest change
<4>[    2.309398]  [2:      swapper/0:    1] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.9.65+ #14
<4>[    2.309508]  [2:      swapper/0:    1] Call trace:
<4>[    2.309546]  [2:      swapper/0:    1] [<ffffff8008121748>] dump_backtrace+0x0/0x248
<4>[    2.309599]  [2:      swapper/0:    1] [<ffffff8008121b48>] show_stack+0x18/0x28
<4>[    2.309652]  [2:      swapper/0:    1] [<ffffff80084d2e84>] dump_stack+0x98/0xc0
<4>[    2.309701]  [2:      swapper/0:    1] [<ffffff800825b784>] panic+0x1e0/0x404
<4>[    2.309751]  [2:      swapper/0:    1] [<ffffff8008e68dc4>] check_reserved_mem+0x4c/0x50
<4>[    2.309802]  [2:      swapper/0:    1] [<ffffff800811c190>] do_one_initcall+0x54/0x214
<4>[    2.309856]  [2:      swapper/0:    1] [<ffffff8009f38f98>] kernel_init_freeable+0x198/0x24c
<4>[    2.309913]  [2:      swapper/0:    1] [<ffffff8009422950>] kernel_init+0x18/0x144
<4>[    2.309961]  [2:      swapper/0:    1] [<ffffff800811ba50>] ret_from_fork+0x10/0x40

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 drivers/of/of_reserved_mem.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/of/of_reserved_mem.c b/drivers/of/of_reserved_mem.c
index 9a4f4246231d..e97d5c5dcc9a 100644
--- a/drivers/of/of_reserved_mem.c
+++ b/drivers/of/of_reserved_mem.c
@@ -65,6 +65,7 @@ int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
 }
 #endif
 
+static bool rmem_overflow;
 /**
  * res_mem_save_node() - save fdt node for second pass initialization
  */
@@ -75,6 +76,7 @@ void __init fdt_reserved_mem_save_node(unsigned long node, const char *uname,
 
 	if (reserved_mem_count == ARRAY_SIZE(reserved_mem)) {
 		pr_err("not enough space all defined regions.\n");
+		rmem_overflow = true;
 		return;
 	}
 
@@ -221,6 +223,7 @@ static int __init __rmem_cmp(const void *a, const void *b)
 	return 0;
 }
 
+static bool rmem_overlap;
 static void __init __rmem_check_for_overlap(void)
 {
 	int i;
@@ -245,6 +248,7 @@ static void __init __rmem_check_for_overlap(void)
 			pr_err("OVERLAP DETECTED!\n%s (%pa--%pa) overlaps with %s (%pa--%pa)\n",
 			       this->name, &this->base, &this_end,
 			       next->name, &next->base, &next_end);
+			rmem_overlap = true;
 		}
 	}
 }
@@ -419,3 +423,13 @@ struct reserved_mem *of_reserved_mem_lookup(struct device_node *np)
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(of_reserved_mem_lookup);
+
+static int check_reserved_mem(void)
+{
+	if (rmem_overflow)
+		panic("overflow on reserved memory, check the latest change");
+	if (rmem_overlap)
+		panic("overlap on reserved memory, check the latest change");
+	return 0;
+}
+late_initcall(check_reserved_mem);
-- 
2.13.0
