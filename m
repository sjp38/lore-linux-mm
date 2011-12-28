Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id DAA1F6B004D
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 14:42:41 -0500 (EST)
From: Philip Prindeville <philipp@redfish-solutions.com>
Subject: [PATCH 2/4] coreboot: Add support for detecting Coreboot BIOS signatures
Date: Wed, 28 Dec 2011 12:42:32 -0700
Message-Id: <1325101352-11130-1-git-send-email-philipp@redfish-solutions.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Ed Wildgoose <ed@wildgooses.com>, Andrew Morton <akpm@linux-foundation.org>, linux-geode@lists.infradead.org, Andres Salomon <dilinger@queued.net>

Add support for Coreboot BIOS detection. This in turn can be used by
platform drivers to verify they are running on the correct hardware,
as many of the low-volume SBC's (especially in the Atom and Geode
universe) don't always identify themselves via DMI or PCI-ID.

The coreboot project lives at:

http://www.coreboot.org/

and the related project Flashrom lives here:

http://flashrom.org/

This library pulls from both, though predominantly the former.

The library locates the Coreboot tables in memory, parses them, and
provides a way to extract from the table the motherboard vendor and
model fields for use in platform drivers.

Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
Reviewed-by: Ed Wildgoose <ed@wildgooses.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Salomon <dilinger@queued.net>
Cc: Nathan Williams <nathan@traverse.com.au>
Cc: Guy Ellis <guy@traverse.com.au>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Patrick Georgi <patrick.georgi@secunet.com>
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Cc: linux-geode@lists.infradead.org
Cc: linux-mm@kvack.org
---
 Documentation/x86/coreboot.txt |   31 +++++
 include/linux/coreboot.h       |  182 +++++++++++++++++++++++++
 lib/Kconfig                    |    8 +
 lib/Makefile                   |    1 +
 lib/coreboot.c                 |  290 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 512 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/x86/coreboot.txt
 create mode 100644 include/linux/coreboot.h
 create mode 100644 lib/coreboot.c

diff --git a/Documentation/x86/coreboot.txt b/Documentation/x86/coreboot.txt
new file mode 100644
index 0000000..35be360
--- /dev/null
+++ b/Documentation/x86/coreboot.txt
@@ -0,0 +1,31 @@
+Coreboot is an open source bootloader/BIOS. It currently is supported on x86, but
+has been made to run on PPC hardware as well.  The project lives here:
+
+http://www.coreboot.org/
+
+It was previously known as LinuxBIOS.
+
+It has been ported to various boards, including the Geode single-board computers alix, wrap, and geos.
+
+The list is here:
+
+http://www.coreboot.org/Supported_Motherboards
+
+http://www.coreboot.org/Supported_Chipsets_and_Devices
+
+Coreboot requires gcc, binutils, and make to be built.
+
+Part of coreboot's initialization includes creating a table (called, not surprisingly, the
+coreboot table) that contains various information about the system, such as memory apertures,
+serial ports, the manufacturer and model number of the system, etc.
+
+A bootable utility called FlashROM is available for programming flash chips. It lives here:
+
+http://flashrom.org/Documentation
+
+it includes a library for reading coreboot tables. Source for flashrom is here:
+
+svn://flashrom.org/flashrom/trunk
+
+The lib/coreboot.c module borrows heavily from flashrom's cbtable.c and coreboot_tables.h
+
diff --git a/include/linux/coreboot.h b/include/linux/coreboot.h
new file mode 100644
index 0000000..0ed6118
--- /dev/null
+++ b/include/linux/coreboot.h
@@ -0,0 +1,182 @@
+/*
+ * This file is part of the coreboot project.
+ *
+ * Copyright (C) 2002 Linux Networx
+ * (Written by Eric Biederman <ebiederman@lnxi.com> for Linux Networx)
+ * Copyright (C) 2005-2007 coresystems GmbH
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA, 02110-1301 USA
+ */
+
+#ifndef COREBOOT_H
+#define COREBOOT_H
+
+#include <linux/types.h>
+
+/* The coreboot table information is for conveying information
+ * from the firmware to the loaded OS image.  Primarily this
+ * is expected to be information that cannot be discovered by
+ * other means, such as querying the hardware directly.
+ *
+ * All of the information should be Position Independent Data.  
+ * That is it should be safe to relocated any of the information
+ * without it's meaning/correctness changing.   For table that
+ * can reasonably be used on multiple architectures the data
+ * size should be fixed.  This should ease the transition between
+ * 32 bit and 64 bit architectures etc.
+ *
+ * The completeness test for the information in this table is:
+ * - Can all of the hardware be detected?
+ * - Are the per motherboard constants available?
+ * - Is there enough to allow a kernel to run that was written before
+ *   a particular motherboard is constructed? (Assuming the kernel
+ *   has drivers for all of the hardware but it does not have
+ *   assumptions on how the hardware is connected together).
+ *
+ * With this test it should be straight forward to determine if a
+ * table entry is required or not.  This should remove much of the
+ * long term compatibility burden as table entries which are
+ * irrelevant or have been replaced by better alternatives may be
+ * dropped.  Of course it is polite and expedite to include extra
+ * table entries and be backwards compatible, but it is not required.
+ */
+
+/* Since coreboot is usually compiled 32bit, gcc will align 64bit 
+ * types to 32bit boundaries. If the coreboot table is dumped on a 
+ * 64bit system, a uint64_t would be aligned to 64bit boundaries, 
+ * breaking the table format.
+ *
+ * lb_uint64 will keep 64bit coreboot table values aligned to 32bit
+ * to ensure compatibility. They can be accessed with the two functions
+ * below: unpack_lb64() and pack_lb64()
+ *
+ * See also: util/lbtdump/lbtdump.c
+ */
+
+struct lb_uint64 {
+	uint32_t lo;
+	uint32_t hi;
+};
+
+static inline uint64_t unpack_lb64(struct lb_uint64 value)
+{
+	uint64_t result;
+	result = value.hi;
+	result = (result << 32) + value.lo;
+	return result;
+}
+
+static inline struct lb_uint64 pack_lb64(uint64_t value)
+{
+	struct lb_uint64 result;
+	result.lo = (value >> 0) & 0xffffffff;
+	result.hi = (value >> 32) & 0xffffffff;
+	return result;
+}
+
+struct lb_header {
+	uint8_t signature[4];	/* LBIO */
+	uint32_t header_bytes;
+	uint32_t header_checksum;
+	uint32_t table_bytes;
+	uint32_t table_checksum;
+	uint32_t table_entries;
+};
+
+/* Every entry in the boot environment list will correspond to a boot
+ * info record.  Encoding both type and size.  The type is obviously
+ * so you can tell what it is.  The size allows you to skip that
+ * boot environment record if you don't know what it easy.  This allows
+ * forward compatibility with records not yet defined.
+ */
+struct lb_record {
+	uint32_t tag;		/* tag ID */
+	uint32_t size;		/* size of record (in bytes) */
+};
+
+#define LB_TAG_UNUSED	0x0000
+
+#define LB_TAG_MEMORY	0x0001
+
+struct lb_memory_range {
+	struct lb_uint64 start;
+	struct lb_uint64 size;
+	uint32_t type;
+#define LB_MEM_RAM       1	/* Memory anyone can use */
+#define LB_MEM_RESERVED  2	/* Don't use this memory region */
+#define LB_MEM_TABLE     16	/* Ram configuration tables are kept in */
+};
+
+struct lb_memory {
+	uint32_t tag;
+	uint32_t size;
+	struct lb_memory_range map[0];
+};
+
+#define LB_TAG_HWRPB	0x0002
+struct lb_hwrpb {
+	uint32_t tag;
+	uint32_t size;
+	uint64_t hwrpb;
+};
+
+#define LB_TAG_MAINBOARD	0x0003
+struct lb_mainboard {
+	uint32_t tag;
+	uint32_t size;
+	uint8_t vendor_idx;
+	uint8_t part_number_idx;
+	uint8_t strings[0];
+};
+
+#define LB_TAG_VERSION		0x0004
+#define LB_TAG_EXTRA_VERSION	0x0005
+#define LB_TAG_BUILD		0x0006
+#define LB_TAG_COMPILE_TIME	0x0007
+#define LB_TAG_COMPILE_BY	0x0008
+#define LB_TAG_COMPILE_HOST	0x0009
+#define LB_TAG_COMPILE_DOMAIN	0x000a
+#define LB_TAG_COMPILER		0x000b
+#define LB_TAG_LINKER		0x000c
+#define LB_TAG_ASSEMBLER	0x000d
+struct lb_string {
+	uint32_t tag;
+	uint32_t size;
+	uint8_t string[0];
+};
+
+#define LB_TAG_FORWARD		0x0011
+struct lb_forward {
+	uint32_t tag;
+	uint32_t size;
+	uint64_t forward;
+};
+
+/*
+ * vendor string, taken from mainboard record.
+ */
+extern const char *coreboot_vendor(void);
+
+/*
+ * part # string, taken from mainboard record.
+ */
+extern const char *coreboot_part(void);
+
+/*
+ * search for Coreboot tables. if found, search entries for
+ * mainboard record and parse it. return address of first record.
+ */
+extern struct lb_record *coreboot_init(void);
+
+#endif				/* COREBOOT_TABLES_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 201e1b3..d880af8 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -98,6 +98,14 @@ config AUDIT_GENERIC
 	depends on AUDIT && !AUDIT_ARCH
 	default y
 
+config COREBOOT
+	bool "Coreboot location/parsing support"
+	depends on X86
+	help
+	  Support for boards running coreboot. It allows platform drivers to
+	  detect their manufacturer and part number by interrogating the BIOS
+	  populated tables.
+
 #
 # compression support is select'ed if needed
 #
diff --git a/lib/Makefile b/lib/Makefile
index dace162..9dd493d 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -64,6 +64,7 @@ obj-$(CONFIG_CRC7)	+= crc7.o
 obj-$(CONFIG_LIBCRC32C)	+= libcrc32c.o
 obj-$(CONFIG_CRC8)	+= crc8.o
 obj-$(CONFIG_GENERIC_ALLOCATOR) += genalloc.o
+obj-$(CONFIG_COREBOOT)	+= coreboot.o
 
 obj-$(CONFIG_ZLIB_INFLATE) += zlib_inflate/
 obj-$(CONFIG_ZLIB_DEFLATE) += zlib_deflate/
diff --git a/lib/coreboot.c b/lib/coreboot.c
new file mode 100644
index 0000000..f3dd191
--- /dev/null
+++ b/lib/coreboot.c
@@ -0,0 +1,290 @@
+/*
+ * This file was extracted from parts of the flashrom project.
+ *
+ * Copyright (C) 2002 Steven James <pyro@linuxlabs.com>
+ * Copyright (C) 2002 Linux Networx
+ * (Written by Eric Biederman <ebiederman@lnxi.com> for Linux Networx)
+ * Copyright (C) 2006-2009 coresystems GmbH
+ * (Written by Stefan Reinauer <stepan@coresystems.de> for coresystems GmbH)
+ * Copyright (C) 2010 Carl-Daniel Hailfinger
+ * Copyright (C) 2011 Philip Prindeville
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
+ */
+
+#include <linux/types.h>
+#include <linux/unistd.h>
+#include <linux/string.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/printk.h>
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <linux/io.h>
+
+#include <linux/ioport.h>
+
+#include <asm/checksum.h>
+#include <asm/page.h>
+
+#include <linux/coreboot.h>
+
+#define for_each_lbrec(head, rec) \
+	for(rec = (struct lb_record *)(((caddr_t)head) + sizeof(*head)); \
+		(((caddr_t)rec) < (((caddr_t)head) + sizeof(*head) + head->table_bytes))  && \
+		(rec->size >= 1) && \
+		((((caddr_t)rec) + rec->size) <= (((caddr_t)head) + sizeof(*head) + head->table_bytes)); \
+		rec = (struct lb_record *)(((caddr_t)rec) + rec->size))
+
+static char lb_part[32], lb_vendor[32];
+
+static inline __sum16 compute_checksum(void *addr, unsigned long length)
+{
+	return ip_compute_csum(addr, length);
+}
+
+static inline uintptr_t vpage_offset(void *addr)
+{
+	return ((uintptr_t)addr & ~PAGE_MASK);
+}
+
+static inline void *vpage_base(void *addr)
+{
+	return (void *)((uintptr_t)addr & PAGE_MASK);
+}
+
+static inline void *__v_offset(void *addr, unsigned offset)
+{
+	return (void *)((caddr_t)addr + offset);
+}
+
+static inline uintptr_t ppage_offset(phys_addr_t addr)
+{
+	return (addr & ~PAGE_MASK);
+}
+
+static inline phys_addr_t ppage_base(phys_addr_t addr)
+{
+	return (phys_addr_t)(addr & PAGE_MASK);
+}
+
+static unsigned count_lb_records(const struct lb_header *head)
+{
+	struct lb_record *rec;
+	unsigned count;
+
+	count = 0;
+	for_each_lbrec(head, rec) {
+		count++;
+	}
+
+	return count;
+}
+
+#ifdef DEBUG
+static void dump_lb_header(const struct lb_header *lh)
+{
+	printk(KERN_DEBUG "header 0x%p\n"
+			  "  sig: %.4s, bytes %u, chksum %#04x,"
+			  " bytes %u, chksum %#04x, entries %u\n",
+	       lh, lh->signature, lh->header_bytes, lh->header_checksum,
+	       lh->table_bytes, lh->table_checksum, lh->table_entries);
+}
+
+static void dump_lb_forward(const struct lb_forward *lf)
+{
+	printk(KERN_DEBUG "forward 0x%p\n  tag %04x, size %u, forward %#llx\n",
+	       lf, lf->tag, lf->size, lf->forward);
+}
+
+static void dump_lb_mainboard(struct lb_mainboard *lm)
+{
+	printk(KERN_DEBUG "mainboard: 0x%p\n  tag %04x, size %u, vendor %s, part %s\n",
+	       lm, lm->tag, lm->size, &lm->strings[lm->vendor_idx],
+	       &lm->strings[lm->part_number_idx]);
+}
+#endif
+
+static struct lb_header *find_lb_table(void *base, void *end)
+{
+	void *addr;
+
+	printk(KERN_DEBUG "Starting search at 0x%p\n", base);
+	/* For now be stupid.... */
+	for (addr = base; addr < end; addr += 16) {
+		struct lb_header *head = (struct lb_header *)addr;
+		struct lb_record *recs;
+
+		if (memcmp(head->signature, "LBIO", 4) != 0)
+			continue;
+		printk(KERN_DEBUG "Found candidate at: 0x%p-%p\n",
+			     addr, addr + head->table_bytes);
+#ifdef DEBUG
+		dump_lb_header(head);
+#endif
+		if (head->header_bytes != sizeof(*head)) {
+			printk(KERN_DEBUG "Header bytes of %u are incorrect.\n",
+				head->header_bytes);
+			continue;
+		}
+		if (count_lb_records(head) != head->table_entries) {
+			printk(KERN_DEBUG "Bad record count: %u.\n",
+				head->table_entries);
+			continue;
+		}
+		if (compute_checksum(head, sizeof(*head)) != 0) {
+			printk(KERN_DEBUG "Bad header checksum.\n");
+			continue;
+		}
+		recs = (struct lb_record *)__v_offset(addr, sizeof(*head));
+		if (compute_checksum(recs, head->table_bytes)
+		    != head->table_checksum) {
+			printk(KERN_DEBUG "Bad table checksum: %#04x.\n",
+				head->table_checksum);
+			continue;
+		}
+		printk(KERN_DEBUG "Found coreboot table at 0x%p.\n", addr);
+		return head;
+
+	};
+
+	return 0;
+}
+
+static void find_mainboard(struct lb_record *ptr)
+{
+	struct lb_mainboard *rec = (struct lb_mainboard *)ptr;
+
+#ifdef DEBUG
+	dump_lb_mainboard(rec);
+#endif
+
+	strlcpy(lb_vendor, &rec->strings[rec->vendor_idx], sizeof(lb_vendor));
+	strlcpy(lb_part, &rec->strings[rec->part_number_idx], sizeof(lb_part));
+}
+
+static struct lb_record *next_record(struct lb_record *rec)
+{
+	return (struct lb_record *)__v_offset(rec, rec->size);
+}
+
+static void search_lb_records(struct lb_record *rec, struct lb_record *last)
+{
+	struct lb_record *next;
+
+	for (next = next_record(rec); (rec < last) && (next <= last); rec = next) {
+		next = next_record(rec);
+		if (rec->tag == LB_TAG_MAINBOARD) {
+			find_mainboard(rec);
+			break;
+		}
+	}
+}
+
+
+#define BYTES_TO_MAP (1024*1024)
+struct lb_record *coreboot_init(void)
+{
+	phys_addr_t start;
+	void *addr, *remap;
+	struct lb_header *lb_table;
+	struct lb_record *rec, *last;
+
+	remap = NULL;
+
+	start = 0x0;
+ 	addr = phys_to_virt(start);
+
+	lb_table = find_lb_table(addr, addr + 0x1000);
+	if (!lb_table) {
+		start = 0xf0000;
+		addr = phys_to_virt(start);
+		lb_table = find_lb_table(addr, addr + BYTES_TO_MAP);
+	}
+	if (lb_table) {
+		struct lb_forward *forward = (struct lb_forward *)
+			__v_offset(lb_table, lb_table->header_bytes);
+
+		if (forward->tag == LB_TAG_FORWARD) {
+			int mapped = 0;
+			phys_addr_t forward_phys = forward->forward;
+			phys_addr_t upper = iomem_map_find_boundary(forward_phys, &mapped);
+			unsigned extent = BYTES_TO_MAP;
+
+#ifdef DEBUG
+			dump_lb_forward(forward);
+#endif
+
+			if (!upper)
+				goto no_region;	/* not a valid address */
+
+			if (mapped) {
+				addr = phys_to_virt(forward_phys);
+			} else {
+				phys_addr_t base = ppage_base(forward_phys);
+
+				upper += 1;
+				if (base + extent > upper)
+					extent = upper - base;
+
+				remap = ioremap(base, extent);
+				if (!remap) {
+					printk(KERN_DEBUG "Couldn't map %x, %u.\n",
+						base, extent);
+					return NULL;
+				}
+					
+				addr = remap + ppage_offset(forward_phys);
+			}
+
+			lb_table = find_lb_table(addr, __v_offset(vpage_base(addr), extent));
+		}
+	}
+
+	if (!lb_table) {
+no_region:
+		printk(KERN_DEBUG "No coreboot table found.\n");
+		return NULL;
+	}
+
+	printk(KERN_DEBUG "coreboot table found at 0x%x.\n", virt_to_phys(lb_table));
+
+	rec = (struct lb_record *)__v_offset(lb_table, lb_table->header_bytes);
+	last = (struct lb_record *)__v_offset(rec, lb_table->table_bytes);
+
+#ifdef DEBUG
+	dump_lb_header(lb_table);
+#endif
+	search_lb_records(rec, last);
+
+	if (remap) {
+		iounmap(remap);
+	}
+
+	return rec;
+}
+EXPORT_SYMBOL(coreboot_init);
+
+const char *coreboot_vendor(void)
+{
+	return lb_vendor;
+}
+EXPORT_SYMBOL(coreboot_vendor);
+
+const char *coreboot_part(void)
+{
+	return lb_part;
+}
+EXPORT_SYMBOL(coreboot_part);
+
-- 
1.7.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
