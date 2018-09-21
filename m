Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2E8E8E0025
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:40:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d10-v6so6637744pll.22
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:40:08 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w64-v6si8510159pgb.476.2018.09.21.15.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 15:40:07 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 2/6] mm/gup_benchmark: Add additional pinning methods
Date: Fri, 21 Sep 2018 16:39:52 -0600
Message-Id: <20180921223956.3485-3-keith.busch@intel.com>
In-Reply-To: <20180921223956.3485-1-keith.busch@intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

This patch provides new gup benchmark ioctl commands to run different
user page pinning methods, get_user_pages_longterm and get_user_pages,
in addition to the existing get_user_pages_fast.

Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 mm/gup_benchmark.c                         | 28 ++++++++++++++++++++++++++--
 tools/testing/selftests/vm/gup_benchmark.c | 13 +++++++++++--
 2 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 76cd35e477af..e6d9ce001ffa 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -6,6 +6,8 @@
 #include <linux/debugfs.h>
 
 #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
+#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
+#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
 
 struct gup_benchmark {
 	__u64 get_delta_usec;
@@ -41,7 +43,23 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
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
@@ -70,8 +88,14 @@ static long gup_benchmark_ioctl(struct file *filep, unsigned int cmd,
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
