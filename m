Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id D8C856B00C1
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 07:13:41 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 03/25] acpi: Remove "continue" in macro INVALID_TABLE().
Date: Wed, 7 Aug 2013 18:51:54 +0800
Message-Id: <1375872736-4822-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

The macro INVALID_TABLE() is defined like this:

 #define INVALID_TABLE(x, path, name)                                    \
         { pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); continue; }

And it is used like this:

	for (...) {
		...
		if (...)
			INVALID_TABLE()
		...
	}

The "continue" in the macro makes the code hard to understand.
Change it to the style like other macros:

 #define INVALID_TABLE(x, path, name)                                    \
         do { pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); } while (0)

And also, INVALID_TABLE() is used to checkout acpi tables, so rename it to
ACPI_INVALID_TABLE(). This is suggested by Toshi Kani <toshi.kani@hp.com>.

So after this patch, this macro should be used like this:

	for (...) {
		...
		if (...) {
			ACPI_INVALID_TABLE()
			continue;
		}
		...
	}

Add the "continue" wherever the macro is called.
(For now, it is only called in acpi_initrd_override().)

The idea is from Yinghai Lu <yinghai@kernel.org>.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Acked-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 drivers/acpi/osl.c |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 6ab2c35..3b8bab2 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -564,8 +564,8 @@ static const char * const table_sigs[] = {
 	ACPI_SIG_RSDT, ACPI_SIG_XSDT, ACPI_SIG_SSDT, NULL };
 
 /* Non-fatal errors: Affected tables/files are ignored */
-#define INVALID_TABLE(x, path, name)					\
-	{ pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); continue; }
+#define ACPI_INVALID_TABLE(x, path, name)					\
+	do { pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); } while (0)
 
 #define ACPI_HEADER_SIZE sizeof(struct acpi_table_header)
 
@@ -593,9 +593,11 @@ void __init acpi_initrd_override(void *data, size_t size)
 		data += offset;
 		size -= offset;
 
-		if (file.size < sizeof(struct acpi_table_header))
-			INVALID_TABLE("Table smaller than ACPI header",
+		if (file.size < sizeof(struct acpi_table_header)) {
+			ACPI_INVALID_TABLE("Table smaller than ACPI header",
 				      cpio_path, file.name);
+			continue;
+		}
 
 		table = file.data;
 
@@ -603,15 +605,21 @@ void __init acpi_initrd_override(void *data, size_t size)
 			if (!memcmp(table->signature, table_sigs[sig], 4))
 				break;
 
-		if (!table_sigs[sig])
-			INVALID_TABLE("Unknown signature",
+		if (!table_sigs[sig]) {
+			ACPI_INVALID_TABLE("Unknown signature",
 				      cpio_path, file.name);
-		if (file.size != table->length)
-			INVALID_TABLE("File length does not match table length",
+			continue;
+		}
+		if (file.size != table->length) {
+			ACPI_INVALID_TABLE("File length does not match table length",
 				      cpio_path, file.name);
-		if (acpi_table_checksum(file.data, table->length))
-			INVALID_TABLE("Bad table checksum",
+			continue;
+		}
+		if (acpi_table_checksum(file.data, table->length)) {
+			ACPI_INVALID_TABLE("Bad table checksum",
 				      cpio_path, file.name);
+			continue;
+		}
 
 		pr_info("%4.4s ACPI table found in initrd [%s%s][0x%x]\n",
 			table->signature, cpio_path, file.name, table->length);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
