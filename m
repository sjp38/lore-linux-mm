Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8046D6B0006
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:20 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id wp13so146451880obc.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:20 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id tx9si5198657oec.22.2016.01.05.10.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:19 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 01/17] resource: Add System RAM resource type
Date: Tue,  5 Jan 2016 11:54:25 -0700
Message-Id: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Dan Williams <dan.j.williams@intel.com>, Toshi Kani <toshi.kani@hpe.com>

I/O resource type, IORESOURCE_MEM, is used for all types of
memory-mapped ranges, ex. System RAM, System ROM, Video RAM,
Persistent Memory, PCI Bus, PCI MMCONFIG, ACPI Tables, IOAPIC,
reserved, and so on.  This requires walk_system_ram_range(),
walk_system_ram_res(), and region_intersects() to use strcmp()
against string "System RAM" to search for System RAM ranges in
the iomem table, which is inefficient.  __ioremap_caller() and
reserve_memtype() on x86, for instance, call walk_system_ram_range()
for every request to check if a given range is in System RAM ranges.

However, adding a new I/O resource type for System RAM is not
a viable option [1].  There are approx. 3800 references to
IORESOURCE_MEM in the kernel/drivers, which make it very
difficult to distinguish their usages between new type and
IORESOURCE_MEM.  The I/O resource types are also used by the
PNP subsystem.  Therefore, this patch introduces an extended
I/O resource type, IORESOURCE_SYSTEM_RAM, which consists of
IORESOURCE_MEM and a new modifier flag IORESOURCE_SYSRAM [2].

To keep the code 'if (resource_type(r) == IORESOURCE_MEM)' to
work continuously for System RAM, resource_ext_type() is added
for extracting extended type bits.

Link[1]: http://lkml.kernel.org/r/<1449168859.9855.54.camel@hpe.com>
Link[2]: http://lkml.kernel.org/r/<CA+55aFy4WQrWexC4u2LxX9Mw2NVoznw7p3Yh=iF4Xtf7zKWnRw@mail.gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 include/linux/ioport.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 24bea08..4b65d94 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -49,12 +49,19 @@ struct resource {
 #define IORESOURCE_WINDOW	0x00200000	/* forwarded by bridge */
 #define IORESOURCE_MUXED	0x00400000	/* Resource is software muxed */
 
+#define IORESOURCE_EXT_TYPE_BITS 0x01000000	/* Resource extended types */
+#define IORESOURCE_SYSRAM	0x01000000	/* System RAM (modifier) */
+
 #define IORESOURCE_EXCLUSIVE	0x08000000	/* Userland may not map this resource */
+
 #define IORESOURCE_DISABLED	0x10000000
 #define IORESOURCE_UNSET	0x20000000	/* No address assigned yet */
 #define IORESOURCE_AUTO		0x40000000
 #define IORESOURCE_BUSY		0x80000000	/* Driver has marked this resource busy */
 
+/* I/O resource extended types */
+#define IORESOURCE_SYSTEM_RAM		(IORESOURCE_MEM|IORESOURCE_SYSRAM)
+
 /* PnP IRQ specific bits (IORESOURCE_BITS) */
 #define IORESOURCE_IRQ_HIGHEDGE		(1<<0)
 #define IORESOURCE_IRQ_LOWEDGE		(1<<1)
@@ -170,6 +177,10 @@ static inline unsigned long resource_type(const struct resource *res)
 {
 	return res->flags & IORESOURCE_TYPE_BITS;
 }
+static inline unsigned long resource_ext_type(const struct resource *res)
+{
+	return res->flags & IORESOURCE_EXT_TYPE_BITS;
+}
 /* True iff r1 completely contains r2 */
 static inline bool resource_contains(struct resource *r1, struct resource *r2)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
