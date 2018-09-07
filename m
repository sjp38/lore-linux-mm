Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C39168E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 18:38:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l125-v6so7821294pga.1
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 15:38:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g16-v6si9200184pgi.373.2018.09.07.15.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 15:38:23 -0700 (PDT)
Date: Fri, 7 Sep 2018 15:39:04 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC 12/12] keys/mktme: Do not revoke in use memory encryption keys
Message-ID: <e8f43039bf904d0547a9fdc1f6da515747305a59.1536356108.git.alison.schofield@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536356108.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

The MKTME key service maps userspace keys to hardware keyids. Those
keys are used in a new system call that encrypts memory. The keys
need to be tightly controlled. One example is that userspace keys
should not be revoked while the hardware keyid slot is still in use.

The KEY_FLAG_KEEP bit offers good control. The mktme service uses
that flag to prevent userspace keys from going away without proper
synchronization with the mktme service type.

The problem is that we need a safe and synchronous way to revoke keys.
The way .revoke methods function now, the key service type is called late
in the revoke process for cleanup after the fact. The mktme key service
has no means to consider and perhaps reject the revoke request.

This proposal inserts the MKTME revoke call earlier into the existing
keyctl <revoke> path. If it is safe to revoke the key, MKTME key service
will turn off KEY_FLAG_KEEP and let the revoke continue and succeed.
Otherwise, not safe, KEY_FLAG_KEEP stays on, which causes the normal
path of revoke to fail.

For the MKTME Key Service, a revoke may be done safely when there are
no outstanding memory mappings encrypted with the key being revoked.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
---
 security/keys/internal.h   |  6 ++++++
 security/keys/keyctl.c     |  7 +++++++
 security/keys/mktme_keys.c | 47 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+)

diff --git a/security/keys/internal.h b/security/keys/internal.h
index 9f8208dc0e55..9fb871522efe 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -316,4 +316,10 @@ static inline void key_check(const struct key *key)
 
 #endif
 
+#ifdef CONFIG_MKTME_KEYS
+extern void mktme_revoke_key(struct key *key);
+#else
+static inline void mktme_revoke_key(struct key *key) {}
+#endif /* CONFIG_MKTME_KEYS */
+
 #endif /* _INTERNAL_H */
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 1ffe60bb2845..86d2596ff275 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -363,6 +363,9 @@ long keyctl_update_key(key_serial_t id,
  * and any links to the key will be automatically garbage collected after a
  * certain amount of time (/proc/sys/kernel/keys/gc_delay).
  *
+ * The MKTME key service type checks if a memory encryption key is in use
+ * before allowing a revoke to proceed.
+ *
  * Keys with KEY_FLAG_KEEP set should not be revoked.
  *
  * If successful, 0 is returned.
@@ -387,6 +390,10 @@ long keyctl_revoke_key(key_serial_t id)
 
 	key = key_ref_to_ptr(key_ref);
 	ret = 0;
+
+	if (strcmp(key->type->name, "mktme") == 0)
+		mktme_revoke_key(key);
+
 	if (test_bit(KEY_FLAG_KEEP, &key->flags))
 		ret = -EPERM;
 	else
diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index dcbce7194647..c665be860538 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -31,6 +31,52 @@ static const char * const mktme_program_err[] = {
 	"Failure to access key table",		/* 5 */
 };
 
+static int mktme_clear_programmed_key(int keyid)
+{
+	struct mktme_key_program *kprog = NULL;
+	int ret;
+
+	kprog = kmem_cache_zalloc(mktme_prog_cache, GFP_KERNEL);
+	if (!kprog)
+		return -ENOMEM;
+
+	kprog->keyid = keyid;
+	kprog->keyid_ctrl = MKTME_KEYID_CLEAR_KEY;
+	ret = mktme_key_program(kprog, mktme_cpumask);
+	if (ret == MKTME_PROG_SUCCESS)
+		mktme_map_clear_keyid(keyid);
+	else
+		pr_debug("mktme: %s [%d]\n", mktme_program_err[ret], ret);
+
+	kmem_cache_free(mktme_prog_cache, kprog);
+	return ret;
+}
+
+/*
+ * If the key is not in use, clear the hardware programming and
+ * allow the revoke to continue by clearing KEY_FLAG_KEEP.
+ */
+void mktme_revoke_key(struct key *key)
+{
+	int keyid, vma_count;
+
+	mktme_map_lock();
+	keyid = mktme_map_keyid_from_serial(key->serial);
+	if (keyid <= 0)
+		goto out;
+
+	vma_count = vma_read_encrypt_ref(keyid);
+	if (vma_count > 0) {
+		pr_debug("mktme not freeing keyid[%d] encrypt_count[%d]\n",
+			 keyid, vma_count);
+		goto out;
+	}
+	if (!mktme_clear_programmed_key(keyid))
+		clear_bit(KEY_FLAG_KEEP, &key->flags);
+out:
+	mktme_map_unlock();
+}
+
 /* If a key is available, program and add the key to the software map. */
 static int mktme_program_key(key_serial_t serial,
 			     struct mktme_key_program *kprog)
@@ -193,6 +239,7 @@ int mktme_instantiate(struct key *key, struct key_preparsed_payload *prep)
 
 	mktme_map_lock();
 	ret = mktme_program_key(key->serial, kprog);
+	set_bit(KEY_FLAG_KEEP, &key->flags);
 	mktme_map_unlock();
 out:
 	kzfree(options);
-- 
2.14.1
