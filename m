Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2CB6B0011
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:55:54 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 202-v6so10634772ion.2
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 05:55:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s103-v6sor6214745ioe.11.2018.04.23.05.55.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 05:55:53 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 8/9] Preliminary self test for pmalloc rare write
Date: Mon, 23 Apr 2018 16:54:57 +0400
Message-Id: <20180423125458.5338-9-igor.stoppa@huawei.com>
In-Reply-To: <20180423125458.5338-1-igor.stoppa@huawei.com>
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net
Cc: labbott@redhat.com, linux-cc=david@fromorbit.com, --cc=rppt@linux.vnet.ibm.com, --security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>

Try to alter locked but modifiable pools.
The test neds some cleanup and expansion.
It is provided primarily as reference.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 mm/test_pmalloc.c | 75 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 75 insertions(+)

diff --git a/mm/test_pmalloc.c b/mm/test_pmalloc.c
index c8835207a400..e8e945e4a4a3 100644
--- a/mm/test_pmalloc.c
+++ b/mm/test_pmalloc.c
@@ -122,6 +122,80 @@ static void test_oovm(void)
 	pmalloc_destroy_pool(pool);
 }
 
+#define REGION_SIZE (PAGE_SIZE / 4)
+#define REGION_NUMBERS 12
+static inline void fill_region(char *addr, char c)
+{
+	size_t i;
+
+	for (i = 0; i < REGION_SIZE - 1; i++)
+		addr[i] = c;
+	addr[i] = '\0';
+}
+
+static inline void init_regions(char *array)
+{
+	size_t i;
+
+	for (i = 0; i < REGION_NUMBERS; i++)
+		fill_region(array + REGION_SIZE * i, i + 'A');
+}
+
+static inline void show_regions(char *array)
+{
+	size_t i;
+
+	for (i = 0; i < REGION_NUMBERS; i++)
+		pr_info("%s", array + REGION_SIZE * i);
+}
+
+static inline void init_big_injection(char *big_injection)
+{
+	size_t i;
+
+	for (i = 0; i < PAGE_SIZE * 3; i++)
+		big_injection[i] = 'X';
+}
+
+/* Verify rewritable feature. */
+static int test_rare_write(void)
+{
+	struct pmalloc_pool *pool;
+	char *array;
+	char injection[] = "123456789";
+	unsigned short size = sizeof(injection);
+	char *big_injection;
+
+
+	pr_notice("Test pmalloc_rare_write()");
+	pool = pmalloc_create_pool(PMALLOC_RW);
+	array = pzalloc(pool, REGION_SIZE * REGION_NUMBERS);
+	init_regions(array);
+	pmalloc_protect_pool(pool);
+	pr_info("------------------------------------------------------");
+	pmalloc_rare_write(pool, array, injection, size);
+	pmalloc_rare_write(pool, array + REGION_SIZE, injection, size);
+	pmalloc_rare_write(pool,
+			   array + 5 * REGION_SIZE / 2 - size / 2,
+			   injection, size);
+	pmalloc_rare_write(pool, array + 3 * REGION_SIZE - size / 2,
+			   injection, size);
+	show_regions(array);
+	pmalloc_destroy_pool(pool);
+	pr_info("------------------------------------------------------");
+	pool = pmalloc_create_pool(PMALLOC_RW);
+	array = pzalloc(pool, REGION_SIZE * REGION_NUMBERS);
+	init_regions(array);
+	pmalloc_protect_pool(pool);
+	big_injection = vmalloc(PAGE_SIZE * 3);
+	init_big_injection(big_injection);
+	pmalloc_rare_write(pool, array + REGION_SIZE / 2, big_injection,
+			   PAGE_SIZE * 2);
+	show_regions(array);
+	pr_info("------------------------------------------------------");
+	return 0;
+}
+
 /**
  * test_pmalloc()  -main entry point for running the test cases
  */
@@ -135,4 +209,5 @@ void test_pmalloc(void)
 		       test_is_pmalloc_object())))
 		return;
 	test_oovm();
+	test_rare_write();
 }
-- 
2.14.1
