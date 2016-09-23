Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 496F228024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 11:12:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w84so20570977wmg.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:12:41 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t129si3741466wme.25.2016.09.23.08.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 08:12:23 -0700 (PDT)
Date: Fri, 23 Sep 2016 17:08:04 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: acpi: Fix broken error check in map_processor()
Message-ID: <alpine.DEB.2.20.1609231705570.5640@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

map_processor() checks the cpuid value returned by acpi_map_cpuid() for -1
but acpi_map_cpuid() returns -EINVAL in case of error.

As a consequence the error is ignored and the following access into percpu
data with that negative cpuid results in a boot crash.

This happens always when NR_CPUS/nr_cpu_ids is smaller than the number of
processors listed in the ACPI tables.

Use a proper error check for id < 0 so the function returns instead of
trying to map CPU#(-EINVAL).

Reported-by: Ingo Molnar <mingo@kernel.org>
Fixes: dc6db24d2476 ("x86/acpi: Set persistent cpuid <-> nodeid mapping when booting")
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 drivers/acpi/processor_core.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -284,7 +284,7 @@ EXPORT_SYMBOL_GPL(acpi_get_cpuid);
 static bool __init
 map_processor(acpi_handle handle, phys_cpuid_t *phys_id, int *cpuid)
 {
-	int type;
+	int type, id;
 	u32 acpi_id;
 	acpi_status status;
 	acpi_object_type acpi_type;
@@ -320,10 +320,11 @@ map_processor(acpi_handle handle, phys_c
 	type = (acpi_type == ACPI_TYPE_DEVICE) ? 1 : 0;
 
 	*phys_id = __acpi_get_phys_id(handle, type, acpi_id, false);
-	*cpuid = acpi_map_cpuid(*phys_id, acpi_id);
-	if (*cpuid == -1)
-		return false;
+	id = acpi_map_cpuid(*phys_id, acpi_id);
 
+	if (id < 0)
+		return false;
+	*cpuid = id;
 	return true;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
