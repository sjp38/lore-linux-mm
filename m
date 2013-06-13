Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 7913590000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:07 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 02/22] x86, microcode: Use common get_ramdisk_{image|size}()
Date: Thu, 13 Jun 2013 21:02:49 +0800
Message-Id: <1371128589-8953-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Fenghua Yu <fenghua.yu@intel.com>

From: Yinghai Lu <yinghai@kernel.org>

In patch1, we change get_ramdisk_image() and get_ramdisk_size()
to global, so we can use them instead of using global variable
boot_params.

We need this to get correct ramdisk adress for 64bits bzImage
that initrd can be loaded above 4G by kexec-tools.

-v2: fix one typo that is found by Tang Chen

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Acked-by: Tejun Heo <tj@kernel.org>
Tested-by: Thomas Renninger <trenn@suse.de>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/kernel/microcode_intel_early.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/microcode_intel_early.c b/arch/x86/kernel/microcode_intel_early.c
index 2e9e128..54575a9 100644
--- a/arch/x86/kernel/microcode_intel_early.c
+++ b/arch/x86/kernel/microcode_intel_early.c
@@ -743,8 +743,8 @@ load_ucode_intel_bsp(void)
 	struct boot_params *boot_params_p;
 
 	boot_params_p = (struct boot_params *)__pa_nodebug(&boot_params);
-	ramdisk_image = boot_params_p->hdr.ramdisk_image;
-	ramdisk_size  = boot_params_p->hdr.ramdisk_size;
+	ramdisk_image = get_ramdisk_image(boot_params_p);
+	ramdisk_size  = get_ramdisk_size(boot_params_p);
 	initrd_start_early = ramdisk_image;
 	initrd_end_early = initrd_start_early + ramdisk_size;
 
@@ -753,8 +753,8 @@ load_ucode_intel_bsp(void)
 		(unsigned long *)__pa_nodebug(&mc_saved_in_initrd),
 		initrd_start_early, initrd_end_early, &uci);
 #else
-	ramdisk_image = boot_params.hdr.ramdisk_image;
-	ramdisk_size  = boot_params.hdr.ramdisk_size;
+	ramdisk_image = get_ramdisk_image(&boot_params);
+	ramdisk_size  = get_ramdisk_size(&boot_params);
 	initrd_start_early = ramdisk_image + PAGE_OFFSET;
 	initrd_end_early = initrd_start_early + ramdisk_size;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
