Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0779C6B6D94
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:37:29 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id g188so8437136pgc.22
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:37:28 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 3si17199771plx.33.2018.12.03.23.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:37:27 -0800 (PST)
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC v2 11/13] keys/mktme: Program memory encryption keys on a system wide basis
Date: Mon,  3 Dec 2018 23:39:58 -0800
Message-Id: <72dd5f38c1fdbc4c532f8caf2d2010f1ddfa8439.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, peterz@infradead.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

The kernel manages the MKTME (Multi-Key Total Memory Encryption) Keys
as a system wide single pool of keys. The hardware, however, manages
the keys on a per physical package basis. Each physical package
maintains a Key Table that all CPU's in that package share.

In order to maintain the consistent, system wide view that the kernel
requires, program all physical packages during a key program request.

Change-Id: I0ff46f37fde47a0305842baeb8ea600b6c568639
Signed-off-by: Alison Schofield <alison.schofield@intel.com>
---
 security/keys/mktme_keys.c | 61 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 60 insertions(+), 1 deletion(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index e615eb58e600..7f113146acf2 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -21,6 +21,7 @@
 #include "internal.h"
 
 struct kmem_cache *mktme_prog_cache;	/* Hardware programming cache */
+cpumask_var_t mktme_leadcpus;		/* one cpu per pkg to program keys */
 
 static const char * const mktme_program_err[] = {
 	"KeyID was successfully programmed",	/* 0 */
@@ -59,6 +60,37 @@ static void mktme_destroy_key(struct key *key)
 	key_put_encrypt_ref(mktme_map_keyid_from_key(key));
 }
 
+struct mktme_hw_program_info {
+	struct mktme_key_program *key_program;
+	unsigned long status;
+};
+
+/* Program a KeyID on a single package. */
+static void mktme_program_package(void *hw_program_info)
+{
+	struct mktme_hw_program_info *info = hw_program_info;
+	int ret;
+
+	ret = mktme_key_program(info->key_program);
+	if (ret != MKTME_PROG_SUCCESS)
+		WRITE_ONCE(info->status, ret);
+}
+
+/* Program a KeyID across the entire system. */
+static int mktme_program_system(struct mktme_key_program *key_program,
+				cpumask_var_t mktme_cpumask)
+{
+	struct mktme_hw_program_info info = {
+		.key_program = key_program,
+		.status = MKTME_PROG_SUCCESS,
+	};
+	get_online_cpus();
+	on_each_cpu_mask(mktme_cpumask, mktme_program_package, &info, 1);
+	put_online_cpus();
+
+	return info.status;
+}
+
 /* Copy the payload to the HW programming structure and program this KeyID */
 static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
 {
@@ -84,7 +116,7 @@ static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
 			kprog->key_field_2[i] ^= kern_entropy[i];
 		}
 	}
-	ret = mktme_key_program(kprog);
+	ret = mktme_program_system(kprog, mktme_leadcpus);
 	kmem_cache_free(mktme_prog_cache, kprog);
 	return ret;
 }
@@ -299,6 +331,28 @@ struct key_type key_type_mktme = {
 	.destroy	= mktme_destroy_key,
 };
 
+static int mktme_build_leadcpus_mask(void)
+{
+	int online_cpu, mktme_cpu;
+	int online_pkgid, mktme_pkgid = -1;
+
+	if (!zalloc_cpumask_var(&mktme_leadcpus, GFP_KERNEL))
+		return -ENOMEM;
+
+	for_each_online_cpu(online_cpu) {
+		online_pkgid = topology_physical_package_id(online_cpu);
+
+		for_each_cpu(mktme_cpu, mktme_leadcpus) {
+			mktme_pkgid = topology_physical_package_id(mktme_cpu);
+			if (mktme_pkgid == online_pkgid)
+				break;
+		}
+		if (mktme_pkgid != online_pkgid)
+			cpumask_set_cpu(online_cpu, mktme_leadcpus);
+	}
+	return 0;
+}
+
 /*
  * Allocate the global mktme_map structure based on the available keyids.
  * Create a cache for the hardware structure. Initialize the encrypt_count
@@ -323,10 +377,15 @@ static int __init init_mktme(void)
 	if (mktme_alloc_encrypt_array() < 0)
 		goto free_cache;
 
+	if (mktme_build_leadcpus_mask() < 0)
+		goto free_array;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
 
+	free_cpumask_var(mktme_leadcpus);
+free_array:
 	mktme_free_encrypt_array();
 free_cache:
 	kmem_cache_destroy(mktme_prog_cache);
-- 
2.14.1
