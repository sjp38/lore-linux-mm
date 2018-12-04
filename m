Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7A276B6D93
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:37:28 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q63so11740204pfi.19
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:37:28 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id h67si18732885pfb.146.2018.12.03.23.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:37:27 -0800 (PST)
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC v2 12/13] keys/mktme: Save MKTME data if kernel cmdline parameter allows
Date: Mon,  3 Dec 2018 23:39:59 -0800
Message-Id: <c2668d6d260bff3c88440ad097eb1445ea005860.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, peterz@infradead.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

MKTME (Multi-Key Total Memory Encryption) key payloads may include
data encryption keys, tweak keys, and additional entropy bits. These
are used to program the MKTME encryption hardware. By default, the
kernel destroys this payload data once the hardware is programmed.

However, in order to fully support CPU Hotplug, saving the key data
becomes important. The MKTME Key Service cannot allow a new physical
package to come online unless it can program the new packages Key Table
to match the Key Tables of all existing physical packages.

With CPU generated keys (a.k.a. random keys or ephemeral keys) the
saving of user key data is not an issue. The kernel and MKTME hardware
can generate strong encryption keys without recalling any user supplied
data.

With USER directed keys (a.k.a. user type) saving the key programming
data (data and tweak key) becomes an issue. The data and tweak keys
are required to program those keys on a new physical package.

In preparation for adding CPU hotplug support:

   Add an 'mktme_vault' where key data is stored.

   Add 'mktme_savekeys' kernel command line parameter that directs
   what key data can be stored. If it is not set, kernel does not
   store users data key or tweak key.

   Add 'mktme_bitmap_user_type' to track when USER type keys are in
   use. If no USER type keys are currently in use, a physical package
   may be brought online, despite the absence of 'mktme_savekeys'.

Change-Id: If57414862f1ac131dd97e29bf4f3937ac33777f6
Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/admin-guide/kernel-parameters.rst |  1 +
 Documentation/admin-guide/kernel-parameters.txt | 11 +++++
 arch/x86/mm/mktme.c                             |  2 +
 security/keys/mktme_keys.c                      | 65 +++++++++++++++++++++++++
 4 files changed, 79 insertions(+)

diff --git a/Documentation/admin-guide/kernel-parameters.rst b/Documentation/admin-guide/kernel-parameters.rst
index b8d0bc07ed0a..1b62b86d0666 100644
--- a/Documentation/admin-guide/kernel-parameters.rst
+++ b/Documentation/admin-guide/kernel-parameters.rst
@@ -120,6 +120,7 @@ parameter is applicable::
 			Documentation/m68k/kernel-options.txt.
 	MDA	MDA console support is enabled.
 	MIPS	MIPS architecture is enabled.
+	MKTME	Multi-Key Total Memory Encryption is enabled.
 	MOUSE	Appropriate mouse support is enabled.
 	MSI	Message Signaled Interrupts (PCI).
 	MTD	MTD (Memory Technology Device) support is enabled.
diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 81d1d5a74728..c777dbf0f75c 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2497,6 +2497,17 @@
 			in the "bleeding edge" mini2440 support kernel at
 			http://repo.or.cz/w/linux-2.6/mini2440.git
 
+	mktme_savekeys  [X86, MKTME] When CONFIG_X86_INTEL_MKTME is set
+			this parameter allows the kernel to save the user
+			specified MKTME key payload. Saving this payload
+			means that the MKTME Key Service can always allows
+			the addition of new physical packages. If the
+			mktme_savekeys parameter is not present, users key
+			data will not be saved, and new physical packages
+			may only be added to the system if no user type
+			MKTME keys are in use.
+			See Documentation/x86/mktme.rst
+
 	mminit_loglevel=
 			[KNL] When CONFIG_DEBUG_MEMORY_INIT is set, this
 			parameter allows control of the logging verbosity for
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 55d34beb9b81..f96f4f2884e8 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -99,10 +99,12 @@ void mktme_map_set_keyid(int keyid, void *key)
 	mktme_map->mapped_keyids++;
 }
 
+extern unsigned long *mktme_bitmap_user_type;
 void mktme_map_free_keyid(int keyid)
 {
 	mktme_map->key[keyid] = 0;
 	mktme_map->mapped_keyids--;
+	clear_bit(keyid, mktme_bitmap_user_type);
 }
 
 int mktme_map_keyid_from_key(void *key)
diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 7f113146acf2..e9c7d306cba1 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -23,6 +23,11 @@
 struct kmem_cache *mktme_prog_cache;	/* Hardware programming cache */
 cpumask_var_t mktme_leadcpus;		/* one cpu per pkg to program keys */
 
+/* Kernel command line parameter allows saving of users key payload. */
+static bool mktme_savekeys;
+/* Track the existence of user type keys to make package hotplug decisions. */
+unsigned long *mktme_bitmap_user_type;
+
 static const char * const mktme_program_err[] = {
 	"KeyID was successfully programmed",	/* 0 */
 	"Invalid KeyID programming command",	/* 1 */
@@ -54,6 +59,9 @@ struct mktme_payload {
 	u8		tweak_key[MKTME_AES_XTS_SIZE];
 };
 
+/* Store keys in this vault if cmdline parameter mktme_savekeys allows */
+struct mktme_payload *mktme_vault;
+
 /* Key Service Method called when Key is garbage collected. */
 static void mktme_destroy_key(struct key *key)
 {
@@ -121,6 +129,23 @@ static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
 	return ret;
 }
 
+static void mktme_load_vault(int keyid, struct mktme_payload *payload)
+{
+	/*
+	 * Always save the control fields to program hotplugged
+	 * packages with RANDOM, CLEAR, or NO_ENCRYPT type keys.
+	 */
+	mktme_vault[keyid].keyid_ctrl = payload->keyid_ctrl;
+
+	/* Only save data and tweak keys if allowed */
+	if (mktme_savekeys) {
+		memcpy(mktme_vault[keyid].data_key, payload->data_key,
+		       MKTME_AES_XTS_SIZE);
+		memcpy(mktme_vault[keyid].tweak_key, payload->tweak_key,
+		       MKTME_AES_XTS_SIZE);
+	}
+}
+
 /* Key Service Method to update an existing key. */
 static int mktme_update_key(struct key *key,
 			    struct key_preparsed_payload *prep)
@@ -144,11 +169,23 @@ static int mktme_update_key(struct key *key,
 			 keyid, ref_count);
 		return -EBUSY;
 	}
+
+	/* Forget if key was user type. */
+	clear_bit(keyid, mktme_bitmap_user_type);
+
 	ret = mktme_program_keyid(keyid, payload);
 	if (ret != MKTME_PROG_SUCCESS) {
 		pr_debug("%s: %s\n", __func__, mktme_program_err[ret]);
 		ret = -ENOKEY;
+		goto out;
 	}
+
+	mktme_load_vault(keyid, payload);
+
+	/* Remember if this key is user type. */
+	if ((payload->keyid_ctrl & 0xff) == MKTME_KEYID_SET_KEY_DIRECT)
+		set_bit(keyid, mktme_bitmap_user_type);
+out:
 	mktme_map_unlock();
 	return ret;
 }
@@ -171,6 +208,13 @@ int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 		ret = -ENOKEY;
 		goto out;
 	}
+
+	mktme_load_vault(keyid, payload);
+
+	/* Remember if key is user type. */
+	if ((payload->keyid_ctrl & 0xff) == MKTME_KEYID_SET_KEY_DIRECT)
+		set_bit(keyid, mktme_bitmap_user_type);
+
 	mktme_map_set_keyid(keyid, key);
 	key_get_encrypt_ref(keyid);
 out:
@@ -380,10 +424,23 @@ static int __init init_mktme(void)
 	if (mktme_build_leadcpus_mask() < 0)
 		goto free_array;
 
+	mktme_bitmap_user_type = bitmap_zalloc(mktme_nr_keyids, GFP_KERNEL);
+	if (!mktme_bitmap_user_type)
+		goto free_mask;
+
+	mktme_vault = kzalloc(sizeof(mktme_vault[0]) * (mktme_nr_keyids + 1),
+			      GFP_KERNEL);
+	if (!mktme_vault)
+		goto free_bitmap;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
 
+	kfree(mktme_vault);
+free_bitmap:
+	bitmap_free(mktme_bitmap_user_type);
+free_mask:
 	free_cpumask_var(mktme_leadcpus);
 free_array:
 	mktme_free_encrypt_array();
@@ -396,3 +453,11 @@ static int __init init_mktme(void)
 }
 
 late_initcall(init_mktme);
+
+static int mktme_enable_savekeys(char *__unused)
+{
+	mktme_savekeys = true;
+	return 1;
+}
+__setup("mktme_savekeys", mktme_enable_savekeys);
+
-- 
2.14.1
