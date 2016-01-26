From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 09/17] drivers: Initialize resource entry to zero
Date: Tue, 26 Jan 2016 21:57:25 +0100
Message-ID: <1453841853-11383-10-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-parisc@vger.kernel.org, linux-renesas-soc@vger.kernel.org, linux-sh@vger.kernel.org
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

I/O resource descriptor, 'desc' in struct resource, needs to be
initialized to zero by default.  Some drivers call kmalloc() to
allocate a resource entry, but do not initialize it to zero by
memset().  Change these drivers to call kzalloc(), instead.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Acked-by: Alexandre Bounine <alexandre.bounine@idt.com>
Acked-by: Helge Deller <deller@gmx.de>
Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Acked-by: Simon Horman <horms+renesas@verge.net.au>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-acpi@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-parisc@vger.kernel.org
Cc: linux-renesas-soc@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Link: http://lkml.kernel.org/r/1452020081-26534-9-git-send-email-toshi.kani@hpe.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 drivers/acpi/acpi_platform.c       | 2 +-
 drivers/parisc/eisa_enumerator.c   | 4 ++--
 drivers/rapidio/rio.c              | 8 ++++----
 drivers/sh/superhyway/superhyway.c | 2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/acpi/acpi_platform.c b/drivers/acpi/acpi_platform.c
index 296b7a14893a..b6f7fa3a1d40 100644
--- a/drivers/acpi/acpi_platform.c
+++ b/drivers/acpi/acpi_platform.c
@@ -62,7 +62,7 @@ struct platform_device *acpi_create_platform_device(struct acpi_device *adev)
 	if (count < 0) {
 		return NULL;
 	} else if (count > 0) {
-		resources = kmalloc(count * sizeof(struct resource),
+		resources = kzalloc(count * sizeof(struct resource),
 				    GFP_KERNEL);
 		if (!resources) {
 			dev_err(&adev->dev, "No memory for resources\n");
diff --git a/drivers/parisc/eisa_enumerator.c b/drivers/parisc/eisa_enumerator.c
index a656d9e83343..21905fef2cbf 100644
--- a/drivers/parisc/eisa_enumerator.c
+++ b/drivers/parisc/eisa_enumerator.c
@@ -91,7 +91,7 @@ static int configure_memory(const unsigned char *buf,
 	for (i=0;i<HPEE_MEMORY_MAX_ENT;i++) {
 		c = get_8(buf+len);
 		
-		if (NULL != (res = kmalloc(sizeof(struct resource), GFP_KERNEL))) {
+		if (NULL != (res = kzalloc(sizeof(struct resource), GFP_KERNEL))) {
 			int result;
 			
 			res->name = name;
@@ -183,7 +183,7 @@ static int configure_port(const unsigned char *buf, struct resource *io_parent,
 	for (i=0;i<HPEE_PORT_MAX_ENT;i++) {
 		c = get_8(buf+len);
 		
-		if (NULL != (res = kmalloc(sizeof(struct resource), GFP_KERNEL))) {
+		if (NULL != (res = kzalloc(sizeof(struct resource), GFP_KERNEL))) {
 			res->name = board;
 			res->start = get_16(buf+len+1);
 			res->end = get_16(buf+len+1)+(c&HPEE_PORT_SIZE_MASK)+1;
diff --git a/drivers/rapidio/rio.c b/drivers/rapidio/rio.c
index d7b87c64b7cd..e220edc85c68 100644
--- a/drivers/rapidio/rio.c
+++ b/drivers/rapidio/rio.c
@@ -117,7 +117,7 @@ int rio_request_inb_mbox(struct rio_mport *mport,
 	if (mport->ops->open_inb_mbox == NULL)
 		goto out;
 
-	res = kmalloc(sizeof(struct resource), GFP_KERNEL);
+	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
 
 	if (res) {
 		rio_init_mbox_res(res, mbox, mbox);
@@ -185,7 +185,7 @@ int rio_request_outb_mbox(struct rio_mport *mport,
 	if (mport->ops->open_outb_mbox == NULL)
 		goto out;
 
-	res = kmalloc(sizeof(struct resource), GFP_KERNEL);
+	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
 
 	if (res) {
 		rio_init_mbox_res(res, mbox, mbox);
@@ -285,7 +285,7 @@ int rio_request_inb_dbell(struct rio_mport *mport,
 {
 	int rc = 0;
 
-	struct resource *res = kmalloc(sizeof(struct resource), GFP_KERNEL);
+	struct resource *res = kzalloc(sizeof(struct resource), GFP_KERNEL);
 
 	if (res) {
 		rio_init_dbell_res(res, start, end);
@@ -360,7 +360,7 @@ int rio_release_inb_dbell(struct rio_mport *mport, u16 start, u16 end)
 struct resource *rio_request_outb_dbell(struct rio_dev *rdev, u16 start,
 					u16 end)
 {
-	struct resource *res = kmalloc(sizeof(struct resource), GFP_KERNEL);
+	struct resource *res = kzalloc(sizeof(struct resource), GFP_KERNEL);
 
 	if (res) {
 		rio_init_dbell_res(res, start, end);
diff --git a/drivers/sh/superhyway/superhyway.c b/drivers/sh/superhyway/superhyway.c
index 2d9e7f3d5611..bb1fb7712134 100644
--- a/drivers/sh/superhyway/superhyway.c
+++ b/drivers/sh/superhyway/superhyway.c
@@ -66,7 +66,7 @@ int superhyway_add_device(unsigned long base, struct superhyway_device *sdev,
 	superhyway_read_vcr(dev, base, &dev->vcr);
 
 	if (!dev->resource) {
-		dev->resource = kmalloc(sizeof(struct resource), GFP_KERNEL);
+		dev->resource = kzalloc(sizeof(struct resource), GFP_KERNEL);
 		if (!dev->resource) {
 			kfree(dev);
 			return -ENOMEM;
-- 
2.3.5
