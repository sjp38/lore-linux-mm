From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 01/17] resource: Add System RAM resource type
Date: Tue, 26 Jan 2016 21:57:17 +0100
Message-ID: <1453841853-11383-2-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-arch-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Jakub Sitnicki <jsitnicki@gmail.com>, Jiang Liu <jiang.liu@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

The IORESOURCE_MEM I/O resource type is used for all types of
memory-mapped ranges, ex. System RAM, System ROM, Video RAM, Persistent
Memory, PCI Bus, PCI MMCONFIG, ACPI Tables, IOAPIC, reserved, and so
on.

This requires walk_system_ram_range(), walk_system_ram_res(), and
region_intersects() to use strcmp() against string "System RAM" to
search for System RAM ranges in the iomem table, which is inefficient.
__ioremap_caller() and reserve_memtype() on x86, for instance, call
walk_system_ram_range() for every request to check if a given range is
in System RAM ranges.

However, adding a new I/O resource type for System RAM is not a viable
option, see [1]. There are approx. 3800 references to IORESOURCE_MEM in
the kernel/drivers, which makes it very difficult to distinguish their
usages between new type and IORESOURCE_MEM.

The I/O resource types are also used by the PNP subsystem. Therefore,
introduce an extended I/O resource type, IORESOURCE_SYSTEM_RAM, which
consists of IORESOURCE_MEM and a new modifier flag IORESOURCE_SYSRAM,
see [2].

To keep the code 'if (resource_type(r) == IORESOURCE_MEM)' still working
for System RAM, resource_ext_type() is added for extracting extended
type bits.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Link: http://lkml.kernel.org/r/1452020081-26534-1-git-send-email-toshi.kani@hpe.com
Link[1]: http://lkml.kernel.org/r/1449168859.9855.54.camel@hpe.com
Link[2]: http://lkml.kernel.org/r/CA+55aFy4WQrWexC4u2LxX9Mw2NVoznw7p3Yh=iF4Xtf7zKWnRw@mail.gmail.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 include/linux/ioport.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 24bea087e7af..4b65d944717f 100644
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
2.3.5
