Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 826F3C468AE
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2697321670
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H/hv3oql"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2697321670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E25DD8E0003; Sat,  6 Jul 2019 06:55:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8AF98E0001; Sat,  6 Jul 2019 06:55:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B41338E0003; Sat,  6 Jul 2019 06:55:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63FC76B000C
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 06:55:19 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r4so5026535wrt.13
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 03:55:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=tc9nxOt0YynZlg4DtgqDwIM4b55l1zqGz9yWCnOUqxc=;
        b=P6oXX3/Tk6KZi35NHpZ00hFFBccHogo1ZsZZjxZejGzAOLlkM3Aj32f1GLaUF4+8za
         vWURO5fF8RHR1/ySc+8fpP+hoQoTHi6sPptSN7UnZxSl4i5AfIxr31GOnHYGWSqiRvdl
         7+mZszSqpC/oSMFX9A2uIOLqyxxYSMQvt5zyI8rg3CSSD8/zbu0XLXtLJrT8bDvuGHD/
         TtMzB0hpFTJ5RDP8OPWJmlTtK8tmh9ukbHsI7MDwOciivpRUchSiDcVknTax6ouVfdQU
         D2k+xK80ZEtnSPYaPziWFrpA+4HEYH7ujqcde7gLiKegs3XpHYNkWX80xbxs6+D+LW/c
         r78A==
X-Gm-Message-State: APjAAAXRaiSyxEjRiHLt0zthd6BFcPb225ZBCn0o5N8jvnEFk+HIPeNY
	FScXQWMs3IE9WRjUA/eKfR6gKDEjakfDvdbHGTkwiNdv0SVNh7B76z8POntwEl7a3Fqmbx8wK4w
	GWURP6xW5JrKBclBwz5AFD72XomQ7BfbrEqzC88AguvzGfddTdSxaGzZkOkyY7t2Gfg==
X-Received: by 2002:adf:e751:: with SMTP id c17mr8987935wrn.98.1562410518960;
        Sat, 06 Jul 2019 03:55:18 -0700 (PDT)
X-Received: by 2002:adf:e751:: with SMTP id c17mr8987792wrn.98.1562410517450;
        Sat, 06 Jul 2019 03:55:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562410517; cv=none;
        d=google.com; s=arc-20160816;
        b=US+2BQ1dsdY1lS9XksfmzBIup532hMTXYTM9hs+1nXcH4iAYqja1K102SZ00vJi6ca
         q5SV1cOppj0wQHgZtf/5o3JBvxJUynUQbFVtRXROK/IQxoi5wmKU6GnxhchPMprfrdaK
         1uY9Gx+VrjC312ImDHglt1l6YYo+YsxiuqQf7za90rkjN/7Hd4dpPNL/k388XH1OPVXR
         EdGaLqrkQ4rqX09E5uPLQ+sDHAnFZO+RkazDs7AW7udjmVESD4PjMU46Feuc3A+9XSmD
         VdwFidhUgF8MXK69v7WOspiF9g73ZrDonJ68GyS40ajISGyZ/QFOJkYP5gtxY5KwW3NH
         V7gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=tc9nxOt0YynZlg4DtgqDwIM4b55l1zqGz9yWCnOUqxc=;
        b=f6fJNa2jvhqp9NvN/fdz2whQl9OJgBfJNijBMGze9NtAgHU8bpih9xXlJzRWh4Ub44
         hTrKi7vpCQRbEaXpKIqKVSrihreExWGVWISW/MLhb6cJZRcwUl+aNVJg+obnR0ay4Pp1
         xm/4kQBe8Gordnd1YvtU7yuSeplwg2xOi6BP9SwwaFSp3rQUwRerS7aberxR6t3tkF2b
         RkGsJNFE3/zLuUAkNmjgfti5cZDJlYNP3GWl1+yyxSLFzv/LsPiffS0VI0PivfJPPRSK
         ZS00cj+wmYVjkfgvUyXbwERMFzyYHXRU8FGJuvN58htzXBehx/XvOYDI3A74EeX8/G9C
         yBVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="H/hv3oql";
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z139sor6286858wmc.25.2019.07.06.03.55.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 03:55:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="H/hv3oql";
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=tc9nxOt0YynZlg4DtgqDwIM4b55l1zqGz9yWCnOUqxc=;
        b=H/hv3oqlvBbndX96qLPf5yWClDQ6sRuTVt5tRUmkZdBjqfNT8QP6eSS48eMgnLnX3M
         WMQ4grRnDFsHfzcmJCa2NZW22qa3lXOGIluOW5jgh2LpcgL7DkJ54y1w0C6Xhkpp2ntZ
         I/av/JjLtKAzbQq7e3mH2IiGg67xxHpyAjtACqs2raUphqFhtSD3uoAU+89+iqorUH8i
         Taggjzu3zY8qh5GVcr/ruUdLkoTpT4zqR8vtjxaqQtGYSk/tQjq/DHcYhOTPMA3P0Zf2
         4XSF8AjFUnGcVP26TnVi4uep/PBucOaPpgJiMZ2o/nHHHTtddc59KmP2z9DdGZLZZfYC
         2KfA==
X-Google-Smtp-Source: APXvYqwjn5IyS6SWM65IBzeh/bdnAqkvGqGa6i9TXN3uin56hMILK/3JcH3obevfA3uL9Qb6/jMB4g==
X-Received: by 2002:a1c:4d6:: with SMTP id 205mr7201683wme.148.1562410517083;
        Sat, 06 Jul 2019 03:55:17 -0700 (PDT)
Received: from localhost (net-93-71-3-102.cust.vodafonedsl.it. [93.71.3.102])
        by smtp.gmail.com with ESMTPSA id h11sm12578794wrx.93.2019.07.06.03.55.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 06 Jul 2019 03:55:16 -0700 (PDT)
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
Subject: [PATCH v5 05/12] LSM: creation of "check_vmflags" LSM hook
Date: Sat,  6 Jul 2019 12:54:46 +0200
Message-Id: <1562410493-8661-6-git-send-email-s.mesoraca16@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Creation of a new LSM hook to check if a given configuration of vmflags,
for a new memory allocation request, should be allowed or not.
It's placed in "do_mmap", "do_brk_flags", "__install_special_mapping"
and "setup_arg_pages".
When loading an ELF, this hook is also used to determine what to do
with an RWE PT_GNU_STACK header. This allows LSM to force the loader
to silently ignore executable stack markings, which is useful a thing to
do when trampoline emulation is available.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 fs/binfmt_elf.c           |  3 ++-
 fs/binfmt_elf_fdpic.c     |  3 ++-
 fs/exec.c                 |  4 ++++
 include/linux/lsm_hooks.h |  7 +++++++
 include/linux/security.h  |  6 ++++++
 mm/mmap.c                 | 13 +++++++++++++
 security/security.c       |  5 +++++
 7 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 8264b46..1d98737 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -806,7 +806,8 @@ static int load_elf_binary(struct linux_binprm *bprm)
 	for (i = 0; i < loc->elf_ex.e_phnum; i++, elf_ppnt++)
 		switch (elf_ppnt->p_type) {
 		case PT_GNU_STACK:
-			if (elf_ppnt->p_flags & PF_X)
+			if (elf_ppnt->p_flags & PF_X &&
+			    !security_check_vmflags(VM_EXEC|VM_READ|VM_WRITE))
 				executable_stack = EXSTACK_ENABLE_X;
 			else
 				executable_stack = EXSTACK_DISABLE_X;
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index d86ebd0d..6e0dee1 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -163,7 +163,8 @@ static int elf_fdpic_fetch_phdrs(struct elf_fdpic_params *params,
 		if (phdr->p_type != PT_GNU_STACK)
 			continue;
 
-		if (phdr->p_flags & PF_X)
+		if (phdr->p_flags & PF_X &&
+		    !security_check_vmflags(VM_EXEC|VM_READ|VM_WRITE))
 			params->flags |= ELF_FDPIC_FLAG_EXEC_STACK;
 		else
 			params->flags |= ELF_FDPIC_FLAG_NOEXEC_STACK;
diff --git a/fs/exec.c b/fs/exec.c
index 89a500b..abf770a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -756,6 +756,10 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	vm_flags |= mm->def_flags;
 	vm_flags |= VM_STACK_INCOMPLETE_SETUP;
 
+	ret = security_check_vmflags(vm_flags);
+	if (ret)
+		goto out_unlock;
+
 	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
 			vm_flags);
 	if (ret)
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 47f58cf..12ce609 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -513,6 +513,11 @@
  *	@reqprot contains the protection requested by the application.
  *	@prot contains the protection that will be applied by the kernel.
  *	Return 0 if permission is granted.
+ * @check_vmflags:
+ *	Check if the requested @vmflags are allowed.
+ *	@vmflags contains the requested vmflags.
+ *	Return 0 if the operation is allowed to continue otherwise return
+ *	the appropriate error code.
  * @file_lock:
  *	Check permission before performing file locking operations.
  *	Note the hook mediates both flock and fcntl style locks.
@@ -1597,6 +1602,7 @@
 				unsigned long prot, unsigned long flags);
 	int (*file_mprotect)(struct vm_area_struct *vma, unsigned long reqprot,
 				unsigned long prot);
+	int (*check_vmflags)(vm_flags_t vmflags);
 	int (*file_lock)(struct file *file, unsigned int cmd);
 	int (*file_fcntl)(struct file *file, unsigned int cmd,
 				unsigned long arg);
@@ -1897,6 +1903,7 @@ struct security_hook_heads {
 	struct hlist_head mmap_addr;
 	struct hlist_head mmap_file;
 	struct hlist_head file_mprotect;
+	struct hlist_head check_vmflags;
 	struct hlist_head file_lock;
 	struct hlist_head file_fcntl;
 	struct hlist_head file_set_fowner;
diff --git a/include/linux/security.h b/include/linux/security.h
index 659071c..aed78eb 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -312,6 +312,7 @@ int security_mmap_file(struct file *file, unsigned long prot,
 int security_mmap_addr(unsigned long addr);
 int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
 			   unsigned long prot);
+int security_check_vmflags(vm_flags_t vmflags);
 int security_file_lock(struct file *file, unsigned int cmd);
 int security_file_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
 void security_file_set_fowner(struct file *file);
@@ -859,6 +860,11 @@ static inline int security_file_mprotect(struct vm_area_struct *vma,
 	return 0;
 }
 
+static inline int security_check_vmflags(vm_flags_t vmflags)
+{
+	return 0;
+}
+
 static inline int security_file_lock(struct file *file, unsigned int cmd)
 {
 	return 0;
diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8a..ec9c0e3d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1390,6 +1390,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 {
 	struct mm_struct *mm = current->mm;
 	int pkey = 0;
+	int error;
 
 	*populate = 0;
 
@@ -1453,6 +1454,10 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	vm_flags |= calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
+	error = security_check_vmflags(vm_flags);
+	if (error)
+		return error;
+
 	if (flags & MAP_LOCKED)
 		if (!can_do_mlock())
 			return -EPERM;
@@ -2996,6 +3001,10 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
 		return -EINVAL;
 	flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
 
+	error = security_check_vmflags(flags);
+	if (error)
+		return error;
+
 	error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
 	if (offset_in_page(error))
 		return error;
@@ -3393,6 +3402,10 @@ static struct vm_area_struct *__install_special_mapping(
 	int ret;
 	struct vm_area_struct *vma;
 
+	ret = security_check_vmflags(vm_flags);
+	if (ret)
+		return ERR_PTR(ret);
+
 	vma = vm_area_alloc(mm);
 	if (unlikely(vma == NULL))
 		return ERR_PTR(-ENOMEM);
diff --git a/security/security.c b/security/security.c
index f493db0..3308e89 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1421,6 +1421,11 @@ int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
 	return call_int_hook(file_mprotect, 0, vma, reqprot, prot);
 }
 
+int security_check_vmflags(vm_flags_t vmflags)
+{
+	return call_int_hook(check_vmflags, 0, vmflags);
+}
+
 int security_file_lock(struct file *file, unsigned int cmd)
 {
 	return call_int_hook(file_lock, 0, file, cmd);
-- 
1.9.1

