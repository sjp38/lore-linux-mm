Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F303828E1
	for <linux-mm@kvack.org>; Sat, 30 Jul 2016 11:43:25 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k135so51001663lfb.2
        for <linux-mm@kvack.org>; Sat, 30 Jul 2016 08:43:25 -0700 (PDT)
Received: from outbound1.eu.mailhop.org (outbound1.eu.mailhop.org. [52.28.251.132])
        by mx.google.com with ESMTPS id n123si8395624wmg.68.2016.07.30.08.43.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jul 2016 08:43:23 -0700 (PDT)
From: Jason Cooper <jason@lakedaemon.net>
Subject: [PATCH v2 1/7] random: Simplify API for random address requests
Date: Sat, 30 Jul 2016 15:42:38 +0000
Message-Id: <20160730154244.403-2-jason@lakedaemon.net>
In-Reply-To: <20160730154244.403-1-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
 <20160730154244.403-1-jason@lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: william.c.roberts@intel.com, Yann Droneaud <ydroneaud@opteya.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, tytso@mit.edu, arnd@arndb.de, gregkh@linuxfoundation.org, catalin.marinas@arm.com, will.deacon@arm.com, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, nnk@google.com, jeffv@google.com, dcashman@android.com, Jason Cooper <jason@lakedaemon.net>

To date, all callers of randomize_range() have set the length to 0, and
check for a zero return value.  For the current callers, the only way
to get zero returned is if end <= start.  Since they are all adding a
constant to the start address, this is unnecessary.

We can remove a bunch of needless checks by simplifying the API to do
just what everyone wants, return an address between [start, start +
range).

While we're here, s/get_random_int/get_random_long/.  No current call
site is adversely affected by get_random_int(), since all current range
requests are < UINT_MAX.  However, we should match caller expectations
to avoid coming up short (ha!) in the future.

All current callers to randomize_range() chose to use the start address
if randomize_range() failed.  Therefore, we simplify things by just
returning the start address on error.

randomize_range() will be removed once all callers have been converted
over to randomize_addr().

Signed-off-by: Jason Cooper <jason@lakedaemon.net>
---
Changes from v1:
 - Explicitly mention page_aligned start assumption (Yann Droneaud)
 - pick random pages vice random addresses (Yann Droneaud)
 - catch range=0 last

 drivers/char/random.c  | 28 ++++++++++++++++++++++++++++
 include/linux/random.h |  1 +
 2 files changed, 29 insertions(+)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 0158d3bff7e5..3bedf69546d6 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1840,6 +1840,34 @@ randomize_range(unsigned long start, unsigned long end, unsigned long len)
 	return PAGE_ALIGN(get_random_int() % range + start);
 }
 
+/**
+ * randomize_addr - Generate a random, page aligned address
+ * @start:	The smallest acceptable address the caller will take.
+ * @range:	The size of the area, starting at @start, within which the
+ *		random address must fall.
+ *
+ * If @start + @range would overflow, @range is capped.
+ *
+ * NOTE: Historical use of randomize_range, which this replaces, presumed that
+ * @start was already page aligned.  This assumption still holds.
+ *
+ * Return: A page aligned address within [start, start + range).  On error,
+ * @start is returned.
+ */
+unsigned long
+randomize_addr(unsigned long start, unsigned long range)
+{
+	if (start > ULONG_MAX - range)
+		range = ULONG_MAX - start;
+
+	range >>= PAGE_SHIFT;
+
+	if (range == 0)
+		return start;
+
+	return start + (get_random_long() % range << PAGE_SHIFT);
+}
+
 /* Interface for in-kernel drivers of true hardware RNGs.
  * Those devices may produce endless random bits and will be throttled
  * when our pool is full.
diff --git a/include/linux/random.h b/include/linux/random.h
index e47e533742b5..f1ca2fa4c071 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -35,6 +35,7 @@ extern const struct file_operations random_fops, urandom_fops;
 unsigned int get_random_int(void);
 unsigned long get_random_long(void);
 unsigned long randomize_range(unsigned long start, unsigned long end, unsigned long len);
+unsigned long randomize_addr(unsigned long start, unsigned long range);
 
 u32 prandom_u32(void);
 void prandom_bytes(void *buf, size_t nbytes);
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
