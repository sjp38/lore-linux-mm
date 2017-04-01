Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85ADC6B0390
	for <linux-mm@kvack.org>; Sat,  1 Apr 2017 17:18:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l43so19423052wre.4
        for <linux-mm@kvack.org>; Sat, 01 Apr 2017 14:18:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8si12854493wrd.173.2017.04.01.14.18.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 01 Apr 2017 14:18:25 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC] mm/crypto: add tunable compression algorithm for zswap
Date: Sat,  1 Apr 2017 23:18:13 +0200
Message-Id: <20170401211813.15146-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>

Zswap (and zram) save memory by compressing pages instead of swapping them
out. This is nice, but with traditional compression algorithms such as LZO,
one cannot know, how well the data will compress, so the overal savings are
unpredictable. This is further complicated by the choice of zpool
implementation for managing the compressed pages. Zbud and z3fold are
relatively simple, but cannot store more then 2 (zbud) or 3 (z3fold)
compressed pages in a page. The rest of the page is wasted. Zsmalloc is more
flexible, but also more complex.

Clearly things would be much easier if the compression ratio was predictable.
But why stop at that - what if we could actually *choose* the compression
ratio? This patch introduces a new compression algorithm that can do just
that! It's called Tunable COmpression, or TCO for short.

In this prototype patch, it offers three predefined ratios, but nothing
prevents more fine-grained settings, except the current crypto API (or my
limited knowledge of it, but I'm guessing nobody really expected the
compression ratio to be tunable). So by doing

echo tco50 > /sys/module/zswap/parameters/compressor

you get 50% compression ratio, guaranteed! This setting and zbud are just the
perfect buddies, if you prefer the nice and simple allocator. Zero internal
fragmentation!

Or,

echo tco30 > /sys/module/zswap/parameters/compressor

is a great match for z3fold, if you want to be smarter and save 50% memory
over zbud, again with no memory wasted! But why stop at that? If you do

echo tco10 > /sys/module/zswap/parameters/compressor

within the next hour, and choose zsmalloc, you will be able to neatly store
10 compressed pages within a single page! Yes, 90% savings!
In the full version of this patch, you'll be able to set any ratio, so you
can decide exactly how much money to waste on extra RAM instead of compressing
the data. Let TCO cut down your system's TCO!

This RFC was not yet tested, but it compiles fine and mostly passes checkpatch
so it must obviously work.
---
 crypto/Kconfig  |   7 +++
 crypto/Makefile |   1 +
 crypto/tco.c    | 164 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 172 insertions(+)
 create mode 100644 crypto/tco.c

diff --git a/crypto/Kconfig b/crypto/Kconfig
index f37e9cca50e1..90761d06d363 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -1618,6 +1618,13 @@ config CRYPTO_LZO
 	help
 	  This is the LZO algorithm.
 
+config CRYPTO_TCO
+	tristate "Tunable compression algorithm"
+	select CRYPTO_ALGAPI
+	select CRYPTO_ACOMP2
+	help
+	  This is the tunable compression (TCO) algorithm.
+
 config CRYPTO_842
 	tristate "842 compression algorithm"
 	select CRYPTO_ALGAPI
diff --git a/crypto/Makefile b/crypto/Makefile
index 8a44057240d5..7566b64809be 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -121,6 +121,7 @@ obj-$(CONFIG_CRYPTO_CRC32) += crc32_generic.o
 obj-$(CONFIG_CRYPTO_CRCT10DIF) += crct10dif_common.o crct10dif_generic.o
 obj-$(CONFIG_CRYPTO_AUTHENC) += authenc.o authencesn.o
 obj-$(CONFIG_CRYPTO_LZO) += lzo.o
+obj-$(CONFIG_CRYPTO_TCO) += tco.o
 obj-$(CONFIG_CRYPTO_LZ4) += lz4.o
 obj-$(CONFIG_CRYPTO_LZ4HC) += lz4hc.o
 obj-$(CONFIG_CRYPTO_842) += 842.o
diff --git a/crypto/tco.c b/crypto/tco.c
new file mode 100644
index 000000000000..be4303657817
--- /dev/null
+++ b/crypto/tco.c
@@ -0,0 +1,164 @@
+/*
+ * Cryptographic API.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/crypto.h>
+#include <linux/vmalloc.h>
+#include <linux/mm.h>
+
+struct tco_ctx {
+	char ratio;
+};
+
+static int tco_init10(struct crypto_tfm *tfm)
+{
+	struct tco_ctx *ctx = crypto_tfm_ctx(tfm);
+
+	ctx->ratio = 10;
+
+	return 0;
+}
+
+static int tco_init30(struct crypto_tfm *tfm)
+{
+	struct tco_ctx *ctx = crypto_tfm_ctx(tfm);
+
+	ctx->ratio = 30;
+
+	return 0;
+}
+
+static int tco_init50(struct crypto_tfm *tfm)
+{
+	struct tco_ctx *ctx = crypto_tfm_ctx(tfm);
+
+	ctx->ratio = 50;
+
+	return 0;
+}
+
+static void tco_exit(struct crypto_tfm *tfm)
+{
+}
+
+static int tco_compress(struct crypto_tfm *tfm, const u8 *src,
+			unsigned int slen, u8 *dst, unsigned int *dlen)
+{
+	unsigned int in, out;
+	struct tco_ctx *ctx = crypto_tfm_ctx(tfm);
+	unsigned int *store_len = (unsigned int *) dst;
+
+	*store_len = slen;
+	dst += sizeof(unsigned int);
+	out = sizeof(unsigned int);
+
+	out = 0;
+	for (in = 0; in < slen; in++, src++) {
+		if (in % 100 < ctx->ratio) {
+			*dst++ = *src;
+			out++;
+		}
+	}
+
+	*dlen = out;
+	return 0;
+}
+
+static int tco_decompress(struct crypto_tfm *tfm, const u8 *src,
+			  unsigned int slen, u8 *dst, unsigned int *dlen)
+{
+	unsigned int in, out;
+	unsigned int max_out = *dlen;
+	unsigned int stored_len;
+	struct tco_ctx *ctx = crypto_tfm_ctx(tfm);
+
+	stored_len = *((unsigned int *) src);
+	src += sizeof(unsigned int);
+	in = sizeof(unsigned int);
+
+	if (max_out < stored_len)
+		stored_len = max_out;
+
+	for (out = 0; out < stored_len; out++, dst++) {
+		if (out % 100 < ctx->ratio && in < slen) {
+			*dst = *src++;
+			in++;
+		}
+	}
+
+	*dlen = stored_len;
+	return 0;
+}
+
+static struct crypto_alg tco10 = {
+	.cra_name		= "tco10",
+	.cra_flags		= CRYPTO_ALG_TYPE_COMPRESS,
+	.cra_ctxsize		= sizeof(struct tco_ctx),
+	.cra_module		= THIS_MODULE,
+	.cra_init		= tco_init10,
+	.cra_exit		= tco_exit,
+	.cra_u			= { .compress = {
+	.coa_compress		= tco_compress,
+	.coa_decompress		= tco_decompress } }
+};
+
+static struct crypto_alg tco30 = {
+	.cra_name		= "tco30",
+	.cra_flags		= CRYPTO_ALG_TYPE_COMPRESS,
+	.cra_ctxsize		= sizeof(struct tco_ctx),
+	.cra_module		= THIS_MODULE,
+	.cra_init		= tco_init30,
+	.cra_exit		= tco_exit,
+	.cra_u			= { .compress = {
+	.coa_compress		= tco_compress,
+	.coa_decompress		= tco_decompress } }
+};
+
+static struct crypto_alg tco50 = {
+	.cra_name		= "tco50",
+	.cra_flags		= CRYPTO_ALG_TYPE_COMPRESS,
+	.cra_ctxsize		= sizeof(struct tco_ctx),
+	.cra_module		= THIS_MODULE,
+	.cra_init		= tco_init50,
+	.cra_exit		= tco_exit,
+	.cra_u			= { .compress = {
+	.coa_compress		= tco_compress,
+	.coa_decompress		= tco_decompress } }
+};
+
+static int __init tco_mod_init(void)
+{
+	int ret;
+
+	ret = crypto_register_alg(&tco10);
+	ret = crypto_register_alg(&tco30);
+	ret = crypto_register_alg(&tco50);
+
+	return ret;
+}
+
+static void __exit tco_mod_fini(void)
+{
+	crypto_unregister_alg(&tco10);
+	crypto_unregister_alg(&tco30);
+	crypto_unregister_alg(&tco50);
+}
+
+module_init(tco_mod_init);
+module_exit(tco_mod_fini);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Tunable Compression Algorithm");
+MODULE_ALIAS_CRYPTO("tco");
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
