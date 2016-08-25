Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76AE583093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 04:36:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so78617213pfd.3
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 01:36:25 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id b1si14458799pfc.187.2016.08.25.01.36.23
        for <linux-mm@kvack.org>;
        Thu, 25 Aug 2016 01:36:24 -0700 (PDT)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH v12 6/7] acpi: Provide the mechanism to validate processors in the ACPI tables
Date: Thu, 25 Aug 2016 16:35:19 +0800
Message-ID: <1472114120-3281-7-git-send-email-douly.fnst@cn.fujitsu.com>
In-Reply-To: <1472114120-3281-1-git-send-email-douly.fnst@cn.fujitsu.com>
References: <1472114120-3281-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org
Cc: x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dou Liyang <douly.fnst@cn.fujitsu.com>

[Problem]

When we set cpuid <-> nodeid mapping to be persistent, it will use the DSDT
As we know, the ACPI tables are just like user's input in that respect, and
we don't crash if user's input is unreasonable.

Such as, the mapping of the proc_id and pxm in some machine's ACPI table is
like this:

proc_id   |    pxm
--------------------
0       <->     0
1       <->     0
2       <->     1
3       <->     1
89      <->     0
89      <->     0
89      <->     0
89      <->     1
89      <->     1
89      <->     2
89      <->     3
.....

We can't be sure which one is correct to the proc_id 89. We may map a wrong
node to a cpu. When pages are allocated, this may cause a kernal panic.

So, we should provide mechanisms to validate the ACPI tables, just like we
do validation to check user's input in web project.

The mechanism is that the processor objects which have the duplicate IDs
are not valid.

[Solution]

We add a validation function, like this:

foreach Processor in DSDT
	proc_id= get_ACPI_Processor_number(Processor)
	if(the proc_id has alreadly existed )
		mark both of them as being unreasonable;

The function will record the unique or duplicate processor IDs.

The duplicate processor IDs such as 89 are regarded as the unreasonable IDs
which mean that the processor objects in question are not valid.

Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
---
 drivers/acpi/acpi_processor.c | 79 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 79 insertions(+)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index 0c15828..346fbfc 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -581,8 +581,87 @@ static struct acpi_scan_handler processor_container_handler = {
 	.attach = acpi_processor_container_attach,
 };
 
+/* The number of the unique processor IDs */
+static int nr_unique_ids;
+
+/* The number of the duplicate processor IDs */
+static int nr_duplicate_ids;
+
+/* Used to store the unique processor IDs */
+static int unique_processor_ids[] = {
+	[0 ... NR_CPUS - 1] = -1,
+};
+
+/* Used to store the duplicate processor IDs */
+static int duplicate_processor_ids[] = {
+	[0 ... NR_CPUS - 1] = -1,
+};
+
+static void processor_validated_ids_update(int proc_id)
+{
+	int i;
+
+	if (nr_unique_ids == NR_CPUS||nr_duplicate_ids == NR_CPUS)
+		return;
+
+	/*
+	 * Firstly, compare the proc_id with duplicate IDs, if the proc_id is
+	 * already in the IDs, do nothing.
+	 */
+	for (i = 0; i < nr_duplicate_ids; i++) {
+		if (duplicate_processor_ids[i] == proc_id)
+			return;
+	}
+
+	/*
+	 * Secondly, compare the proc_id with unique IDs, if the proc_id is in
+	 * the IDs, put it in the duplicate IDs.
+	 */
+	for (i = 0; i < nr_unique_ids; i++) {
+		if (unique_processor_ids[i] == proc_id) {
+			duplicate_processor_ids[nr_duplicate_ids] = proc_id;
+			nr_duplicate_ids++;
+			return;
+		}
+	}
+
+	/*
+	 * Lastly, the proc_id is a unique ID, put it in the unique IDs.
+	 */
+	unique_processor_ids[nr_unique_ids] = proc_id;
+	nr_unique_ids++;
+}
+
+static acpi_status acpi_processor_ids_walk(acpi_handle handle,
+						u32 lvl,
+						void *context,
+						void **rv)
+{
+	acpi_status status;
+	union acpi_object object = { 0 };
+	struct acpi_buffer buffer = { sizeof(union acpi_object), &object };
+
+	status = acpi_evaluate_object(handle, NULL, NULL, &buffer);
+	if (ACPI_FAILURE(status))
+		acpi_handle_info(handle, "Not get the processor object\n");
+	else
+		processor_validated_ids_update(object.processor.proc_id);
+
+	return AE_OK;
+}
+
+static void acpi_processor_duplication_valiate(void)
+{
+	/* Search all processor nodes in ACPI namespace */
+	acpi_walk_namespace(ACPI_TYPE_PROCESSOR, ACPI_ROOT_OBJECT,
+						ACPI_UINT32_MAX,
+						acpi_processor_ids_walk,
+						NULL, NULL, NULL);
+}
+
 void __init acpi_processor_init(void)
 {
+	acpi_processor_duplication_valiate();
 	acpi_scan_add_handler_with_hotplug(&processor_handler, "processor");
 	acpi_scan_add_handler(&processor_container_handler);
 }
-- 
2.5.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
