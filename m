Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A87F2C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:49:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60CD2217F4
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:49:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i+OQAUFh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60CD2217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C41F96B0007; Mon,  2 Sep 2019 05:49:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF3AB6B0008; Mon,  2 Sep 2019 05:49:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB96E6B000A; Mon,  2 Sep 2019 05:49:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id 86FE96B0007
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 05:49:30 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 384BD824CA32
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:49:30 +0000 (UTC)
X-FDA: 75889508100.16.ear55_6ff9f597dc816
X-HE-Tag: ear55_6ff9f597dc816
X-Filterd-Recvd-Size: 12649
Received: from mail-lf1-f65.google.com (mail-lf1-f65.google.com [209.85.167.65])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:49:29 +0000 (UTC)
Received: by mail-lf1-f65.google.com with SMTP id u13so9947269lfm.9
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 02:49:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=ELliIk7mN48lnwHRYxrs10D4uhKnpdq+0nyt4G1gwJ0=;
        b=i+OQAUFhY8Wd+kthYeDIJL4u+/OzryQp/vydJ19qUbDNUvPkT5Ue8OVrOp6jcogf2h
         HUXcZKW11h5aKztw6EtlXuEgC3vnfquviSECHvyAlfEdik9Vd5eAUlH3HRm3Nw9xrhIH
         YbH6VOcsi8gIHJmAudmc777rD0V+buG7MCjVuCLuNGNx/iVygWoUihSHNU7TyPdY4O4e
         hbBnbykvR09xf9ANHudMl+kL1pT+TdyYj8u2BeSHexwGIsftvK4vUphWZtzg8Hg0ssNL
         WC3k+Q9Z7cIQbWlZXyGO/fDtyhBCOg92YidEtWw+baAgKDyKKAdZhJaERWEPhoUGpa53
         khhw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=ELliIk7mN48lnwHRYxrs10D4uhKnpdq+0nyt4G1gwJ0=;
        b=uifRzxuzP0oJJXhjWEfDqPC5p93op9Meq6FZ/9a+DDRRQjJMaAi5jD8O1QyvRx0B3P
         rxEJeOFj/YlUnl4TIZ3LvITjupfQnU+u94jGcGS3246k8se+DtdtfHCJha7xqPlpKVGC
         hZKgGDtblQv33JT5SsBpyylpsfatSl4WLcAbmiXQ6iGWHM1LLlLPL4ifIpN/XXH3/mqq
         sWZbgYQm0tJPm9BbUYJFyTAdpQfWGWnAGG5e1V+o7p01fcpe1DkF+NCpHI6gQChKmJK7
         3KswZnblx+0Hf5c0/U/DZ3Tj9iXZvw+usq+aoK7a6bVmrwLpiPqyWhOJABTljplgIv+P
         dWSw==
X-Gm-Message-State: APjAAAUmtQb1a8J36h2UQ6FoxqTvuNuASSd/53fCGlbPcaKt+TO8XLvg
	/6z8Jj+/vF47ANzK5k4xGDs=
X-Google-Smtp-Source: APXvYqzYCrNKqPmTeHZPYpeOscWBYdlZNz/5Hbcjgpkiy7KqtzCugnERLE9eqBaOhhekEge9dXU9ow==
X-Received: by 2002:ac2:5633:: with SMTP id b19mr623473lff.103.1567417768085;
        Mon, 02 Sep 2019 02:49:28 -0700 (PDT)
Received: from localhost.localdomain (mobile-user-2e84ba-175.dhcp.inet.fi. [46.132.186.175])
        by smtp.gmail.com with ESMTPSA id h1sm771635lja.18.2019.09.02.02.49.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Sep 2019 02:49:27 -0700 (PDT)
From: Janne Karhunen <janne.karhunen@gmail.com>
To: linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	zohar@linux.ibm.com,
	linux-mm@kvack.org,
	viro@zeniv.linux.org.uk
Cc: Konsta Karsisto <konsta.karsisto@gmail.com>,
	Janne Karhunen <janne.karhunen@gmail.com>
Subject: [PATCH 3/3] ima: update the file measurement on writes
Date: Mon,  2 Sep 2019 12:45:40 +0300
Message-Id: <20190902094540.12786-3-janne.karhunen@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190902094540.12786-1-janne.karhunen@gmail.com>
References: <20190902094540.12786-1-janne.karhunen@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Konsta Karsisto <konsta.karsisto@gmail.com>

Hook do_writepages() in order to do IMA measurement of an inode
that is written out.

Depends on commit 72649b7862a7 ("ima: keep the integrity state of open files up to date")'

Signed-off-by: Konsta Karsisto <konsta.karsisto@gmail.com>
Signed-off-by: Janne Karhunen <janne.karhunen@gmail.com>
---
 include/linux/ima.h               |  10 +++
 mm/page-writeback.c               |   7 ++
 security/integrity/iint.c         |   3 +
 security/integrity/ima/ima.h      |  14 ++++
 security/integrity/ima/ima_main.c | 115 ++++++++++++++++++++++++++++--
 security/integrity/integrity.h    |   6 ++
 6 files changed, 150 insertions(+), 5 deletions(-)

diff --git a/include/linux/ima.h b/include/linux/ima.h
index 6736844e90d3..9d83f4beac7f 100644
--- a/include/linux/ima.h
+++ b/include/linux/ima.h
@@ -96,6 +96,8 @@ static inline void ima_kexec_cmdline(const void *buf, int size) {}
 #if ((defined CONFIG_IMA) && defined(CONFIG_IMA_MEASURE_WRITES))
 void ima_file_update(struct file *file);
 void ima_file_delayed_update(struct file *file);
+void ima_inode_update(struct inode *inode);
+void ima_inode_delayed_update(struct inode *inode);
 #else
 static inline void ima_file_update(struct file *file)
 {
@@ -105,6 +107,14 @@ static inline void ima_file_delayed_update(struct file *file)
 {
 	return;
 }
+static inline void ima_inode_update(struct inode *inode)
+{
+	return;
+}
+static inline void ima_inode_delayed_update(struct inode *inode)
+{
+	return;
+}
 #endif
 
 #ifndef CONFIG_IMA_KEXEC
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 1804f64ff43c..d5041c625529 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -38,6 +38,7 @@
 #include <linux/sched/rt.h>
 #include <linux/sched/signal.h>
 #include <linux/mm_inline.h>
+#include <linux/ima.h>
 #include <trace/events/writeback.h>
 
 #include "internal.h"
@@ -2347,6 +2348,12 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
 		cond_resched();
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
 	}
+	if (ret == 0) {
+		if (wbc->sync_mode == WB_SYNC_ALL)
+			ima_inode_update(mapping->host);
+		else
+			ima_inode_delayed_update(mapping->host);
+	}
 	return ret;
 }
 
diff --git a/security/integrity/iint.c b/security/integrity/iint.c
index e12c4900510f..bac15a2b8bee 100644
--- a/security/integrity/iint.c
+++ b/security/integrity/iint.c
@@ -82,6 +82,8 @@ static void iint_free(struct integrity_iint_cache *iint)
 	iint->ima_creds_status = INTEGRITY_UNKNOWN;
 	iint->evm_status = INTEGRITY_UNKNOWN;
 	iint->measured_pcrs = 0;
+	WARN_ON(iint->ima_work.file);
+	WARN_ON(!list_empty(&iint->file_list));
 	kmem_cache_free(iint_cache, iint);
 }
 
@@ -161,6 +163,7 @@ static void init_once(void *foo)
 	iint->ima_read_status = INTEGRITY_UNKNOWN;
 	iint->ima_creds_status = INTEGRITY_UNKNOWN;
 	iint->evm_status = INTEGRITY_UNKNOWN;
+	INIT_LIST_HEAD(&iint->file_list);
 	mutex_init(&iint->mutex);
 }
 
diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
index 195e67631f70..04ba4888b764 100644
--- a/security/integrity/ima/ima.h
+++ b/security/integrity/ima/ima.h
@@ -162,6 +162,10 @@ int ima_lsm_policy_change(struct notifier_block *nb, unsigned long event,
 			  void *lsm_data);
 #if ((defined CONFIG_IMA) && defined(CONFIG_IMA_MEASURE_WRITES))
 void ima_cancel_measurement(struct integrity_iint_cache *iint);
+void ima_get_file(struct integrity_iint_cache *iint,
+		  struct file *file);
+void ima_put_file(struct integrity_iint_cache *iint,
+		  struct file *file);
 #else
 static inline void ima_cancel_measurement(struct integrity_iint_cache *iint)
 {
@@ -172,6 +176,16 @@ static inline void ima_init_measurement(struct integrity_iint_cache *iint,
 {
 	return;
 }
+static inline void ima_get_file(struct integrity_iint_cache *iint,
+				struct file *file)
+{
+	return;
+}
+static inline void ima_put_file(struct integrity_iint_cache *iint,
+				struct file *file)
+{
+	return;
+}
 #endif
 
 /*
diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima/ima_main.c
index 46d28cdb6466..affc74a07125 100644
--- a/security/integrity/ima/ima_main.c
+++ b/security/integrity/ima/ima_main.c
@@ -12,7 +12,8 @@
  *
  * File: ima_main.c
  *	implements the IMA hooks: ima_bprm_check, ima_file_mmap,
- *	ima_file_delayed_update, ima_file_update and ima_file_check.
+ *	ima_file_update, ima_file_delayed_update, ima_inode_update,
+ *	ima_inode_delayed_update and ima_file_check.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -157,6 +158,7 @@ static void ima_check_last_writer(struct integrity_iint_cache *iint,
 	ima_cancel_measurement(iint);
 
 	mutex_lock(&iint->mutex);
+	ima_put_file(iint, file);
 	if (atomic_read(&inode->i_writecount) == 1) {
 		update = test_and_clear_bit(IMA_UPDATE_XATTR,
 					    &iint->atomic_flags);
@@ -295,6 +297,12 @@ static int process_measurement(struct file *file, const struct cred *cred,
 		set_bit(IMA_UPDATE_XATTR, &iint->atomic_flags);
 	}
 
+	if (must_appraise && (file->f_mode & FMODE_WRITE))
+		set_bit(IMA_UPDATE_XATTR, &iint->atomic_flags);
+
+	/* Cache file for measurements triggered from inode writeback */
+	ima_get_file(iint, file);
+
 	/* Nothing to do, just return existing appraised status */
 	if (!action) {
 		if (must_appraise) {
@@ -362,12 +370,9 @@ static int process_measurement(struct file *file, const struct cred *cred,
 out:
 	if (pathbuf)
 		__putname(pathbuf);
-	if (must_appraise) {
+	if (must_appraise)
 		if (rc && (ima_appraise & IMA_APPRAISE_ENFORCE))
 			return -EACCES;
-		if (file->f_mode & FMODE_WRITE)
-			set_bit(IMA_UPDATE_XATTR, &iint->atomic_flags);
-	}
 	return 0;
 }
 
@@ -425,6 +430,42 @@ int ima_bprm_check(struct linux_binprm *bprm)
 }
 
 #ifdef CONFIG_IMA_MEASURE_WRITES
+void ima_get_file(struct integrity_iint_cache *iint,
+		  struct file *file)
+{
+	struct ima_fl_entry *e;
+
+	if (!iint || !file)
+		return;
+	if (!(file->f_mode & FMODE_WRITE) ||
+	    !test_bit(IMA_UPDATE_XATTR, &iint->atomic_flags))
+		return;
+
+	list_for_each_entry(e, &iint->file_list, list) {
+		if (e->file == file)
+			return;
+	}
+	e = kmalloc(sizeof(*e), GFP_KERNEL);
+	if (!e)
+		return;
+	e->file = file;
+	list_add(&e->list, &iint->file_list);
+}
+
+void ima_put_file(struct integrity_iint_cache *iint,
+		  struct file *file)
+{
+	struct ima_fl_entry *e;
+
+	list_for_each_entry(e, &iint->file_list, list) {
+		if (e->file == file) {
+			list_del(&e->list);
+			kfree(e);
+			break;
+		}
+	}
+}
+
 static unsigned long ima_inode_update_delay(struct inode *inode)
 {
 	unsigned long blocks, msecs;
@@ -454,6 +495,7 @@ void ima_cancel_measurement(struct integrity_iint_cache *iint)
 		return;
 
 	cancel_delayed_work_sync(&iint->ima_work.work);
+	iint->ima_work.file = NULL;
 	iint->ima_work.state = IMA_WORK_CANCELLED;
 }
 
@@ -499,6 +541,69 @@ void ima_file_delayed_update(struct file *file)
 }
 EXPORT_SYMBOL_GPL(ima_file_delayed_update);
 
+/**
+ * ima_inode_delayed_update - delayed measurement update of an inode
+ * @inode: dirty inode chosen for writeback
+ *
+ * Schedule work to measure the first available 'struct file' cached
+ * in the iint entry that references this inode. This allows IMA to
+ * track inode writebacks.
+ *
+ * Note that we haven't incremented the refcount for the files we keep
+ * track of in order to not mess up the normal file refcounting. If we
+ * see a file whose f_count is already zero, we simply skip it. If we
+ * fail to find any available file reference, the measurement will be
+ * handled by the ima_check_last_writer().
+ */
+void ima_inode_delayed_update(struct inode *inode)
+{
+	struct integrity_iint_cache *iint;
+	struct ima_fl_entry *e;
+	bool found = false;
+
+	iint = integrity_iint_find(inode);
+	if (!iint)
+		return;
+
+	if (iint->ima_work.state == IMA_WORK_ACTIVE)
+		return;
+
+	mutex_lock(&iint->mutex);
+	list_for_each_entry(e, &iint->file_list, list) {
+		if (file_count(e->file) == 0)
+			continue;
+		found = true;
+		break;
+	}
+	mutex_unlock(&iint->mutex);
+	if (found && e->file)
+		ima_file_delayed_update(e->file);
+}
+EXPORT_SYMBOL_GPL(ima_inode_delayed_update);
+
+void ima_inode_update(struct inode *inode)
+{
+	struct integrity_iint_cache *iint;
+	struct ima_fl_entry *e;
+	bool found = false;
+
+	iint = integrity_iint_find(inode);
+	if (!iint)
+		return;
+
+	mutex_lock(&iint->mutex);
+	list_for_each_entry(e, &iint->file_list, list) {
+		if (file_count(e->file) == 0)
+			continue;
+		found = true;
+		break;
+	}
+	mutex_unlock(&iint->mutex);
+	if (found && e->file)
+		ima_file_update(e->file);
+}
+EXPORT_SYMBOL_GPL(ima_inode_update);
+
 /**
  * ima_file_update - update the file measurement
  * @file: pointer to file structure being updated
diff --git a/security/integrity/integrity.h b/security/integrity/integrity.h
index 0f80c3d2e079..17af72683b87 100644
--- a/security/integrity/integrity.h
+++ b/security/integrity/integrity.h
@@ -132,6 +132,11 @@ struct ima_work_entry {
 	uint8_t state;
 };
 
+struct ima_fl_entry {
+	struct list_head list;
+	struct file *file;
+};
+
 /* integrity data associated with an inode */
 struct integrity_iint_cache {
 	struct rb_node rb_node;	/* rooted in integrity_iint_tree */
@@ -149,6 +154,7 @@ struct integrity_iint_cache {
 	enum integrity_status evm_status:4;
 	struct ima_digest_data *ima_hash;
 	struct ima_work_entry ima_work;
+	struct list_head file_list;
 };
 
 /* rbtree tree calls to lookup, insert, delete
-- 
2.17.1


