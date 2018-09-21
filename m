Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 065328E0028
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:40:09 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id h1-v6so2000338pld.21
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:40:08 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w64-v6si8510159pgb.476.2018.09.21.15.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 15:40:07 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 4/6] tools/gup_benchmark: Allow user specified file
Date: Fri, 21 Sep 2018 16:39:54 -0600
Message-Id: <20180921223956.3485-5-keith.busch@intel.com>
In-Reply-To: <20180921223956.3485-1-keith.busch@intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
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
