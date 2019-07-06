Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2D66C0650E
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E4A021670
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="thNRn6TJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E4A021670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12CF28E0009; Sat,  6 Jul 2019 06:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B6A88E0006; Sat,  6 Jul 2019 06:55:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD3C08E0009; Sat,  6 Jul 2019 06:55:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 928B98E0006
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 06:55:26 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v7so5018543wrt.6
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 03:55:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=u2RjwdUFNE3OIK/3bCmlFikIsAzp11hkr0vwILrcAOk=;
        b=gAY05uIpzZGZZgiyEf+ykyDCyIqAUo2czs325YrStu6APeW7JzIY259QAhzPLMuuhr
         MQvtiQVOz3uru+9LIG8P9/kl8OLVtEPibPze10lLtYwwggt4u78sX5Qi46kzhYNYTFHE
         317YKRvqExE3hpg935ZLl8IxTFWPTAiT/5xlqrUYNMuTsVNGDhZ4d4Hr7R46HDSWn3pj
         I2A0cSQe+w7EF9SCpsgdHyvx7TXgDyECuBhD60QHM3zuKr4tcLm6D3+kK+loR+JmyBn6
         JvVfQGD91lKR8J8PmbTtaliUpU5O7VRxrVQD8ZlXnw+CF6Ig2cBIfwHaRkWDu1oFhDv8
         a6kg==
X-Gm-Message-State: APjAAAUKEfHNkwHWzGogGeuUXJ7/bYU+VvkiY9q8vjAC5PpXRnkOhIKj
	jWkXzCZ1fKP1fjUujehebFOZSU+xZuUcRq+tFuQtsSNgxwPaqbSTY6CLLyMig8hxhnltsoSZuS5
	9R8fBoc2fEK95PdtLEpr5/ne96voGyQoYmaQYrWYnt/NczjJIaUZV74VUo0uhGBXhKA==
X-Received: by 2002:adf:e941:: with SMTP id m1mr8891630wrn.279.1562410526181;
        Sat, 06 Jul 2019 03:55:26 -0700 (PDT)
X-Received: by 2002:adf:e941:: with SMTP id m1mr8891517wrn.279.1562410524783;
        Sat, 06 Jul 2019 03:55:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562410524; cv=none;
        d=google.com; s=arc-20160816;
        b=V6od/aS5QadXzwXCTzTbiiRn8mbIvQb7J26b24F26Vn0uuGHYBoa2thXNamvbYJjLJ
         Ngh+LheUrnd9S+WnM3IjCKre0AVerAJxyZPtnnszR2LJ9hiwfcsF7JmThcqYsul4dfnY
         SAdV0pHOAMcFWbxGDSv+kKOq34OMi9MV+OZjFrIYeN8L2WAETdAcGthPGqu6w0GcPpYf
         LeD6eY3BelDPlkDyTC3yOuQKr289vwI0kUje52PHwAGNbdZ3uTTONzvB0oCI2XcPU/+S
         8px9Rb6CEIxfFnPl6Eb7aM6j6JQd6QjniXnxWy1y/2F0+3Nxugry94cPKkNbwSZXRJJv
         oAlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=u2RjwdUFNE3OIK/3bCmlFikIsAzp11hkr0vwILrcAOk=;
        b=KAwpwUISUwYf+m3MIxGJreFb/w3ImG0Kj2AlT4aFA/JSaHez+M4vcpArua/QTH3qgI
         wABI/NTzUl3pF7f6VkV0pmUTYvFx+Yf4ESFebOYt6uwuFzo7jXx/MVfheAtKMF+s5PUn
         oEsGN0k8i2s5Kv7bO1LkS8y0j9TGNpqz9tz7ZMpBlQfEYg769ZHWphgTyyUnEaTlFM2X
         NUqyilUAF2JH69D54O05ssxK3pNi1LMOjLy7X0EH6kJIOg0gAqA3tnnAagXGF1vbzXuw
         tYEuDnyWt4gK18GYly66jNLamXOKCmq2DW/K5a44hbRM/8osAP0azAMytbxCf8w5Q2U9
         fbrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=thNRn6TJ;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i126sor2555623wmg.5.2019.07.06.03.55.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 03:55:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=thNRn6TJ;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=u2RjwdUFNE3OIK/3bCmlFikIsAzp11hkr0vwILrcAOk=;
        b=thNRn6TJGPSAjqCTr1tPi/WxernvhpJlmpA3TOqpdYJiE30WEHmKtQQLBhQkPRLOPw
         6LdBMJiwQeRDj45LsQ+CyPeBPtz6Sm/DVPA/1jFuQwsFGykkDeEEAkecFk+eI93fAHD1
         qYlH4joBKaM50/AAsI6LhYNjkSKoWjJohjBdSbGLIHp32dQu3tN7YZr1eYxcsB+bqXUy
         bX3ZLkExfr5FGb8+TAw/oOIVBNNg7ayqAkWV/3r6PYpzR3qHiM4xg4ORrndOJWzJXK+K
         OUQHzEOkfBbfQCpO4tDaUbNknqB74EkTe516YzXQIsCHfecezahJQP/7fVtAx2XeBD7c
         +9Fw==
X-Google-Smtp-Source: APXvYqxxhkCkToEoUM8bgIOUXQl0J7gFqXqis0ZuQI5jP94wYx8vI8XERZcndoRkmUp3pDS0ZQ935g==
X-Received: by 2002:a1c:5f87:: with SMTP id t129mr8243038wmb.150.1562410524445;
        Sat, 06 Jul 2019 03:55:24 -0700 (PDT)
Received: from localhost (net-93-71-3-102.cust.vodafonedsl.it. [93.71.3.102])
        by smtp.gmail.com with ESMTPSA id h11sm12578794wrx.93.2019.07.06.03.55.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 06 Jul 2019 03:55:23 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Brad Spengler <spender@grsecurity.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Christoph Hellwig <hch@infradead.org>,
	James Morris <james.l.morris@oracle.com>,
	Jann Horn <jannh@google.com>,
	Kees Cook <keescook@chromium.org>,
	PaX Team <pageexec@freemail.hu>,
	Salvatore Mesoraca <s.mesoraca16@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH v5 11/12] S.A.R.A.: /proc/*/mem write limitation
Date: Sat,  6 Jul 2019 12:54:52 +0200
Message-Id: <1562410493-8661-12-git-send-email-s.mesoraca16@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Prevent a task from opening, in "write" mode, any /proc/*/mem
file that operates on the task's mm.
A process could use it to overwrite read-only memory, bypassing
S.A.R.A. restrictions.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 security/sara/include/sara_data.h | 18 ++++++++++++++++-
 security/sara/sara_data.c         |  8 ++++++++
 security/sara/wxprot.c            | 41 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/security/sara/include/sara_data.h b/security/sara/include/sara_data.h
index 9216c47..ee95f74 100644
--- a/security/sara/include/sara_data.h
+++ b/security/sara/include/sara_data.h
@@ -15,6 +15,7 @@
 #define __SARA_DATA_H
 
 #include <linux/cred.h>
+#include <linux/fs.h>
 #include <linux/init.h>
 #include <linux/lsm_hooks.h>
 #include <linux/spinlock.h>
@@ -40,6 +41,10 @@ struct sara_shm_data {
 	spinlock_t	lock;
 };
 
+struct sara_inode_data {
+	struct task_struct *task;
+};
+
 
 static inline struct sara_data *get_sara_data(const struct cred *cred)
 {
@@ -79,6 +84,17 @@ static inline struct sara_shm_data *get_sara_shm_data(
 #define lock_sara_shm(X) (spin_lock(&get_sara_shm_data((X))->lock))
 #define unlock_sara_shm(X) (spin_unlock(&get_sara_shm_data((X))->lock))
 
-#endif
+
+static inline struct sara_inode_data *get_sara_inode_data(
+						const struct inode *inode)
+{
+	if (unlikely(!inode->i_security))
+		return NULL;
+	return inode->i_security + sara_blob_sizes.lbs_inode;
+}
+
+#define get_sara_inode_task(X) (get_sara_inode_data((X))->task)
+
+#endif /* CONFIG_SECURITY_SARA_WXPROT */
 
 #endif /* __SARA_H */
diff --git a/security/sara/sara_data.c b/security/sara/sara_data.c
index 9afca37..e875cf0 100644
--- a/security/sara/sara_data.c
+++ b/security/sara/sara_data.c
@@ -17,6 +17,7 @@
 #include <linux/cred.h>
 #include <linux/lsm_hooks.h>
 #include <linux/mm.h>
+#include <linux/slab.h>
 #include <linux/spinlock.h>
 
 static int sara_cred_prepare(struct cred *new, const struct cred *old,
@@ -40,15 +41,22 @@ static int sara_shm_alloc_security(struct kern_ipc_perm *shp)
 	return 0;
 }
 
+static void sara_task_to_inode(struct task_struct *t, struct inode *i)
+{
+	get_sara_inode_task(i) = t;
+}
+
 static struct security_hook_list data_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(cred_prepare, sara_cred_prepare),
 	LSM_HOOK_INIT(cred_transfer, sara_cred_transfer),
 	LSM_HOOK_INIT(shm_alloc_security, sara_shm_alloc_security),
+	LSM_HOOK_INIT(task_to_inode, sara_task_to_inode),
 };
 
 struct lsm_blob_sizes sara_blob_sizes __lsm_ro_after_init = {
 	.lbs_cred = sizeof(struct sara_data),
 	.lbs_ipc = sizeof(struct sara_shm_data),
+	.lbs_inode = sizeof(struct sara_inode_data),
 };
 
 int __init sara_data_init(void)
diff --git a/security/sara/wxprot.c b/security/sara/wxprot.c
index 773d1fd..1a8d132 100644
--- a/security/sara/wxprot.c
+++ b/security/sara/wxprot.c
@@ -22,8 +22,11 @@
 #include <linux/mm.h>
 #include <linux/mman.h>
 #include <linux/module.h>
+#include <linux/mount.h>
 #include <linux/printk.h>
 #include <linux/ratelimit.h>
+#include <linux/sched/mm.h>
+#include <linux/sched/task.h>
 #include <linux/spinlock.h>
 #include <linux/xattr.h>
 
@@ -615,6 +618,43 @@ static int sara_file_mprotect(struct vm_area_struct *vma,
 	return 0;
 }
 
+static int sara_file_open(struct file *file)
+{
+	struct task_struct *t;
+	struct mm_struct *mm;
+	u16 sara_wxp_flags = get_current_sara_wxp_flags();
+
+	/*
+	 * Prevent write access to /proc/.../mem
+	 * if it operates on the mm_struct of the
+	 * current process: it could be used to
+	 * bypass W^X.
+	 */
+
+	if (!sara_enabled ||
+	    !wxprot_enabled ||
+	    !(sara_wxp_flags & SARA_WXP_WXORX) ||
+	    !(file->f_mode & FMODE_WRITE))
+		return 0;
+
+	t = get_sara_inode_task(file_inode(file));
+	if (unlikely(t != NULL &&
+		     strcmp(file->f_path.dentry->d_name.name,
+			    "mem") == 0)) {
+		get_task_struct(t);
+		mm = get_task_mm(t);
+		put_task_struct(t);
+		if (unlikely(mm == current->mm))
+			sara_warn_or_goto(error,
+					  "write access to /proc/*/mem");
+		mmput(mm);
+	}
+	return 0;
+error:
+	mmput(mm);
+	return -EACCES;
+}
+
 #ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
 static int sara_pagefault_handler(struct pt_regs *regs,
 				  unsigned long error_code,
@@ -778,6 +818,7 @@ static int sara_setprocattr(const char *name, void *value, size_t size)
 	LSM_HOOK_INIT(check_vmflags, sara_check_vmflags),
 	LSM_HOOK_INIT(shm_shmat, sara_shm_shmat),
 	LSM_HOOK_INIT(file_mprotect, sara_file_mprotect),
+	LSM_HOOK_INIT(file_open, sara_file_open),
 #ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
 	LSM_HOOK_INIT(pagefault_handler, sara_pagefault_handler),
 #endif
-- 
1.9.1

