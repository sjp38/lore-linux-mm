Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id E3DB36B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 03:31:55 -0400 (EDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH 1/4] memcg: correct RESOURCE_MAX to ULLONG_MAX
Date: Wed, 31 Jul 2013 15:31:22 +0800
Message-ID: <1375255885-10648-2-git-send-email-h.huangqiang@huawei.com>
In-Reply-To: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
References: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: handai.szj@taobao.com, lizefan@huawei.com, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, mhocko@suse.cz, jeff.liu@oracle.com

Current RESOURCE_MAX is ULONG_MAX, but the value we used to set resource
limit is unsigned long long, so we can set bigger value than that which
is strange. The XXX_MAX should be reasonable max value, bigger than that
should be overflow.

Notice that this change will affect user output of default *.limit_in_bytes:
before change:
$ cat /cgroup/memory/memory.limit_in_bytes
9223372036854775807

after change:
$ cat /cgroup/memory/memory.limit_in_bytes
18446744073709551615

But it doesn't alter the API in term of input - we can still use
"echo -1 > *.limit_in_bytes" to reset the numbers to "unlimited".

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
---
 include/linux/res_counter.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 96a509b..586bc7c 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -54,7 +54,7 @@ struct res_counter {
 	struct res_counter *parent;
 };
 
-#define RESOURCE_MAX (unsigned long long)LLONG_MAX
+#define RESOURCE_MAX ULLONG_MAX
 
 /**
  * Helpers to interact with userspace
-- 
1.8.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
