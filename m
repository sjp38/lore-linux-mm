Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2955B8E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 18:35:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a23-v6so8042801pfo.23
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 15:35:32 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v21-v6si9288620plo.397.2018.09.07.15.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 15:35:30 -0700 (PDT)
Date: Fri, 7 Sep 2018 15:36:12 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC 04/12] x86/mm: Add helper functions to manage memory encryption
 keys
Message-ID: <28a55df5da1ecfea28bac588d3ac429cf1419b42.1536356108.git.alison.schofield@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536356108.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

Define a global mapping structure to track the mapping of userspace
keys to hardware keyids in MKTME (Multi-Key Total Memory Encryption).
This data will be used for the memory encryption system call and the
kernel key service API.

Implement helper functions to access this mapping structure and make
them visible to the MKTME Kernel Key Service: security/keys/mktme_keys

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
---
 arch/x86/include/asm/mktme.h | 11 ++++++
 arch/x86/mm/mktme.c          | 85 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 96 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index dbfbd955da98..f6acd551457f 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -13,6 +13,17 @@ extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
 extern int mktme_keyid_shift;
 
+/* Manage mappings between hardware keyids and userspace keys */
+extern int mktme_map_alloc(void);
+extern void mktme_map_free(void);
+extern void mktme_map_lock(void);
+extern void mktme_map_unlock(void);
+extern int mktme_map_get_free_keyid(void);
+extern void mktme_map_clear_keyid(int keyid);
+extern void mktme_map_set_keyid(int keyid, unsigned int serial);
+extern int mktme_map_keyid_from_serial(unsigned int serial);
+extern unsigned int mktme_map_serial_from_keyid(int keyid);
+
 extern struct page_ext_operations page_mktme_ops;
 
 #define page_keyid page_keyid
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 660caf6a5ce1..5246d8323359 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -63,6 +63,91 @@ int vma_keyid(struct vm_area_struct *vma)
 	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
 }
 
+/*
+ * struct mktme_mapping and the mktme_map_* functions manage the mapping
+ * of userspace keys to hardware keyids in MKTME. They are used by the
+ * the encrypt_mprotect system call and the MKTME Key Service API.
+ */
+struct mktme_mapping {
+	struct mutex	lock;		/* protect this map & HW state */
+	unsigned int	mapped_keyids;
+	unsigned int	serial[];
+};
+
+struct mktme_mapping *mktme_map;
+
+static inline long mktme_map_size(void)
+{
+	long size = 0;
+
+	size += sizeof(mktme_map);
+	size += sizeof(mktme_map->serial[0]) * mktme_nr_keyids;
+	return size;
+}
+
+int mktme_map_alloc(void)
+{
+	mktme_map = kzalloc(mktme_map_size(), GFP_KERNEL);
+	if (!mktme_map)
+		return 0;
+	mutex_init(&mktme_map->lock);
+	return 1;
+}
+
+void mktme_map_free(void)
+{
+	kfree(mktme_map);
+}
+
+void mktme_map_lock(void)
+{
+	mutex_lock(&mktme_map->lock);
+}
+
+void mktme_map_unlock(void)
+{
+	mutex_unlock(&mktme_map->lock);
+}
+
+void mktme_map_set_keyid(int keyid, unsigned int serial)
+{
+	mktme_map->serial[keyid] = serial;
+	mktme_map->mapped_keyids++;
+}
+
+void mktme_map_clear_keyid(int keyid)
+{
+	mktme_map->serial[keyid] = 0;
+	mktme_map->mapped_keyids--;
+}
+
+unsigned int mktme_map_serial_from_keyid(int keyid)
+{
+	return mktme_map->serial[keyid];
+}
+
+int mktme_map_keyid_from_serial(unsigned int serial)
+{
+	int i;
+
+	for (i = 1; i < mktme_nr_keyids; i++)
+		if (mktme_map->serial[i] == serial)
+			return i;
+	return 0;
+}
+
+int mktme_map_get_free_keyid(void)
+{
+	int i;
+
+	if (mktme_map->mapped_keyids < mktme_nr_keyids) {
+		for (i = 1; i < mktme_nr_keyids; i++)
+			if (mktme_map->serial[i] == 0)
+				return i;
+	}
+	return 0;
+}
+
 void prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
 {
 	int i;
-- 
2.14.1
