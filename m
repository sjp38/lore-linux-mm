Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B6EC06B0037
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 16:21:13 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so3108977pdj.2
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:21:13 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so3302277pab.29
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:21:11 -0700 (PDT)
Message-ID: <52570C16.5030803@gmail.com>
Date: Fri, 11 Oct 2013 04:20:38 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH part1 v7 5/6] x86, acpi, crash, kdump: Do reserve_crashkernel()
 after SRAT is parsed.
References: <52570A6E.2010806@gmail.com>
In-Reply-To: <52570A6E.2010806@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, mina86@mina86.com, Minchan Kim <minchan@kernel.org>, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com
Cc: "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

Memory reserved for crashkernel could be large. So we should not allocate
this memory bottom up from the end of kernel image.

When SRAT is parsed, we will be able to know whihc memory is hotpluggable,
and we can avoid allocating this memory for the kernel. So reorder
reserve_crashkernel() after SRAT is parsed.

Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/x86/kernel/setup.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index f0de629..b5e350d 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1120,8 +1120,6 @@ void __init setup_arch(char **cmdline_p)
 	acpi_initrd_override((void *)initrd_start, initrd_end - initrd_start);
 #endif
 
-	reserve_crashkernel();
-
 	vsmp_init();
 
 	io_delay_init();
@@ -1134,6 +1132,13 @@ void __init setup_arch(char **cmdline_p)
 	early_acpi_boot_init();
 
 	initmem_init();
+
+	/*
+	 * Reserve memory for crash kernel after SRAT is parsed so that it
+	 * won't consume hotpluggable memory.
+	 */
+	reserve_crashkernel();
+
 	memblock_find_dma_reserve();
 
 #ifdef CONFIG_KVM_GUEST
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
