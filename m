Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 8BDF46B0197
	for <linux-mm@kvack.org>; Sun,  5 May 2013 11:46:01 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kl13so1640784pab.34
        for <linux-mm@kvack.org>; Sun, 05 May 2013 08:46:00 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 3/3] memcg: replace memparse to avoid input overflow
Date: Sun,  5 May 2013 23:44:41 +0800
Message-Id: <1367768681-4451-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, mhocko@suse.cz, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

memparse() doesn't check if overflow has happens, and it even has no
args to inform user that the unexpected situation has occurred. Besides,
some of its callers make a little artful use of the current implementation
and it also seems to involve too much if changing memparse() interface.

This patch rewrites memcg's internal res_counter_memparse_write_strategy().
It doesn't use memparse() any more and replaces simple_strtoull() with
kstrtoull() to avoid input overflow.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 kernel/res_counter.c |   41 ++++++++++++++++++++++++++++++++++++-----
 1 file changed, 36 insertions(+), 5 deletions(-)

diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index be8ddda..a990e8e0 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -182,19 +182,50 @@ int res_counter_memparse_write_strategy(const char *buf,
 {
 	char *end;
 	unsigned long long res;
+	int ret, len, suffix = 0;
+	char *ptr;
 
 	/* return RES_COUNTER_MAX(unlimited) if "-1" is specified */
 	if (*buf == '-') {
-		res = simple_strtoull(buf + 1, &end, 10);
-		if (res != 1 || *end != '\0')
+		ret = kstrtoull(buf + 1, 10, &res);
+		if (res != 1 || ret)
 			return -EINVAL;
 		*resp = RES_COUNTER_MAX;
 		return 0;
 	}
 
-	res = memparse(buf, &end);
-	if (*end != '\0')
-		return -EINVAL;
+	len = strlen(buf);
+	end = buf + len - 1;
+	switch (*end) {
+	case 'G':
+	case 'g':
+		suffix ++;
+	case 'M':
+	case 'm':
+		suffix ++;
+	case 'K':
+	case 'k':
+		suffix ++;
+		len --;
+	default:
+		break;
+	}
+
+	ptr = kmalloc(len + 1, GFP_KERNEL);
+	if (!ptr) return -ENOMEM;
+
+	strlcpy(ptr, buf, len + 1);
+	ret = kstrtoull(ptr, 0, &res);
+	kfree(ptr);
+	if (ret) return -EINVAL;
+
+	while (suffix) {
+		/* check for overflow while multiplying suffix number */
+		if (unlikely(res & (~0ull << 54)))
+			return -EINVAL;
+		res <<= 10;
+		suffix --;
+	}
 
 	if (PAGE_ALIGN(res) >= res)
 		res = PAGE_ALIGN(res);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
