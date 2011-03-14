Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9B1298D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 22:28:07 -0400 (EDT)
Message-ID: <20110316022804.27682.qmail@science.horizon.com>
From: George Spelvin <linux@horizon.com>
Date: Sun, 13 Mar 2011 20:57:01 -0400
Subject: [PATCH 2/8] drivers/char/random: Split out __get_random_int
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, mpm@selenic.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@horizon.com

The unlocked function is needed for following work.
No API change.

(Minor functional change while messing with code: all 64 bits of
the cycles counter is used.  No API change.)
---
 drivers/char/random.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 4bcc4f2..fdbf7b6 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1621,22 +1621,29 @@ EXPORT_SYMBOL(secure_dccp_sequence_number);
 /*
  * Get a random word for internal kernel use only. Similar to urandom but
  * with the goal of minimal entropy pool depletion. As a result, the random
- * value is not cryptographically secure but for several uses the cost of
- * depleting entropy is too high
+ * value is not strongly cryptographically secure, but for several uses the
+ * cost of depleting entropy is too high.
  */
 DEFINE_PER_CPU(__u32 [4], get_random_int_hash);
-unsigned int get_random_int(void)
+static u32 __get_random_int(u32 *hash)
 {
-	struct keydata *keyptr;
-	__u32 *hash = get_cpu_var(get_random_int_hash);
-	int ret;
+	struct keydata const *keyptr = get_keyptr();
+	cycles_t c = get_cycles();
 
-	keyptr = get_keyptr();
-	hash[0] += current->pid + jiffies + get_cycles();
+	/* Throw in some extra seed material */
+	hash[0] += (__u32)c;
+	hash[1] += (__u32)(c>>16>>16); /* Safe if cycles_it is 32 bits. */
+	hash[2] += current->pid + jiffies;
 
-	ret = half_md4_transform(hash, keyptr->secret);
-	put_cpu_var(get_random_int_hash);
+	return half_md4_transform(hash, keyptr->secret);
+}
 
+unsigned int get_random_int(void)
+{
+	u32 *hash = get_cpu_var(get_random_int_hash);
+	u32 ret = __get_random_int(hash);
+
+	put_cpu_var(get_random_int_hash);
 	return ret;
 }
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
