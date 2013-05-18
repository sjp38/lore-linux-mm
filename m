Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 176A46B0033
	for <linux-mm@kvack.org>; Sat, 18 May 2013 19:27:09 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 4/5] ACPI / scan: Add second pass of companion offlining to hot-remove code
Date: Sun, 19 May 2013 01:34:14 +0200
Message-ID: <3662688.5fMZaG7XgD@vostro.rjw.lan>
In-Reply-To: <2250271.rGYN6WlBxf@vostro.rjw.lan>
References: <2250271.rGYN6WlBxf@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ACPI Devel Maling List <linux-acpi@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <liuj97@gmail.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-mm@kvack.org

From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

As indicated by comments in mm/memory_hotplug.c:remove_memory(),
if CONFIG_MEMCG is set, it may not be possible to offline all of the
memory blocks held by one module (FRU) in one pass (because one of
them may be used by the others to store page cgroup in that case
and that block has to be offlined before the other ones).

To handle that arguably corner case, add a second pass of companion
device offlining to acpi_scan_hot_remove() and make it ignore errors
returned in the first pass (and make it skip the second pass if the
first one is successful).

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 drivers/acpi/scan.c |   67 ++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 50 insertions(+), 17 deletions(-)

Index: linux-pm/drivers/acpi/scan.c
===================================================================
--- linux-pm.orig/drivers/acpi/scan.c
+++ linux-pm/drivers/acpi/scan.c
@@ -131,6 +131,7 @@ static acpi_status acpi_bus_offline_comp
 {
 	struct acpi_device *device = NULL;
 	struct acpi_device_physical_node *pn;
+	bool second_pass = (bool)data;
 	acpi_status status = AE_OK;
 
 	if (acpi_bus_get_device(handle, &device))
@@ -141,15 +142,26 @@ static acpi_status acpi_bus_offline_comp
 	list_for_each_entry(pn, &device->physical_node_list, node) {
 		int ret;
 
+		if (second_pass) {
+			/* Skip devices offlined by the first pass. */
+			if (pn->put_online)
+				continue;
+		} else {
+			pn->put_online = false;
+		}
 		ret = device_offline(pn->dev);
 		if (acpi_force_hot_remove)
 			continue;
 
-		if (ret < 0) {
-			status = AE_ERROR;
-			break;
+		if (ret >= 0) {
+			pn->put_online = !ret;
+		} else {
+			*ret_p = pn->dev;
+			if (second_pass) {
+				status = AE_ERROR;
+				break;
+			}
 		}
-		pn->put_online = !ret;
 	}
 
 	mutex_unlock(&device->physical_node_lock);
@@ -185,6 +197,7 @@ static int acpi_scan_hot_remove(struct a
 	acpi_handle not_used;
 	struct acpi_object_list arg_list;
 	union acpi_object arg;
+	struct device *errdev;
 	acpi_status status;
 	unsigned long long sta;
 
@@ -197,22 +210,42 @@ static int acpi_scan_hot_remove(struct a
 
 	lock_device_hotplug();
 
-	status = acpi_walk_namespace(ACPI_TYPE_ANY, handle, ACPI_UINT32_MAX,
-				     NULL, acpi_bus_offline_companions, NULL,
-				     NULL);
-	if (ACPI_SUCCESS(status) || acpi_force_hot_remove)
-		status = acpi_bus_offline_companions(handle, 0, NULL, NULL);
-
-	if (ACPI_FAILURE(status) && !acpi_force_hot_remove) {
-		acpi_bus_online_companions(handle, 0, NULL, NULL);
+	/*
+	 * Carry out two passes here and ignore errors in the first pass,
+	 * because if the devices in question are memory blocks and
+	 * CONFIG_MEMCG is set, one of the blocks may hold data structures
+	 * that the other blocks depend on, but it is not known in advance which
+	 * block holds them.
+	 *
+	 * If the first pass is successful, the second one isn't needed, though.
+	 */
+	errdev = NULL;
+	acpi_walk_namespace(ACPI_TYPE_ANY, handle, ACPI_UINT32_MAX,
+			    NULL, acpi_bus_offline_companions,
+			    (void *)false, (void **)&errdev);
+	acpi_bus_offline_companions(handle, 0, (void *)false, (void **)&errdev);
+	if (errdev) {
+		errdev = NULL;
 		acpi_walk_namespace(ACPI_TYPE_ANY, handle, ACPI_UINT32_MAX,
-				    acpi_bus_online_companions, NULL, NULL,
-				    NULL);
+				    NULL, acpi_bus_offline_companions,
+				    (void *)true , (void **)&errdev);
+		if (!errdev || acpi_force_hot_remove)
+			acpi_bus_offline_companions(handle, 0, (void *)true,
+						    (void **)&errdev);
+
+		if (errdev && !acpi_force_hot_remove) {
+			dev_warn(errdev, "Offline failed.\n");
+			acpi_bus_online_companions(handle, 0, NULL, NULL);
+			acpi_walk_namespace(ACPI_TYPE_ANY, handle,
+					    ACPI_UINT32_MAX,
+					    acpi_bus_online_companions, NULL,
+					    NULL, NULL);
 
-		unlock_device_hotplug();
+			unlock_device_hotplug();
 
-		put_device(&device->dev);
-		return -EBUSY;
+			put_device(&device->dev);
+			return -EBUSY;
+		}
 	}
 
 	ACPI_DEBUG_PRINT((ACPI_DB_INFO,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
