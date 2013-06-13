Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id CD89F90000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:04 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 01/22] x86: Change get_ramdisk_{image|size}() to global
Date: Thu, 13 Jun 2013 21:02:48 +0800
Message-Id: <1371128589-8953-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Yinghai Lu <yinghai@kernel.org>

This patch does two things:
1. Change get_ramdisk_image() and get_ramdisk_size() to global.
2. Make get_ramdisk_image() and get_ramdisk_size() take a
   boot_params pointer parameter.

The whole patch-set tries to split ACPI initrd table override
procedure into two steps: finding and copying.
The finding step is done at head_32.S and head64.c stage. So we
need to call get_ramdisk_image() and get_ramdisk_size() in these
two files.

And also, in head_32.S, it can only access boot_params via physical
address during 32bit flat mode, so make get_ramdisk_image() and
get_ramdisk_size() take a boot_params pointer, so that we can pass
a physical address to code in head_32.S.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Acked-by: Tejun Heo <tj@kernel.org>
Tested-by: Thomas Renninger <trenn@suse.de>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/setup.h |    3 +++
 arch/x86/kernel/setup.c      |   28 ++++++++++++++--------------
 2 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
index b7bf350..4f71d48 100644
--- a/arch/x86/include/asm/setup.h
+++ b/arch/x86/include/asm/setup.h
@@ -106,6 +106,9 @@ void *extend_brk(size_t size, size_t align);
 	RESERVE_BRK(name, sizeof(type) * entries)
 
 extern void probe_roms(void);
+u64 get_ramdisk_image(struct boot_params *bp);
+u64 get_ramdisk_size(struct boot_params *bp);
+
 #ifdef __i386__
 
 void __init i386_start_kernel(void);
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 56f7fcf..66ab495 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -297,19 +297,19 @@ static void __init reserve_brk(void)
 
 #ifdef CONFIG_BLK_DEV_INITRD
 
-static u64 __init get_ramdisk_image(void)
+u64 __init get_ramdisk_image(struct boot_params *bp)
 {
-	u64 ramdisk_image = boot_params.hdr.ramdisk_image;
+	u64 ramdisk_image = bp->hdr.ramdisk_image;
 
-	ramdisk_image |= (u64)boot_params.ext_ramdisk_image << 32;
+	ramdisk_image |= (u64)bp->ext_ramdisk_image << 32;
 
 	return ramdisk_image;
 }
-static u64 __init get_ramdisk_size(void)
+u64 __init get_ramdisk_size(struct boot_params *bp)
 {
-	u64 ramdisk_size = boot_params.hdr.ramdisk_size;
+	u64 ramdisk_size = bp->hdr.ramdisk_size;
 
-	ramdisk_size |= (u64)boot_params.ext_ramdisk_size << 32;
+	ramdisk_size |= (u64)bp->ext_ramdisk_size << 32;
 
 	return ramdisk_size;
 }
@@ -318,8 +318,8 @@ static u64 __init get_ramdisk_size(void)
 static void __init relocate_initrd(void)
 {
 	/* Assume only end is not page aligned */
-	u64 ramdisk_image = get_ramdisk_image();
-	u64 ramdisk_size  = get_ramdisk_size();
+	u64 ramdisk_image = get_ramdisk_image(&boot_params);
+	u64 ramdisk_size  = get_ramdisk_size(&boot_params);
 	u64 area_size     = PAGE_ALIGN(ramdisk_size);
 	u64 ramdisk_here;
 	unsigned long slop, clen, mapaddr;
@@ -358,8 +358,8 @@ static void __init relocate_initrd(void)
 		ramdisk_size  -= clen;
 	}
 
-	ramdisk_image = get_ramdisk_image();
-	ramdisk_size  = get_ramdisk_size();
+	ramdisk_image = get_ramdisk_image(&boot_params);
+	ramdisk_size  = get_ramdisk_size(&boot_params);
 	printk(KERN_INFO "Move RAMDISK from [mem %#010llx-%#010llx] to"
 		" [mem %#010llx-%#010llx]\n",
 		ramdisk_image, ramdisk_image + ramdisk_size - 1,
@@ -369,8 +369,8 @@ static void __init relocate_initrd(void)
 static void __init early_reserve_initrd(void)
 {
 	/* Assume only end is not page aligned */
-	u64 ramdisk_image = get_ramdisk_image();
-	u64 ramdisk_size  = get_ramdisk_size();
+	u64 ramdisk_image = get_ramdisk_image(&boot_params);
+	u64 ramdisk_size  = get_ramdisk_size(&boot_params);
 	u64 ramdisk_end   = PAGE_ALIGN(ramdisk_image + ramdisk_size);
 
 	if (!boot_params.hdr.type_of_loader ||
@@ -382,8 +382,8 @@ static void __init early_reserve_initrd(void)
 static void __init reserve_initrd(void)
 {
 	/* Assume only end is not page aligned */
-	u64 ramdisk_image = get_ramdisk_image();
-	u64 ramdisk_size  = get_ramdisk_size();
+	u64 ramdisk_image = get_ramdisk_image(&boot_params);
+	u64 ramdisk_size  = get_ramdisk_size(&boot_params);
 	u64 ramdisk_end   = PAGE_ALIGN(ramdisk_image + ramdisk_size);
 	u64 mapped_size;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
