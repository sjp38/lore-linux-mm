Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 072E96B0010
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 12:15:52 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o23so4623998wrc.9
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 09:15:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p14sor1591086wmh.14.2018.03.01.09.15.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 09:15:50 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 2/2] kasan: disallow compiler to optimize away memset in tests
Date: Thu,  1 Mar 2018 18:15:43 +0100
Message-Id: <105ec9a308b2abedb1a0d1fdced0c22d765e4732.1519924383.git.andreyknvl@google.com>
In-Reply-To: <cover.1519924383.git.andreyknvl@google.com>
References: <cover.1519924383.git.andreyknvl@google.com>
In-Reply-To: <cover.1519924383.git.andreyknvl@google.com>
References: <cover.1519924383.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Nick Terrell <terrelln@fb.com>, Chris Mason <clm@fb.com>, Yury Norov <ynorov@caviumnetworks.com>, Al Viro <viro@zeniv.linux.org.uk>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Jeff Layton <jlayton@redhat.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: Kostya Serebryany <kcc@google.com>, Andrey Konovalov <andreyknvl@google.com>

A compiler can optimize away memset calls by replacing them with mov
instructions. There are KASAN tests, that specifically test that KASAN
correctly handles memset calls, we don't want this optimization to
happen.

The solution is to add -fno-builtin flag to test_kasan.ko

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 lib/Makefile | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/Makefile b/lib/Makefile
index a90d4fcd748f..9c940c4c0593 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -52,6 +52,7 @@ obj-$(CONFIG_TEST_FIRMWARE) += test_firmware.o
 obj-$(CONFIG_TEST_SYSCTL) += test_sysctl.o
 obj-$(CONFIG_TEST_HASH) += test_hash.o test_siphash.o
 obj-$(CONFIG_TEST_KASAN) += test_kasan.o
+CFLAGS_test_kasan.o += -fno-builtin
 obj-$(CONFIG_TEST_KSTRTOX) += test-kstrtox.o
 obj-$(CONFIG_TEST_LIST_SORT) += test_list_sort.o
 obj-$(CONFIG_TEST_LKM) += test_module.o
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
