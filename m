Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 054DC8E0004
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 17:01:06 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n4-v6so3046770plk.7
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:01:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h76-v6si23286604pfk.329.2018.09.19.14.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 14:01:03 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 4/7] tools/gup_benchmark: Allow user specified file
Date: Wed, 19 Sep 2018 15:02:47 -0600
Message-Id: <20180919210250.28858-5-keith.busch@intel.com>
In-Reply-To: <20180919210250.28858-1-keith.busch@intel.com>
References: <20180919210250.28858-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

The gup benchmark by default maps anonymous memory. This patch allows a
user to specify a file to map, providing a means to test various
file backings, like device and filesystem DAX.

Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 tools/testing/selftests/vm/gup_benchmark.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
index b2082df8beb4..f2c99e2436f8 100644
--- a/tools/testing/selftests/vm/gup_benchmark.c
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -33,9 +33,12 @@ int main(int argc, char **argv)
 	unsigned long size = 128 * MB;
 	int i, fd, opt, nr_pages = 1, thp = -1, repeats = 1, write = 0;
 	int cmd = GUP_FAST_BENCHMARK;
+	int file_map = -1;
+	int flags = MAP_ANONYMOUS | MAP_PRIVATE;
+	char *file = NULL;
 	char *p;
 
-	while ((opt = getopt(argc, argv, "m:r:n:tTLU")) != -1) {
+	while ((opt = getopt(argc, argv, "m:r:n:f:tTLU")) != -1) {
 		switch (opt) {
 		case 'm':
 			size = atoi(optarg) * MB;
@@ -61,11 +64,22 @@ int main(int argc, char **argv)
 		case 'w':
 			write = 1;
 			break;
+		case 'f':
+			file = optarg;
+			flags &= ~(MAP_PRIVATE | MAP_ANONYMOUS);
+			flags |= MAP_SHARED;
+			break;
 		default:
 			return -1;
 		}
 	}
 
+	if (file) {
+		file_map = open(file, O_RDWR|O_CREAT);
+		if (file_map < 0)
+			perror("open"), exit(file_map);
+	}
+
 	gup.nr_pages_per_call = nr_pages;
 	gup.flags = write;
 
@@ -73,8 +87,7 @@ int main(int argc, char **argv)
 	if (fd == -1)
 		perror("open"), exit(1);
 
-	p = mmap(NULL, size, PROT_READ | PROT_WRITE,
-			MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
+	p = mmap(NULL, size, PROT_READ | PROT_WRITE, flags, file_map, 0);
 	if (p == MAP_FAILED)
 		perror("mmap"), exit(1);
 	gup.addr = (unsigned long)p;
-- 
2.14.4
