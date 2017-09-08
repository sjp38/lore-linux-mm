Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC4FB6B04CC
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 17:56:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v82so6792483pgb.5
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 14:56:54 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s66si2151974pfj.26.2017.09.08.14.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 14:56:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: Add infrastructure for get_user_pages_fast() benchmarking
Date: Sat,  9 Sep 2017 00:56:02 +0300
Message-Id: <20170908215603.9189-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170908215603.9189-1-kirill.shutemov@linux.intel.com>
References: <20170908215603.9189-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, Thorsten Leemhuis <regressions@leemhuis.info>, Jonathan Corbet <corbet@lwn.net>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Performance of get_user_pages_fast() is critical for some workloads, but
it's tricky to test it directly.

This patch provides /sys/kernel/debug/gup_benchmark that helps with
testing performance of it.

See tools/testing/selftests/vm/gup_benchmark.c for userspace
counterpart.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/Kconfig                                 |   9 +++
 mm/Makefile                                |   1 +
 mm/gup_benchmark.c                         | 100 +++++++++++++++++++++++++++++
 tools/testing/selftests/vm/Makefile        |   1 +
 tools/testing/selftests/vm/gup_benchmark.c |  91 ++++++++++++++++++++++++++
 5 files changed, 202 insertions(+)
 create mode 100644 mm/gup_benchmark.c
 create mode 100644 tools/testing/selftests/vm/gup_benchmark.c

diff --git a/mm/Kconfig b/mm/Kconfig
index 0ded10a22639..97eda34b9a81 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -704,3 +704,12 @@ config PERCPU_STATS
 	  This feature collects and exposes statistics via debugfs. The
 	  information includes global and per chunk statistics, which can
 	  be used to help understand percpu memory usage.
+
+config GUP_BENCHMARK
+	bool "Enable infrastructure for get_user_pages_fast() benchmarking"
+	default n
+	help
+	  Provides /sys/kernel/debug/gup_benchmark that helps with testing
+	  performance of get_user_pages_fast().
+
+	  See tools/testing/selftests/vm/gup_benchmark.c
diff --git a/mm/Makefile b/mm/Makefile
index 411bd24d4a7c..2f788a5970f8 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -104,3 +104,4 @@ obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
 obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
+obj-$(CONFIG_GUP_BENCHMARK) += gup_benchmark.o
diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
new file mode 100644
index 000000000000..5c8e2abeaa15
--- /dev/null
+++ b/mm/gup_benchmark.c
@@ -0,0 +1,100 @@
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/ktime.h>
+#include <linux/debugfs.h>
+
+#define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
+
+struct gup_benchmark {
+	__u64 delta_usec;
+	__u64 addr;
+	__u64 size;
+	__u32 nr_pages_per_call;
+	__u32 flags;
+};
+
+static int __gup_benchmark_ioctl(unsigned int cmd,
+		struct gup_benchmark *gup)
+{
+	ktime_t start_time, end_time;
+	unsigned long i, nr, nr_pages, addr, next;
+	struct page **pages;
+
+	nr_pages = gup->size / PAGE_SIZE;
+	pages = kvmalloc(sizeof(void *) * nr_pages, GFP_KERNEL);
+	if (!pages)
+		return -ENOMEM;
+
+	i = 0;
+	nr = gup->nr_pages_per_call;
+	start_time = ktime_get();
+	for (addr = gup->addr; addr < gup->addr + gup->size; addr = next) {
+		if (nr != gup->nr_pages_per_call)
+			break;
+
+		next = addr + nr * PAGE_SIZE;
+		if (next > gup->addr + gup->size) {
+			next = gup->addr + gup->size;
+			nr = (next - addr) / PAGE_SIZE;
+		}
+
+		nr = get_user_pages_fast(addr, nr, gup->flags & 1, pages + i);
+		i += nr;
+	}
+	end_time = ktime_get();
+
+	gup->delta_usec = ktime_us_delta(end_time, start_time);
+	gup->size = addr - gup->addr;
+
+	for (i = 0; i < nr_pages; i++) {
+		if (!pages[i])
+			break;
+		put_page(pages[i]);
+	}
+
+	kvfree(pages);
+	return 0;
+}
+
+static long gup_benchmark_ioctl(struct file *filep, unsigned int cmd,
+		unsigned long arg)
+{
+	struct gup_benchmark gup;
+	int ret;
+
+	if (cmd != GUP_FAST_BENCHMARK)
+		return -EINVAL;
+
+	if (copy_from_user(&gup, (void __user *)arg, sizeof(gup)))
+		return -EFAULT;
+
+	ret = __gup_benchmark_ioctl(cmd, &gup);
+	if (ret)
+		return ret;
+
+	if (copy_to_user((void __user *)arg, &gup, sizeof(gup)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static const struct file_operations gup_benchmark_fops = {
+	.open = nonseekable_open,
+	.unlocked_ioctl = gup_benchmark_ioctl,
+};
+
+static int gup_benchmark_init(void)
+{
+	void *ret;
+
+	ret = debugfs_create_file_unsafe("gup_benchmark", 0600, NULL, NULL,
+			&gup_benchmark_fops);
+	if (!ret)
+		pr_warn("Failed to create gup_benchmark in debugfs");
+
+	return 0;
+}
+
+late_initcall(gup_benchmark_init);
diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index cbb29e41ef2b..084212d9e3e2 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -17,6 +17,7 @@ TEST_GEN_FILES += transhuge-stress
 TEST_GEN_FILES += userfaultfd
 TEST_GEN_FILES += mlock-random-test
 TEST_GEN_FILES += virtual_address_range
+TEST_GEN_FILES += gup_benchmark
 
 TEST_PROGS := run_vmtests
 
diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
new file mode 100644
index 000000000000..36df55132036
--- /dev/null
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -0,0 +1,91 @@
+#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <sys/prctl.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+
+#include <linux/types.h>
+
+#define MB (1UL << 20)
+#define PAGE_SIZE sysconf(_SC_PAGESIZE)
+
+#define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
+
+struct gup_benchmark {
+	__u64 delta_usec;
+	__u64 addr;
+	__u64 size;
+	__u32 nr_pages_per_call;
+	__u32 flags;
+};
+
+int main(int argc, char **argv)
+{
+	struct gup_benchmark gup;
+	unsigned long size = 128 * MB;
+	int i, fd, opt, nr_pages = 1, thp = -1, repeats = 1, write = 0;
+	char *p;
+
+	while ((opt = getopt(argc, argv, "m:r:n:tT")) != -1) {
+		switch (opt) {
+		case 'm':
+			size = atoi(optarg) * MB;
+			break;
+		case 'r':
+			repeats = atoi(optarg);
+			break;
+		case 'n':
+			nr_pages = atoi(optarg);
+			break;
+		case 't':
+			thp = 1;
+			break;
+		case 'T':
+			thp = 0;
+			break;
+		case 'w':
+			write = 1;
+		default:
+			return -1;
+		}
+	}
+
+	gup.nr_pages_per_call = nr_pages;
+	gup.flags = write;
+
+	fd = open("/sys/kernel/debug/gup_benchmark", O_RDWR);
+	if (fd == -1)
+		perror("open"), exit(1);
+
+	p = mmap(NULL, size, PROT_READ | PROT_WRITE,
+			MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
+	if (p == MAP_FAILED)
+		perror("mmap"), exit(1);
+	gup.addr = (unsigned long)p;
+
+	if (thp == 1)
+		madvise(p, size, MADV_HUGEPAGE);
+	else if (thp == 0)
+		madvise(p, size, MADV_NOHUGEPAGE);
+
+	for (; (unsigned long)p < gup.addr + size; p += PAGE_SIZE)
+		p[0] = 0;
+
+	for (i = 0; i < repeats; i++) {
+		gup.size = size;
+		if (ioctl(fd, GUP_FAST_BENCHMARK, &gup))
+			perror("ioctl"), exit(1);
+
+		printf("Time: %lld us", gup.delta_usec);
+		if (gup.size != size)
+			printf(", truncated (size: %lld)", gup.size);
+		printf("\n");
+	}
+
+	return 0;
+}
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
