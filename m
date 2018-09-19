Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 408E58E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 17:01:04 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h65-v6so3333772pfk.18
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:01:04 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h76-v6si23286604pfk.329.2018.09.19.14.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 14:01:03 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 1/7] mm/gup_benchmark: Time put_page
Date: Wed, 19 Sep 2018 15:02:44 -0600
Message-Id: <20180919210250.28858-2-keith.busch@intel.com>
In-Reply-To: <20180919210250.28858-1-keith.busch@intel.com>
References: <20180919210250.28858-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

We'd like to measure time to unpin user pages, so this adds a second
benchmark timer on put_page, separate from get_page.

This will break ABI on this ioctl, but being an in-kernel benchmark may
be acceptable.

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
