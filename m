Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 729526B0036
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 23:57:56 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so2021619pdj.29
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 20:57:56 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id bv2si16943763pbb.63.2014.06.05.20.57.53
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 20:57:55 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 1/2] mem-hotplug: Avoid illegal state prefixed with legal state when changing state of memory_block.
Date: Fri, 6 Jun 2014 11:58:53 +0800
Message-ID: <1402027134-14423-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1402027134-14423-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1402027134-14423-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org, toshi.kani@hp.com, tj@kernel.org, hpa@zytor.com, mingo@elte.hu, laijs@cn.fujitsu.com
Cc: isimatu.yasuaki@jp.fujitsu.com, hutao@cn.fujitsu.com, guz.fnst@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We use the following command to online a memory_block:

echo online|online_kernel|online_movable > /sys/devices/system/memory/memoryXXX/state

But, if we do the following:

echo online_fhsjkghfkd > /sys/devices/system/memory/memoryXXX/state

the block will also be onlined.

This is because the following code in store_mem_state() does not compare the whole string,
but only the prefix of the string.

store_mem_state()
{
	......
 328         if (!strncmp(buf, "online_kernel", min_t(int, count, 13)))

Here, only compare the first 13 letters of the string. If we give "online_kernelXXXXXX",
it will be recognized as online_kernel, which is incorrect.

 329                 online_type = ONLINE_KERNEL;
 330         else if (!strncmp(buf, "online_movable", min_t(int, count, 14)))

We have the same problem here,

 331                 online_type = ONLINE_MOVABLE;
 332         else if (!strncmp(buf, "online", min_t(int, count, 6)))

here,

(Here is more problematic. If we give online_movalbe, which is a typo of online_movable,
 it will be recognized as online without noticing the author.)

 333                 online_type = ONLINE_KEEP;
 334         else if (!strncmp(buf, "offline", min_t(int, count, 7)))

and here.

 335                 online_type = -1;
 336         else {
 337                 ret = -EINVAL;
 338                 goto err;
 339         }
	......
}

This patch fix this problem by using sysfs_streq() to compare the whole string.

Reported-by: Hu Tao <hutao@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---

change log v1 -> v2:
	Following Andrew's suggestion, use sysfs_streq() to compare the whole string
	so that we can simplify the code.

---
---
 drivers/base/memory.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index bece691..fa664b9 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -325,13 +325,13 @@ store_mem_state(struct device *dev,
 	if (ret)
 		return ret;
 
-	if (!strncmp(buf, "online_kernel", min_t(int, count, 13)))
+	if (sysfs_streq(buf, "online_kernel"))
 		online_type = ONLINE_KERNEL;
-	else if (!strncmp(buf, "online_movable", min_t(int, count, 14)))
+	else if (sysfs_streq(buf, "online_movable"))
 		online_type = ONLINE_MOVABLE;
-	else if (!strncmp(buf, "online", min_t(int, count, 6)))
+	else if (sysfs_streq(buf, "online"))
 		online_type = ONLINE_KEEP;
-	else if (!strncmp(buf, "offline", min_t(int, count, 7)))
+	else if (sysfs_streq(buf, "offline"))
 		online_type = -1;
 	else {
 		ret = -EINVAL;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
