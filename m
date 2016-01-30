Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 241A76B0253
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:29:19 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id g73so113930147ioe.3
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:29:19 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id qd10si1841728igb.33.2016.01.30.01.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:29:17 -0800 (PST)
Date: Sat, 30 Jan 2016 01:28:01 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-9babd5c8caa6e62c116efc3a64a09f65af4112b0@git.kernel.org>
Reply-To: linux-mm@kvack.org, rafael.j.wysocki@intel.com, toshi.kani@hpe.com,
        mcgrof@suse.com, hanjun.guo@linaro.org, jiang.liu@linux.intel.com,
        brgerst@gmail.com, hpa@zytor.com, torvalds@linux-foundation.org,
        bp@alien8.de, jsitnicki@gmail.com, toshi.kani@hp.com,
        tglx@linutronix.de, bp@suse.de, linux-kernel@vger.kernel.org,
        peterz@infradead.org, akpm@linux-foundation.org, luto@amacapital.net,
        mingo@kernel.org, dan.j.williams@intel.com, dvlasenk@redhat.com
In-Reply-To: <1453841853-11383-2-git-send-email-bp@alien8.de>
References: <1453841853-11383-2-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] resource: Add System RAM resource type
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: jsitnicki@gmail.com, toshi.kani@hp.com, bp@alien8.de, hpa@zytor.com, torvalds@linux-foundation.org, mcgrof@suse.com, jiang.liu@linux.intel.com, hanjun.guo@linaro.org, brgerst@gmail.com, rafael.j.wysocki@intel.com, linux-mm@kvack.org, toshi.kani@hpe.com, mingo@kernel.org, dan.j.williams@intel.com, dvlasenk@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, luto@amacapital.net, linux-kernel@vger.kernel.org, tglx@linutronix.de, bp@suse.de

Commit-ID:  9babd5c8caa6e62c116efc3a64a09f65af4112b0
Gitweb:     http://git.kernel.org/tip/9babd5c8caa6e62c116efc3a64a09f65af4112b0
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:17 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:56 +0100

resource: Add System RAM resource type

The IORESOURCE_MEM I/O resource type is used for all types of
memory-mapped ranges, ex. System RAM, System ROM, Video RAM,
Persistent Memory, PCI Bus, PCI MMCONFIG, ACPI Tables, IOAPIC,
reserved, and so on.

This requires walk_system_ram_range(), walk_system_ram_res(),
and region_intersects() to use strcmp() against string "System
RAM" to search for System RAM ranges in the iomem table, which
is inefficient. __ioremap_caller() and reserve_memtype() on x86,
for instance, call walk_system_ram_range() for every request to
check if a given range is in System RAM ranges.

However, adding a new I/O resource type for System RAM is not a
viable option, see [1]. There are approx. 3800 references to
IORESOURCE_MEM in the kernel/drivers, which makes it very
difficult to distinguish their usages between new type and
IORESOURCE_MEM.

The I/O resource types are also used by the PNP subsystem.
Therefore, introduce an extended I/O resource type,
IORESOURCE_SYSTEM_RAM, which consists of IORESOURCE_MEM and a
new modifier flag IORESOURCE_SYSRAM, see [2].

To keep the code 'if (resource_type(r) == IORESOURCE_MEM)' still
working for System RAM, resource_ext_type() is added for
extracting extended type bits.

Link[1]: http://lkml.kernel.org/r/1449168859.9855.54.camel@hpe.com
Link[2]: http://lkml.kernel.org/r/CA+55aFy4WQrWexC4u2LxX9Mw2NVoznw7p3Yh=iF4Xtf7zKWnRw@mail.gmail.com

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-2-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/ioport.h | 11 +++++++++++
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
