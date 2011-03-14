Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8C8DC8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 22:28:07 -0400 (EDT)
Message-ID: <20110316022804.27692.qmail@science.horizon.com>
From: George Spelvin <linux@horizon.com>
Date: Mon, 14 Mar 2011 12:46:32 -0400
Subject: [PATCH 3/8] drivers/char/random: make get_random_int_hash a structure
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, mpm@selenic.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@horizon.com

We'll need to add some fields to it in later work.
---
 drivers/char/random.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index fdbf7b6..113508e 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1624,7 +1624,10 @@ EXPORT_SYMBOL(secure_dccp_sequence_number);
  * value is not strongly cryptographically secure, but for several uses the
  * cost of depleting entropy is too high.
  */
-DEFINE_PER_CPU(__u32 [4], get_random_int_hash);
+struct cpu_random {
+	u32 hash[4];
+};
+DEFINE_PER_CPU(struct cpu_random, get_random_int_data);
 static u32 __get_random_int(u32 *hash)
 {
 	struct keydata const *keyptr = get_keyptr();
@@ -1640,10 +1643,10 @@ static u32 __get_random_int(u32 *hash)
 
 unsigned int get_random_int(void)
 {
-	u32 *hash = get_cpu_var(get_random_int_hash);
-	u32 ret = __get_random_int(hash);
+	struct cpu_random *r = &get_cpu_var(get_random_int_data);
+	u32 ret = __get_random_int(r->hash);
 
-	put_cpu_var(get_random_int_hash);
+	put_cpu_var(r);
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
