Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A70626B6D98
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:37:34 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y8so8459869pgq.12
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:37:34 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y6si15330213pgb.516.2018.12.03.23.37.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:37:27 -0800 (PST)
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC v2 10/13] keys/mktme: Add the MKTME Key Service type for memory encryption
Date: Mon,  3 Dec 2018 23:39:57 -0800
Message-Id: <42d44fb5ddbbf7241a2494fc688e274ade641965.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, peterz@infradead.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

MKTME (Multi-Key Total Memory Encryption) is a technology that allows
transparent memory encryption in upcoming Intel platforms. MKTME will
support mulitple encryption domains, each having their own key. The main
use case for the feature is virtual machine isolation. The API needs the
flexibility to work for a wide range of uses.

The MKTME key service type manages the addition and removal of the memory
encryption keys. It maps Userspace Keys to hardware KeyIDs. It programs
the hardware with the user requested encryption options.

The only supported encryption algorithm is AES-XTS 128.

The MKTME key service is half of the MKTME API level solution. It pairs
with a new memory encryption system call: encrypt_mprotect() that uses
the keys to encrypt memory.

See Documentation/x86/mktme/mktme.rst

Change-Id: Idda4af2beabb739c77719897affff183ee9fa716
Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig           |   1 +
 include/keys/mktme-type.h  |  41 ++++++
 security/keys/Kconfig      |  11 ++
 security/keys/Makefile     |   1 +
 security/keys/mktme_keys.c | 339 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 393 insertions(+)
 create mode 100644 include/keys/mktme-type.h
 create mode 100644 security/keys/mktme_keys.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 7ac78e2856c7..c2e3bb5af077 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1531,6 +1531,7 @@ config X86_INTEL_MKTME
 	bool "Intel Multi-Key Total Memory Encryption"
 	select DYNAMIC_PHYSICAL_MASK
 	select PAGE_EXTENSION
+	select MKTME_KEYS
 	depends on X86_64 && CPU_SUP_INTEL
 	---help---
 	  Say yes to enable support for Multi-Key Total Memory Encryption.
diff --git a/include/keys/mktme-type.h b/include/keys/mktme-type.h
new file mode 100644
index 000000000000..c63c6568087f
--- /dev/null
+++ b/include/keys/mktme-type.h
@@ -0,0 +1,41 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+/* Key service for Multi-KEY Total Memory Encryption */
+
+#ifndef _KEYS_MKTME_TYPE_H
+#define _KEYS_MKTME_TYPE_H
+
+#include <linux/key.h>
+
+/*
+ * The AES-XTS 128 encryption algorithm requires 128 bits for each
+ * user supplied data key and tweak key.
+ */
+#define MKTME_AES_XTS_SIZE	16	/* 16 bytes, 128 bits */
+
+enum mktme_alg {
+	MKTME_ALG_AES_XTS_128,
+};
+
+const char *const mktme_alg_names[] = {
+	[MKTME_ALG_AES_XTS_128]	= "aes-xts-128",
+};
+
+enum mktme_type {
+	MKTME_TYPE_ERROR = -1,
+	MKTME_TYPE_USER,
+	MKTME_TYPE_CPU,
+	MKTME_TYPE_CLEAR,
+	MKTME_TYPE_NO_ENCRYPT,
+};
+
+const char *const mktme_type_names[] = {
+	[MKTME_TYPE_USER]	= "user",
+	[MKTME_TYPE_CPU]	= "cpu",
+	[MKTME_TYPE_CLEAR]	= "clear",
+	[MKTME_TYPE_NO_ENCRYPT]	= "no-encrypt",
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
index 9cef54064f60..94c84f10a857 100644
--- a/security/keys/Makefile
+++ b/security/keys/Makefile
@@ -30,3 +30,4 @@ obj-$(CONFIG_ASYMMETRIC_KEY_TYPE) += keyctl_pkey.o
 obj-$(CONFIG_BIG_KEYS) += big_key.o
 obj-$(CONFIG_TRUSTED_KEYS) += trusted.o
 obj-$(CONFIG_ENCRYPTED_KEYS) += encrypted-keys/
+obj-$(CONFIG_MKTME_KEYS) += mktme_keys.o
diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
new file mode 100644
index 000000000000..e615eb58e600
--- /dev/null
+++ b/security/keys/mktme_keys.c
@@ -0,0 +1,339 @@
+// SPDX-License-Identifier: GPL-3.0
+
+/* Documentation/x86/mktme/mktme_keys.rst */
+
+#include <linux/cred.h>
+#include <linux/cpu.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/key.h>
+#include <linux/key-type.h>
+#include <linux/init.h>
+#include <linux/parser.h>
+#include <linux/random.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <asm/intel_pconfig.h>
+#include <asm/mktme.h>
+#include <keys/mktme-type.h>
+#include <keys/user-type.h>
+
+#include "internal.h"
+
+struct kmem_cache *mktme_prog_cache;	/* Hardware programming cache */
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
+enum mktme_opt_id {
+	OPT_ERROR = -1,
+	OPT_TYPE,
+	OPT_KEY,
+	OPT_TWEAK,
+	OPT_ALGORITHM,
+};
+
+static const match_table_t mktme_token = {
+	{OPT_TYPE, "type=%s"},
+	{OPT_KEY, "key=%s"},
+	{OPT_TWEAK, "tweak=%s"},
+	{OPT_ALGORITHM, "algorithm=%s"},
+	{OPT_ERROR, NULL}
+};
+
+struct mktme_payload {
+	u32		keyid_ctrl;	/* Command & Encryption Algorithm */
+	u8		data_key[MKTME_AES_XTS_SIZE];
+	u8		tweak_key[MKTME_AES_XTS_SIZE];
+};
+
+/* Key Service Method called when Key is garbage collected. */
+static void mktme_destroy_key(struct key *key)
+{
+	key_put_encrypt_ref(mktme_map_keyid_from_key(key));
+}
+
+/* Copy the payload to the HW programming structure and program this KeyID */
+static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
+{
+	struct mktme_key_program *kprog = NULL;
+	u8 kern_entropy[MKTME_AES_XTS_SIZE];
+	int i, ret;
+
+	kprog = kmem_cache_zalloc(mktme_prog_cache, GFP_KERNEL);
+	if (!kprog)
+		return -ENOMEM;
+
+	/* Hardware programming requires cached aligned struct */
+	kprog->keyid = keyid;
+	kprog->keyid_ctrl = payload->keyid_ctrl;
+	memcpy(kprog->key_field_1, payload->data_key, MKTME_AES_XTS_SIZE);
+	memcpy(kprog->key_field_2, payload->tweak_key, MKTME_AES_XTS_SIZE);
+
+	/* Strengthen the entropy fields for CPU generated keys */
+	if ((payload->keyid_ctrl & 0xff) == MKTME_KEYID_SET_KEY_RANDOM) {
+		get_random_bytes(&kern_entropy, sizeof(kern_entropy));
+		for (i = 0; i < (MKTME_AES_XTS_SIZE); i++) {
+			kprog->key_field_1[i] ^= kern_entropy[i];
+			kprog->key_field_2[i] ^= kern_entropy[i];
+		}
+	}
+	ret = mktme_key_program(kprog);
+	kmem_cache_free(mktme_prog_cache, kprog);
+	return ret;
+}
+
+/* Key Service Method to update an existing key. */
+static int mktme_update_key(struct key *key,
+			    struct key_preparsed_payload *prep)
+{
+	struct mktme_payload *payload = prep->payload.data[0];
+	int keyid, ref_count;
+	int ret;
+
+	mktme_map_lock();
+	keyid = mktme_map_keyid_from_key(key);
+	if (keyid <= 0)
+		return -EINVAL;
+	/*
+	 * ref_count will be at least one when we get here because the
+	 * key already exists. If ref_count is not > 1, it is safe to
+	 * update the key while holding the mktme_map_lock.
+	 */
+	ref_count = mktme_read_encrypt_ref(keyid);
+	if (ref_count > 1) {
+		pr_debug("mktme not updating keyid[%d] encrypt_count[%d]\n",
+			 keyid, ref_count);
+		return -EBUSY;
+	}
+	ret = mktme_program_keyid(keyid, payload);
+	if (ret != MKTME_PROG_SUCCESS) {
+		pr_debug("%s: %s\n", __func__, mktme_program_err[ret]);
+		ret = -ENOKEY;
+	}
+	mktme_map_unlock();
+	return ret;
+}
+
+/* Key Service Method to create a new key. Payload is preparsed. */
+int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
+{
+	struct mktme_payload *payload = prep->payload.data[0];
+	int keyid, ret;
+
+	mktme_map_lock();
+	keyid = mktme_map_get_free_keyid();
+	if (keyid == 0) {
+		ret = -ENOKEY;
+		goto out;
+	}
+	ret = mktme_program_keyid(keyid, payload);
+	if (ret != MKTME_PROG_SUCCESS) {
+		pr_debug("%s: %s\n", __func__, mktme_program_err[ret]);
+		ret = -ENOKEY;
+		goto out;
+	}
+	mktme_map_set_keyid(keyid, key);
+	key_get_encrypt_ref(keyid);
+out:
+	mktme_map_unlock();
+	return ret;
+}
+
+/* Verify the user provided the needed arguments for the TYPE of Key */
+static int mktme_check_options(struct mktme_payload *payload,
+			       unsigned long token_mask, enum mktme_type type)
+{
+	if (!token_mask)
+		return -EINVAL;
+
+	switch (type) {
+	case MKTME_TYPE_USER:
+		if (test_bit(OPT_ALGORITHM, &token_mask))
+			payload->keyid_ctrl |= MKTME_AES_XTS_128;
+		else
+			return -EINVAL;
+
+		if ((test_bit(OPT_KEY, &token_mask)) &&
+		    (test_bit(OPT_TWEAK, &token_mask)))
+			payload->keyid_ctrl |= MKTME_KEYID_SET_KEY_DIRECT;
+		else
+			return -EINVAL;
+		break;
+
+	case MKTME_TYPE_CPU:
+		if (test_bit(OPT_ALGORITHM, &token_mask))
+			payload->keyid_ctrl |= MKTME_AES_XTS_128;
+		else
+			return -EINVAL;
+
+		payload->keyid_ctrl |= MKTME_KEYID_SET_KEY_RANDOM;
+		break;
+
+	case MKTME_TYPE_CLEAR:
+		payload->keyid_ctrl |= MKTME_KEYID_CLEAR_KEY;
+		break;
+
+	case MKTME_TYPE_NO_ENCRYPT:
+		payload->keyid_ctrl |= MKTME_KEYID_NO_ENCRYPT;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/* Parse the options and store the key programming data in the payload. */
+static int mktme_get_options(char *options, struct mktme_payload *payload)
+{
+	enum mktme_type type = MKTME_TYPE_ERROR;
+	substring_t args[MAX_OPT_ARGS];
+	unsigned long token_mask = 0;
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
+		case OPT_KEY:
+			ret = hex2bin(payload->data_key, args[0].from,
+				      MKTME_AES_XTS_SIZE);
+			if (ret < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_TWEAK:
+			ret = hex2bin(payload->tweak_key, args[0].from,
+				      MKTME_AES_XTS_SIZE);
+			if (ret < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_TYPE:
+			type = match_string(mktme_type_names,
+					    ARRAY_SIZE(mktme_type_names),
+					    args[0].from);
+			if (type < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_ALGORITHM:
+			ret = match_string(mktme_alg_names,
+					   ARRAY_SIZE(mktme_alg_names),
+					   args[0].from);
+			if (ret < 0)
+				return -EINVAL;
+			break;
+
+		default:
+			return -EINVAL;
+		}
+	}
+	return mktme_check_options(payload, token_mask, type);
+}
+
+void mktme_free_preparsed_key(struct key_preparsed_payload *prep)
+{
+	kzfree(prep->payload.data[0]);
+}
+
+/*
+ * Key Service Method to preparse a payload before a key is created.
+ * Check permissions and the options. Load the proposed key field
+ * data into the payload for use by instantiate and update methods.
+ */
+int mktme_preparse_key(struct key_preparsed_payload *prep)
+{
+	struct mktme_payload *mktme_payload;
+	size_t datalen = prep->datalen;
+	char *options;
+	int ret;
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
+	mktme_payload = kzalloc(sizeof(*mktme_payload), GFP_KERNEL);
+	if (!mktme_payload) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	ret = mktme_get_options(options, mktme_payload);
+	if (ret < 0)
+		goto out;
+
+	prep->quotalen = sizeof(mktme_payload);
+	prep->payload.data[0] = mktme_payload;
+out:
+	kzfree(options);
+	return ret;
+}
+
+struct key_type key_type_mktme = {
+	.name		= "mktme",
+	.preparse	= mktme_preparse_key,
+	.free_preparse	= mktme_free_preparsed_key,
+	.instantiate	= mktme_instantiate_key,
+	.update		= mktme_update_key,
+	.describe	= user_describe,
+	.destroy	= mktme_destroy_key,
+};
+
+/*
+ * Allocate the global mktme_map structure based on the available keyids.
+ * Create a cache for the hardware structure. Initialize the encrypt_count
+ * array to track * VMA's per keyid. Once all that succeeds, register the
+ * 'mktme' key type.
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
+	if (mktme_alloc_encrypt_array() < 0)
+		goto free_cache;
+
+	ret = register_key_type(&key_type_mktme);
+	if (!ret)
+		return ret;			/* SUCCESS */
+
+	mktme_free_encrypt_array();
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
