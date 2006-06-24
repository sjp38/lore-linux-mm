Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5O26ItX018430
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 22:06:19 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5O26VxD180362
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 20:06:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5O26Iv0016961
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 20:06:18 -0600
Subject: [RFC] Patch [4/4] x86_64 sparsmem add- acpi fixup take 2
	motherboard.c
From: keith mannthey <kmannth@us.ibm.com>
Reply-To: kmannth@us.ibm.com
Content-Type: multipart/mixed; boundary="=-ZVYFtZ280pwAKzInbC8g"
Date: Fri, 23 Jun 2006 19:06:17 -0700
Message-Id: <1151114777.7094.53.camel@keithlap>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel <lhms-devel@lists.sourceforge.net>
Cc: linux-mm <linux-mm@kvack.org>, dave hansen <haveblue@us.ibm.com>, kame <kamezawa.hiroyu@jp.fujitsu.com>, intel-acpi <acpi@linux.intel.com>
List-ID: <linux-mm.kvack.org>

--=-ZVYFtZ280pwAKzInbC8g
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


patch against the motherboard driver.  I am unsure what the correct fix
is but there are 3 options.

1. The motherboard driver needs to be fixed (my patch or something like
it)
2. The algorithm in acpi_bus_match/acpi_bus_find_driver is flawed. 
3. There is somthing wrong with the ACPI namespace on the box (BIOS).   

Let me explain what is happening from a I don't know much about acpi
point of view. 

  My system loads to acpi memory hot plug driver just fine during boot.
It installs and registers  acpi_memory_device_driver and it's handler.
When the hot add memory event occurs the handler is called.  
this is the relevant call path

acpi_memory_get_device
acpi_bus_add
acpi_add_single_object
acpi_bus_find_driver
acpi_bus_driver_init
driver->ops.add

  The algorithm it try to match devices from acpi_bus_drivers.  It looks
for drivers that are on the right bus and calls acpi_bus_driver_init.
If it gets a good return value for acpi_bus_driver_init it thinks it
found the device and returns.  The problem is the motherboard driver
driver->ops.add is getting called and it ALWAYS returns AE_OK. 

  The device that is passed back up the call chain is the wrong one and
things break down. 
 
  My fix is to make the motherboard driver return an error when it sees
resources it doesn't know about. I don't know if this is the correct
solution or to but it highlights the problem I am having. With this
patch in place this work as expected with regards to the acpi memory
device. 

Kame (who helped me greatly in tracking down the source my troubles)
thinks that the root cause is that the device has both a _HID and _CID
The driver for _HID is different for _CID and the driver for _CID is
found before _HID and I run the wrong add. 

I am not sure what the correct solution to this problem is. Built
against 2.6.17-mm1 but should apply with fuzz just about anywhere. 

Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>

--=-ZVYFtZ280pwAKzInbC8g
Content-Disposition: attachment; filename=patch-2.6.17-mm1-motherboard
Content-Type: text/x-patch; name=patch-2.6.17-mm1-motherboard; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.17-mm1-orig/drivers/acpi/motherboard.c linux-2.6.17-mm1/drivers/acpi/motherboard.c
--- linux-2.6.17-mm1-orig/drivers/acpi/motherboard.c	2006-06-23 16:12:01.000000000 -0400
+++ linux-2.6.17-mm1/drivers/acpi/motherboard.c	2006-06-23 18:22:25.000000000 -0400
@@ -88,6 +88,7 @@
 		}
 	} else {
 		/* Memory mapped IO? */
+		 return -EINVAL;
 	}
 
 	if (requested_res)
@@ -97,12 +98,14 @@
 
 static int acpi_motherboard_add(struct acpi_device *device)
 {
+	acpi_status status;
 	if (!device)
 		return -EINVAL;
-	acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+
+	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
 			    acpi_reserve_io_ranges, NULL);
 
-	return 0;
+	return status;
 }
 
 static struct acpi_driver acpi_motherboard_driver1 = {

--=-ZVYFtZ280pwAKzInbC8g--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
