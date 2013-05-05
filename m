Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 7FA5E6B0197
	for <linux-mm@kvack.org>; Sun,  5 May 2013 11:44:31 -0400 (EDT)
Received: by mail-da0-f51.google.com with SMTP id h15so1416029dan.24
        for <linux-mm@kvack.org>; Sun, 05 May 2013 08:44:30 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 2/3] memcg: check more strictly to avoid PAGE_ALIGN wrapped to 0
Date: Sun,  5 May 2013 23:43:10 +0800
Message-Id: <1367768590-4403-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, mhocko@suse.cz, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

Since PAGE_ALIGN is aligning up(the next page boundary), this can
prevent input values wrapped to 0 and cause strange result to user.

This patch also rename the second arg of
res_counter_memparse_write_strategy() to 'resp' and add a local
variable 'res' to save the too often dereferences. Thanks Andrew
for pointing it out!


Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Reported-by: Li Wenpeng <xingke.lwp@taobao.com>
---
 kernel/res_counter.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 3f0417f..be8ddda 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -178,23 +178,29 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
 #endif
 
 int res_counter_memparse_write_strategy(const char *buf,
-					unsigned long long *res)
+					unsigned long long *resp)
 {
 	char *end;
+	unsigned long long res;
 
 	/* return RES_COUNTER_MAX(unlimited) if "-1" is specified */
 	if (*buf == '-') {
-		*res = simple_strtoull(buf + 1, &end, 10);
-		if (*res != 1 || *end != '\0')
+		res = simple_strtoull(buf + 1, &end, 10);
+		if (res != 1 || *end != '\0')
 			return -EINVAL;
-		*res = RES_COUNTER_MAX;
+		*resp = RES_COUNTER_MAX;
 		return 0;
 	}
 
-	*res = memparse(buf, &end);
+	res = memparse(buf, &end);
 	if (*end != '\0')
 		return -EINVAL;
 
-	*res = PAGE_ALIGN(*res);
+	if (PAGE_ALIGN(res) >= res)
+		res = PAGE_ALIGN(res);
+	else
+		res = RES_COUNTER_MAX; /* avoid PAGE_ALIGN wrapping to zero */
+
+	*resp = res;
 	return 0;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
