Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 606A68E0025
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:40:08 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t26-v6so7146854pfh.0
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:40:08 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w64-v6si8510159pgb.476.2018.09.21.15.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 15:40:06 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 1/6] mm/gup_benchmark: Time put_page
Date: Fri, 21 Sep 2018 16:39:51 -0600
Message-Id: <20180921223956.3485-2-keith.busch@intel.com>
In-Reply-To: <20180921223956.3485-1-keith.busch@intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

We'd like to measure time to unpin user pages, so this adds a second
benchmark timer on put_page, separate from get_page.

Adding the field will breaks this ioctl ABI, but should be okay since
this an in-tree kernel selftest.

Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 mm/gup_benchmark.c                         | 8 ++++++--
 tools/testing/selftests/vm/gup_benchmark.c | 6 ++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 6a473709e9b6..76cd35e477af 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -8,7 +8,8 @@
 #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
 
 struct gup_benchmark {
-	__u64 delta_usec;
+	__u64 get_delta_usec;
+	__u64 put_delta_usec;
 	__u64 addr;
 	__u64 size;
 	__u32 nr_pages_per_call;
@@ -47,14 +48,17 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 	}
 	end_time = ktime_get();
 
-	gup->delta_usec = ktime_us_delta(end_time, start_time);
+	gup->get_delta_usec = ktime_us_delta(end_time, start_time);
 	gup->size = addr - gup->addr;
 
+	start_time = ktime_get();
 	for (i = 0; i < nr_pages; i++) {
 		if (!pages[i])
 			break;
 		put_page(pages[i]);
 	}
+	end_time = ktime_get();
+	gup->put_delta_usec = ktime_us_delta(end_time, start_time);
 
 	kvfree(pages);
 	return 0;
diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
index 36df55132036..bdcb97acd0ac 100644
--- a/tools/testing/selftests/vm/gup_benchmark.c
+++ b/tools/testing/selftests/vm/gup_benchmark.c
@@ -17,7 +17,8 @@
 #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
 
 struct gup_benchmark {
-	__u64 delta_usec;
+	__u64 get_delta_usec;
+	__u64 put_delta_usec;
 	__u64 addr;
 	__u64 size;
 	__u32 nr_pages_per_call;
@@ -81,7 +82,8 @@ int main(int argc, char **argv)
 		if (ioctl(fd, GUP_FAST_BENCHMARK, &gup))
 			perror("ioctl"), exit(1);
 
-		printf("Time: %lld us", gup.delta_usec);
+		printf("Time: get:%lld put:%lld us", gup.get_delta_usec,
+			gup.put_delta_usec);
 		if (gup.size != size)
 			printf(", truncated (size: %lld)", gup.size);
 		printf("\n");
-- 
2.14.4
