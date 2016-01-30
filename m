Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C2B396B0256
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:32:15 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id uo6so55385322pac.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:32:15 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id g7si8244773pat.11.2016.01.30.01.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:32:15 -0800 (PST)
Date: Sat, 30 Jan 2016 01:31:01 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-9a975bee4b3945b271bcff18a520d4863c210f8b@git.kernel.org>
Reply-To: torvalds@linux-foundation.org, dvlasenk@redhat.com,
        rafael.j.wysocki@intel.com, hpa@zytor.com, mingo@kernel.org,
        toshi.kani@hp.com, linux-mm@kvack.org, peterz@infradead.org,
        bp@suse.de, bp@alien8.de, brgerst@gmail.com, akpm@linux-foundation.org,
        deller@gmx.de, mcgrof@suse.com, horms+renesas@verge.net.au,
        tglx@linutronix.de, toshi.kani@hpe.com, linux-kernel@vger.kernel.org,
        alexandre.bounine@idt.com, luto@amacapital.net
In-Reply-To: <1453841853-11383-10-git-send-email-bp@alien8.de>
References: <1453841853-11383-10-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] drivers: Initialize resource entry to zero
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: brgerst@gmail.com, akpm@linux-foundation.org, bp@suse.de, bp@alien8.de, mcgrof@suse.com, horms+renesas@verge.net.au, deller@gmx.de, linux-kernel@vger.kernel.org, alexandre.bounine@idt.com, toshi.kani@hpe.com, tglx@linutronix.de, luto@amacapital.net, dvlasenk@redhat.com, rafael.j.wysocki@intel.com, torvalds@linux-foundation.org, toshi.kani@hp.com, linux-mm@kvack.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

Commit-ID:  9a975bee4b3945b271bcff18a520d4863c210f8b
Gitweb:     http://git.kernel.org/tip/9a975bee4b3945b271bcff18a520d4863c210f8b
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:25 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:58 +0100

drivers: Initialize resource entry to zero

I/O resource descriptor, 'desc' in struct resource, needs to be
initialized to zero by default.  Some drivers call kmalloc() to
allocate a resource entry, but do not initialize it to zero by
memset().  Change these drivers to call kzalloc(), instead.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Acked-by: Alexandre Bounine <alexandre.bounine@idt.com>
Acked-by: Helge Deller <deller@gmx.de>
Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Acked-by: Simon Horman <horms+renesas@verge.net.au>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-acpi@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-parisc@vger.kernel.org
Cc: linux-renesas-soc@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Link: http://lkml.kernel.org/r/1453841853-11383-10-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 drivers/acpi/acpi_platform.c       | 2 +-
 drivers/parisc/eisa_enumerator.c   | 4 ++--
 drivers/rapidio/rio.c              | 8 ++++----
 drivers/sh/superhyway/superhyway.c | 2 +-
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
