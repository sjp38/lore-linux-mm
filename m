Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA1B6828E4
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 17:25:48 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so70432275pad.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 14:25:48 -0700 (PDT)
Received: from pmta2.delivery5.ore.mailhop.org (pmta2.delivery5.ore.mailhop.org. [54.186.218.12])
        by mx.google.com with ESMTPS id z86si14266260pfd.171.2016.07.28.14.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 14:25:47 -0700 (PDT)
From: Jason Cooper <jason@lakedaemon.net>
Subject: [PATCH 7/7] random: Remove unused randomize_range()
Date: Thu, 28 Jul 2016 20:47:30 +0000
Message-Id: <20160728204730.27453-8-jason@lakedaemon.net>
In-Reply-To: <20160728204730.27453-1-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: william.c.roberts@intel.com, Yann Droneaud <ydroneaud@opteya.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, tytso@mit.edu, arnd@arndb.de, gregkh@linuxfoundation.org, catalin.marinas@arm.com, will.deacon@arm.com, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, nnk@google.com, jeffv@google.com, dcashman@android.com, Jason Cooper <jason@lakedaemon.net>

All call sites for randomize_range have been updated to use the much
simpler and more robust randomize_addr.  Remove the now unnecessary
code.

Signed-off-by: Jason Cooper <jason@lakedaemon.net>
---
 drivers/char/random.c  | 19 -------------------
 include/linux/random.h |  1 -
 2 files changed, 20 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 3610774bcc53..5333763a4820 100644
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
  * randomize_addr - Generate a random, page aligned address
  * @start:	The smallest acceptable address the caller will take.
diff --git a/include/linux/random.h b/include/linux/random.h
index f1ca2fa4c071..1ad877a98186 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -34,7 +34,6 @@ extern const struct file_operations random_fops, urandom_fops;
 
 unsigned int get_random_int(void);
 unsigned long get_random_long(void);
-unsigned long randomize_range(unsigned long start, unsigned long end, unsigned long len);
 unsigned long randomize_addr(unsigned long start, unsigned long range);
 
 u32 prandom_u32(void);
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
