Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D29CB6B0253
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 12:04:24 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id b205so127377583wmb.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 09:04:24 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id g5si27426802wmf.51.2016.02.21.09.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 09:04:23 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id c200so140074903wme.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 09:04:23 -0800 (PST)
Message-ID: <56C9EE14.9090003@plexistor.com>
Date: Sun, 21 Feb 2016 19:04:20 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 1/2] mmap: Define a new MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>
In-Reply-To: <56C9EDCF.8010007@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Chinner <david@fromorbit.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>


In dax.c we go to great length to keep track of write
faulted pages, so on m/fsync time we can cl_flush all these
"dirty" pages, so they are durable.

This is heavy on locking and resources and slows down
write-mmap performance considerably.

But some applications might already be aware of PMEM and
might use the fast movnt instructions to directly persist
to pmem storage bypassing CPU caches.

For these applications we define a new MAP_PMEM_AWARE mmap
flag.

In a later patch we use this flag in fs/dax.c so to optimize
for these applications.

NOTE: In current code we also want/need for the vma to
carry this flag so a new VM_PMEM_AWARE flag is also defined
and do_mmap() will translate between the constants.

NOTE2: vm_flags has already exhausted the 32 bits, but there
was a hole left at value 0x00800000
(After VM_HUGETLB and before VM_ARCH_1)
I hope this does not step on anyone's toes?

CC: Dan Williams <dan.j.williams@intel.com>
CC: Ross Zwisler <ross.zwisler@linux.intel.com>
CC: Matthew Wilcox <willy@linux.intel.com>
CC: linux-nvdimm <linux-nvdimm@ml01.01.org>
CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
CC: Oleg Nesterov <oleg@redhat.com>
CC: Mel Gorman <mgorman@suse.de>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: linux-mm@kvack.org (open list:MEMORY MANAGEMENT)

Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 include/linux/mm.h              | 1 +
 include/uapi/asm-generic/mman.h | 1 +
 mm/mmap.c                       | 2 ++
 3 files changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 376f373..fe992c0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -155,6 +155,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
+#define VM_PMEM_AWARE	0x00800000	/* Caries MAP_PMEM_AWARE */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_ARCH_2	0x02000000
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 7162cd4..0dc14d7 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -12,6 +12,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_PMEM_AWARE	0x80000		/* dax.c: Do not cl_flush dirty pages */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 76d1ec2..5ebc525 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1402,6 +1402,8 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		if (file && is_file_hugepages(file))
 			vm_flags |= VM_NORESERVE;
 	}
+	if (flags & MAP_PMEM_AWARE)
+		vm_flags |= VM_PMEM_AWARE;
 
 	addr = mmap_region(file, addr, len, vm_flags, pgoff);
 	if (!IS_ERR_VALUE(addr) &&
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
