Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 205F56B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 23:25:57 -0400 (EDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH v2 4/4] memcg: reduce function dereference
Date: Fri, 2 Aug 2013 11:25:33 +0800
Message-ID: <1375413933-10732-5-git-send-email-h.huangqiang@huawei.com>
In-Reply-To: <1375413933-10732-1-git-send-email-h.huangqiang@huawei.com>
References: <1375413933-10732-1-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, lizefan@huawei.com, handai.szj@taobao.com, handai.szj@gmail.com, jeff.liu@oracle.com, nishimura@mxp.nes.nec.co.jp, cgroups@vger.kernel.org, linux-mm@kvack.org

From: Sha Zhengju <handai.szj@taobao.com>

This function dereferences res far too often, so optimize it.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 kernel/res_counter.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 085d3ae..4aa8a30 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -178,27 +178,30 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
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
 
-	if (PAGE_ALIGN(*res) >= *res)
-		*res = PAGE_ALIGN(*res);
+	if (PAGE_ALIGN(res) >= res)
+		res = PAGE_ALIGN(res);
 	else
-		*res = RES_COUNTER_MAX;
+		res = RES_COUNTER_MAX;
+
+	*resp = res;
 
 	return 0;
 }
-- 
1.8.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
