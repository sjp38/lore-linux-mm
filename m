Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id E6B4F800CA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:38 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id o62so274354926oif.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:38 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id q124si30827456oig.77.2016.01.05.10.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:38 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 09/17] drivers: Initialize resource entry to zero
Date: Tue,  5 Jan 2016 11:54:33 -0700
Message-Id: <1452020081-26534-9-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

I/O resource descriptor, 'desc' in struct resource, needs to be
initialized to zero by default.  Some drivers call kmalloc() to
allocate a resource entry, but does not initialize it to zero by
memset().  Change these drivers to call kzalloc(), instead.

Cc: linux-acpi@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Acked-by: Simon Horman <horms+renesas@verge.net.au> # sh
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 drivers/acpi/acpi_platform.c       |    2 +-
 drivers/parisc/eisa_enumerator.c   |    4 ++--
 drivers/rapidio/rio.c              |    8 ++++----
 drivers/sh/superhyway/superhyway.c |    2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/acpi/acpi_platform.c b/drivers/acpi/acpi_platform.c
index 296b7a1..b6f7fa3 100644
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
index a656d9e..21905fe 100644
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
index d7b87c6..e220edc 100644
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
index 2d9e7f3..bb1fb771 100644
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
