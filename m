Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id E0E7C6B0039
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 06:03:32 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [RESEND PATCH v2 4/9] x86: Support allocate memory from bottom upwards in setup_log_buf().
Date: Thu, 12 Sep 2013 17:52:12 +0800
Message-Id: <1378979537-21196-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1378979537-21196-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1378979537-21196-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, toshi.kani@hp.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

During early boot, if the bottom up mode is set, just
try allocating bottom up from the end of kernel image,
and if that fails, do normal top down allocation.

So in function setup_log_buf(), we add the above logic.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 kernel/printk/printk.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index b4e8500..2958118 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -759,9 +759,20 @@ void __init setup_log_buf(int early)
 	if (early) {
 		unsigned long mem;
 
+		if (memblock_direction_bottom_up()) {
+			mem = memblock_alloc_bottom_up(
+						MEMBLOCK_ALLOC_ACCESSIBLE,
+						MEMBLOCK_ALLOC_ACCESSIBLE,
+						new_log_buf_len, PAGE_SIZE);
+			if (mem)
+				goto success;
+		}
+
 		mem = memblock_alloc(new_log_buf_len, PAGE_SIZE);
 		if (!mem)
 			return;
+
+success:
 		new_log_buf = __va(mem);
 	} else {
 		new_log_buf = alloc_bootmem_nopanic(new_log_buf_len);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
