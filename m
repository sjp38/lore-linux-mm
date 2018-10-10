Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 93C2C6B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 15:59:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id v7-v6so4735286plo.23
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 12:59:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 144-v6si23190413pgh.282.2018.10.10.12.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 12:59:46 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 2/6] mm/gup_benchmark: Add additional pinning methods
Date: Wed, 10 Oct 2018 13:56:01 -0600
Message-Id: <20181010195605.10689-2-keith.busch@intel.com>
In-Reply-To: <20181010195605.10689-1-keith.busch@intel.com>
References: <20181010195605.10689-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Keith Busch <keith.busch@intel.com>

This patch provides new gup benchmark ioctl commands to run different
user page pinning methods, get_user_pages_longterm and get_user_pages,
in addition to the existing get_user_pages_fast.

Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 mm/gup_benchmark.c                         | 28 ++++++++++++++++++++++++++--
 tools/testing/selftests/vm/gup_benchmark.c | 13 +++++++++++--
 2 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index b344abd6e8e4..ab103a018627 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -6,6 +6,8 @@
 #include <linux/debugfs.h>
 
 #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
+#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
+#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
 
 struct gup_benchmark {
 	__u64 get_delta_usec;
@@ -42,7 +44,23 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 			nr = (next - addr) / PAGE_SIZE;
 		}
 
-		nr = get_user_pages_fast(addr, nr, gup->flags & 1, pages + i);
+		switch (cmd) {
+		case GUP_FAST_BENCHMARK:
+			nr = get_user_pages_fast(addr, nr, gup->flags & 1,
+						 pages + i);
+			break;
+		case GUP_LONGTERM_BENCHMARK:
+			nr = get_user_pages_longterm(addr, nr, gup->flags & 1,
+						     pages + i, NULL);
+			break;
+		case GUP_BENCHMARK:
+			nr = get_user_pages(addr, nr, gup->flags & 1, pages + i,
+					    NULL);
+			break;
+		default:
+			return -1;
+		}
+
 		if (nr <= 0)
 			break;
 		i += nr;
@@ -71,8 +89,14 @@ static long gup_benchmark_ioctl(struct file *filep, unsigned int cmd,
 	struct gup_benchmark gup;
 	int ret;
 
-	if (cmd != GUP_FAST_BENCHMARK)
+	switch (cmd) {
+	case GUP_FAST_BENCHMARK:
+	case GUP_LONGTERM_BENCHMARK:
+	case GUP_BENCHMARK:
+		break;
+	default:
 		return -EINVAL;
+	}
 
 	if (copy_from_user(&gup, (void __user *)arg, sizeof(gup)))
 		return -EFAULT;
diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
index bdcb97acd0ac..c2f785ded9b9 100644
--- a/tools/testing/selftests/vm/gup_benchmark.c
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -15,6 +15,8 @@
 #define PAGE_SIZE sysconf(_SC_PAGESIZE)
 
 #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
+#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
+#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
 
 struct gup_benchmark {
 	__u64 get_delta_usec;
@@ -30,9 +32,10 @@ int main(int argc, char **argv)
 	struct gup_benchmark gup;
 	unsigned long size = 128 * MB;
 	int i, fd, opt, nr_pages = 1, thp = -1, repeats = 1, write = 0;
+	int cmd = GUP_FAST_BENCHMARK;
 	char *p;
 
-	while ((opt = getopt(argc, argv, "m:r:n:tT")) != -1) {
+	while ((opt = getopt(argc, argv, "m:r:n:tTLU")) != -1) {
 		switch (opt) {
 		case 'm':
 			size = atoi(optarg) * MB;
@@ -49,6 +52,12 @@ int main(int argc, char **argv)
 		case 'T':
 			thp = 0;
 			break;
+		case 'L':
+			cmd = GUP_LONGTERM_BENCHMARK;
+			break;
+		case 'U':
+			cmd = GUP_BENCHMARK;
+			break;
 		case 'w':
 			write = 1;
 		default:
@@ -79,7 +88,7 @@ int main(int argc, char **argv)
 
 	for (i = 0; i < repeats; i++) {
 		gup.size = size;
-		if (ioctl(fd, GUP_FAST_BENCHMARK, &gup))
+		if (ioctl(fd, cmd, &gup))
 			perror("ioctl"), exit(1);
 
 		printf("Time: get:%lld put:%lld us", gup.get_delta_usec,
-- 
2.14.4
