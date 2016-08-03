Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 203116B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 19:39:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so423798264pfg.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 16:39:47 -0700 (PDT)
Received: from pmta2.delivery5.ore.mailhop.org (pmta2.delivery5.ore.mailhop.org. [54.186.218.12])
        by mx.google.com with ESMTPS id bg10si11231572pab.12.2016.08.03.16.39.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 16:39:45 -0700 (PDT)
From: Jason Cooper <jason@lakedaemon.net>
Subject: [PATCH v3 1/7] random: Simplify API for random address requests
Date: Wed,  3 Aug 2016 23:39:07 +0000
Message-Id: <20160803233913.32511-2-jason@lakedaemon.net>
In-Reply-To: <20160803233913.32511-1-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
 <20160803233913.32511-1-jason@lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, "Roberts, William C" <william.c.roberts@intel.com>, Yann Droneaud <ydroneaud@opteya.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, benh@kernel.crashing.org, paulus@samba.org, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, viro@zeniv.linux.org.uk, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>, Jason Cooper <jason@lakedaemon.net>

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
Changes from v2:
 - s/randomize_addr/randomize_page/ (Kees Cook)
 - PAGE_ALIGN(start) if it wasn't (Kees Cook, Michael Ellerman)

 drivers/char/random.c  | 33 +++++++++++++++++++++++++++++++++
 include/linux/random.h |  1 +
 2 files changed, 34 insertions(+)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 0158d3bff7e5..61cb434e3bea 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1840,6 +1840,39 @@ randomize_range(unsigned long start, unsigned long end, unsigned long len)
 	return PAGE_ALIGN(get_random_int() % range + start);
 }
 
+/**
+ * randomize_page - Generate a random, page aligned address
+ * @start:	The smallest acceptable address the caller will take.
+ * @range:	The size of the area, starting at @start, within which the
+ *		random address must fall.
+ *
+ * If @start + @range would overflow, @range is capped.
+ *
+ * NOTE: Historical use of randomize_range, which this replaces, presumed that
+ * @start was already page aligned.  We now align it regardless.
+ *
+ * Return: A page aligned address within [start, start + range).  On error,
+ * @start is returned.
+ */
+unsigned long
+randomize_page(unsigned long start, unsigned long range)
+{
+	if (!PAGE_ALIGNED(start)) {
+		range -= PAGE_ALIGN(start) - start;
+		start = PAGE_ALIGN(start);
+	}
+
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
index e47e533742b5..098fec690d65 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -35,6 +35,7 @@ extern const struct file_operations random_fops, urandom_fops;
 unsigned int get_random_int(void);
 unsigned long get_random_long(void);
 unsigned long randomize_range(unsigned long start, unsigned long end, unsigned long len);
+unsigned long randomize_page(unsigned long start, unsigned long range);
 
 u32 prandom_u32(void);
 void prandom_bytes(void *buf, size_t nbytes);
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
