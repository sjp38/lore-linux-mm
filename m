Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC83C6B026A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 16:00:21 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y86-v6so5934615pff.6
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 13:00:21 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e7-v6si26111287pgn.82.2018.10.10.13.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 13:00:20 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 4/6] tools/gup_benchmark: Allow user specified file
Date: Wed, 10 Oct 2018 13:56:03 -0600
Message-Id: <20181010195605.10689-4-keith.busch@intel.com>
In-Reply-To: <20181010195605.10689-1-keith.busch@intel.com>
References: <20181010195605.10689-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Keith Busch <keith.busch@intel.com>

This patch allows a user to specify a file to map by adding a new option,
'-f', providing a means to test various file backings.

If not specified, the benchmark will use a private mapping of /dev/zero,
which produces an anonymous mapping as before.

Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 tools/testing/selftests/vm/gup_benchmark.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
index b2082df8beb4..b675a3d60975 100644
--- a/tools/testing/selftests/vm/gup_benchmark.c
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -31,11 +31,12 @@ int main(int argc, char **argv)
 {
 	struct gup_benchmark gup;
 	unsigned long size = 128 * MB;
-	int i, fd, opt, nr_pages = 1, thp = -1, repeats = 1, write = 0;
+	int i, fd, filed, opt, nr_pages = 1, thp = -1, repeats = 1, write = 0;
 	int cmd = GUP_FAST_BENCHMARK;
+	char *file = "/dev/zero";
 	char *p;
 
-	while ((opt = getopt(argc, argv, "m:r:n:tTLU")) != -1) {
+	while ((opt = getopt(argc, argv, "m:r:n:f:tTLU")) != -1) {
 		switch (opt) {
 		case 'm':
 			size = atoi(optarg) * MB;
@@ -61,11 +62,18 @@ int main(int argc, char **argv)
 		case 'w':
 			write = 1;
 			break;
+		case 'f':
+			file = optarg;
+			break;
 		default:
 			return -1;
 		}
 	}
 
+	filed = open(file, O_RDWR|O_CREAT);
+	if (filed < 0)
+		perror("open"), exit(filed);
+
 	gup.nr_pages_per_call = nr_pages;
 	gup.flags = write;
 
@@ -73,8 +81,7 @@ int main(int argc, char **argv)
 	if (fd == -1)
 		perror("open"), exit(1);
 
-	p = mmap(NULL, size, PROT_READ | PROT_WRITE,
-			MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
+	p = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE, filed, 0);
 	if (p == MAP_FAILED)
 		perror("mmap"), exit(1);
 	gup.addr = (unsigned long)p;
-- 
2.14.4
