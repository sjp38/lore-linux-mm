Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8DF48E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 18:37:56 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g12-v6so7665257plo.1
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 15:37:56 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v1-v6si9737154plb.387.2018.09.07.15.37.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 15:37:55 -0700 (PDT)
Date: Fri, 7 Sep 2018 15:38:36 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC 11/12] keys/mktme: Add a new key service type for memory
 encryption keys
Message-ID: <1a14a6feb02f968c5e6b98360f6f16106b633b58.1536356108.git.alison.schofield@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536356108.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

MKTME (Multi-Key Total Memory Encryption) is a technology that allows
transparent memory encryption in upcoming Intel platforms. MKTME will
support mulitple encryption domains, each having their own key. The main
use case for the feature is virtual machine isolation. The API needs the
flexibility to work for a wide range of uses.

The MKTME key service type manages the addition and removal of the memory
encryption keys. It maps software keys to hardware keyids and programs
the hardware with the user requested encryption options.

The only supported encryption algorithm is AES-XTS 128.

The MKTME key service is half of the MKTME API level solution. It pairs
with a new memory encryption system call: encrypt_mprotect() that uses
the keys to encrypt memory.

See Documentation/x86/mktme-keys.txt

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
---
 arch/x86/Kconfig           |   1 +
 include/keys/mktme-type.h  |  28 +++++
 security/keys/Kconfig      |  11 ++
 security/keys/Makefile     |   1 +
 security/keys/mktme_keys.c | 278 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 319 insertions(+)
 create mode 100644 include/keys/mktme-type.h
 create mode 100644 security/keys/mktme_keys.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 023a22568c06..50d8aa6a58e9 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1527,6 +1527,7 @@ config X86_INTEL_MKTME
 	bool "Intel Multi-Key Total Memory Encryption"
 	select DYNAMIC_PHYSICAL_MASK
 	select PAGE_EXTENSION
+	select MKTME_KEYS
 	depends on X86_64 && CPU_SUP_INTEL
 	---help---
 	  Say yes to enable support for Multi-Key Total Memory Encryption.
diff --git a/include/keys/mktme-type.h b/include/keys/mktme-type.h
new file mode 100644
index 000000000000..bebe74cb2b51
--- /dev/null
+++ b/include/keys/mktme-type.h
@@ -0,0 +1,28 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+/*
+ * Key service for Multi-KEY Total Memory Encryption
+ */
+
+#ifndef _KEYS_MKTME_TYPE_H
+#define _KEYS_MKTME_TYPE_H
+
+#include <linux/key.h>
+
+/*
+ * The AES-XTS 128 encryption algorithm requires 128 bits for each
+ * user supplied option: userkey=, tweak=, entropy=.
+ */
+#define MKTME_AES_XTS_SIZE	16
+
+enum mktme_alg {
+	MKTME_ALG_AES_XTS_128,
+};
+
+const char *const mktme_alg_names[] = {
+	[MKTME_ALG_AES_XTS_128]	= "aes_xts_128",
+};
+
+extern struct key_type key_type_mktme;
+
+#endif /* _KEYS_MKTME_TYPE_H */
diff --git a/security/keys/Kconfig b/security/keys/Kconfig
index 6462e6654ccf..c36972113e67 100644
--- a/security/keys/Kconfig
+++ b/security/keys/Kconfig
@@ -101,3 +101,14 @@ config KEY_DH_OPERATIONS
 	 in the kernel.
 
 	 If you are unsure as to whether this is required, answer N.
+
+config MKTME_KEYS
+	bool "Multi-Key Total Memory Encryption Keys"
+	depends on KEYS && X86_INTEL_MKTME
+	help
+	  This option provides support for Multi-Key Total Memory
+	  Encryption (MKTME) on Intel platforms offering the feature.
+	  MKTME allows userspace to manage the hardware encryption
+	  keys through the kernel key services.
+
+	  If you are unsure as to whether this is required, answer N.
diff --git a/security/keys/Makefile b/security/keys/Makefile
index ef1581b337a3..2d9f9a82cb8a 100644
--- a/security/keys/Makefile
+++ b/security/keys/Makefile
@@ -29,3 +29,4 @@ obj-$(CONFIG_KEY_DH_OPERATIONS) += dh.o
 obj-$(CONFIG_BIG_KEYS) += big_key.o
 obj-$(CONFIG_TRUSTED_KEYS) += trusted.o
 obj-$(CONFIG_ENCRYPTED_KEYS) += encrypted-keys/
+obj-$(CONFIG_MKTME_KEYS) += mktme_keys.o
diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
new file mode 100644
index 000000000000..dcbce7194647
--- /dev/null
+++ b/security/keys/mktme_keys.c
@@ -0,0 +1,278 @@
+// SPDX-License-Identifier: GPL-3.0
+
+/* Documentation/x86/mktme-keys.txt */
+
+#include <linux/cred.h>
+#include <linux/cpu.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/key.h>
+#include <linux/key-type.h>
+#include <linux/init.h>
+#include <linux/parser.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <asm/intel_pconfig.h>
+#include <asm/mktme.h>
+#include <keys/mktme-type.h>
+#include <keys/user-type.h>
+
+#include "internal.h"
+
+struct kmem_cache *mktme_prog_cache;	/* hardware programming struct */
+cpumask_var_t mktme_cpumask;		/* one cpu per pkg to program keys */
+
+static const char * const mktme_program_err[] = {
+	"KeyID was successfully programmed",	/* 0 */
+	"Invalid KeyID programming command",	/* 1 */
+	"Insufficient entropy",			/* 2 */
+	"KeyID not valid",			/* 3 */
+	"Invalid encryption algorithm chosen",	/* 4 */
+	"Failure to access key table",		/* 5 */
+};
+
+/* If a key is available, program and add the key to the software map. */
+static int mktme_program_key(key_serial_t serial,
+			     struct mktme_key_program *kprog)
+{
+	int keyid, ret;
+
+	keyid = mktme_map_get_free_keyid();
+	if (keyid == 0)
+		return -EDQUOT;
+
+	kprog->keyid = keyid;
+	ret = mktme_key_program(kprog, mktme_cpumask);
+	if (ret == MKTME_PROG_SUCCESS)
+		mktme_map_set_keyid(keyid, serial);
+	else
+		pr_debug("mktme: %s [%d]\n", mktme_program_err[ret], ret);
+
+	return ret;
+}
+
+enum mktme_opt_id	{
+	OPT_ERROR = -1,
+	OPT_USERKEY,
+	OPT_TWEAK,
+	OPT_ENTROPY,
+	OPT_ALGORITHM,
+};
+
+static const match_table_t mktme_token = {
+	{OPT_USERKEY, "userkey=%s"},
+	{OPT_TWEAK, "tweak=%s"},
+	{OPT_ENTROPY, "entropy=%s"},
+	{OPT_ALGORITHM, "algorithm=%s"},
+	{OPT_ERROR, NULL}
+
+};
+
+/*
+ * Algorithm AES-XTS 128 is the only supported encryption algorithm.
+ * CPU Generated Key: requires user supplied entropy and accepts no
+ *		      other options.
+ * User Supplied Key: requires user supplied tweak key and accepts
+ *		      no other options.
+ */
+static int mktme_check_options(struct mktme_key_program *kprog,
+			       unsigned long token_mask)
+{
+	if (!token_mask)
+		return -EINVAL;
+
+	kprog->keyid_ctrl |= MKTME_AES_XTS_128;
+
+	if (!test_bit(OPT_USERKEY, &token_mask)) {
+		if ((!test_bit(OPT_ENTROPY, &token_mask)) ||
+		    (test_bit(OPT_TWEAK, &token_mask)))
+			return -EINVAL;
+
+		kprog->keyid_ctrl |= MKTME_KEYID_SET_KEY_RANDOM;
+	}
+	if (test_bit(OPT_USERKEY, &token_mask)) {
+		if ((test_bit(OPT_ENTROPY, &token_mask)) ||
+		    (!test_bit(OPT_TWEAK, &token_mask)))
+			return -EINVAL;
+
+		kprog->keyid_ctrl |= MKTME_KEYID_SET_KEY_DIRECT;
+	}
+	return 0;
+}
+
+/*
+ * Parse the options and begin to fill in the key programming struct kprog.
+ * Check the lengths of incoming data and push data directly into kprog fields.
+ */
+static int mktme_get_options(char *options, struct mktme_key_program *kprog)
+{
+	int len = MKTME_AES_XTS_SIZE / 2;
+	substring_t args[MAX_OPT_ARGS];
+	unsigned long token_mask = 0;
+	enum mktme_alg alg;
+	char *p = options;
+	int ret, token;
+
+	while ((p = strsep(&options, " \t"))) {
+		if (*p == '\0' || *p == ' ' || *p == '\t')
+			continue;
+		token = match_token(p, mktme_token, args);
+		if (test_and_set_bit(token, &token_mask))
+			return -EINVAL;
+
+		switch (token) {
+		case OPT_USERKEY:
+			if (strlen(args[0].from) != MKTME_AES_XTS_SIZE)
+				return -EINVAL;
+			ret = hex2bin(kprog->key_field_1, args[0].from, len);
+			if (ret < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_TWEAK:
+			if (strlen(args[0].from) != MKTME_AES_XTS_SIZE)
+				return -EINVAL;
+			ret = hex2bin(kprog->key_field_2, args[0].from, len);
+			if (ret < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_ENTROPY:
+			if (strlen(args[0].from) != MKTME_AES_XTS_SIZE)
+				return -EINVAL;
+			/* Applied to both CPU-generated data and tweak keys */
+			ret = hex2bin(kprog->key_field_1, args[0].from, len);
+			ret = hex2bin(kprog->key_field_2, args[0].from, len);
+			if (ret < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_ALGORITHM:
+			alg = match_string(mktme_alg_names,
+					   ARRAY_SIZE(mktme_alg_names),
+					   args[0].from);
+			if (alg != MKTME_ALG_AES_XTS_128)
+				return -EINVAL;
+			break;
+
+		default:
+			return -EINVAL;
+		}
+	}
+	return mktme_check_options(kprog, token_mask);
+}
+
+/* Key Service Command: Creates a software key and programs hardware */
+int mktme_instantiate(struct key *key, struct key_preparsed_payload *prep)
+{
+	struct mktme_key_program *kprog = NULL;
+	size_t datalen = prep->datalen;
+	char *options;
+	int ret = 0;
+
+	if (!capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
+		return -EACCES;
+
+	if (datalen <= 0 || datalen > 1024 || !prep->data)
+		return -EINVAL;
+
+	options = kmemdup(prep->data, datalen + 1, GFP_KERNEL);
+	if (!options)
+		return -ENOMEM;
+
+	options[datalen] = '\0';
+
+	kprog = kmem_cache_zalloc(mktme_prog_cache, GFP_KERNEL);
+	if (!kprog) {
+		kzfree(options);
+		return -ENOMEM;
+	}
+	ret = mktme_get_options(options, kprog);
+	if (ret < 0)
+		goto out;
+
+	mktme_map_lock();
+	ret = mktme_program_key(key->serial, kprog);
+	mktme_map_unlock();
+out:
+	kzfree(options);
+	kmem_cache_free(mktme_prog_cache, kprog);
+	return ret;
+}
+
+struct key_type key_type_mktme = {
+	.name = "mktme",
+	.instantiate = mktme_instantiate,
+	.describe = user_describe,
+};
+
+/*
+ * Build mktme_cpumask to include one cpu per physical package.
+ * The mask is used in mktme_key_program() when the hardware key
+ * table is programmed on a per package basis.
+ */
+static int mktme_build_cpumask(void)
+{
+	int online_cpu, mktme_cpu;
+	int online_pkgid, mktme_pkgid = -1;
+
+	if (!zalloc_cpumask_var(&mktme_cpumask, GFP_KERNEL))
+		return -ENOMEM;
+
+	for_each_online_cpu(online_cpu) {
+		online_pkgid = topology_physical_package_id(online_cpu);
+
+		for_each_cpu(mktme_cpu, mktme_cpumask) {
+			mktme_pkgid = topology_physical_package_id(mktme_cpu);
+			if (mktme_pkgid == online_pkgid)
+				break;
+		}
+		if (mktme_pkgid != online_pkgid)
+			cpumask_set_cpu(online_cpu, mktme_cpumask);
+	}
+	return 0;
+}
+
+/*
+ * Allocate the global key map structure based on the available keyids
+ * at boot time. Create a cache and a cpu_mask to use for programming
+ * the hardware. Initialize the encrypt_count array to track VMA's per
+ * keyid. Once all that succeeds, register the 'mktme' key type.
+ */
+static int __init init_mktme(void)
+{
+	int ret;
+
+	/* Verify keys are present */
+	if (!(mktme_nr_keyids > 0))
+		return -EINVAL;
+
+	if (!mktme_map_alloc())
+		return -ENOMEM;
+
+	mktme_prog_cache = KMEM_CACHE(mktme_key_program, SLAB_PANIC);
+	if (!mktme_prog_cache)
+		goto free_map;
+
+	if (vma_alloc_encrypt_array() < 0)
+		goto free_cache;
+
+	if (mktme_build_cpumask() < 0)
+		goto free_array;
+
+	ret = register_key_type(&key_type_mktme);
+	if (!ret)
+		return ret;
+
+	free_cpumask_var(mktme_cpumask);
+free_array:
+	vma_free_encrypt_array();
+free_cache:
+	kmem_cache_destroy(mktme_prog_cache);
+free_map:
+	mktme_map_free();
+
+	return -ENOMEM;
+}
+
+late_initcall(init_mktme);
-- 
2.14.1
