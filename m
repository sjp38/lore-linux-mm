Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 4AADF6B00BF
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 07:13:40 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 16/25] x86: Make get_ramdisk_{image|size}() global.
Date: Wed, 7 Aug 2013 18:52:07 +0800
Message-Id: <1375872736-4822-17-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

In the following patches, we need to call get_ramdisk_{image|size}()
to get initrd file's address and size. So make these two functions
global.

v1 -> v2:
As tj suggested, make these two function static inline in
arch/x86/include/asm/setup.h.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/x86/include/asm/setup.h |   21 +++++++++++++++++++++
 arch/x86/kernel/setup.c      |   18 ------------------
 2 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
index b7bf350..cfdb55d 100644
--- a/arch/x86/include/asm/setup.h
+++ b/arch/x86/include/asm/setup.h
@@ -106,6 +106,27 @@ void *extend_brk(size_t size, size_t align);
 	RESERVE_BRK(name, sizeof(type) * entries)
 
 extern void probe_roms(void);
+
+#ifdef CONFIG_BLK_DEV_INITRD
+static inline u64 __init get_ramdisk_image(void)
+{
+	u64 ramdisk_image = boot_params.hdr.ramdisk_image;
+
+	ramdisk_image |= (u64)boot_params.ext_ramdisk_image << 32;
+
+	return ramdisk_image;
+}
+
+static inline u64 __init get_ramdisk_size(void)
+{
+	u64 ramdisk_size = boot_params.hdr.ramdisk_size;
+
+	ramdisk_size |= (u64)boot_params.ext_ramdisk_size << 32;
+
+	return ramdisk_size;
+}
+#endif /* CONFIG_BLK_DEV_INITRD */
+
 #ifdef __i386__
 
 void __init i386_start_kernel(void);
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index fdb5a26..da44353 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -296,24 +296,6 @@ static void __init reserve_brk(void)
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
-
-static u64 __init get_ramdisk_image(void)
-{
-	u64 ramdisk_image = boot_params.hdr.ramdisk_image;
-
-	ramdisk_image |= (u64)boot_params.ext_ramdisk_image << 32;
-
-	return ramdisk_image;
-}
-static u64 __init get_ramdisk_size(void)
-{
-	u64 ramdisk_size = boot_params.hdr.ramdisk_size;
-
-	ramdisk_size |= (u64)boot_params.ext_ramdisk_size << 32;
-
-	return ramdisk_size;
-}
-
 #define MAX_MAP_CHUNK	(NR_FIX_BTMAPS << PAGE_SHIFT)
 static void __init relocate_initrd(void)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
