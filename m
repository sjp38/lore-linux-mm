Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 51EBA6B0034
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 23:25:58 -0400 (EDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH v2 3/4] memcg: avoid overflow caused by PAGE_ALIGN
Date: Fri, 2 Aug 2013 11:25:32 +0800
Message-ID: <1375413933-10732-4-git-send-email-h.huangqiang@huawei.com>
In-Reply-To: <1375413933-10732-1-git-send-email-h.huangqiang@huawei.com>
References: <1375413933-10732-1-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, lizefan@huawei.com, handai.szj@taobao.com, handai.szj@gmail.com, jeff.liu@oracle.com, nishimura@mxp.nes.nec.co.jp, cgroups@vger.kernel.org, linux-mm@kvack.org

From: Sha Zhengju <handai.szj@taobao.com>

Since PAGE_ALIGN is aligning up(the next page boundary), so after PAGE_ALIGN,
the value might be overflow, such as write the MAX value to *.limit_in_bytes.

$ cat /cgroup/memory/memory.limit_in_bytes
18446744073709551615

# echo 18446744073709551615 > /cgroup/memory/memory.limit_in_bytes
bash: echo: write error: Invalid argument

Some user programs might depend on such behaviours(like libcg, we read the
value in snapshot, then use the value to reset cgroup later), and that
will cause confusion. So we need to fix it.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 kernel/res_counter.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 3f0417f..085d3ae 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -195,6 +195,10 @@ int res_counter_memparse_write_strategy(const char *buf,
 	if (*end != '\0')
 		return -EINVAL;
 
-	*res = PAGE_ALIGN(*res);
+	if (PAGE_ALIGN(*res) >= *res)
+		*res = PAGE_ALIGN(*res);
+	else
+		*res = RES_COUNTER_MAX;
+
 	return 0;
 }
-- 
1.8.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
