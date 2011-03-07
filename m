Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A6CD88D003E
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:49:36 -0500 (EST)
Date: 7 Mar 2011 12:49:34 -0500
Message-ID: <20110307174934.15811.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
In-Reply-To: <20110307141948.11415.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@horizon.com

To go with my earlier code, here's a (proof of concept) more efficient
random number generator for a series of small values.  A bit more code,
but a lot less calls to half_md4_transform.

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 773007d..6b3fd4e 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1658,6 +1658,84 @@ unsigned int get_random_int(void)
 	return ret;
 }
 
+struct random_mod_state {
+	unsigned int x, lim;	/* Invariant: 0 <= x < lim, and random */
+	__u8 const *seed;
+	unsigned len;
+};
+
+void
+get_random_mod_start(struct random_mod_state *s)
+{
+	s->x = 0;
+	s->lim = 0;
+	s->len = 0;
+
+	preempt_disable();	/* For access to percpu variables */
+}
+
+/*
+ * Return a random 0 <= x < m.  This is exacctly uniformly distributed,
+ * which "random() % m" is not, and it is economical with seed entropy.
+ * For example, this can shuffle 27 elements (27! > 2^93) with only
+ * one call to half_md4_transform.
+ *
+ * This is limited to 24-bit moduli m; larger values risk overflow.
+ */
+unsigned
+get_random_mod(struct random_mod_state *s, unsigned m)
+{
+        unsigned x = s->x, lim = x->lim;
+
+        for (;;) {
+		unsigned k;
+
+		/* Ensure lim >= m */
+		while (lim < m) {
+			/* Invoke underlying random bit source */
+			if (!s->len--) {
+				__u32 *h = __get_cpu_var(get_random_int_hash);
+				struct keydata const *keyptr = get_keyptr();
+				cycles_t c = get_cycles();
+
+				/* Throw in some extra seed material */
+				h[0] += (__u32)c;
+				h[1] += (__u32)(c>>16>>16); /* 32-bit safe */
+				h[2] += current->pid + jiffies;
+
+				half_md4_transform(h, keyptr->secret);
+
+				/* And use last 12 bytes as random numbers */
+				s->seed = (__u8 *)(h + 1);
+				s->len = 11;	/* Pre-decremented */
+			}
+			/* Add one byte to state */
+			x = x<<8 | *s->seed++;
+			lim <<= 8;
+		}
+		/*
+		 * Core loop.  We occasionally have to discard and regenerate
+		 * to ensure uniformity.
+		 */
+		k = lim % m;
+		if (x >= k) {
+			x -= k;		lim -= k;
+			/* Final result: Return x % m, keep x / m */
+			s->x = x/m;	s->lim = lim/m;
+			return x % m;
+		}
+		/* Non-uniform: keep fractional part and try again */
+		lim = k;
+	}
+}
+
+void
+get_random_mod_stop(struct random_mod_state *s)
+{
+	(void)s;
+	preempt_enable();	/* Drop lock on s->seed */
+}
+
 /*
  * randomize_range() returns a start address such that
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
