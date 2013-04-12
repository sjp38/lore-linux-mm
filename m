Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8FC426B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 02:39:45 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id mc17so1263676pbc.14
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 23:39:44 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH] memcg: Check more strictly to avoid ULLONG overflow by PAGE_ALIGN
Date: Fri, 12 Apr 2013 14:39:23 +0800
Message-Id: <1365748763-4350-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

While writing memory.limit_in_bytes, a confusing result may happen:

$ mkdir /memcg/test
$ cat /memcg/test/memory.limit_in_bytes
9223372036854775807
$ cat /memcg/test/memory.memsw.limit_in_bytes
9223372036854775807
$ echo 18446744073709551614 > /memcg/test/memory.limit_in_bytes
$ cat /memcg/test/memory.limit_in_bytes
0

Strangely, the write successed and reset the limit to 0.
The patch corrects RESOURCE_MAX and fixes this kind of overflow.


Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Reported-by: Li Wenpeng < xingke.lwp@taobao.com>
Cc: Jie Liu <jeff.liu@oracle.com>
---
 include/linux/res_counter.h |    2 +-
 kernel/res_counter.c        |    8 +++++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index c230994..c2f01fc 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -54,7 +54,7 @@ struct res_counter {
 	struct res_counter *parent;
 };
 
-#define RESOURCE_MAX (unsigned long long)LLONG_MAX
+#define RESOURCE_MAX (unsigned long long)ULLONG_MAX
 
 /**
  * Helpers to interact with userspace
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index ff55247..6c35310 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -195,6 +195,12 @@ int res_counter_memparse_write_strategy(const char *buf,
 	if (*end != '\0')
 		return -EINVAL;
 
-	*res = PAGE_ALIGN(*res);
+	/* Since PAGE_ALIGN is aligning up(the next page boundary),
+	 * check the left space to avoid overflow to 0. */
+	if (RESOURCE_MAX - *res < PAGE_SIZE - 1)
+		*res = RESOURCE_MAX;
+	else
+		*res = PAGE_ALIGN(*res);
+
 	return 0;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
