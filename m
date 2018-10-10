Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5068C6B000E
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 16:00:21 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id i189-v6so4590527pge.6
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 13:00:21 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e7-v6si26111287pgn.82.2018.10.10.13.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 13:00:20 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 5/6] tools/gup_benchmark: Add MAP_SHARED option
Date: Wed, 10 Oct 2018 13:56:04 -0600
Message-Id: <20181010195605.10689-5-keith.busch@intel.com>
In-Reply-To: <20181010195605.10689-1-keith.busch@intel.com>
References: <20181010195605.10689-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Keith Busch <keith.busch@intel.com>

This patch adds a new benchmark option, -S, to request MAP_SHARED. This
can be used to compare with MAP_PRIVATE, or for files that require this
option, like dax.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 tools/testing/selftests/vm/gup_benchmark.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
index b675a3d60975..24528b54549d 100644
--- a/tools/testing/selftests/vm/gup_benchmark.c
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -32,11 +32,11 @@ int main(int argc, char **argv)
 	struct gup_benchmark gup;
 	unsigned long size = 128 * MB;
 	int i, fd, filed, opt, nr_pages = 1, thp = -1, repeats = 1, write = 0;
-	int cmd = GUP_FAST_BENCHMARK;
+	int cmd = GUP_FAST_BENCHMARK, flags = MAP_PRIVATE;
 	char *file = "/dev/zero";
 	char *p;
 
-	while ((opt = getopt(argc, argv, "m:r:n:f:tTLU")) != -1) {
+	while ((opt = getopt(argc, argv, "m:r:n:f:tTLUS")) != -1) {
 		switch (opt) {
 		case 'm':
 			size = atoi(optarg) * MB;
@@ -65,6 +65,10 @@ int main(int argc, char **argv)
 		case 'f':
 			file = optarg;
 			break;
+		case 'S':
+			flags &= ~MAP_PRIVATE;
+			flags |= MAP_SHARED;
+			break;
 		default:
 			return -1;
 		}
@@ -81,7 +85,7 @@ int main(int argc, char **argv)
 	if (fd == -1)
 		perror("open"), exit(1);
 
-	p = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE, filed, 0);
+	p = mmap(NULL, size, PROT_READ | PROT_WRITE, flags, filed, 0);
 	if (p == MAP_FAILED)
 		perror("mmap"), exit(1);
 	gup.addr = (unsigned long)p;
-- 
2.14.4
