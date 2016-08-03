Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 775626B0264
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 19:39:57 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so378878467pac.3
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 16:39:57 -0700 (PDT)
Received: from pmta2.delivery5.ore.mailhop.org (pmta2.delivery5.ore.mailhop.org. [54.186.218.12])
        by mx.google.com with ESMTPS id x21si11212078pfj.106.2016.08.03.16.39.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 16:39:56 -0700 (PDT)
From: Jason Cooper <jason@lakedaemon.net>
Subject: [PATCH v3 7/7] random: Remove unused randomize_range()
Date: Wed,  3 Aug 2016 23:39:13 +0000
Message-Id: <20160803233913.32511-8-jason@lakedaemon.net>
In-Reply-To: <20160803233913.32511-1-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
 <20160803233913.32511-1-jason@lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, "Roberts, William C" <william.c.roberts@intel.com>, Yann Droneaud <ydroneaud@opteya.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, benh@kernel.crashing.org, paulus@samba.org, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, viro@zeniv.linux.org.uk, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>, Jason Cooper <jason@lakedaemon.net>

All call sites for randomize_range have been updated to use the much
simpler and more robust randomize_addr.  Remove the now unnecessary
code.

Signed-off-by: Jason Cooper <jason@lakedaemon.net>
---
 drivers/char/random.c  | 19 -------------------
 include/linux/random.h |  1 -
 2 files changed, 20 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 61cb434e3bea..46d332dd27a4 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1821,25 +1821,6 @@ unsigned long get_random_long(void)
 }
 EXPORT_SYMBOL(get_random_long);
 
-/*
- * randomize_range() returns a start address such that
- *
- *    [...... <range> .....]
- *  start                  end
- *
- * a <range> with size "len" starting at the return value is inside in the
- * area defined by [start, end], but is otherwise randomized.
- */
-unsigned long
-randomize_range(unsigned long start, unsigned long end, unsigned long len)
-{
-	unsigned long range = end - len - start;
-
-	if (end <= start + len)
-		return 0;
-	return PAGE_ALIGN(get_random_int() % range + start);
-}
-
 /**
  * randomize_page - Generate a random, page aligned address
  * @start:	The smallest acceptable address the caller will take.
diff --git a/include/linux/random.h b/include/linux/random.h
index 098fec690d65..9281dbbb7f4a 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -34,7 +34,6 @@ extern const struct file_operations random_fops, urandom_fops;
 
 unsigned int get_random_int(void);
 unsigned long get_random_long(void);
-unsigned long randomize_range(unsigned long start, unsigned long end, unsigned long len);
 unsigned long randomize_page(unsigned long start, unsigned long range);
 
 u32 prandom_u32(void);
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
